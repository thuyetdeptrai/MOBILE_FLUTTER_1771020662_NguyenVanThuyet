using Microsoft.EntityFrameworkCore;
using Pcm.Api.Data;
using Pcm.Api.Entities;
using Microsoft.AspNetCore.SignalR;
using Pcm.Api.Hubs;

namespace Pcm.Api.Services
{
    public class AutoCancelService : BackgroundService
    {
        private readonly IServiceProvider _services;
        private readonly ILogger<AutoCancelService> _logger;

        public AutoCancelService(IServiceProvider services, ILogger<AutoCancelService> logger)
        {
            _services = services;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("AutoCancelService is starting.");

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    await DoWork(stoppingToken);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error occurred in AutoCancelService.");
                }

                await Task.Delay(TimeSpan.FromMinutes(1), stoppingToken); // Chạy mỗi phút
            }

            _logger.LogInformation("AutoCancelService is stopping.");
        }

        private async Task DoWork(CancellationToken stoppingToken)
        {
            using (var scope = _services.CreateScope())
            {
                var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
                var hubContext = scope.ServiceProvider.GetRequiredService<IHubContext<PcmHub>>();

                var now = DateTime.Now;
                var expiredHolds = await context.Bookings
                    .Where(b => b.Status == BookingStatus.Holding && b.HoldExpiry < now)
                    .ToListAsync();

                if (expiredHolds.Any())
                {
                    _logger.LogInformation("Found {Count} expired holds. Releasing...", expiredHolds.Count);

                    foreach (var hold in expiredHolds)
                    {
                        context.Bookings.Remove(hold);
                        
                        // Thông báo real-time qua SignalR
                        await hubContext.Clients.All.SendAsync("ReceiveSlotRelease", new { 
                            hold.CourtId, 
                            BookingDate = hold.BookingDate.ToString("yyyy-MM-dd"),
                            hold.StartTime
                        });
                    }

                    await context.SaveChangesAsync();
                }
            }
        }
    }
}
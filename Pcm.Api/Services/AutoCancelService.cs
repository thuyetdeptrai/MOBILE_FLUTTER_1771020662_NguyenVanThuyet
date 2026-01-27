using Microsoft.EntityFrameworkCore;
using Pcm.Api.Data;
using Pcm.Api.Entities;

namespace Pcm.Api.Services
{
    public class AutoCancelService : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;

        public AutoCancelService(IServiceProvider serviceProvider)
        {
            _serviceProvider = serviceProvider;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                // Chạy mỗi 1 phút
                await Task.Delay(TimeSpan.FromMinutes(1), stoppingToken);
                await CancelUnpaidBookings();
            }
        }

        private async Task CancelUnpaidBookings()
        {
            using (var scope = _serviceProvider.CreateScope())
            {
                var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

                // Tìm các đơn đặt sân "PendingPayment" quá 5 phút
                var limitTime = DateTime.Now.AddMinutes(-5);
                
                var expiredBookings = await context.Bookings
                    .Where(b => b.Status == BookingStatus.PendingPayment && b.CreatedDate < limitTime)
                    .ToListAsync();

                if (expiredBookings.Any())
                {
                    foreach (var booking in expiredBookings)
                    {
                        booking.Status = BookingStatus.Cancelled;
                    }
                    await context.SaveChangesAsync();
                    Console.WriteLine($"[AUTO] Đã hủy {expiredBookings.Count} đơn đặt sân quá hạn.");
                }
            }
        }
    }
}
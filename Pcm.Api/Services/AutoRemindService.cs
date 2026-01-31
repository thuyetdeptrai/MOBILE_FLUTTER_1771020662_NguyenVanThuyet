using Microsoft.EntityFrameworkCore;
using Pcm.Api.Data;
using Pcm.Api.Entities;
using Microsoft.AspNetCore.SignalR;
using Pcm.Api.Hubs;

namespace Pcm.Api.Services
{
    public class AutoRemindService : BackgroundService
    {
        private readonly IServiceProvider _services;
        private readonly ILogger<AutoRemindService> _logger;

        public AutoRemindService(IServiceProvider services, ILogger<AutoRemindService> logger)
        {
            _services = services;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("AutoRemindService is starting.");

            while (!stoppingToken.IsCancellationRequested)
            {
                // Chỉ chạy quét một lần mỗi ngày (ví dụ lúc 8h sáng) hoặc chạy định kỳ 
                // Ở đây chúng ta chạy 1 tiếng 1 lần cho đơn giản
                try
                {
                    await DoWork(stoppingToken);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error occurred in AutoRemindService.");
                }

                await Task.Delay(TimeSpan.FromHours(1), stoppingToken);
            }
        }

        private async Task DoWork(CancellationToken stoppingToken)
        {
            using (var scope = _services.CreateScope())
            {
                var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
                var hubContext = scope.ServiceProvider.GetRequiredService<IHubContext<PcmHub>>();

                // Tìm các booking diễn ra vào ngày mai
                var tomorrow = DateTime.Now.Date.AddDays(1);
                var reminders = await context.Bookings
                    .Include(b => b.Court)
                    .Where(b => b.BookingDate == tomorrow && b.Status == BookingStatus.Confirmed)
                    .ToListAsync();

                _logger.LogInformation("Sending {Count} reminders for tomorrow.", reminders.Count);

                foreach (var b in reminders)
                {
                    // Kiểm tra xem đã gửi reminder chưa (có thể dùng bảng khác hoặc trường phụ)
                    // Ở đây demo tạo notification
                    await NotificationHelper.CreateAndSendAsync(
                        context, hubContext, b.MemberId,
                        "Nhắc lịch đặt sân",
                        $"Bạn có lịch chơi tại {b.Court?.Name} vào ngày mai ({tomorrow:dd/MM}) lúc {b.StartTime:hh\\:mm}.",
                        "BookingReminder",
                        b.Id
                    );
                }
                
                await context.SaveChangesAsync();
            }
        }
    }
}

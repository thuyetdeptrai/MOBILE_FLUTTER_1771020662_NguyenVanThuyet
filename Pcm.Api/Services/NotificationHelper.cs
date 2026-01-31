using Microsoft.AspNetCore.SignalR;
using Pcm.Api.Data;
using Pcm.Api.Entities;
using Pcm.Api.Hubs;

namespace Pcm.Api.Services
{
    public static class NotificationHelper
    {
        public static async Task CreateAndSendAsync(
            ApplicationDbContext context,
            IHubContext<PcmHub> hubContext,
            string memberId,
            string title,
            string message,
            string typeStr,
            int? referenceId = null)
        {
            // Chuyển đổi chuỗi sang Enum (demo đơn giản)
            var type = NotificationType.Info;
            if (typeStr.Contains("Success")) type = NotificationType.Success;
            if (typeStr.Contains("Warning")) type = NotificationType.Warning;
            if (typeStr.Contains("Error")) type = NotificationType.Error;

            var noti = new Notification
            {
                MemberId = memberId,
                Title = title,
                Message = message,
                Type = type,
                ReferenceId = referenceId,
                CreatedDate = DateTime.Now,
                IsRead = false
            };

            context.Notifications.Add(noti);
            
            // Gửi qua SignalR
            await hubContext.Clients.User(memberId).SendAsync("ReceiveNotification", new
            {
                noti.Id,
                noti.Title,
                noti.Message,
                Type = noti.Type.ToString(),
                noti.CreatedDate
            });
        }
    }
}

using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Pcm.Api.Data;
using Pcm.Api.Entities;
using Pcm.Api.Hubs;

namespace Pcm.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class NotificationsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly IHubContext<PcmHub> _hubContext;

        public NotificationsController(ApplicationDbContext context, IHubContext<PcmHub> hubContext)
        {
            _context = context;
            _hubContext = hubContext;
        }

        // GET: api/notifications/{memberId}
        [HttpGet("{memberId}")]
        public async Task<IActionResult> GetNotifications(string memberId, [FromQuery] bool? unreadOnly = false)
        {
            var query = _context.Notifications
                .Where(n => n.MemberId == memberId)
                .AsQueryable();

            if (unreadOnly == true)
                query = query.Where(n => !n.IsRead);

            var notifications = await query
                .OrderByDescending(n => n.CreatedDate)
                .Take(50) // Limit 50 notifications
                .ToListAsync();

            var unreadCount = await _context.Notifications
                .CountAsync(n => n.MemberId == memberId && !n.IsRead);

            return Ok(new { notifications, unreadCount });
        }

        // PUT: api/notifications/{id}/read
        [HttpPut("{id}/read")]
        public async Task<IActionResult> MarkAsRead(int id)
        {
            var notification = await _context.Notifications.FindAsync(id);
            if (notification == null) return NotFound();

            notification.IsRead = true;
            await _context.SaveChangesAsync();

            return Ok(new { Message = "Đã đọc" });
        }

        // PUT: api/notifications/read-all/{memberId}
        [HttpPut("read-all/{memberId}")]
        public async Task<IActionResult> MarkAllAsRead(string memberId)
        {
            var unread = await _context.Notifications
                .Where(n => n.MemberId == memberId && !n.IsRead)
                .ToListAsync();

            foreach (var n in unread)
                n.IsRead = true;

            await _context.SaveChangesAsync();

            return Ok(new { Message = $"Đã đánh dấu {unread.Count} thông báo là đã đọc" });
        }

        // DELETE: api/notifications/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteNotification(int id)
        {
            var notification = await _context.Notifications.FindAsync(id);
            if (notification == null) return NotFound();

            _context.Notifications.Remove(notification);
            await _context.SaveChangesAsync();

            return Ok(new { Message = "Đã xóa" });
        }
    }

}

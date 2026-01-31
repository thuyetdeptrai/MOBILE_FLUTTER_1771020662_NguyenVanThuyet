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
    public class NewsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly IHubContext<PcmHub> _hubContext;

        public NewsController(ApplicationDbContext context, IHubContext<PcmHub> hubContext)
        {
            _context = context;
            _hubContext = hubContext;
        }

        // GET: api/news
        [HttpGet]
        public async Task<IActionResult> GetNews([FromQuery] bool? pinnedOnly = false)
        {
            var query = _context.News
                .Where(n => n.IsActive)
                .Include(n => n.Author)
                .AsQueryable();

            if (pinnedOnly == true)
                query = query.Where(n => n.IsPinned);

            var news = await query
                .OrderByDescending(n => n.IsPinned)
                .ThenByDescending(n => n.CreatedDate)
                .Select(n => new 
                {
                    n.Id,
                    n.Title,
                    n.Content,
                    n.ImageUrl,
                    n.IsPinned,
                    AuthorName = n.Author != null ? n.Author.FullName : "Admin",
                    n.CreatedDate
                })
                .ToListAsync();

            return Ok(news);
        }

        // POST: api/news (Admin)
        [HttpPost]
        public async Task<IActionResult> CreateNews([FromBody] CreateNewsRequest req)
        {
            var news = new News
            {
                Title = req.Title,
                Content = req.Content,
                ImageUrl = req.ImageUrl,
                IsPinned = req.IsPinned,
                AuthorId = req.AuthorId,
                CreatedDate = DateTime.Now
            };

            _context.News.Add(news);
            await _context.SaveChangesAsync();

            // Gửi thông báo real-time cho tất cả users
            await _hubContext.Clients.All.SendAsync("ReceiveNews", new 
            { 
                news.Id, 
                news.Title, 
                news.IsPinned 
            });

            return Ok(new { Message = "Đã đăng tin mới!", news.Id });
        }

        // PUT: api/news/{id}/pin (Admin)
        [HttpPut("{id}/pin")]
        public async Task<IActionResult> TogglePin(int id)
        {
            var news = await _context.News.FindAsync(id);
            if (news == null) return NotFound("Tin không tồn tại");

            news.IsPinned = !news.IsPinned;
            news.UpdatedDate = DateTime.Now;
            await _context.SaveChangesAsync();

            return Ok(new { Message = news.IsPinned ? "Đã ghim tin" : "Đã bỏ ghim", news.IsPinned });
        }

        // DELETE: api/news/{id} (Admin)
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteNews(int id)
        {
            var news = await _context.News.FindAsync(id);
            if (news == null) return NotFound("Tin không tồn tại");

            news.IsActive = false; // Soft delete
            await _context.SaveChangesAsync();

            return Ok(new { Message = "Đã xóa tin" });
        }
    }

    public class CreateNewsRequest
    {
        public string Title { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public string? ImageUrl { get; set; }
        public bool IsPinned { get; set; } = false;
        public string? AuthorId { get; set; }
    }
}

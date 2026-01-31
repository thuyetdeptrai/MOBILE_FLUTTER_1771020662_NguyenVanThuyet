using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;
using Pcm.Api.Data;
using Pcm.Api.Entities;

namespace Pcm.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CourtsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public CourtsController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetCourts()
        {
            return Ok(await _context.Courts.Where(c => c.IsActive).ToListAsync());
        }

        [HttpGet("booked-slots")]
        public async Task<IActionResult> GetBookedSlots(int courtId, DateTime date)
        {
            var booked = await _context.Bookings
                .Where(b => b.CourtId == courtId 
                         && b.BookingDate.Date == date.Date
                         && b.Status != BookingStatus.Cancelled)
                .Select(b => b.StartTime.Hours)
                .ToListAsync();
            return Ok(booked);
        }

        [HttpPost("book")]
        public async Task<IActionResult> BookCourt([FromBody] BookingRequest req)
        {
            var court = await _context.Courts.FindAsync(req.CourtId);
            if (court == null) return NotFound("Sân không tồn tại");

            var member = await _context.Members.FindAsync(req.MemberId);
            if (member == null) return NotFound("Hội viên không tồn tại");

            bool isTaken = await _context.Bookings.AnyAsync(b => 
                b.CourtId == req.CourtId && 
                b.BookingDate.Date == req.Date.Date && 
                b.StartTime.Hours == req.Hour && 
                b.Status != BookingStatus.Cancelled);
            
            if (isTaken) return BadRequest("Giờ này đã có người đặt rồi!");

            if (member.WalletBalance < court.PricePerHour)
                return BadRequest($"Bạn thiếu tiền! Cần {court.PricePerHour:N0}đ.");

            // Trừ tiền
            member.WalletBalance -= court.PricePerHour;
            member.TotalSpent += court.PricePerHour;

            var startSpan = new TimeSpan(req.Hour, 0, 0);
            var endSpan = new TimeSpan(req.Hour + 1, 0, 0);

            var booking = new Booking
            {
                MemberId = req.MemberId,
                CourtId = req.CourtId,
                BookingDate = req.Date,
                StartTime = startSpan,
                EndTime = endSpan,
                TotalPrice = court.PricePerHour,
                Status = BookingStatus.Confirmed,
                CreatedDate = DateTime.Now
            };

            _context.WalletTransactions.Add(new WalletTransaction
            {
                MemberId = member.Id,
                Amount = court.PricePerHour,
                Type = TransactionType.Payment,
                Description = $"Đặt sân {court.Name} ({req.Hour}h - {req.Hour+1}h)",
                CreatedDate = DateTime.Now,
                Status = TransactionStatus.Completed
            });

            _context.Bookings.Add(booking);
            await _context.SaveChangesAsync();

            return Ok(new { Message = "Đặt sân thành công!", NewBalance = member.WalletBalance });
        }

        // --- Admin Endpoints ---

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> CreateCourt([FromBody] CreateCourtRequest req)
        {
            var court = new Court
            {
                Name = req.Name,
                Type = req.Type,
                PricePerHour = req.PricePerHour,
                ImageUrl = req.ImageUrl,
                IsActive = true
            };
            _context.Courts.Add(court);
            await _context.SaveChangesAsync();
            return Ok(court);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> UpdateCourt(int id, [FromBody] CreateCourtRequest req)
        {
            var court = await _context.Courts.FindAsync(id);
            if (court == null) return NotFound();

            court.Name = req.Name;
            court.Type = req.Type;
            court.PricePerHour = req.PricePerHour;
            if (!string.IsNullOrEmpty(req.ImageUrl)) court.ImageUrl = req.ImageUrl;
            
            await _context.SaveChangesAsync();
            return Ok(court);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> DeleteCourt(int id)
        {
            var court = await _context.Courts.FindAsync(id);
            if (court == null) return NotFound();
            
            court.IsActive = false; // Soft delete
            await _context.SaveChangesAsync();
            return Ok();
        }
    }

    public class CreateCourtRequest
    {
        public string Name { get; set; } = string.Empty;
        public string Type { get; set; } = "Standard";
        public decimal PricePerHour { get; set; }
        public string? ImageUrl { get; set; }
    }

    public class BookingRequest
    {
        public string MemberId { get; set; } = string.Empty;
        public int CourtId { get; set; }
        public DateTime Date { get; set; }
        public int Hour { get; set; }
    }
}
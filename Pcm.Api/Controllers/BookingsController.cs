using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Pcm.Api.Data;
using Pcm.Api.Entities;
using Microsoft.AspNetCore.SignalR;
using Pcm.Api.Hubs;

using Pcm.Api.Services;

namespace Pcm.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BookingsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly IHubContext<PcmHub> _hubContext;

        public BookingsController(ApplicationDbContext context, IHubContext<PcmHub> hubContext)
        {
            _context = context;
            _hubContext = hubContext;
        }

        [HttpGet]
        public async Task<IActionResult> GetBookings(
            [FromQuery] int? courtId, 
            [FromQuery] DateTime? from, 
            [FromQuery] DateTime? to,
            [FromQuery] string? memberId)
        {
            try 
            {
                var query = _context.Bookings
                    .Include(b => b.Court)
                    .Include(b => b.Member)
                    .AsQueryable();

                if (courtId.HasValue)
                    query = query.Where(b => b.CourtId == courtId.Value);

                if (from.HasValue)
                    query = query.Where(b => b.BookingDate >= from.Value.Date);

                if (to.HasValue)
                    query = query.Where(b => b.BookingDate <= to.Value.Date);
                    
                if (!string.IsNullOrEmpty(memberId))
                    query = query.Where(b => b.MemberId == memberId);

                var bookings = await query
                    .OrderByDescending(b => b.BookingDate)
                    .ThenBy(b => b.StartTime)
                    .Select(b => new 
                    {
                        b.Id,
                        b.CourtId,
                        CourtName = b.Court!.Name,
                        b.MemberId,
                        MemberName = b.Member!.FullName,
                        b.BookingDate,
                        b.StartTime,
                        b.EndTime,
                        b.TotalPrice,
                        b.Status,
                        b.CreatedDate,
                        b.IsRecurring,
                        b.RecurrenceType
                    })
                    .ToListAsync();

                return Ok(bookings);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Lỗi: {ex.Message} | Inner: {ex.InnerException?.Message}");
            }
        }

        [HttpPost]
        public async Task<IActionResult> CreateBooking([FromBody] CreateBookingRequest req)
        {
            var member = await _context.Members.FindAsync(req.MemberId);
            if (member == null) return NotFound("Thành viên không tồn tại");

            var court = await _context.Courts.FindAsync(req.CourtId);
            if (court == null) return NotFound("Sân không tồn tại");

            // --- KIỂM TRA QUYỀN ĐẶT ĐỊNH KỲ ---
            if (req.IsRecurring && member.Tier < Tier.Gold)
                return BadRequest("Chỉ thành viên hạng Vàng hoặc Kim Cương mới được đặt lịch định kỳ!");

            // Danh sách các ngày cần đặt
            var datesToBook = new List<DateTime>();
            var startDate = req.StartTime.Date;
            datesToBook.Add(startDate);

            if (req.IsRecurring && req.RecurrenceEnd.HasValue)
            {
                var current = startDate;
                while (true)
                {
                    if (req.RecurrenceType == RecurrenceType.Daily) current = current.AddDays(1);
                    else if (req.RecurrenceType == RecurrenceType.Weekly) current = current.AddDays(7);
                    else if (req.RecurrenceType == RecurrenceType.Monthly) current = current.AddMonths(1);
                    else break;

                    if (current.Date > req.RecurrenceEnd.Value.Date) break;
                    datesToBook.Add(current);
                }
            }

            // Giới hạn chuỗi định kỳ tối đa 12 buổi để tránh lạm dụng
            if (datesToBook.Count > 12) return BadRequest("Chuỗi đặt lịch định kỳ không được quá 12 buổi!");

            var reqStart = req.StartTime.TimeOfDay;
            var reqEnd = req.EndTime.TimeOfDay;

            // KIỂM TRA XUNG ĐỘT CHO TẤT CẢ CÁC NGÀY
            foreach (var date in datesToBook)
            {
                var conflict = await _context.Bookings.AnyAsync(b => 
                    b.CourtId == req.CourtId &&
                    b.BookingDate == date &&
                    b.Status != BookingStatus.Cancelled &&
                    !(b.Status == BookingStatus.Holding && b.MemberId == req.MemberId) && // Bỏ qua slot đang giữ bởi chính mình
                    (
                        (reqStart >= b.StartTime && reqStart < b.EndTime) ||
                        (reqEnd > b.StartTime && reqEnd <= b.EndTime) ||
                        (reqStart <= b.StartTime && reqEnd >= b.EndTime)
                    )
                );

                if (conflict) return BadRequest($"Xung đột lịch vào ngày {date:dd/MM/yyyy}!");
            }

            // Tính tổng tiền
            var hoursPerSession = (decimal)(req.EndTime - req.StartTime).TotalHours;
            var pricePerSession = hoursPerSession * court.PricePerHour;
            var totalAmount = pricePerSession * datesToBook.Count;

            if (member.WalletBalance < totalAmount) 
                return BadRequest($"Số dư không đủ! Cần {totalAmount:N0}đ cho {datesToBook.Count} buổi.");

            // Thanh toán
            member.WalletBalance -= totalAmount;
            member.TotalSpent += totalAmount;
            member.UpdateTier(); // TỰ ĐỘNG NÂNG HẠNG

            var recurrenceId = req.IsRecurring ? Guid.NewGuid() : (Guid?)null;

            foreach (var date in datesToBook)
            {
                // Xóa slot đang giữ (nếu có) trước khi tạo mới
                var ownHolds = await _context.Bookings
                    .Where(b => b.CourtId == req.CourtId && b.BookingDate == date && 
                                b.MemberId == req.MemberId && b.Status == BookingStatus.Holding)
                    .ToListAsync();
                if (ownHolds.Any()) _context.Bookings.RemoveRange(ownHolds);

                var booking = new Booking
                {
                    CourtId = req.CourtId,
                    MemberId = req.MemberId,
                    BookingDate = date,
                    StartTime = reqStart,
                    EndTime = reqEnd,
                    TotalPrice = pricePerSession,
                    Status = BookingStatus.Confirmed,
                    CreatedDate = DateTime.Now,
                    IsRecurring = req.IsRecurring,
                    RecurrenceType = req.RecurrenceType,
                    RecurrenceEnd = req.RecurrenceEnd,
                    RecurrenceId = recurrenceId
                };
                _context.Bookings.Add(booking);
            }

            _context.WalletTransactions.Add(new WalletTransaction
            {
                MemberId = member.Id,
                Amount = totalAmount,
                Type = TransactionType.Payment,
                Description = $"Đặt sân {court.Name} {(req.IsRecurring ? "Định kỳ" : "")} ({datesToBook.Count} buổi - {req.StartTime:HH:mm})",
                CreatedDate = DateTime.Now,
                Status = TransactionStatus.Completed
            });

            await _context.SaveChangesAsync();

            // Notify (Cập nhật grid cho tất cả users)
            await _hubContext.Clients.All.SendAsync("ReceiveBookingUpdate", new { 
                req.CourtId, 
                BookingDate = req.StartTime.ToString("yyyy-MM-dd"),
                req.IsRecurring
            });

            // Gửi thông báo cá nhân cho user đặt sân
            await NotificationHelper.CreateAndSendAsync(
                _context, _hubContext, member.Id,
                "Đặt sân thành công!",
                $"Bạn đã đặt {court.Name} lúc {req.StartTime:HH:mm dd/MM}. {(req.IsRecurring ? $"Định kỳ {datesToBook.Count} buổi." : "")}",
                "Success"
            );

            return Ok(new { Message = "Đặt sân thành công!", NewBalance = member.WalletBalance, NewTier = member.Tier.ToString() });
        }

        /// <summary>
        /// Giữ chỗ slot 5 phút - người khác sẽ thấy slot "Đang giữ"
        /// </summary>
        [HttpPost("hold")]
        public async Task<IActionResult> HoldSlot([FromBody] HoldSlotRequest req)
        {
            // Cleanup expired holds trước
            await CleanupExpiredHolds();

            // Kiểm tra slot có trống không
            var existingBooking = await _context.Bookings
                .Where(b => b.CourtId == req.CourtId 
                    && b.BookingDate.Date == req.BookingDate.Date
                    && b.StartTime == req.StartTime
                    && b.Status != BookingStatus.Cancelled)
                .FirstOrDefaultAsync();

            if (existingBooking != null)
            {
                if (existingBooking.Status == BookingStatus.Holding && existingBooking.MemberId == req.MemberId)
                {
                    // Gia hạn hold
                    existingBooking.HoldExpiry = DateTime.Now.AddMinutes(5);
                    await _context.SaveChangesAsync();
                    return Ok(new { Message = "Đã gia hạn giữ chỗ", BookingId = existingBooking.Id, ExpiresAt = existingBooking.HoldExpiry });
                }
                return Conflict(new { Message = "Slot này đã được đặt hoặc đang giữ bởi người khác" });
            }

            // Tạo booking mới với status Holding
            var hold = new Booking
            {
                CourtId = req.CourtId,
                MemberId = req.MemberId,
                BookingDate = req.BookingDate.Date,
                StartTime = req.StartTime,
                EndTime = req.EndTime,
                Status = BookingStatus.Holding,
                HoldExpiry = DateTime.Now.AddMinutes(5),
                CreatedDate = DateTime.Now
            };

            _context.Bookings.Add(hold);
            await _context.SaveChangesAsync();

            // Notify others about the hold
            await _hubContext.Clients.All.SendAsync("ReceiveSlotHold", new { 
                req.CourtId, 
                BookingDate = req.BookingDate.ToString("yyyy-MM-dd"),
                req.StartTime,
                HeldBy = req.MemberId,
                ExpiresAt = hold.HoldExpiry
            });

            return Ok(new { Message = "Đã giữ chỗ 5 phút", BookingId = hold.Id, ExpiresAt = hold.HoldExpiry });
        }

        /// <summary>
        /// Hủy giữ chỗ
        /// </summary>
        [HttpPost("release/{id}")]
        public async Task<IActionResult> ReleaseSlot(int id)
        {
            var booking = await _context.Bookings.FindAsync(id);
            if (booking == null)
                return NotFound();

            if (booking.Status != BookingStatus.Holding)
                return BadRequest(new { Message = "Booking này không ở trạng thái giữ chỗ" });

            _context.Bookings.Remove(booking);
            await _context.SaveChangesAsync();

            // Notify others
            await _hubContext.Clients.All.SendAsync("ReceiveSlotRelease", new { 
                booking.CourtId, 
                BookingDate = booking.BookingDate.ToString("yyyy-MM-dd"),
                booking.StartTime
            });

            return Ok(new { Message = "Đã hủy giữ chỗ" });
        }

        /// <summary>
        /// Dọn dẹp các hold đã hết hạn
        /// </summary>
        private async Task CleanupExpiredHolds()
        {
            var expiredHolds = await _context.Bookings
                .Where(b => b.Status == BookingStatus.Holding && b.HoldExpiry < DateTime.Now)
                .ToListAsync();

            if (expiredHolds.Any())
            {
                _context.Bookings.RemoveRange(expiredHolds);
                await _context.SaveChangesAsync();
            }
        }
    }

    public class HoldSlotRequest
    {
        public int CourtId { get; set; }
        public string MemberId { get; set; } = string.Empty;
        public DateTime BookingDate { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
    }

    public class CreateBookingRequest
    {
        public int CourtId { get; set; }
        public string MemberId { get; set; } = string.Empty;
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        
        // --- Định kỳ ---
        public bool IsRecurring { get; set; } = false;
        public RecurrenceType RecurrenceType { get; set; } = RecurrenceType.None;
        public DateTime? RecurrenceEnd { get; set; }
    }
}

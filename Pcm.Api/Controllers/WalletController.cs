using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Pcm.Api.Data;
using Pcm.Api.Entities;

namespace Pcm.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class WalletController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public WalletController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet("{memberId}")]
        public async Task<IActionResult> GetWalletInfo(string memberId)
        {
            // SỬA: Tìm trong bảng Members thay vì Users
            var member = await _context.Members.FindAsync(memberId);
            if (member == null) return NotFound("Member không tồn tại"); // Sửa thông báo

            var transactions = await _context.WalletTransactions
                .Where(t => t.MemberId == memberId)
                .OrderByDescending(t => t.CreatedDate)
                .ToListAsync();

            return Ok(new 
            {
                Balance = member.WalletBalance, // Lấy từ member
                History = transactions
            });
        }

        [HttpPost("deposit")]
        public async Task<IActionResult> Deposit([FromBody] DepositRequest req)
        {
            // SỬA: Tìm trong bảng Members
            var member = await _context.Members.FindAsync(req.MemberId);
            if (member == null) return NotFound("Member không tồn tại");

            if (req.Amount <= 0) return BadRequest("Số tiền nạp phải lớn hơn 0");

            var transaction = new WalletTransaction
            {
                MemberId = member.Id, // Dùng ID member
                Amount = req.Amount,
                Type = TransactionType.Deposit, // Dùng Enum chuẩn
                Description = $"Yêu cầu nạp: {req.Amount:N0}đ. Ảnh: {req.EvidenceUrl}",
                CreatedDate = DateTime.Now,
                Status = 0
            };

            _context.WalletTransactions.Add(transaction);
            await _context.SaveChangesAsync();
            
            return Ok(new { Message = "Đã gửi yêu cầu! Vui lòng chờ Admin duyệt.", Status = "Pending" });
        }

        // API Duyệt tiền (Admin)
        [HttpPost("approve/{transactionId}")]
        public async Task<IActionResult> ApproveDeposit(int transactionId)
        {
            var transaction = await _context.WalletTransactions.FindAsync(transactionId);
            if (transaction == null) return NotFound("Giao dịch không tồn tại");

            if (transaction.Status != 0) return BadRequest("Giao dịch này đã xử lý rồi!");

            // SỬA: Tìm Member để cộng tiền
            var member = await _context.Members.FindAsync(transaction.MemberId);
            if (member == null) return NotFound("Member không tồn tại");

            member.WalletBalance += transaction.Amount;
            member.TotalDeposited += transaction.Amount;

            transaction.Status = 1;
            transaction.Description += " (Đã duyệt)";

            await _context.SaveChangesAsync();
            return Ok(new { Message = "Đã duyệt nạp tiền thành công!", NewBalance = member.WalletBalance });
        }
    }

    public class DepositRequest
    {
        public string MemberId { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public string? EvidenceUrl { get; set; }
    }
}
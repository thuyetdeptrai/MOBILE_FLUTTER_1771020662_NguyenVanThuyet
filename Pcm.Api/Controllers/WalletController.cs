using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Pcm.Api.Data;
using Pcm.Api.Entities;
using Pcm.Api.Hubs;
using Pcm.Api.Services;

namespace Pcm.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class WalletController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly IHubContext<PcmHub> _hubContext;

        public WalletController(ApplicationDbContext context, IHubContext<PcmHub> hubContext)
        {
            _context = context;
            _hubContext = hubContext;
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
                walletBalance = member.WalletBalance, // Đổi tên để khớp với Mobile
                tier = member.Tier.ToString(),        // Thêm Tier cho Mobile
                totalSpent = member.TotalSpent,
                Balance = member.WalletBalance,       // Giữ lại cho backward compatibility
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
                Status = TransactionStatus.Pending
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

            if (transaction.Status != TransactionStatus.Pending) return BadRequest("Giao dịch này đã xử lý rồi!");

            // SỬA: Tìm Member để cộng tiền
            var member = await _context.Members.FindAsync(transaction.MemberId);
            if (member == null) return NotFound("Member không tồn tại");

            member.WalletBalance += transaction.Amount;
            member.TotalDeposited += transaction.Amount;

            transaction.Status = TransactionStatus.Completed; // Sửa từ 1 sang Enum
            transaction.Description += " (Đã duyệt)";

            await _context.SaveChangesAsync();

            // Gửi thông báo real-time khi nạp tiền thành công
            await NotificationHelper.CreateAndSendAsync(
                _context, _hubContext, member.Id,
                "Nạp tiền thành công!",
                $"Số dư của bạn đã được cộng {transaction.Amount:N0}đ. Số dư mới: {member.WalletBalance:N0}đ",
                "DepositApproved",
                transactionId
            );

            return Ok(new { Message = "Đã duyệt nạp tiền thành công!", NewBalance = member.WalletBalance });
        }
        // API Lấy danh sách yêu cầu nạp tiền (Admin)
        [HttpGet("pending")]
        public async Task<IActionResult> GetPendingDeposits()
        {
            var pending = await _context.WalletTransactions
                .Where(t => t.Status == TransactionStatus.Pending && t.Type == TransactionType.Deposit)
                .OrderByDescending(t => t.CreatedDate)
                .Select(t => new 
                {
                    t.Id,
                    t.MemberId,
                    MemberName = _context.Members.Where(m => m.Id == t.MemberId).Select(m => m.FullName).FirstOrDefault(),
                    t.Amount,
                    t.Description,
                    t.CreatedDate
                })
                .ToListAsync();

            return Ok(pending);
        }

        // API Tổng quan Quỹ (Admin/Treasurer)
        [HttpGet("fund-summary")]
        public async Task<IActionResult> GetFundSummary()
        {
            // Tổng tiền đã nạp vào hệ thống
            var totalDeposited = await _context.WalletTransactions
                .Where(t => t.Type == TransactionType.Deposit && t.Status == TransactionStatus.Completed)
                .SumAsync(t => t.Amount);
            
            // Tổng tiền đã chi (Payment, Refund, Withdraw)
            var totalSpent = await _context.WalletTransactions
                .Where(t => (t.Type == TransactionType.Payment || t.Type == TransactionType.Withdraw) && t.Status == TransactionStatus.Completed)
                .SumAsync(t => t.Amount);
            
            // Tổng tiền thưởng đã phát
            var totalReward = await _context.WalletTransactions
                .Where(t => t.Type == TransactionType.Reward && t.Status == TransactionStatus.Completed)
                .SumAsync(t => t.Amount);
            
            // Số dư quỹ hiện tại
            var currentFund = totalDeposited - totalSpent - totalReward;
            
            // Danh sách thành viên có số dư âm (nếu có lỗi dữ liệu)
            var negativeBalanceMembers = await _context.Members
                .Where(m => m.WalletBalance < 0)
                .Select(m => new { m.Id, m.FullName, m.WalletBalance })
                .ToListAsync();

            var pendingDepositsCount = await _context.WalletTransactions
                .CountAsync(t => t.Status == TransactionStatus.Pending && t.Type == TransactionType.Deposit);

            return Ok(new 
            {
                totalDeposited,
                totalSpent,
                totalReward,
                currentFund,
                isNegative = currentFund < 0,
                negativeBalanceMembers,
                pendingDepositsCount,
                warningMessage = currentFund < 0 ? "⚠️ CẢNH BÁO: Quỹ đang âm!" : null
            });
        }
    }

    public class DepositRequest
    {
        public string MemberId { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public string? EvidenceUrl { get; set; }
    }
}
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;
using Pcm.Api.Data;
using Pcm.Api.Entities;
using System.Globalization;

namespace Pcm.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Admin")] // Chỉ Admin được xem thống kê
    public class AnalyticsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public AnalyticsController(ApplicationDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Thống kê tổng quan dashboard
        /// </summary>
        [HttpGet("overview")]
        public async Task<IActionResult> GetOverview()
        {
            var now = DateTime.Now;
            var startOfMonth = new DateTime(now.Year, now.Month, 1);
            var startOfToday = now.Date;

            // 1. Doanh thu (Tổng nạp)
            var totalRevenue = await _context.WalletTransactions
                .Where(t => t.Type == TransactionType.Deposit && t.Status == TransactionStatus.Completed) // Approved
                .SumAsync(t => t.Amount);

            var revenueThisMonth = await _context.WalletTransactions
                .Where(t => t.Type == TransactionType.Deposit 
                            && t.Status == TransactionStatus.Completed 
                            && t.CreatedDate >= startOfMonth)
                .SumAsync(t => t.Amount);

            // 2. Booking Stats
            var bookingsToday = await _context.Bookings
                .CountAsync(b => b.BookingDate == startOfToday && b.Status != BookingStatus.Cancelled);

            var bookingsMonth = await _context.Bookings
                .CountAsync(b => b.BookingDate >= startOfMonth && b.Status != BookingStatus.Cancelled);

            // 3. Member Stats
            var totalMembers = await _context.Members.CountAsync();
            var newMembersThisMonth = await _context.Members
                .CountAsync(m => m.JoinDate >= startOfMonth);

            return Ok(new
            {
                Revenue = new
                {
                    Total = totalRevenue,
                    ThisMonth = revenueThisMonth,
                    Growth = 0 // Cần logic so sánh tháng trước nếu muốn
                },
                Bookings = new
                {
                    Today = bookingsToday,
                    ThisMonth = bookingsMonth
                },
                Members = new
                {
                    Total = totalMembers,
                    NewThisMonth = newMembersThisMonth
                }
            });
        }

        /// <summary>
        /// Thống kê doanh thu theo 6 tháng gần nhất (để vẽ biểu đồ)
        /// </summary>
        [HttpGet("revenue-chart")]
        public async Task<IActionResult> GetRevenueChart()
        {
            var now = DateTime.Now;
            var sixMonthsAgo = now.AddMonths(-5);
            var startDate = new DateTime(sixMonthsAgo.Year, sixMonthsAgo.Month, 1);

            // Group transactions by Month
            var data = await _context.WalletTransactions
                .Where(t => t.Type == TransactionType.Deposit 
                            && t.Status == TransactionStatus.Completed 
                            && t.CreatedDate >= startDate)
                .GroupBy(t => new { t.CreatedDate.Year, t.CreatedDate.Month })
                .Select(g => new
                {
                    Year = g.Key.Year,
                    Month = g.Key.Month,
                    Total = g.Sum(t => t.Amount)
                })
                .ToListAsync();

            // Fill missing months with 0
            var result = new List<object>();
            for (int i = 0; i < 6; i++)
            {
                var d = startDate.AddMonths(i);
                var record = data.FirstOrDefault(x => x.Year == d.Year && x.Month == d.Month);
                result.Add(new
                {
                    Month = $"T{d.Month}",
                    Amount = record?.Total ?? 0
                });
            }

            return Ok(result);
        }

        /// <summary>
        /// Danh sách thành viên tiêu biểu (Top Spenders)
        /// </summary>
        [HttpGet("top-members")]
        public async Task<IActionResult> GetTopMembers()
        {
            var topMembers = await _context.Members
                .OrderByDescending(m => m.TotalSpent)
                .Take(5)
                .Select(m => new
                {
                    m.Id,
                    m.FullName,
                    m.UserName,
                    m.AvatarUrl,
                    m.Tier,
                    m.TotalSpent,
                    m.WalletBalance
                })
                .ToListAsync();

            return Ok(topMembers);
        }
    }
}

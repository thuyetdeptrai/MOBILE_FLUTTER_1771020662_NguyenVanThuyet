using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Pcm.Api.Data;
using Pcm.Api.Entities;

namespace Pcm.Api.Controllers
{
    [Route("api/[controller]")] // <--- Dòng này giúp tạo ra đường dẫn /api/Tournaments
    [ApiController]             // <--- Dòng này báo cho Swagger biết đây là API
    public class TournamentsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public TournamentsController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/Tournaments
        [HttpGet]
        public async Task<IActionResult> GetTournaments()
        {
            var tournaments = await _context.Tournaments
                .Include(t => t.Participants)
                .ToListAsync();

            var result = tournaments.Select(t => new 
            {
                t.Id,
                t.Name,
                t.Description,
                t.StartDate,
                t.EntryFee,
                t.PrizePool,
                t.Status,
                CurrentParticipants = t.Participants.Count,
                t.MaxParticipants
            });

            return Ok(result);
        }

        // POST: api/Tournaments/join
        [HttpPost("join")]
        public async Task<IActionResult> JoinTournament([FromBody] TournamentParticipant request)
        {
            var tournament = await _context.Tournaments.Include(t => t.Participants).FirstOrDefaultAsync(t => t.Id == request.TournamentId);
            if (tournament == null) return NotFound("Giải đấu không tồn tại");

            if (tournament.Participants.Count >= tournament.MaxParticipants)
                return BadRequest("Giải đấu đã đủ số lượng!");

            var existing = await _context.TournamentParticipants
                .FirstOrDefaultAsync(p => p.TournamentId == request.TournamentId && p.MemberId == request.MemberId);
            if (existing != null) return BadRequest("Bạn đã đăng ký rồi!");

            var member = await _context.Members.FindAsync(request.MemberId);
            if (member == null) return NotFound("Hội viên không tồn tại");
            
            if (member.WalletBalance < tournament.EntryFee)
                return BadRequest($"Số dư không đủ! Cần {tournament.EntryFee:N0}đ.");

            member.WalletBalance -= tournament.EntryFee;
            member.TotalSpent += tournament.EntryFee;

            var participant = new TournamentParticipant
            {
                TournamentId = request.TournamentId,
                MemberId = request.MemberId,
                RegisteredDate = DateTime.Now,
                PaymentStatus = "Paid"
            };
            
            _context.WalletTransactions.Add(new WalletTransaction
            {
                MemberId = member.Id,
                Amount = tournament.EntryFee,
                Type = (TransactionType)2,
                Description = $"Phí tham gia giải: {tournament.Name}",
                CreatedDate = DateTime.Now,
                Status = 1
            });

            _context.TournamentParticipants.Add(participant);
            await _context.SaveChangesAsync();

            return Ok(new { Message = "Đăng ký thành công!", NewBalance = member.WalletBalance });
        }
    }
}
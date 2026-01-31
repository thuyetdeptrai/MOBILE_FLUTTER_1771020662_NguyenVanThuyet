using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Pcm.Api.Data;
using Pcm.Api.Entities;
using Microsoft.AspNetCore.SignalR;
using Pcm.Api.Services;
using Pcm.Api.Hubs;

namespace Pcm.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DuelsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly IHubContext<PcmHub> _hubContext;

        public DuelsController(ApplicationDbContext context, IHubContext<PcmHub> hubContext)
        {
            _context = context;
            _hubContext = hubContext;
        }

        /// <summary>
        /// GET: Lấy danh sách kèo thách đấu
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetDuels(
            [FromQuery] string? memberId,
            [FromQuery] DuelStatus? status)
        {
            var query = _context.Duels
                .Include(d => d.Challenger)
                .Include(d => d.ChallengerPartner)
                .Include(d => d.Opponent)
                .Include(d => d.OpponentPartner)
                .Include(d => d.Court)
                .AsQueryable();

            if (!string.IsNullOrEmpty(memberId))
            {
                query = query.Where(d =>
                    d.ChallengerId == memberId ||
                    d.ChallengerPartnerId == memberId ||
                    d.OpponentId == memberId ||
                    d.OpponentPartnerId == memberId);
            }

            if (status.HasValue)
            {
                query = query.Where(d => d.Status == status.Value);
            }

            var duels = await query
                .OrderByDescending(d => d.CreatedDate)
                .Select(d => new
                {
                    d.Id,
                    Challenger = new { d.Challenger!.Id, d.Challenger.FullName, d.Challenger.AvatarUrl, d.Challenger.DuprRating },
                    ChallengerPartner = d.ChallengerPartner != null ? new { d.ChallengerPartner.Id, d.ChallengerPartner.FullName, d.ChallengerPartner.AvatarUrl } : null,
                    Opponent = new { d.Opponent!.Id, d.Opponent.FullName, d.Opponent.AvatarUrl, d.Opponent.DuprRating },
                    OpponentPartner = d.OpponentPartner != null ? new { d.OpponentPartner.Id, d.OpponentPartner.FullName, d.OpponentPartner.AvatarUrl } : null,
                    d.BetAmount,
                    d.Type,
                    d.Status,
                    d.ChallengerScore,
                    d.OpponentScore,
                    d.WinnerId,
                    d.ScheduledTime,
                    CourtName = d.Court != null ? d.Court.Name : null,
                    d.Message,
                    d.CreatedDate
                })
                .ToListAsync();

            return Ok(duels);
        }

        /// <summary>
        /// GET: Chi tiết kèo thách đấu
        /// </summary>
        [HttpGet("{id}")]
        public async Task<IActionResult> GetDuel(int id)
        {
            var duel = await _context.Duels
                .Include(d => d.Challenger)
                .Include(d => d.ChallengerPartner)
                .Include(d => d.Opponent)
                .Include(d => d.OpponentPartner)
                .Include(d => d.Court)
                .FirstOrDefaultAsync(d => d.Id == id);

            if (duel == null) return NotFound();

            return Ok(new
            {
                duel.Id,
                Challenger = new { duel.Challenger!.Id, duel.Challenger.FullName, duel.Challenger.AvatarUrl, duel.Challenger.DuprRating },
                ChallengerPartner = duel.ChallengerPartner != null ? new { duel.ChallengerPartner.Id, duel.ChallengerPartner.FullName, duel.ChallengerPartner.AvatarUrl } : null,
                Opponent = new { duel.Opponent!.Id, duel.Opponent.FullName, duel.Opponent.AvatarUrl, duel.Opponent.DuprRating },
                OpponentPartner = duel.OpponentPartner != null ? new { duel.OpponentPartner.Id, duel.OpponentPartner.FullName, duel.OpponentPartner.AvatarUrl } : null,
                duel.BetAmount,
                duel.Type,
                duel.Status,
                duel.ChallengerScore,
                duel.OpponentScore,
                duel.WinnerId,
                duel.ScheduledTime,
                CourtName = duel.Court?.Name,
                duel.Message,
                duel.CreatedDate,
                duel.AcceptedDate,
                duel.CompletedDate
            });
        }

        /// <summary>
        /// POST: Tạo kèo thách đấu mới
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> CreateDuel([FromBody] CreateDuelRequest req)
        {
            // Validate
            var challenger = await _context.Members.FindAsync(req.ChallengerId);
            if (challenger == null) return NotFound("Người thách đấu không tồn tại");

            var opponent = await _context.Members.FindAsync(req.OpponentId);
            if (opponent == null) return NotFound("Đối thủ không tồn tại");

            if (req.ChallengerId == req.OpponentId)
                return BadRequest("Không thể tự thách đấu chính mình!");

            // Check balance (Challenger phải có đủ tiền cược)
            if (challenger.WalletBalance < req.BetAmount)
                return BadRequest($"Số dư không đủ! Cần {req.BetAmount:N0}đ để đặt cược.");

            // Tạm giữ tiền cược của Challenger (Escrow)
            challenger.WalletBalance -= req.BetAmount;

            _context.WalletTransactions.Add(new WalletTransaction
            {
                MemberId = challenger.Id,
                Amount = req.BetAmount,
                Type = TransactionType.Payment,
                Description = $"Đặt cược thách đấu với {opponent.FullName}",
                CreatedDate = DateTime.Now,
                Status = TransactionStatus.Pending // Pending (escrow)
            });

            var duel = new Duel
            {
                ChallengerId = req.ChallengerId,
                ChallengerPartnerId = req.ChallengerPartnerId,
                OpponentId = req.OpponentId,
                OpponentPartnerId = req.OpponentPartnerId,
                BetAmount = req.BetAmount,
                Type = req.Type,
                Status = DuelStatus.Pending,
                ScheduledTime = req.ScheduledTime,
                CourtId = req.CourtId,
                Message = req.Message,
                CreatedDate = DateTime.Now
            };

            _context.Duels.Add(duel);
            await _context.SaveChangesAsync();

            // Gửi notification cho Opponent
            await NotificationHelper.CreateAndSendAsync(
                _context, _hubContext, opponent.Id,
                "🥊 Bạn có lời thách đấu!",
                $"{challenger.FullName} thách đấu bạn với {req.BetAmount:N0}đ",
                "DuelChallenge"
            );

            return Ok(new { Message = "Đã tạo kèo thách đấu!", DuelId = duel.Id });
        }

        /// <summary>
        /// POST: Chấp nhận thách đấu
        /// </summary>
        [HttpPost("{id}/accept")]
        public async Task<IActionResult> AcceptDuel(int id, [FromQuery] string memberId)
        {
            var duel = await _context.Duels
                .Include(d => d.Challenger)
                .FirstOrDefaultAsync(d => d.Id == id);

            if (duel == null) return NotFound();
            if (duel.Status != DuelStatus.Pending) return BadRequest("Kèo này đã được xử lý");
            if (duel.OpponentId != memberId) return BadRequest("Bạn không phải người được thách đấu");

            var opponent = await _context.Members.FindAsync(memberId);
            if (opponent == null) return NotFound();

            // Check balance
            if (opponent.WalletBalance < duel.BetAmount)
                return BadRequest($"Số dư không đủ! Cần {duel.BetAmount:N0}đ để chấp nhận.");

            // Giữ tiền của Opponent
            opponent.WalletBalance -= duel.BetAmount;

            _context.WalletTransactions.Add(new WalletTransaction
            {
                MemberId = opponent.Id,
                Amount = duel.BetAmount,
                Type = TransactionType.Payment,
                Description = $"Chấp nhận thách đấu với {duel.Challenger!.FullName}",
                CreatedDate = DateTime.Now,
                Status = TransactionStatus.Pending // Pending (escrow)
            });

            duel.Status = DuelStatus.Accepted;
            duel.AcceptedDate = DateTime.Now;

            await _context.SaveChangesAsync();

            // Notify Challenger
            await NotificationHelper.CreateAndSendAsync(
                _context, _hubContext, duel.ChallengerId,
                "✅ Thách đấu được chấp nhận!",
                $"{opponent.FullName} đã chấp nhận thách đấu của bạn.",
                "DuelAccepted"
            );

            return Ok(new { Message = "Đã chấp nhận thách đấu!" });
        }

        /// <summary>
        /// POST: Từ chối thách đấu
        /// </summary>
        [HttpPost("{id}/decline")]
        public async Task<IActionResult> DeclineDuel(int id, [FromQuery] string memberId)
        {
            var duel = await _context.Duels
                .Include(d => d.Challenger)
                .Include(d => d.Opponent)
                .FirstOrDefaultAsync(d => d.Id == id);

            if (duel == null) return NotFound();
            if (duel.Status != DuelStatus.Pending) return BadRequest("Kèo này đã được xử lý");
            if (duel.OpponentId != memberId) return BadRequest("Bạn không phải người được thách đấu");

            // Hoàn tiền cho Challenger
            var challenger = await _context.Members.FindAsync(duel.ChallengerId);
            if (challenger != null)
            {
                challenger.WalletBalance += duel.BetAmount;

                _context.WalletTransactions.Add(new WalletTransaction
                {
                    MemberId = challenger.Id,
                    Amount = duel.BetAmount,
                    Type = TransactionType.Refund,
                    Description = $"Hoàn tiền thách đấu - {duel.Opponent!.FullName} từ chối",
                    CreatedDate = DateTime.Now,
                    Status = TransactionStatus.Completed
                });
            }

            duel.Status = DuelStatus.Declined;

            await _context.SaveChangesAsync();

            // Notify Challenger
            await NotificationHelper.CreateAndSendAsync(
                _context, _hubContext, duel.ChallengerId,
                "❌ Thách đấu bị từ chối",
                $"{duel.Opponent!.FullName} đã từ chối thách đấu. Tiền cược đã được hoàn lại.",
                "DuelDeclined"
            );

            return Ok(new { Message = "Đã từ chối thách đấu. Tiền cược hoàn lại cho người thách đấu." });
        }

        /// <summary>
        /// PUT: Ghi kết quả và chia tiền (Winner lấy tất cả)
        /// </summary>
        [HttpPut("{id}/result")]
        public async Task<IActionResult> RecordResult(int id, [FromBody] DuelResultRequest req)
        {
            var duel = await _context.Duels
                .Include(d => d.Challenger)
                .Include(d => d.Opponent)
                .FirstOrDefaultAsync(d => d.Id == id);

            if (duel == null) return NotFound();
            if (duel.Status != DuelStatus.Accepted && duel.Status != DuelStatus.InProgress)
                return BadRequest("Kèo chưa được chấp nhận hoặc đã kết thúc");

            duel.ChallengerScore = req.ChallengerScore;
            duel.OpponentScore = req.OpponentScore;
            duel.Status = DuelStatus.Completed;
            duel.CompletedDate = DateTime.Now;

            // Xác định winner
            string winnerId;
            string loserId;
            if (req.ChallengerScore > req.OpponentScore)
            {
                winnerId = duel.ChallengerId;
                loserId = duel.OpponentId;
            }
            else
            {
                winnerId = duel.OpponentId;
                loserId = duel.ChallengerId;
            }

            duel.WinnerId = winnerId;

            // Chia tiền: Winner lấy tổng tiền cược (BetAmount * 2)
            var totalWinnings = duel.BetAmount * 2;
            var winner = await _context.Members.FindAsync(winnerId);
            if (winner != null)
            {
                winner.WalletBalance += totalWinnings;

                _context.WalletTransactions.Add(new WalletTransaction
                {
                    MemberId = winnerId,
                    Amount = totalWinnings,
                    Type = TransactionType.Reward,
                    Description = $"🎉 Thắng thách đấu ({req.ChallengerScore}-{req.OpponentScore})",
                    CreatedDate = DateTime.Now,
                    Status = TransactionStatus.Completed
                });
            }

            await _context.SaveChangesAsync();

            // Notify both
            await NotificationHelper.CreateAndSendAsync(
                _context, _hubContext, winnerId,
                "🏆 Bạn thắng thách đấu!",
                $"Bạn đã thắng và nhận được {totalWinnings:N0}đ",
                "DuelWon"
            );

            await NotificationHelper.CreateAndSendAsync(
                _context, _hubContext, loserId,
                "😢 Bạn thua thách đấu",
                $"Kết quả: {req.ChallengerScore}-{req.OpponentScore}. Chúc bạn may mắn lần sau!",
                "DuelLost"
            );

            return Ok(new
            {
                Message = "Đã ghi kết quả!",
                WinnerId = winnerId,
                TotalWinnings = totalWinnings
            });
        }

        /// <summary>
        /// DELETE: Hủy kèo (chỉ khi Pending, hoàn tiền Challenger)
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<IActionResult> CancelDuel(int id, [FromQuery] string memberId)
        {
            var duel = await _context.Duels.FindAsync(id);
            if (duel == null) return NotFound();

            if (duel.ChallengerId != memberId)
                return BadRequest("Chỉ người thách đấu mới có thể hủy");

            if (duel.Status != DuelStatus.Pending)
                return BadRequest("Chỉ có thể hủy kèo đang chờ chấp nhận");

            // Hoàn tiền
            var challenger = await _context.Members.FindAsync(duel.ChallengerId);
            if (challenger != null)
            {
                challenger.WalletBalance += duel.BetAmount;
                _context.WalletTransactions.Add(new WalletTransaction
                {
                    MemberId = challenger.Id,
                    Amount = duel.BetAmount,
                    Type = TransactionType.Refund,
                    Description = "Hủy thách đấu",
                    CreatedDate = DateTime.Now,
                    Status = TransactionStatus.Completed
                });
            }

            duel.Status = DuelStatus.Cancelled;
            await _context.SaveChangesAsync();

            return Ok(new { Message = "Đã hủy kèo. Tiền cược đã hoàn lại." });
        }
    }

    public class CreateDuelRequest
    {
        public string ChallengerId { get; set; } = string.Empty;
        public string? ChallengerPartnerId { get; set; }
        public string OpponentId { get; set; } = string.Empty;
        public string? OpponentPartnerId { get; set; }
        public decimal BetAmount { get; set; }
        public DuelType Type { get; set; } = DuelType.Singles;
        public DateTime? ScheduledTime { get; set; }
        public int? CourtId { get; set; }
        public string? Message { get; set; }
    }

    public class DuelResultRequest
    {
        public int ChallengerScore { get; set; }
        public int OpponentScore { get; set; }
    }
}

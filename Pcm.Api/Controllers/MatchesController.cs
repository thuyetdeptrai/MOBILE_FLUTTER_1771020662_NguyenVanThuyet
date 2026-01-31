using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Pcm.Api.Data;
using Pcm.Api.Entities;
using Microsoft.AspNetCore.SignalR;
using Pcm.Api.Hubs;

namespace Pcm.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MatchesController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly IHubContext<PcmHub> _hubContext;

        public MatchesController(ApplicationDbContext context, IHubContext<PcmHub> hubContext)
        {
            _context = context;
            _hubContext = hubContext;
        }

        /// <summary>
        /// Lấy danh sách trận đấu
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetMatches(
            [FromQuery] string? memberId,
            [FromQuery] DateTime? from,
            [FromQuery] DateTime? to,
            [FromQuery] Pcm.Api.Entities.MatchType? type)
        {
            var query = _context.Matches
                .Include(m => m.Team1Player1)
                .Include(m => m.Team1Player2)
                .Include(m => m.Team2Player1)
                .Include(m => m.Team2Player2)
                .Include(m => m.Court)
                .AsQueryable();

            if (!string.IsNullOrEmpty(memberId))
            {
                query = query.Where(m => 
                    m.Team1Player1Id == memberId || 
                    m.Team1Player2Id == memberId ||
                    m.Team2Player1Id == memberId ||
                    m.Team2Player2Id == memberId);
            }

            if (from.HasValue)
                query = query.Where(m => m.MatchDate >= from.Value.Date);

            if (to.HasValue)
                query = query.Where(m => m.MatchDate <= to.Value.Date);

            if (type.HasValue)
                query = query.Where(m => m.Type == type.Value);

            var matches = await query
                .OrderByDescending(m => m.MatchDate)
                .ThenByDescending(m => m.StartTime)
                .Select(m => new
                {
                    m.Id,
                    m.CourtId,
                    CourtName = m.Court != null ? m.Court.Name : "Sân ngoài",
                    m.MatchDate,
                    m.StartTime,
                    // Player Details
                    Team1Player1 = new { m.Team1Player1!.Id, m.Team1Player1.FullName, m.Team1Player1.AvatarUrl, m.Team1Player1.DuprRating },
                    Team1Player2 = m.Team1Player2 != null ? new { m.Team1Player2.Id, m.Team1Player2.FullName, m.Team1Player2.AvatarUrl, m.Team1Player2.DuprRating } : null,
                    Team2Player1 = new { m.Team2Player1!.Id, m.Team2Player1.FullName, m.Team2Player1.AvatarUrl, m.Team2Player1.DuprRating },
                    Team2Player2 = m.Team2Player2 != null ? new { m.Team2Player2.Id, m.Team2Player2.FullName, m.Team2Player2.AvatarUrl, m.Team2Player2.DuprRating } : null,
                    
                    m.Team1Score,
                    m.Team2Score,
                    m.Status,
                    m.Type,
                    m.Winner,
                    m.CreatedDate,
                    m.CompletedDate
                })
                .ToListAsync();

            return Ok(matches);
        }

        /// <summary>
        /// Lấy trận đấu của một member
        /// </summary>
        [HttpGet("my-matches/{memberId}")]
        public async Task<IActionResult> GetMyMatches(string memberId)
        {
            var matches = await _context.Matches
                .Include(m => m.Team1Player1)
                .Include(m => m.Team1Player2)
                .Include(m => m.Team2Player1)
                .Include(m => m.Team2Player2)
                .Where(m => 
                    m.Team1Player1Id == memberId || 
                    m.Team1Player2Id == memberId ||
                    m.Team2Player1Id == memberId ||
                    m.Team2Player2Id == memberId)
                .OrderByDescending(m => m.MatchDate)
                .Select(m => new
                {
                    m.Id,
                    m.MatchDate,
                    m.StartTime,
                    // Minimal info for list
                    Team1Player1Name = m.Team1Player1!.FullName,
                    Team1Player2Name = m.Team1Player2 != null ? m.Team1Player2.FullName : null,
                    Team2Player1Name = m.Team2Player1!.FullName,
                    Team2Player2Name = m.Team2Player2 != null ? m.Team2Player2.FullName : null,
                    
                    m.Team1Score,
                    m.Team2Score,
                    m.Status,
                    m.Type,
                    m.Winner,
                    IsWinner = (m.Winner == 1 && (m.Team1Player1Id == memberId || m.Team1Player2Id == memberId)) ||
                               (m.Winner == 2 && (m.Team2Player1Id == memberId || m.Team2Player2Id == memberId))
                })
                .ToListAsync();

            return Ok(matches);
        }

        /// <summary>
        /// Lấy chi tiết trận đấu
        /// </summary>
        [HttpGet("{id}")]
        public async Task<IActionResult> GetMatch(int id)
        {
            var match = await _context.Matches
                .Include(m => m.Team1Player1)
                .Include(m => m.Team1Player2)
                .Include(m => m.Team2Player1)
                .Include(m => m.Team2Player2)
                .Include(m => m.Court)
                .Where(m => m.Id == id)
                .Select(m => new
                {
                    m.Id,
                    m.CourtId,
                    CourtName = m.Court != null ? m.Court.Name : "Sân ngoài",
                    m.MatchDate,
                    m.StartTime,
                    // Player Details
                    Team1Player1 = new { m.Team1Player1!.Id, m.Team1Player1.FullName, m.Team1Player1.AvatarUrl, m.Team1Player1.DuprRating },
                    Team1Player2 = m.Team1Player2 != null ? new { m.Team1Player2.Id, m.Team1Player2.FullName, m.Team1Player2.AvatarUrl, m.Team1Player2.DuprRating } : null,
                    Team2Player1 = new { m.Team2Player1!.Id, m.Team2Player1.FullName, m.Team2Player1.AvatarUrl, m.Team2Player1.DuprRating },
                    Team2Player2 = m.Team2Player2 != null ? new { m.Team2Player2.Id, m.Team2Player2.FullName, m.Team2Player2.AvatarUrl, m.Team2Player2.DuprRating } : null,
                    
                    m.Team1Score,
                    m.Team2Score,
                    m.Status,
                    m.Type,
                    m.Winner,
                    m.CreatedDate,
                    m.CompletedDate
                })
                .FirstOrDefaultAsync();

            if (match == null) return NotFound();

            return Ok(match);
        }

        /// <summary>
        /// Tạo trận đấu mới
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> CreateMatch([FromBody] CreateMatchRequest req)
        {
            // Validate players exist
            var players = new[] { req.Team1Player1Id, req.Team1Player2Id, req.Team2Player1Id, req.Team2Player2Id }
                .Where(p => !string.IsNullOrEmpty(p))
                .Distinct()
                .ToList();

            var existingPlayers = await _context.Members
                .Where(m => players.Contains(m.Id))
                .Select(m => m.Id)
                .ToListAsync();

            if (existingPlayers.Count != players.Count)
                return BadRequest(new { Message = "Một hoặc nhiều người chơi không tồn tại" });

            var match = new Match
            {
                CourtId = req.CourtId,
                MatchDate = req.MatchDate.Date,
                StartTime = req.StartTime,
                Team1Player1Id = req.Team1Player1Id,
                Team1Player2Id = req.Team1Player2Id,
                Team2Player1Id = req.Team2Player1Id,
                Team2Player2Id = req.Team2Player2Id,
                Type = req.Type,
                Status = MatchStatus.Scheduled,
                CreatedDate = DateTime.Now
            };

            _context.Matches.Add(match);
            await _context.SaveChangesAsync();

            return Ok(new { Message = "Đã tạo trận đấu", MatchId = match.Id });
        }

        /// <summary>
        /// Ghi kết quả trận đấu và cập nhật DUPR
        /// </summary>
        [HttpPut("{id}/result")]
        public async Task<IActionResult> RecordResult(int id, [FromBody] RecordResultRequest req)
        {
            var match = await _context.Matches.FindAsync(id);
            if (match == null)
                return NotFound();

            if (match.Status == MatchStatus.Completed)
                return BadRequest(new { Message = "Trận đấu đã kết thúc" });

            match.Team1Score = req.Team1Score;
            match.Team2Score = req.Team2Score;
            match.Status = MatchStatus.Completed;
            match.CompletedDate = DateTime.Now;

            // Cập nhật DUPR cho tất cả người chơi
            await UpdateDuprRatings(match);

            await _context.SaveChangesAsync();

            // Notify
            await _hubContext.Clients.All.SendAsync("ReceiveMatchResult", new
            {
                match.Id,
                match.Team1Score,
                match.Team2Score,
                match.Winner
            });

            return Ok(new { 
                Message = "Đã ghi kết quả", 
                Winner = match.Winner,
                Team1Score = match.Team1Score,
                Team2Score = match.Team2Score
            });
        }

        /// <summary>
        /// Cập nhật DUPR rating dựa trên kết quả trận
        /// </summary>
        private async Task UpdateDuprRatings(Match match)
        {
            var playerIds = new[] { match.Team1Player1Id, match.Team1Player2Id, match.Team2Player1Id, match.Team2Player2Id }
                .Where(p => !string.IsNullOrEmpty(p))
                .ToList();

            var players = await _context.Members
                .Where(m => playerIds.Contains(m.Id))
                .ToListAsync();

            // Tính DUPR thay đổi
            // Thắng: +0.05 đến +0.15 (tùy độ chênh lệch điểm)
            // Thua: -0.05 đến -0.10
            var scoreDiff = Math.Abs(match.Team1Score - match.Team2Score);
            var winBonus = 0.05 + (scoreDiff * 0.01); // Max +0.15 nếu thắng 11-0
            var lossPenalty = 0.05 + (scoreDiff * 0.005); // Max -0.10

            if (winBonus > 0.15) winBonus = 0.15;
            if (lossPenalty > 0.10) lossPenalty = 0.10;

            foreach (var player in players)
            {
                bool isTeam1 = player.Id == match.Team1Player1Id || player.Id == match.Team1Player2Id;
                bool isWinner = (match.Winner == 1 && isTeam1) || (match.Winner == 2 && !isTeam1);

                if (isWinner)
                {
                    player.DuprRating += winBonus;
                    player.MatchesWon++;
                }
                else
                {
                    player.DuprRating -= lossPenalty;
                }

                player.TotalMatches++;

                // Clamp DUPR trong khoảng 2.0 - 6.0
                if (player.DuprRating < 2.0) player.DuprRating = 2.0;
                if (player.DuprRating > 6.0) player.DuprRating = 6.0;
            }
        }

        /// <summary>
        /// Bắt đầu trận đấu
        /// </summary>
        [HttpPut("{id}/start")]
        public async Task<IActionResult> StartMatch(int id)
        {
            var match = await _context.Matches.FindAsync(id);
            if (match == null)
                return NotFound();

            match.Status = MatchStatus.InProgress;
            await _context.SaveChangesAsync();

            return Ok(new { Message = "Trận đấu đã bắt đầu" });
        }

        /// <summary>
        /// Hủy trận đấu
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<IActionResult> CancelMatch(int id)
        {
            var match = await _context.Matches.FindAsync(id);
            if (match == null)
                return NotFound();

            if (match.Status == MatchStatus.Completed)
                return BadRequest(new { Message = "Không thể hủy trận đã hoàn thành" });

            match.Status = MatchStatus.Cancelled;
            await _context.SaveChangesAsync();

            return Ok(new { Message = "Đã hủy trận đấu" });
        }
    }

    public class CreateMatchRequest
    {
        public int? CourtId { get; set; }
        public DateTime MatchDate { get; set; }
        public TimeSpan StartTime { get; set; }
        public string Team1Player1Id { get; set; } = string.Empty;
        public string? Team1Player2Id { get; set; }
        public string Team2Player1Id { get; set; } = string.Empty;
        public string? Team2Player2Id { get; set; }
        public Pcm.Api.Entities.MatchType Type { get; set; } = Pcm.Api.Entities.MatchType.Friendly;
    }

    public class RecordResultRequest
    {
        public int Team1Score { get; set; }
        public int Team2Score { get; set; }
    }
}

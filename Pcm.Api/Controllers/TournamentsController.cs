using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;
using Pcm.Api.Data;
using Pcm.Api.Entities;
using Pcm.Api.Services;

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

        // POST: api/Tournaments
        [HttpPost]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> CreateTournament([FromBody] Tournament tournament)
        {
            if (tournament == null) return BadRequest("Dữ liệu không hợp lệ");

            _context.Tournaments.Add(tournament);
            await _context.SaveChangesAsync();

            return Ok(tournament);
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
                Type = TransactionType.Payment,
                Description = $"Phí tham gia giải: {tournament.Name}",
                CreatedDate = DateTime.Now,
                Status = TransactionStatus.Completed
            });

            _context.TournamentParticipants.Add(participant);
            await _context.SaveChangesAsync();

            return Ok(new { Message = "Đăng ký thành công!", NewBalance = member.WalletBalance });
        }

        /// <summary>
        /// GET: Chi tiết giải đấu kèm matches
        /// </summary>
        [HttpGet("{id}")]
        public async Task<IActionResult> GetTournament(int id)
        {
            var tournament = await _context.Tournaments
                .Include(t => t.Participants).ThenInclude(p => p.Member)
                .Include(t => t.Matches)
                .FirstOrDefaultAsync(t => t.Id == id);

            if (tournament == null) return NotFound();

            return Ok(new
            {
                tournament.Id,
                tournament.Name,
                tournament.Description,
                tournament.StartDate,
                tournament.EntryFee,
                tournament.PrizePool,
                tournament.Status,
                tournament.Format,
                tournament.HasGroupStage,
                tournament.GroupCount,
                tournament.Prize1stPercent,
                tournament.Prize2ndPercent,
                tournament.Prize3rdPercent,
                CurrentParticipants = tournament.Participants.Count,
                tournament.MaxParticipants,
                Participants = tournament.Participants.Select(p => new
                {
                    p.MemberId,
                    p.Member?.FullName,
                    p.Member?.AvatarUrl,
                    p.Member?.DuprRating,
                    p.RegisteredDate
                }),
                Matches = tournament.Matches.OrderBy(m => m.Round).ThenBy(m => m.MatchOrder).Select(m => new
                {
                    m.Id,
                    m.Round,
                    m.MatchOrder,
                    m.Team1Player1Id,
                    m.Team1Player2Id,
                    m.Team2Player1Id,
                    m.Team2Player2Id,
                    m.Team1Score,
                    m.Team2Score,
                    m.Winner,
                    m.Status,
                    m.ScheduledTime,
                    m.CourtId
                })
            });
        }

        /// <summary>
        /// GET: Lấy danh sách matches của giải
        /// </summary>
        [HttpGet("{id}/matches")]
        public async Task<IActionResult> GetTournamentMatches(int id)
        {
            var matches = await _context.TournamentMatches
                .Include(m => m.Team1Player1)
                .Include(m => m.Team1Player2)
                .Include(m => m.Team2Player1)
                .Include(m => m.Team2Player2)
                .Include(m => m.Court)
                .Where(m => m.TournamentId == id)
                .OrderBy(m => m.Round)
                .ThenBy(m => m.MatchOrder)
                .Select(m => new
                {
                    m.Id,
                    m.Round,
                    m.MatchOrder,
                    Team1Player1 = m.Team1Player1 != null ? new { m.Team1Player1.Id, m.Team1Player1.FullName, m.Team1Player1.AvatarUrl } : null,
                    Team1Player2 = m.Team1Player2 != null ? new { m.Team1Player2.Id, m.Team1Player2.FullName, m.Team1Player2.AvatarUrl } : null,
                    Team2Player1 = m.Team2Player1 != null ? new { m.Team2Player1.Id, m.Team2Player1.FullName, m.Team2Player1.AvatarUrl } : null,
                    Team2Player2 = m.Team2Player2 != null ? new { m.Team2Player2.Id, m.Team2Player2.FullName, m.Team2Player2.AvatarUrl } : null,
                    m.Team1Score,
                    m.Team2Score,
                    m.Winner,
                    m.Status,
                    m.ScheduledTime,
                    CourtName = m.Court != null ? m.Court.Name : null
                })
                .ToListAsync();

            return Ok(matches);
        }

        /// <summary>
        /// POST: Admin - Tự động tạo lịch thi đấu (Random shuffle)
        /// </summary>
        [HttpPost("{id}/generate-schedule")]
        public async Task<IActionResult> GenerateSchedule(int id)
        {
            var tournament = await _context.Tournaments
                .Include(t => t.Participants).ThenInclude(p => p.Member)
                .Include(t => t.Matches)
                .FirstOrDefaultAsync(t => t.Id == id);

            if (tournament == null) return NotFound("Giải đấu không tồn tại");
            if (tournament.Matches.Any()) return BadRequest("Lịch thi đấu đã được tạo trước đó!");

            var teams = tournament.Participants.ToList();
            if (teams.Count < 2) return BadRequest("Cần ít nhất 2 đội!");

            // Xáo trộn ngẫu nhiên (Random)
            var random = new Random();
            teams = teams.OrderBy(_ => random.Next()).ToList();

            var matches = new List<TournamentMatch>();

            if (tournament.HasGroupStage)
            {
                // Chia bảng + đánh vòng tròn
                matches = GenerateGroupStage(tournament.Id, teams, tournament.GroupCount);
            }
            else
            {
                // Knockout trực tiếp
                matches = GenerateKnockoutBracket(tournament.Id, teams);
            }

            _context.TournamentMatches.AddRange(matches);
            tournament.Status = "Ongoing";
            await _context.SaveChangesAsync();

            return Ok(new { Message = $"Đã tạo {matches.Count} trận đấu!", MatchCount = matches.Count });
        }

        /// <summary>
        /// PUT: Ghi kết quả trận đấu trong giải
        /// </summary>
        [HttpPut("matches/{matchId}/result")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> RecordMatchResult(int matchId, [FromBody] TournamentMatchResultRequest req)
        {
            var match = await _context.TournamentMatches
                .Include(m => m.Tournament)
                .FirstOrDefaultAsync(m => m.Id == matchId);

            if (match == null) return NotFound();
            if (match.Status == TournamentMatchStatus.Completed) return BadRequest("Trận đấu đã kết thúc");

            match.Team1Score = req.Team1Score;
            match.Team2Score = req.Team2Score;
            match.Winner = req.Team1Score > req.Team2Score ? 1 : 2;
            match.Status = TournamentMatchStatus.Completed;

            // Nếu là knockout, cập nhật winner lên vòng tiếp theo
            await AdvanceWinnerToNextRound(match);

            await _context.SaveChangesAsync();

            return Ok(new { Message = "Đã ghi kết quả!", match.Winner });
        }

        /// <summary>
        /// POST: Kết thúc giải và chia thưởng cho Top 1-2-3
        /// </summary>
        [HttpPost("{id}/complete")]
        public async Task<IActionResult> CompleteTournament(int id)
        {
            var tournament = await _context.Tournaments
                .Include(t => t.Matches)
                .Include(t => t.Participants).ThenInclude(p => p.Member)
                .FirstOrDefaultAsync(t => t.Id == id);

            if (tournament == null) return NotFound();

            // Tìm Final và SemiFinal matches
            var finalMatch = tournament.Matches.FirstOrDefault(m => m.Round == "Final" && m.Status == TournamentMatchStatus.Completed);
            var semiFinalMatches = tournament.Matches.Where(m => m.Round == "SemiFinal" && m.Status == TournamentMatchStatus.Completed).ToList();

            if (finalMatch == null) return BadRequest("Chưa có kết quả chung kết!");

            // Top 1: Winner của Final
            string winner1Id = finalMatch.Winner == 1 ? finalMatch.Team1Player1Id! : finalMatch.Team2Player1Id!;
            
            // Top 2: Loser của Final
            string winner2Id = finalMatch.Winner == 1 ? finalMatch.Team2Player1Id! : finalMatch.Team1Player1Id!;

            // Top 3: Losers của SemiFinal (có thể có 2 người, lấy người đầu tiên hoặc chia đôi)
            var semiFinalLosers = new List<string>();
            foreach (var sf in semiFinalMatches)
            {
                var loserId = sf.Winner == 1 ? sf.Team2Player1Id : sf.Team1Player1Id;
                if (!string.IsNullOrEmpty(loserId)) semiFinalLosers.Add(loserId);
            }

            // Tính giải thưởng
            var prize1 = tournament.PrizePool * tournament.Prize1stPercent / 100;
            var prize2 = tournament.PrizePool * tournament.Prize2ndPercent / 100;
            var prize3Total = tournament.PrizePool * tournament.Prize3rdPercent / 100;
            var prize3Each = semiFinalLosers.Count > 0 ? prize3Total / semiFinalLosers.Count : 0;

            // Chia thưởng Top 1
            var member1 = await _context.Members.FindAsync(winner1Id);
            if (member1 != null)
            {
                member1.WalletBalance += prize1;
                _context.WalletTransactions.Add(new WalletTransaction
                {
                    MemberId = winner1Id,
                    Amount = prize1,
                    Type = TransactionType.Reward,
                    Description = $"🏆 Vô địch {tournament.Name}",
                    CreatedDate = DateTime.Now,
                    Status = TransactionStatus.Completed
                });
            }

            // Chia thưởng Top 2
            var member2 = await _context.Members.FindAsync(winner2Id);
            if (member2 != null)
            {
                member2.WalletBalance += prize2;
                _context.WalletTransactions.Add(new WalletTransaction
                {
                    MemberId = winner2Id,
                    Amount = prize2,
                    Type = TransactionType.Reward,
                    Description = $"🥈 Á quân {tournament.Name}",
                    CreatedDate = DateTime.Now,
                    Status = TransactionStatus.Completed
                });
            }

            // Chia thưởng Top 3
            foreach (var loserId in semiFinalLosers)
            {
                var member3 = await _context.Members.FindAsync(loserId);
                if (member3 != null)
                {
                    member3.WalletBalance += prize3Each;
                    _context.WalletTransactions.Add(new WalletTransaction
                    {
                        MemberId = loserId,
                        Amount = prize3Each,
                        Type = TransactionType.Reward,
                        Description = $"🥉 Hạng 3 {tournament.Name}",
                        CreatedDate = DateTime.Now,
                        Status = TransactionStatus.Completed
                    });
                }
            }

            tournament.Status = "Completed";
            await _context.SaveChangesAsync();

            return Ok(new
            {
                Message = "Đã hoàn thành giải đấu và chia thưởng!",
                Top1 = new { MemberId = winner1Id, Prize = prize1 },
                Top2 = new { MemberId = winner2Id, Prize = prize2 },
                Top3 = semiFinalLosers.Select(l => new { MemberId = l, Prize = prize3Each })
            });
        }

        #region Private Helper Methods

        /// <summary>
        /// Tạo lịch vòng bảng (Round Robin trong mỗi bảng)
        /// </summary>
        private List<TournamentMatch> GenerateGroupStage(int tournamentId, List<TournamentParticipant> teams, int groupCount)
        {
            var matches = new List<TournamentMatch>();
            var teamsPerGroup = teams.Count / groupCount;
            var order = 1;

            for (int g = 0; g < groupCount; g++)
            {
                var groupName = $"Group{(char)('A' + g)}";
                var groupTeams = teams.Skip(g * teamsPerGroup).Take(teamsPerGroup).ToList();

                // Round Robin: mỗi đội đấu với tất cả đội khác
                for (int i = 0; i < groupTeams.Count; i++)
                {
                    for (int j = i + 1; j < groupTeams.Count; j++)
                    {
                        matches.Add(new TournamentMatch
                        {
                            TournamentId = tournamentId,
                            Round = groupName,
                            MatchOrder = order++,
                            Team1Player1Id = groupTeams[i].MemberId,
                            Team2Player1Id = groupTeams[j].MemberId,
                            Status = TournamentMatchStatus.Scheduled
                        });
                    }
                }
            }

            return matches;
        }

        /// <summary>
        /// Tạo lịch knockout (Loại trực tiếp)
        /// </summary>
        private List<TournamentMatch> GenerateKnockoutBracket(int tournamentId, List<TournamentParticipant> teams)
        {
            var matches = new List<TournamentMatch>();
            var count = teams.Count;

            // Tính số vòng cần thiết
            var rounds = new List<string>();
            if (count >= 16) rounds.Add("Round16");
            if (count >= 8) rounds.Add("QuarterFinal");
            if (count >= 4) rounds.Add("SemiFinal");
            rounds.Add("Final");

            // Vòng đầu tiên: ghép cặp
            var currentRound = rounds.First();
            var order = 1;
            for (int i = 0; i < count / 2; i++)
            {
                matches.Add(new TournamentMatch
                {
                    TournamentId = tournamentId,
                    Round = currentRound,
                    MatchOrder = order++,
                    Team1Player1Id = teams[i * 2].MemberId,
                    Team2Player1Id = teams[i * 2 + 1].MemberId,
                    Status = TournamentMatchStatus.Scheduled
                });
            }

            // Tạo các trận shell cho các vòng tiếp theo (chưa có đội)
            var matchesInRound = count / 2;
            for (int r = 1; r < rounds.Count; r++)
            {
                matchesInRound /= 2;
                for (int i = 0; i < matchesInRound; i++)
                {
                    matches.Add(new TournamentMatch
                    {
                        TournamentId = tournamentId,
                        Round = rounds[r],
                        MatchOrder = order++,
                        Status = TournamentMatchStatus.Pending // Chờ xác định đội
                    });
                }
            }

            return matches;
        }

        /// <summary>
        /// Đẩy winner lên vòng tiếp theo trong knockout
        /// </summary>
        private async Task AdvanceWinnerToNextRound(TournamentMatch completedMatch)
        {
            var winnerId = completedMatch.Winner == 1 
                ? completedMatch.Team1Player1Id 
                : completedMatch.Team2Player1Id;

            if (string.IsNullOrEmpty(winnerId)) return;

            // Xác định vòng tiếp theo
            string nextRound = completedMatch.Round switch
            {
                "Round16" => "QuarterFinal",
                "QuarterFinal" => "SemiFinal",
                "SemiFinal" => "Final",
                _ => ""
            };

            if (string.IsNullOrEmpty(nextRound)) return;

            // Tìm trận tiếp theo cần điền
            // Logic: MatchOrder trong vòng hiện tại / 2 (làm tròn lên) = MatchOrder trong vòng tiếp
            var nextMatchOrder = (completedMatch.MatchOrder + 1) / 2;
            var isTeam1 = completedMatch.MatchOrder % 2 == 1; // Odd = Team1, Even = Team2

            var nextMatch = await _context.TournamentMatches
                .Where(m => m.TournamentId == completedMatch.TournamentId 
                         && m.Round == nextRound)
                .OrderBy(m => m.MatchOrder)
                .Skip(nextMatchOrder - 1)
                .FirstOrDefaultAsync();

            if (nextMatch != null)
            {
                if (isTeam1 || string.IsNullOrEmpty(nextMatch.Team1Player1Id))
                    nextMatch.Team1Player1Id = winnerId;
                else
                    nextMatch.Team2Player1Id = winnerId;

                // Nếu cả 2 đội đã có, chuyển sang Scheduled
                if (!string.IsNullOrEmpty(nextMatch.Team1Player1Id) && !string.IsNullOrEmpty(nextMatch.Team2Player1Id))
                    nextMatch.Status = TournamentMatchStatus.Scheduled;
            }
        }

        #endregion
    }

    public class TournamentMatchResultRequest
    {
        public int Team1Score { get; set; }
        public int Team2Score { get; set; }
    }
}

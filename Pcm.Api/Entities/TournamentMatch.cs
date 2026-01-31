using System.ComponentModel.DataAnnotations;

namespace Pcm.Api.Entities
{
    /// <summary>
    /// Trận đấu trong giải (Vòng bảng hoặc Knockout)
    /// </summary>
    public class TournamentMatch
    {
        [Key]
        public int Id { get; set; }

        public int TournamentId { get; set; }
        public Tournament? Tournament { get; set; }

        // Vòng đấu: "GroupA", "GroupB", "QuarterFinal", "SemiFinal", "Final"
        public string Round { get; set; } = string.Empty;
        public int MatchOrder { get; set; } // Thứ tự trong vòng

        // Đội 1 (có thể null nếu chưa xác định - knockout rounds)
        public string? Team1Player1Id { get; set; }
        public Member? Team1Player1 { get; set; }
        public string? Team1Player2Id { get; set; }
        public Member? Team1Player2 { get; set; }

        // Đội 2
        public string? Team2Player1Id { get; set; }
        public Member? Team2Player1 { get; set; }
        public string? Team2Player2Id { get; set; }
        public Member? Team2Player2 { get; set; }

        // Kết quả
        public int Team1Score { get; set; } = 0;
        public int Team2Score { get; set; } = 0;
        public int Winner { get; set; } = 0; // 0: chưa xác định, 1: Team1, 2: Team2
        public string? Details { get; set; } // Chi tiết các set (JSON)

        // Lịch thi đấu
        public DateTime? ScheduledTime { get; set; }
        public int? CourtId { get; set; }
        public Court? Court { get; set; }

        public TournamentMatchStatus Status { get; set; } = TournamentMatchStatus.Pending;
        public DateTime CreatedDate { get; set; } = DateTime.Now;
    }
}

using System.ComponentModel.DataAnnotations;

namespace Pcm.Api.Entities
{
    /// <summary>
    /// Trận đấu giao hữu / xếp hạng - ảnh hưởng đến DUPR
    /// </summary>
    public class Match
    {
        [Key]
        public int Id { get; set; }

        public int? CourtId { get; set; }
        public Court? Court { get; set; }

        public DateTime MatchDate { get; set; }
        public TimeSpan StartTime { get; set; }

        // Team 1 (có thể 1v1 hoặc 2v2)
        public string Team1Player1Id { get; set; } = string.Empty;
        public Member? Team1Player1 { get; set; }
        public string? Team1Player2Id { get; set; }
        public Member? Team1Player2 { get; set; }

        // Team 2
        public string Team2Player1Id { get; set; } = string.Empty;
        public Member? Team2Player1 { get; set; }
        public string? Team2Player2Id { get; set; }
        public Member? Team2Player2 { get; set; }

        // Điểm số (Pickleball: thường đến 11 hoặc 15)
        public int Team1Score { get; set; } = 0;
        public int Team2Score { get; set; } = 0;

        public MatchStatus Status { get; set; } = MatchStatus.Scheduled;
        public MatchType Type { get; set; } = MatchType.Friendly;
        public bool IsRanked { get; set; } = false; // Có tính điểm DUPR không
        public string? Details { get; set; } // Chi tiết các set (JSON: "11-9, 5-11...")

        public DateTime CreatedDate { get; set; } = DateTime.Now;
        public DateTime? CompletedDate { get; set; }

        // Computed: Team nào thắng (1, 2, hoặc 0 nếu chưa xong)
        public int Winner => Status == MatchStatus.Completed 
            ? (Team1Score > Team2Score ? 1 : (Team2Score > Team1Score ? 2 : 0))
            : 0;
    }
}

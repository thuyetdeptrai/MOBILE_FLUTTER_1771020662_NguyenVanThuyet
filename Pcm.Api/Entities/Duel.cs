using System.ComponentModel.DataAnnotations;

namespace Pcm.Api.Entities
{
    /// <summary>
    /// Kèo thách đấu 1v1 hoặc 2v2 với tiền thưởng
    /// </summary>
    public class Duel
    {
        [Key]
        public int Id { get; set; }

        // Người thách đấu (Challenger)
        public string ChallengerId { get; set; } = string.Empty;
        public Member? Challenger { get; set; }
        public string? ChallengerPartnerId { get; set; } // Nếu 2v2
        public Member? ChallengerPartner { get; set; }

        // Người bị thách (Opponent)
        public string OpponentId { get; set; } = string.Empty;
        public Member? Opponent { get; set; }
        public string? OpponentPartnerId { get; set; }
        public Member? OpponentPartner { get; set; }

        // Tiền cược (mỗi bên đặt số này, winner lấy cả 2)
        public decimal BetAmount { get; set; } = 0;
        
        public DuelType Type { get; set; } = DuelType.Singles;
        public DuelStatus Status { get; set; } = DuelStatus.Pending;

        // Kết quả
        public int ChallengerScore { get; set; } = 0;
        public int OpponentScore { get; set; } = 0;
        public string? WinnerId { get; set; } // MemberId của người/đội thắng (player1 của team thắng)

        // Thời gian & địa điểm
        public DateTime? ScheduledTime { get; set; }
        public int? CourtId { get; set; }
        public Court? Court { get; set; }

        public DateTime CreatedDate { get; set; } = DateTime.Now;
        public DateTime? AcceptedDate { get; set; }
        public DateTime? CompletedDate { get; set; }

        // Mô tả / ghi chú
        public string? Message { get; set; }
    }
}

using System.ComponentModel.DataAnnotations;

namespace Pcm.Api.Entities
{
    public class TournamentParticipant
    {
        [Key]
        public int Id { get; set; }

        public int TournamentId { get; set; }
        public Tournament? Tournament { get; set; }

        public string MemberId { get; set; } = string.Empty;
        public Member? Member { get; set; }

        // --- CÁC CỘT CÒN THIẾU GÂY LỖI ---
        public DateTime RegisteredDate { get; set; } = DateTime.Now;
        public string PaymentStatus { get; set; } = "Pending"; // Paid hoặc Pending
    }
}
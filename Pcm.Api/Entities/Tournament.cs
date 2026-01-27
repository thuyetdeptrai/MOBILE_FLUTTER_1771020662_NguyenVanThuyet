using System.ComponentModel.DataAnnotations;

namespace Pcm.Api.Entities
{
    public class Tournament
    {
        [Key]
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public DateTime StartDate { get; set; }
        
        // --- CÁC CỘT QUAN TRỌNG ---
        public decimal EntryFee { get; set; } = 0; // Phí tham gia
        public decimal PrizePool { get; set; } = 0; // Giải thưởng
        public int MaxParticipants { get; set; } = 16;
        public string Status { get; set; } = "Open";

        // Quan hệ 1-nhiều
        public ICollection<TournamentParticipant> Participants { get; set; } = new List<TournamentParticipant>();
    }
}
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
        public string? Settings { get; set; } // Cấu hình nâng cao (JSON)

        // --- CẤU HÌNH GIẢI ĐẤU ---
        public TournamentFormat Format { get; set; } = TournamentFormat.SingleElimination;
        public int GroupCount { get; set; } = 2;       // Số bảng (nếu có vòng bảng)
        public bool HasGroupStage { get; set; } = false;
        
        // --- CHIA GIẢI THƯỞNG (%) ---
        public int Prize1stPercent { get; set; } = 60;  // Top 1: 60%
        public int Prize2ndPercent { get; set; } = 30;  // Top 2: 30%
        public int Prize3rdPercent { get; set; } = 10;  // Top 3: 10%

        // Quan hệ 1-nhiều
        public ICollection<TournamentParticipant> Participants { get; set; } = new List<TournamentParticipant>();
        public ICollection<TournamentMatch> Matches { get; set; } = new List<TournamentMatch>();
    }
}
using Microsoft.AspNetCore.Identity;
using System.ComponentModel.DataAnnotations;

namespace Pcm.Api.Entities
{
    // Member KẾ THỪA IdentityUser để dùng chung bảng với Identity columns
    public class Member : IdentityUser
    {
        public string FullName { get; set; } = string.Empty;
        public string? AvatarUrl { get; set; }
        public DateTime JoinDate { get; set; } = DateTime.Now;
        
        public Tier Tier { get; set; } = Tier.Bronze;
        public double RankLevel { get; set; } = 0;
        public decimal WalletBalance { get; set; } = 0;
        public decimal TotalSpent { get; set; } = 0;
        public decimal TotalDeposited { get; set; } = 0;
        
        // Thống kê người chơi
        public double DuprRating { get; set; } = 3.0; // DUPR từ 2.0 - 6.0
        public int TotalMatches { get; set; } = 0;
        public int MatchesWon { get; set; } = 0;
        public int TotalTournaments { get; set; } = 0;
        
        // Computed property
        public double WinRate => TotalMatches > 0 ? (double)MatchesWon / TotalMatches * 100 : 0;

        public void UpdateTier()
        {
            if (TotalSpent >= 10000000) Tier = Tier.Diamond;
            else if (TotalSpent >= 5000000) Tier = Tier.Gold;
            else if (TotalSpent >= 1000000) Tier = Tier.Silver;
            else Tier = Tier.Bronze;
        }
    }
}
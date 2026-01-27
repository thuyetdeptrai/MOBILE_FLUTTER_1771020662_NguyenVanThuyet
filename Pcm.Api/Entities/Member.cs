using Microsoft.AspNetCore.Identity;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Pcm.Api.Entities
{
    public class Member
    {
        [Key]
        public string Id { get; set; } = string.Empty;

        // BẮT BUỘC PHẢI CÓ CỘT NÀY ĐỂ LIÊN KẾT TÀI KHOẢN
        public string UserId { get; set; } = string.Empty; 

        public string FullName { get; set; } = string.Empty;
        public DateTime JoinDate { get; set; }
        
        // SỬA Status THÀNH IsActive CHO KHỚP CODE
        public bool IsActive { get; set; } = true; 

        public Tier Tier { get; set; } = Tier.Bronze; // Enum vừa tạo
        public double RankLevel { get; set; } = 0;
        public decimal WalletBalance { get; set; } = 0;
        public decimal TotalSpent { get; set; } = 0;
        public decimal TotalDeposited { get; set; } = 0;
    }
}
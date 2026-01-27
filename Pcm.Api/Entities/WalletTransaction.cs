using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Pcm.Api.Entities
{
    public class WalletTransaction
    {
        [Key]
        public int Id { get; set; }

        public string MemberId { get; set; } = string.Empty;
        
        // --- CÁC CỘT CÒN THIẾU GÂY LỖI ---
        public decimal Amount { get; set; }
        
        // Loại giao dịch (1: Nạp, 2: Trừ...)
        public TransactionType Type { get; set; } 
        
        public string Description { get; set; } = string.Empty;
        public DateTime CreatedDate { get; set; } = DateTime.Now;
        
        // Trạng thái (0: Chờ duyệt, 1: Thành công, 2: Hủy)
        public int Status { get; set; } = 1; 
    }
}
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
        
        // Trạng thái (Pending, Completed, Rejected, Failed)
        public TransactionStatus Status { get; set; } = TransactionStatus.Pending; 
        
        // ID liên quan (BookingId, TournamentId...) để truy vết
        public string? RelatedId { get; set; }
    }
}
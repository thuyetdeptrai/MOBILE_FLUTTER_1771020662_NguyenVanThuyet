using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Pcm.Api.Entities
{
    public class Booking
    {
        [Key]
        public int Id { get; set; }

        public int CourtId { get; set; }
        public Court? Court { get; set; } // Link đến bảng Court

        public string MemberId { get; set; } = string.Empty;
        public Member? Member { get; set; } // Link đến bảng Member

        public DateTime BookingDate { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }

        // --- CÁC CỘT CÒN THIẾU GÂY LỖI ---
        public decimal TotalPrice { get; set; } = 0;
        public BookingStatus Status { get; set; } = BookingStatus.PendingPayment; // Dùng Enum
        public DateTime CreatedDate { get; set; } = DateTime.Now;
    }
}
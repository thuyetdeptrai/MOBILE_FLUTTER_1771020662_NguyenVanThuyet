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

        public decimal TotalPrice { get; set; } = 0;
        public BookingStatus Status { get; set; } = BookingStatus.PendingPayment; // Dùng Enum
        public DateTime CreatedDate { get; set; } = DateTime.Now;

        // --- Đặt lịch định kỳ ---
        public bool IsRecurring { get; set; } = false;
        public RecurrenceType RecurrenceType { get; set; } = RecurrenceType.None;
        public DateTime? RecurrenceEnd { get; set; }
        public Guid? RecurrenceId { get; set; }
        public string? RecurrenceRule { get; set; } // VD: "Weekly;Tue,Thu"
        public int? ParentBookingId { get; set; } // Nếu đây là con từ lịch lặp

        // --- Hold Slot (Giữ chỗ 5 phút) ---
        public DateTime? HoldExpiry { get; set; }  // Thời điểm hết hạn giữ chỗ
    }
}

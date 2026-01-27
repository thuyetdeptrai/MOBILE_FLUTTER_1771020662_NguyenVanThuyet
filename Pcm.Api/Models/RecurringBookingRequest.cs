using System.ComponentModel.DataAnnotations;

namespace Pcm.Api.Models
{
    public class RecurringBookingRequest
    {
        [Required]
        public int CourtId { get; set; }

        [Required]
        public string MemberId { get; set; } = string.Empty;

        // Giờ bắt đầu/kết thúc (Chỉ quan tâm Giờ:Phút, không quan tâm ngày)
        public DateTime StartTime { get; set; } 
        public DateTime EndTime { get; set; }

        // Khoảng thời gian muốn đặt (Ví dụ: Từ 01/02 đến 28/02)
        public DateTime FromDate { get; set; }
        public DateTime ToDate { get; set; }

        // Danh sách các thứ trong tuần muốn đặt
        // 0 = Chủ nhật, 1 = Thứ 2, ..., 6 = Thứ 7
        public List<int> DaysOfWeek { get; set; } = new List<int>();
    }
}
using System.ComponentModel.DataAnnotations;

namespace Pcm.Api.Models
{
    public class BookingRequest
    {
        [Required]
        public int CourtId { get; set; }

        [Required]
        public string MemberId { get; set; } = string.Empty;

        [Required]
        public DateTime StartTime { get; set; }

        [Required]
        public DateTime EndTime { get; set; }
    }
}
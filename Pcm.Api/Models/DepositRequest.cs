namespace Pcm.Api.Models
{
    public class DepositRequest
    {
        public string MemberId { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public string? EvidenceUrl { get; set; } // <--- THÊM CỘT NÀY
    }
}
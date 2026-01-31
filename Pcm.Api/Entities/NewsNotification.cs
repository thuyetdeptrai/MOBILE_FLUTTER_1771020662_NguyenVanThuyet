using System.ComponentModel.DataAnnotations;

namespace Pcm.Api.Entities
{
    public class News
    {
        [Key]
        public int Id { get; set; }
        
        public string Title { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public string? ImageUrl { get; set; }
        
        public bool IsPinned { get; set; } = false;
        public bool IsActive { get; set; } = true;
        
        public string? AuthorId { get; set; }
        public Member? Author { get; set; }
        
        public DateTime CreatedDate { get; set; } = DateTime.Now;
        public DateTime? UpdatedDate { get; set; }
    }
    
    public class Notification
    {
        [Key]
        public int Id { get; set; }
        
        public string MemberId { get; set; } = string.Empty;
        public Member? Member { get; set; }
        
        public string Title { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        
        // Type: Info, Success, Warning, Error
        public NotificationType Type { get; set; } = NotificationType.Info;
        public string? LinkUrl { get; set; } // Link điều hướng khi tap vào noti (URL hoặc Route)
        
        public bool IsRead { get; set; } = false;
        public DateTime CreatedDate { get; set; } = DateTime.Now;
        
        // Reference ID (optional) - for linking to booking, tournament, etc.
        public int? ReferenceId { get; set; }
    }
}

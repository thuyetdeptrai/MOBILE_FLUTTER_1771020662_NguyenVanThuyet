namespace Pcm.Api.Entities
{
    public class Court
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Type { get; set; } = "Standard";
        public string? ImageUrl { get; set; }
        public string? Description { get; set; }
        public decimal PricePerHour { get; set; }
        public bool IsActive { get; set; } = true;
    }
}
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Pcm.Api.Entities;

namespace Pcm.Api.Data
{
    // QUAN TRỌNG: Kế thừa IdentityDbContext<IdentityUser> (Chuẩn)
    // Tuyệt đối không sửa thành Member ở dòng dưới
    public class ApplicationDbContext : IdentityDbContext<IdentityUser>
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        // Khai báo các bảng dữ liệu của chúng ta ở đây
        // Đây chính là dòng giúp sửa lỗi "does not contain definition for Members"
        public DbSet<Member> Members { get; set; } 
        public DbSet<Court> Courts { get; set; }
        public DbSet<Booking> Bookings { get; set; }
        public DbSet<Tournament> Tournaments { get; set; }
        public DbSet<TournamentParticipant> TournamentParticipants { get; set; }
        public DbSet<WalletTransaction> WalletTransactions { get; set; }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            // Tùy chỉnh tên bảng Identity cho gọn (Không bắt buộc, nhưng nên làm cho đẹp DB)
            builder.Entity<IdentityUser>().ToTable("Users");
            builder.Entity<IdentityRole>().ToTable("Roles");
            builder.Entity<IdentityUserRole<string>>().ToTable("UserRoles");
            builder.Entity<IdentityUserClaim<string>>().ToTable("UserClaims");
            builder.Entity<IdentityUserLogin<string>>().ToTable("UserLogins");
            builder.Entity<IdentityUserToken<string>>().ToTable("UserTokens");
            builder.Entity<IdentityRoleClaim<string>>().ToTable("RoleClaims");

            // Config cho Member
            builder.Entity<Member>().ToTable("662_Members"); // Đặt tên theo MSSV của bạn
        }
    }
}
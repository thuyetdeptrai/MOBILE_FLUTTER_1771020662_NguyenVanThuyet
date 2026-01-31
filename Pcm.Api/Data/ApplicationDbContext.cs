using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Pcm.Api.Entities;

namespace Pcm.Api.Data
{
    // Dùng Member thay vì IdentityUser vì Member kế thừa IdentityUser
    public class ApplicationDbContext : IdentityDbContext<Member>
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        // Các bảng dữ liệu khác
        public DbSet<Member> Members { get; set; }
        public DbSet<Court> Courts { get; set; }
        public DbSet<Booking> Bookings { get; set; }
        public DbSet<Tournament> Tournaments { get; set; }
        public DbSet<TournamentParticipant> TournamentParticipants { get; set; }
        public DbSet<WalletTransaction> WalletTransactions { get; set; }
        public DbSet<News> News { get; set; }
        public DbSet<Notification> Notifications { get; set; }
        public DbSet<Match> Matches { get; set; }
        public DbSet<TournamentMatch> TournamentMatches { get; set; }
        public DbSet<Duel> Duels { get; set; }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            // Map các bảng nghiệp vụ với tiền tố 662_
            builder.Entity<Member>().ToTable("662_Members");
            builder.Entity<Court>().ToTable("662_Courts");
            builder.Entity<Booking>().ToTable("662_Bookings");
            builder.Entity<Tournament>().ToTable("662_Tournaments");
            builder.Entity<TournamentParticipant>().ToTable("662_TournamentParticipants");
            builder.Entity<WalletTransaction>().ToTable("662_WalletTransactions");
            builder.Entity<News>().ToTable("662_News");
            builder.Entity<Notification>().ToTable("662_Notifications");
            builder.Entity<Match>().ToTable("662_Matches");
            builder.Entity<TournamentMatch>().ToTable("662_TournamentMatches");
            builder.Entity<Duel>().ToTable("662_Duels");
            
            // Các bảng Identity khác
            builder.Entity<IdentityRole>().ToTable("662_Roles");
            builder.Entity<IdentityUserRole<string>>().ToTable("662_UserRoles");
            builder.Entity<IdentityUserClaim<string>>().ToTable("662_UserClaims");
            builder.Entity<IdentityUserLogin<string>>().ToTable("662_UserLogins");
            builder.Entity<IdentityUserToken<string>>().ToTable("662_UserTokens");
            builder.Entity<IdentityRoleClaim<string>>().ToTable("662_RoleClaims");

            // Tier enum lưu dưới dạng string
            builder.Entity<Member>()
                .Property(m => m.Tier)
                .HasConversion<string>();

            // Cấu hình kiểu dữ liệu Decimal cho tiền tệ (tránh warning truncation)
            builder.Entity<Member>().Property(m => m.WalletBalance).HasColumnType("decimal(18,2)");
            builder.Entity<Member>().Property(m => m.TotalSpent).HasColumnType("decimal(18,2)");
            builder.Entity<Member>().Property(m => m.TotalDeposited).HasColumnType("decimal(18,2)");

            builder.Entity<Court>().Property(c => c.PricePerHour).HasColumnType("decimal(18,2)");

            builder.Entity<Booking>().Property(b => b.TotalPrice).HasColumnType("decimal(18,2)");

            builder.Entity<Tournament>().Property(t => t.EntryFee).HasColumnType("decimal(18,2)");
            builder.Entity<Tournament>().Property(t => t.PrizePool).HasColumnType("decimal(18,2)");

            builder.Entity<WalletTransaction>().Property(w => w.Amount).HasColumnType("decimal(18,2)");

            // Duel configuration
            builder.Entity<Duel>().Property(d => d.BetAmount).HasColumnType("decimal(18,2)");

            // Fix multiple cascade paths for TournamentMatch
            builder.Entity<TournamentMatch>()
                .HasOne(m => m.Team1Player1)
                .WithMany()
                .HasForeignKey(m => m.Team1Player1Id)
                .OnDelete(DeleteBehavior.NoAction);

            builder.Entity<TournamentMatch>()
                .HasOne(m => m.Team1Player2)
                .WithMany()
                .HasForeignKey(m => m.Team1Player2Id)
                .OnDelete(DeleteBehavior.NoAction);

            builder.Entity<TournamentMatch>()
                .HasOne(m => m.Team2Player1)
                .WithMany()
                .HasForeignKey(m => m.Team2Player1Id)
                .OnDelete(DeleteBehavior.NoAction);

            builder.Entity<TournamentMatch>()
                .HasOne(m => m.Team2Player2)
                .WithMany()
                .HasForeignKey(m => m.Team2Player2Id)
                .OnDelete(DeleteBehavior.NoAction);

            // Fix multiple cascade paths for Duel
            builder.Entity<Duel>()
                .HasOne(d => d.Challenger)
                .WithMany()
                .HasForeignKey(d => d.ChallengerId)
                .OnDelete(DeleteBehavior.NoAction);

            builder.Entity<Duel>()
                .HasOne(d => d.ChallengerPartner)
                .WithMany()
                .HasForeignKey(d => d.ChallengerPartnerId)
                .OnDelete(DeleteBehavior.NoAction);

            builder.Entity<Duel>()
                .HasOne(d => d.Opponent)
                .WithMany()
                .HasForeignKey(d => d.OpponentId)
                .OnDelete(DeleteBehavior.NoAction);

            builder.Entity<Duel>()
                .HasOne(d => d.OpponentPartner)
                .WithMany()
                .HasForeignKey(d => d.OpponentPartnerId)
                .OnDelete(DeleteBehavior.NoAction);

            // Fix multiple cascade paths for Match (Daily Matches)
            builder.Entity<Match>()
                .HasOne(m => m.Team1Player1)
                .WithMany()
                .HasForeignKey(m => m.Team1Player1Id)
                .OnDelete(DeleteBehavior.NoAction);

            builder.Entity<Match>()
                .HasOne(m => m.Team1Player2)
                .WithMany()
                .HasForeignKey(m => m.Team1Player2Id)
                .OnDelete(DeleteBehavior.NoAction);

            builder.Entity<Match>()
                .HasOne(m => m.Team2Player1)
                .WithMany()
                .HasForeignKey(m => m.Team2Player1Id)
                .OnDelete(DeleteBehavior.NoAction);

            builder.Entity<Match>()
                .HasOne(m => m.Team2Player2)
                .WithMany()
                .HasForeignKey(m => m.Team2Player2Id)
                .OnDelete(DeleteBehavior.NoAction);
        }
    }
}
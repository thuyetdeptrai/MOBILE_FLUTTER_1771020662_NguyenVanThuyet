using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Pcm.Api.Data;
using Pcm.Api.Entities;

namespace Pcm.Api.Services
{
    public static class DbSeeder
    {
        public static async Task SeedData(IServiceProvider serviceProvider)
        {
            using var scope = serviceProvider.CreateScope();
            var userManager = scope.ServiceProvider.GetRequiredService<UserManager<Member>>();
            var roleManager = scope.ServiceProvider.GetRequiredService<RoleManager<IdentityRole>>();
            var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

            await context.Database.MigrateAsync();

            // 1. Tạo Roles: Admin, Member, Tresurer, Referee
            string[] roles = { "Admin", "Member", "Treasurer", "Referee" };
            foreach (var role in roles)
            {
                if (!await roleManager.RoleExistsAsync(role))
                {
                    await roleManager.CreateAsync(new IdentityRole(role));
                }
            }

            // 2. Tạo Special Users (Admin, Treasurer, Referee)
            var specialUsers = new[]
            {
                ("admin", "admin@pcm.vn", "Quản trị viên", "Admin"),
                ("treasurer", "treasurer@pcm.vn", "Thủ quỹ", "Treasurer"),
                ("referee", "referee@pcm.vn", "Trọng tài", "Referee")
            };

            foreach (var (username, email, name, role) in specialUsers)
            {
                if (await userManager.FindByEmailAsync(email) == null)
                {
                    var user = new Member
                    {
                        UserName = username,
                        Email = email,
                        EmailConfirmed = true,
                        FullName = name,
                        Tier = Tier.Diamond,
                        JoinDate = DateTime.Now,
                        WalletBalance = 0,
                        DuprRating = 5.0
                    };
                    var result = await userManager.CreateAsync(user, "Admin@123"); // Password chung
                    if (result.Succeeded)
                    {
                        await userManager.AddToRoleAsync(user, role);
                    }
                }
            }

            // 3. Tạo 20 Sample Members
            var random = new Random();
            for (int i = 1; i <= 20; i++)
            {
                var email = $"member{i:D2}@pcm.vn";
                if (await userManager.FindByEmailAsync(email) == null)
                {
                    // Random stats
                    var tier = (Tier)random.Next(0, 4); // 0-3
                    var balance = random.Next(20, 101) * 100000m; // 2tr - 10tr
                    var dupr = 2.5 + (random.NextDouble() * 3.0); // 2.5 - 5.5

                    var member = new Member
                    {
                        UserName = $"member{i:D2}",
                        Email = email,
                        EmailConfirmed = true,
                        FullName = $"Thành viên {i:D2}",
                        Tier = tier,
                        JoinDate = DateTime.Now.AddDays(-random.Next(10, 365)),
                        WalletBalance = balance,
                        DuprRating = Math.Round(dupr, 2),
                        TotalMatches = random.Next(0, 50),
                        MatchesWon = random.Next(0, 25)
                    };

                    var result = await userManager.CreateAsync(member, "Member@123");
                    if (result.Succeeded)
                    {
                        await userManager.AddToRoleAsync(member, "Member");
                        
                        // Fake history transaction
                        context.WalletTransactions.Add(new WalletTransaction
                        {
                            MemberId = member.Id,
                            Amount = balance,
                            Type = TransactionType.Deposit,
                            Description = "Nạp tiền khởi tạo",
                            CreatedDate = DateTime.Now.AddDays(-1),
                            Status = TransactionStatus.Completed
                        });
                    }
                }
            }

            // 4. Tạo Sample Courts (nếu chưa có)
            if (!context.Courts.Any())
            {
                context.Courts.AddRange(
                    new Court { Name = "Sân A1 - Indoor", Description = "Sân trong nhà chuẩn thi đấu", PricePerHour = 200000, IsActive = true },
                    new Court { Name = "Sân A2 - Indoor", Description = "Sân trong nhà chuẩn thi đấu", PricePerHour = 200000, IsActive = true },
                    new Court { Name = "Sân B1 - Outdoor", Description = "Sân ngoài trời thoáng mát", PricePerHour = 120000, IsActive = true },
                    new Court { Name = "Sân B2 - Outdoor", Description = "Sân ngoài trời thoáng mát", PricePerHour = 120000, IsActive = true },
                    new Court { Name = "Sân VIP Galaxy", Description = "Sân VIP có điều hòa & phục vụ", PricePerHour = 500000, IsActive = true }
                );
            }

            // 5. Tạo Sample Tournaments
            if (!context.Tournaments.Any(t => t.Name.Contains("Summer Open")))
            {
                context.Tournaments.Add(new Tournament
                {
                    Name = "Summer Open 2026",
                    Description = "Giải đấu mùa hè 2026 (Đã kết thúc)",
                    StartDate = DateTime.Now.AddDays(-30),
                    EntryFee = 300000,
                    PrizePool = 10000000,
                    MaxParticipants = 16,
                    Status = "Completed",
                    Format = TournamentFormat.SingleElimination,
                    Prize1stPercent = 60,
                    Prize2ndPercent = 30,
                    Prize3rdPercent = 10
                });
            }

            if (!context.Tournaments.Any(t => t.Name.Contains("Winter Cup")))
            {
                context.Tournaments.Add(new Tournament
                {
                    Name = "Winter Cup",
                    Description = "Giải đấu mùa đông đang mở đăng ký",
                    StartDate = DateTime.Now.AddDays(15),
                    EntryFee = 500000,
                    PrizePool = 20000000,
                    MaxParticipants = 32,
                    Status = "Registering",
                    Format = TournamentFormat.GroupThenKnockout,
                    HasGroupStage = true,
                    GroupCount = 8,
                    Prize1stPercent = 50,
                    Prize2ndPercent = 30,
                    Prize3rdPercent = 20
                });
            }

            await context.SaveChangesAsync();
        }
    }
}

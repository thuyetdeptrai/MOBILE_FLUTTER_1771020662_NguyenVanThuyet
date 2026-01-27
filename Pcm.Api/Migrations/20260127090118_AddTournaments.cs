using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace Pcm.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddTournaments : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_662_Bookings_662_Bookings_ParentBookingId",
                table: "662_Bookings");

            migrationBuilder.DropForeignKey(
                name: "FK_662_Bookings_662_Courts_CourtId",
                table: "662_Bookings");

            migrationBuilder.DropForeignKey(
                name: "FK_662_Bookings_662_Members_MemberId",
                table: "662_Bookings");

            migrationBuilder.DropPrimaryKey(
                name: "PK_662_Courts",
                table: "662_Courts");

            migrationBuilder.DropPrimaryKey(
                name: "PK_662_Bookings",
                table: "662_Bookings");

            migrationBuilder.DeleteData(
                table: "662_Members",
                keyColumn: "Id",
                keyValue: "admin-id-123");

            migrationBuilder.DeleteData(
                table: "662_Members",
                keyColumn: "Id",
                keyValue: "member-id-456");

            migrationBuilder.RenameTable(
                name: "662_Courts",
                newName: "Courts");

            migrationBuilder.RenameTable(
                name: "662_Bookings",
                newName: "Bookings");

            migrationBuilder.RenameIndex(
                name: "IX_662_Bookings_ParentBookingId",
                table: "Bookings",
                newName: "IX_Bookings_ParentBookingId");

            migrationBuilder.RenameIndex(
                name: "IX_662_Bookings_MemberId",
                table: "Bookings",
                newName: "IX_Bookings_MemberId");

            migrationBuilder.RenameIndex(
                name: "IX_662_Bookings_CourtId",
                table: "Bookings",
                newName: "IX_Bookings_CourtId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Courts",
                table: "Courts",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Bookings",
                table: "Bookings",
                column: "Id");

            migrationBuilder.CreateTable(
                name: "Tournaments",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    StartDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    EntryFee = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    PrizePool = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    MaxParticipants = table.Column<int>(type: "int", nullable: false),
                    Status = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Tournaments", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "TournamentParticipants",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    TournamentId = table.Column<int>(type: "int", nullable: false),
                    MemberId = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    RegisteredDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    PaymentStatus = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TournamentParticipants", x => x.Id);
                    table.ForeignKey(
                        name: "FK_TournamentParticipants_Tournaments_TournamentId",
                        column: x => x.TournamentId,
                        principalTable: "Tournaments",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.InsertData(
                table: "Tournaments",
                columns: new[] { "Id", "Description", "EntryFee", "MaxParticipants", "Name", "PrizePool", "StartDate", "Status" },
                values: new object[] { 1, "Giải đấu mở rộng dành cho mọi lứa tuổi.", 200000m, 16, "Pickleball Open Cup 2026", 5000000m, new DateTime(2026, 2, 6, 16, 1, 17, 709, DateTimeKind.Local).AddTicks(8428), "Open" });

            migrationBuilder.CreateIndex(
                name: "IX_TournamentParticipants_TournamentId",
                table: "TournamentParticipants",
                column: "TournamentId");

            migrationBuilder.AddForeignKey(
                name: "FK_Bookings_662_Members_MemberId",
                table: "Bookings",
                column: "MemberId",
                principalTable: "662_Members",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Bookings_Bookings_ParentBookingId",
                table: "Bookings",
                column: "ParentBookingId",
                principalTable: "Bookings",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Bookings_Courts_CourtId",
                table: "Bookings",
                column: "CourtId",
                principalTable: "Courts",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Bookings_662_Members_MemberId",
                table: "Bookings");

            migrationBuilder.DropForeignKey(
                name: "FK_Bookings_Bookings_ParentBookingId",
                table: "Bookings");

            migrationBuilder.DropForeignKey(
                name: "FK_Bookings_Courts_CourtId",
                table: "Bookings");

            migrationBuilder.DropTable(
                name: "TournamentParticipants");

            migrationBuilder.DropTable(
                name: "Tournaments");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Courts",
                table: "Courts");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Bookings",
                table: "Bookings");

            migrationBuilder.RenameTable(
                name: "Courts",
                newName: "662_Courts");

            migrationBuilder.RenameTable(
                name: "Bookings",
                newName: "662_Bookings");

            migrationBuilder.RenameIndex(
                name: "IX_Bookings_ParentBookingId",
                table: "662_Bookings",
                newName: "IX_662_Bookings_ParentBookingId");

            migrationBuilder.RenameIndex(
                name: "IX_Bookings_MemberId",
                table: "662_Bookings",
                newName: "IX_662_Bookings_MemberId");

            migrationBuilder.RenameIndex(
                name: "IX_Bookings_CourtId",
                table: "662_Bookings",
                newName: "IX_662_Bookings_CourtId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_662_Courts",
                table: "662_Courts",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_662_Bookings",
                table: "662_Bookings",
                column: "Id");

            migrationBuilder.InsertData(
                table: "662_Members",
                columns: new[] { "Id", "AccessFailedCount", "AvatarUrl", "ConcurrencyStamp", "Email", "EmailConfirmed", "FullName", "JoinDate", "LockoutEnabled", "LockoutEnd", "NormalizedEmail", "NormalizedUserName", "PasswordHash", "PhoneNumber", "PhoneNumberConfirmed", "RankLevel", "SecurityStamp", "Tier", "TotalDeposited", "TotalSpent", "TwoFactorEnabled", "UserName", "WalletBalance" },
                values: new object[,]
                {
                    { "admin-id-123", 0, null, "e0d14c37-a725-430e-86d5-1715c2175ac5", "admin@pcm.com", true, "Administrator", new DateTime(2026, 1, 27, 15, 32, 55, 701, DateTimeKind.Local).AddTicks(9894), false, null, "ADMIN@PCM.COM", "ADMIN", "AQAAAAIAAYagAAAAELHIaBVNu3azFGVgkE6i5Jl+Db8gKbaSsXiktYikUbcYCmyKFfitg9cp+RDWduLNxg==", null, false, 3.0, "5db7f389-787b-47c4-91c8-502615732fde", "Bronze", 0m, 0m, false, "admin", 0m },
                    { "member-id-456", 0, null, "a3be3c87-95cc-4135-8372-2ebdc296bc0f", "user1@pcm.com", true, "Nguyễn Văn A", new DateTime(2026, 1, 27, 15, 32, 55, 764, DateTimeKind.Local).AddTicks(1918), false, null, "USER1@PCM.COM", "USER1", "AQAAAAIAAYagAAAAEB3FYXujn4zWRO+b9jvJNzDz1qKd5N1zbrZnhZo+dayfSngZls7emm4nEk2GrD9tVA==", null, false, 3.0, "a3bcc7fd-309b-437d-b7df-ff24ce4064ec", "Bronze", 0m, 0m, false, "user1", 5000000m }
                });

            migrationBuilder.AddForeignKey(
                name: "FK_662_Bookings_662_Bookings_ParentBookingId",
                table: "662_Bookings",
                column: "ParentBookingId",
                principalTable: "662_Bookings",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_662_Bookings_662_Courts_CourtId",
                table: "662_Bookings",
                column: "CourtId",
                principalTable: "662_Courts",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_662_Bookings_662_Members_MemberId",
                table: "662_Bookings",
                column: "MemberId",
                principalTable: "662_Members",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}

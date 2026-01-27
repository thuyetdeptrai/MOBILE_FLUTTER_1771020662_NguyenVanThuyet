using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Pcm.Api.Migrations
{
    /// <inheritdoc />
    public partial class UpdateWalletAndTier : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "Status",
                table: "662_WalletTransactions",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AlterColumn<string>(
                name: "Tier",
                table: "662_Members",
                type: "nvarchar(max)",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AddColumn<decimal>(
                name: "TotalDeposited",
                table: "662_Members",
                type: "decimal(18,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.UpdateData(
                table: "662_Members",
                keyColumn: "Id",
                keyValue: "admin-id-123",
                columns: new[] { "ConcurrencyStamp", "JoinDate", "PasswordHash", "SecurityStamp", "Tier", "TotalDeposited" },
                values: new object[] { "e0d14c37-a725-430e-86d5-1715c2175ac5", new DateTime(2026, 1, 27, 15, 32, 55, 701, DateTimeKind.Local).AddTicks(9894), "AQAAAAIAAYagAAAAELHIaBVNu3azFGVgkE6i5Jl+Db8gKbaSsXiktYikUbcYCmyKFfitg9cp+RDWduLNxg==", "5db7f389-787b-47c4-91c8-502615732fde", "Bronze", 0m });

            migrationBuilder.UpdateData(
                table: "662_Members",
                keyColumn: "Id",
                keyValue: "member-id-456",
                columns: new[] { "ConcurrencyStamp", "JoinDate", "PasswordHash", "SecurityStamp", "Tier", "TotalDeposited" },
                values: new object[] { "a3be3c87-95cc-4135-8372-2ebdc296bc0f", new DateTime(2026, 1, 27, 15, 32, 55, 764, DateTimeKind.Local).AddTicks(1918), "AQAAAAIAAYagAAAAEB3FYXujn4zWRO+b9jvJNzDz1qKd5N1zbrZnhZo+dayfSngZls7emm4nEk2GrD9tVA==", "a3bcc7fd-309b-437d-b7df-ff24ce4064ec", "Bronze", 0m });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Status",
                table: "662_WalletTransactions");

            migrationBuilder.DropColumn(
                name: "TotalDeposited",
                table: "662_Members");

            migrationBuilder.AlterColumn<int>(
                name: "Tier",
                table: "662_Members",
                type: "int",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)");

            migrationBuilder.UpdateData(
                table: "662_Members",
                keyColumn: "Id",
                keyValue: "admin-id-123",
                columns: new[] { "ConcurrencyStamp", "JoinDate", "PasswordHash", "SecurityStamp", "Tier" },
                values: new object[] { "e9b3fdf7-32fe-4e6c-b56d-4da118505a37", new DateTime(2026, 1, 27, 14, 16, 9, 427, DateTimeKind.Local).AddTicks(7011), "AQAAAAIAAYagAAAAEISGa4tmQIlcoc5fz2Y3GzzC4jz3YGXDNt/CPxzsceuqEnDEoSJUx1/NrkbAGQHl9w==", "2c3b9eab-dfb4-48d7-91e8-03a114ef72a2", 0 });

            migrationBuilder.UpdateData(
                table: "662_Members",
                keyColumn: "Id",
                keyValue: "member-id-456",
                columns: new[] { "ConcurrencyStamp", "JoinDate", "PasswordHash", "SecurityStamp", "Tier" },
                values: new object[] { "65329bd8-09e9-470f-869b-67739998ffc9", new DateTime(2026, 1, 27, 14, 16, 9, 490, DateTimeKind.Local).AddTicks(2771), "AQAAAAIAAYagAAAAEFV5pPxOp9U1yt1nGJiiyKMgOxQRz1TuTUXLHO85TT6+tJAKshFEmUZV5GgZXsjqCw==", "0493497f-6bdb-4c68-b339-7b3fcfd15ff9", 0 });
        }
    }
}

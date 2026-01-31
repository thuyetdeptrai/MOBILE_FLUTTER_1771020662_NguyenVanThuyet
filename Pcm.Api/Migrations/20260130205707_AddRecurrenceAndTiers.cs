using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Pcm.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddRecurrenceAndTiers : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsRecurring",
                table: "Bookings",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<DateTime>(
                name: "RecurrenceEnd",
                table: "Bookings",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "RecurrenceId",
                table: "Bookings",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "RecurrenceType",
                table: "Bookings",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsRecurring",
                table: "Bookings");

            migrationBuilder.DropColumn(
                name: "RecurrenceEnd",
                table: "Bookings");

            migrationBuilder.DropColumn(
                name: "RecurrenceId",
                table: "Bookings");

            migrationBuilder.DropColumn(
                name: "RecurrenceType",
                table: "Bookings");
        }
    }
}

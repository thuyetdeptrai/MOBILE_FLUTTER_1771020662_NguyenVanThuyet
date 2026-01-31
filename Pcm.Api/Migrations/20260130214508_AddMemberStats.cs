using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Pcm.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddMemberStats : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<double>(
                name: "DuprRating",
                table: "662_Members",
                type: "float",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<int>(
                name: "MatchesWon",
                table: "662_Members",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "TotalMatches",
                table: "662_Members",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "TotalTournaments",
                table: "662_Members",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DuprRating",
                table: "662_Members");

            migrationBuilder.DropColumn(
                name: "MatchesWon",
                table: "662_Members");

            migrationBuilder.DropColumn(
                name: "TotalMatches",
                table: "662_Members");

            migrationBuilder.DropColumn(
                name: "TotalTournaments",
                table: "662_Members");
        }
    }
}

using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Pcm.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddCourtFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ImageUrl",
                table: "Courts",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Type",
                table: "Courts",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ImageUrl",
                table: "Courts");

            migrationBuilder.DropColumn(
                name: "Type",
                table: "Courts");
        }
    }
}

using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Pcm.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddTournamentMatchAndDuel : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "Format",
                table: "Tournaments",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "GroupCount",
                table: "Tournaments",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<bool>(
                name: "HasGroupStage",
                table: "Tournaments",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<int>(
                name: "Prize1stPercent",
                table: "Tournaments",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "Prize2ndPercent",
                table: "Tournaments",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "Prize3rdPercent",
                table: "Tournaments",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "HoldExpiry",
                table: "Bookings",
                type: "datetime2",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "Duels",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ChallengerId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    ChallengerPartnerId = table.Column<string>(type: "nvarchar(450)", nullable: true),
                    OpponentId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    OpponentPartnerId = table.Column<string>(type: "nvarchar(450)", nullable: true),
                    BetAmount = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    Type = table.Column<int>(type: "int", nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false),
                    ChallengerScore = table.Column<int>(type: "int", nullable: false),
                    OpponentScore = table.Column<int>(type: "int", nullable: false),
                    WinnerId = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ScheduledTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CourtId = table.Column<int>(type: "int", nullable: true),
                    CreatedDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    AcceptedDate = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CompletedDate = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Message = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Duels", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Duels_662_Members_ChallengerId",
                        column: x => x.ChallengerId,
                        principalTable: "662_Members",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Duels_662_Members_ChallengerPartnerId",
                        column: x => x.ChallengerPartnerId,
                        principalTable: "662_Members",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Duels_662_Members_OpponentId",
                        column: x => x.OpponentId,
                        principalTable: "662_Members",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Duels_662_Members_OpponentPartnerId",
                        column: x => x.OpponentPartnerId,
                        principalTable: "662_Members",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Duels_Courts_CourtId",
                        column: x => x.CourtId,
                        principalTable: "Courts",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "Matches",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CourtId = table.Column<int>(type: "int", nullable: true),
                    MatchDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    StartTime = table.Column<TimeSpan>(type: "time", nullable: false),
                    Team1Player1Id = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Team1Player2Id = table.Column<string>(type: "nvarchar(450)", nullable: true),
                    Team2Player1Id = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Team2Player2Id = table.Column<string>(type: "nvarchar(450)", nullable: true),
                    Team1Score = table.Column<int>(type: "int", nullable: false),
                    Team2Score = table.Column<int>(type: "int", nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false),
                    Type = table.Column<int>(type: "int", nullable: false),
                    CreatedDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CompletedDate = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Matches", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Matches_662_Members_Team1Player1Id",
                        column: x => x.Team1Player1Id,
                        principalTable: "662_Members",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Matches_662_Members_Team1Player2Id",
                        column: x => x.Team1Player2Id,
                        principalTable: "662_Members",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Matches_662_Members_Team2Player1Id",
                        column: x => x.Team2Player1Id,
                        principalTable: "662_Members",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Matches_662_Members_Team2Player2Id",
                        column: x => x.Team2Player2Id,
                        principalTable: "662_Members",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Matches_Courts_CourtId",
                        column: x => x.CourtId,
                        principalTable: "Courts",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "TournamentMatches",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    TournamentId = table.Column<int>(type: "int", nullable: false),
                    Round = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    MatchOrder = table.Column<int>(type: "int", nullable: false),
                    Team1Player1Id = table.Column<string>(type: "nvarchar(450)", nullable: true),
                    Team1Player2Id = table.Column<string>(type: "nvarchar(450)", nullable: true),
                    Team2Player1Id = table.Column<string>(type: "nvarchar(450)", nullable: true),
                    Team2Player2Id = table.Column<string>(type: "nvarchar(450)", nullable: true),
                    Team1Score = table.Column<int>(type: "int", nullable: false),
                    Team2Score = table.Column<int>(type: "int", nullable: false),
                    Winner = table.Column<int>(type: "int", nullable: false),
                    ScheduledTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CourtId = table.Column<int>(type: "int", nullable: true),
                    Status = table.Column<int>(type: "int", nullable: false),
                    CreatedDate = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TournamentMatches", x => x.Id);
                    table.ForeignKey(
                        name: "FK_TournamentMatches_662_Members_Team1Player1Id",
                        column: x => x.Team1Player1Id,
                        principalTable: "662_Members",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_TournamentMatches_662_Members_Team1Player2Id",
                        column: x => x.Team1Player2Id,
                        principalTable: "662_Members",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_TournamentMatches_662_Members_Team2Player1Id",
                        column: x => x.Team2Player1Id,
                        principalTable: "662_Members",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_TournamentMatches_662_Members_Team2Player2Id",
                        column: x => x.Team2Player2Id,
                        principalTable: "662_Members",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_TournamentMatches_Courts_CourtId",
                        column: x => x.CourtId,
                        principalTable: "Courts",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_TournamentMatches_Tournaments_TournamentId",
                        column: x => x.TournamentId,
                        principalTable: "Tournaments",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Duels_ChallengerId",
                table: "Duels",
                column: "ChallengerId");

            migrationBuilder.CreateIndex(
                name: "IX_Duels_ChallengerPartnerId",
                table: "Duels",
                column: "ChallengerPartnerId");

            migrationBuilder.CreateIndex(
                name: "IX_Duels_CourtId",
                table: "Duels",
                column: "CourtId");

            migrationBuilder.CreateIndex(
                name: "IX_Duels_OpponentId",
                table: "Duels",
                column: "OpponentId");

            migrationBuilder.CreateIndex(
                name: "IX_Duels_OpponentPartnerId",
                table: "Duels",
                column: "OpponentPartnerId");

            migrationBuilder.CreateIndex(
                name: "IX_Matches_CourtId",
                table: "Matches",
                column: "CourtId");

            migrationBuilder.CreateIndex(
                name: "IX_Matches_Team1Player1Id",
                table: "Matches",
                column: "Team1Player1Id");

            migrationBuilder.CreateIndex(
                name: "IX_Matches_Team1Player2Id",
                table: "Matches",
                column: "Team1Player2Id");

            migrationBuilder.CreateIndex(
                name: "IX_Matches_Team2Player1Id",
                table: "Matches",
                column: "Team2Player1Id");

            migrationBuilder.CreateIndex(
                name: "IX_Matches_Team2Player2Id",
                table: "Matches",
                column: "Team2Player2Id");

            migrationBuilder.CreateIndex(
                name: "IX_TournamentMatches_CourtId",
                table: "TournamentMatches",
                column: "CourtId");

            migrationBuilder.CreateIndex(
                name: "IX_TournamentMatches_Team1Player1Id",
                table: "TournamentMatches",
                column: "Team1Player1Id");

            migrationBuilder.CreateIndex(
                name: "IX_TournamentMatches_Team1Player2Id",
                table: "TournamentMatches",
                column: "Team1Player2Id");

            migrationBuilder.CreateIndex(
                name: "IX_TournamentMatches_Team2Player1Id",
                table: "TournamentMatches",
                column: "Team2Player1Id");

            migrationBuilder.CreateIndex(
                name: "IX_TournamentMatches_Team2Player2Id",
                table: "TournamentMatches",
                column: "Team2Player2Id");

            migrationBuilder.CreateIndex(
                name: "IX_TournamentMatches_TournamentId",
                table: "TournamentMatches",
                column: "TournamentId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Duels");

            migrationBuilder.DropTable(
                name: "Matches");

            migrationBuilder.DropTable(
                name: "TournamentMatches");

            migrationBuilder.DropColumn(
                name: "Format",
                table: "Tournaments");

            migrationBuilder.DropColumn(
                name: "GroupCount",
                table: "Tournaments");

            migrationBuilder.DropColumn(
                name: "HasGroupStage",
                table: "Tournaments");

            migrationBuilder.DropColumn(
                name: "Prize1stPercent",
                table: "Tournaments");

            migrationBuilder.DropColumn(
                name: "Prize2ndPercent",
                table: "Tournaments");

            migrationBuilder.DropColumn(
                name: "Prize3rdPercent",
                table: "Tournaments");

            migrationBuilder.DropColumn(
                name: "HoldExpiry",
                table: "Bookings");
        }
    }
}

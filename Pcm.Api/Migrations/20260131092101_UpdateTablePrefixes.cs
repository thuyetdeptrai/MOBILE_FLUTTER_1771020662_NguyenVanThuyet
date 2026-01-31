using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Pcm.Api.Migrations
{
    /// <inheritdoc />
    public partial class UpdateTablePrefixes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Bookings_662_Members_MemberId",
                table: "Bookings");

            migrationBuilder.DropForeignKey(
                name: "FK_Bookings_Courts_CourtId",
                table: "Bookings");

            migrationBuilder.DropForeignKey(
                name: "FK_Duels_662_Members_ChallengerId",
                table: "Duels");

            migrationBuilder.DropForeignKey(
                name: "FK_Duels_662_Members_ChallengerPartnerId",
                table: "Duels");

            migrationBuilder.DropForeignKey(
                name: "FK_Duels_662_Members_OpponentId",
                table: "Duels");

            migrationBuilder.DropForeignKey(
                name: "FK_Duels_662_Members_OpponentPartnerId",
                table: "Duels");

            migrationBuilder.DropForeignKey(
                name: "FK_Duels_Courts_CourtId",
                table: "Duels");

            migrationBuilder.DropForeignKey(
                name: "FK_Matches_662_Members_Team1Player1Id",
                table: "Matches");

            migrationBuilder.DropForeignKey(
                name: "FK_Matches_662_Members_Team1Player2Id",
                table: "Matches");

            migrationBuilder.DropForeignKey(
                name: "FK_Matches_662_Members_Team2Player1Id",
                table: "Matches");

            migrationBuilder.DropForeignKey(
                name: "FK_Matches_662_Members_Team2Player2Id",
                table: "Matches");

            migrationBuilder.DropForeignKey(
                name: "FK_Matches_Courts_CourtId",
                table: "Matches");

            migrationBuilder.DropForeignKey(
                name: "FK_News_662_Members_AuthorId",
                table: "News");

            migrationBuilder.DropForeignKey(
                name: "FK_Notifications_662_Members_MemberId",
                table: "Notifications");

            migrationBuilder.DropForeignKey(
                name: "FK_RoleClaims_Roles_RoleId",
                table: "RoleClaims");

            migrationBuilder.DropForeignKey(
                name: "FK_TournamentMatches_662_Members_Team1Player1Id",
                table: "TournamentMatches");

            migrationBuilder.DropForeignKey(
                name: "FK_TournamentMatches_662_Members_Team1Player2Id",
                table: "TournamentMatches");

            migrationBuilder.DropForeignKey(
                name: "FK_TournamentMatches_662_Members_Team2Player1Id",
                table: "TournamentMatches");

            migrationBuilder.DropForeignKey(
                name: "FK_TournamentMatches_662_Members_Team2Player2Id",
                table: "TournamentMatches");

            migrationBuilder.DropForeignKey(
                name: "FK_TournamentMatches_Courts_CourtId",
                table: "TournamentMatches");

            migrationBuilder.DropForeignKey(
                name: "FK_TournamentMatches_Tournaments_TournamentId",
                table: "TournamentMatches");

            migrationBuilder.DropForeignKey(
                name: "FK_TournamentParticipants_662_Members_MemberId",
                table: "TournamentParticipants");

            migrationBuilder.DropForeignKey(
                name: "FK_TournamentParticipants_Tournaments_TournamentId",
                table: "TournamentParticipants");

            migrationBuilder.DropForeignKey(
                name: "FK_UserClaims_662_Members_UserId",
                table: "UserClaims");

            migrationBuilder.DropForeignKey(
                name: "FK_UserLogins_662_Members_UserId",
                table: "UserLogins");

            migrationBuilder.DropForeignKey(
                name: "FK_UserRoles_662_Members_UserId",
                table: "UserRoles");

            migrationBuilder.DropForeignKey(
                name: "FK_UserRoles_Roles_RoleId",
                table: "UserRoles");

            migrationBuilder.DropForeignKey(
                name: "FK_UserTokens_662_Members_UserId",
                table: "UserTokens");

            migrationBuilder.DropPrimaryKey(
                name: "PK_WalletTransactions",
                table: "WalletTransactions");

            migrationBuilder.DropPrimaryKey(
                name: "PK_UserTokens",
                table: "UserTokens");

            migrationBuilder.DropPrimaryKey(
                name: "PK_UserRoles",
                table: "UserRoles");

            migrationBuilder.DropPrimaryKey(
                name: "PK_UserLogins",
                table: "UserLogins");

            migrationBuilder.DropPrimaryKey(
                name: "PK_UserClaims",
                table: "UserClaims");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Tournaments",
                table: "Tournaments");

            migrationBuilder.DropPrimaryKey(
                name: "PK_TournamentParticipants",
                table: "TournamentParticipants");

            migrationBuilder.DropPrimaryKey(
                name: "PK_TournamentMatches",
                table: "TournamentMatches");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Roles",
                table: "Roles");

            migrationBuilder.DropPrimaryKey(
                name: "PK_RoleClaims",
                table: "RoleClaims");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Notifications",
                table: "Notifications");

            migrationBuilder.DropPrimaryKey(
                name: "PK_News",
                table: "News");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Matches",
                table: "Matches");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Duels",
                table: "Duels");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Courts",
                table: "Courts");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Bookings",
                table: "Bookings");

            migrationBuilder.RenameTable(
                name: "WalletTransactions",
                newName: "662_WalletTransactions");

            migrationBuilder.RenameTable(
                name: "UserTokens",
                newName: "662_UserTokens");

            migrationBuilder.RenameTable(
                name: "UserRoles",
                newName: "662_UserRoles");

            migrationBuilder.RenameTable(
                name: "UserLogins",
                newName: "662_UserLogins");

            migrationBuilder.RenameTable(
                name: "UserClaims",
                newName: "662_UserClaims");

            migrationBuilder.RenameTable(
                name: "Tournaments",
                newName: "662_Tournaments");

            migrationBuilder.RenameTable(
                name: "TournamentParticipants",
                newName: "662_TournamentParticipants");

            migrationBuilder.RenameTable(
                name: "TournamentMatches",
                newName: "662_TournamentMatches");

            migrationBuilder.RenameTable(
                name: "Roles",
                newName: "662_Roles");

            migrationBuilder.RenameTable(
                name: "RoleClaims",
                newName: "662_RoleClaims");

            migrationBuilder.RenameTable(
                name: "Notifications",
                newName: "662_Notifications");

            migrationBuilder.RenameTable(
                name: "News",
                newName: "662_News");

            migrationBuilder.RenameTable(
                name: "Matches",
                newName: "662_Matches");

            migrationBuilder.RenameTable(
                name: "Duels",
                newName: "662_Duels");

            migrationBuilder.RenameTable(
                name: "Courts",
                newName: "662_Courts");

            migrationBuilder.RenameTable(
                name: "Bookings",
                newName: "662_Bookings");

            migrationBuilder.RenameIndex(
                name: "IX_UserRoles_RoleId",
                table: "662_UserRoles",
                newName: "IX_662_UserRoles_RoleId");

            migrationBuilder.RenameIndex(
                name: "IX_UserLogins_UserId",
                table: "662_UserLogins",
                newName: "IX_662_UserLogins_UserId");

            migrationBuilder.RenameIndex(
                name: "IX_UserClaims_UserId",
                table: "662_UserClaims",
                newName: "IX_662_UserClaims_UserId");

            migrationBuilder.RenameIndex(
                name: "IX_TournamentParticipants_TournamentId",
                table: "662_TournamentParticipants",
                newName: "IX_662_TournamentParticipants_TournamentId");

            migrationBuilder.RenameIndex(
                name: "IX_TournamentParticipants_MemberId",
                table: "662_TournamentParticipants",
                newName: "IX_662_TournamentParticipants_MemberId");

            migrationBuilder.RenameIndex(
                name: "IX_TournamentMatches_TournamentId",
                table: "662_TournamentMatches",
                newName: "IX_662_TournamentMatches_TournamentId");

            migrationBuilder.RenameIndex(
                name: "IX_TournamentMatches_Team2Player2Id",
                table: "662_TournamentMatches",
                newName: "IX_662_TournamentMatches_Team2Player2Id");

            migrationBuilder.RenameIndex(
                name: "IX_TournamentMatches_Team2Player1Id",
                table: "662_TournamentMatches",
                newName: "IX_662_TournamentMatches_Team2Player1Id");

            migrationBuilder.RenameIndex(
                name: "IX_TournamentMatches_Team1Player2Id",
                table: "662_TournamentMatches",
                newName: "IX_662_TournamentMatches_Team1Player2Id");

            migrationBuilder.RenameIndex(
                name: "IX_TournamentMatches_Team1Player1Id",
                table: "662_TournamentMatches",
                newName: "IX_662_TournamentMatches_Team1Player1Id");

            migrationBuilder.RenameIndex(
                name: "IX_TournamentMatches_CourtId",
                table: "662_TournamentMatches",
                newName: "IX_662_TournamentMatches_CourtId");

            migrationBuilder.RenameIndex(
                name: "IX_RoleClaims_RoleId",
                table: "662_RoleClaims",
                newName: "IX_662_RoleClaims_RoleId");

            migrationBuilder.RenameIndex(
                name: "IX_Notifications_MemberId",
                table: "662_Notifications",
                newName: "IX_662_Notifications_MemberId");

            migrationBuilder.RenameIndex(
                name: "IX_News_AuthorId",
                table: "662_News",
                newName: "IX_662_News_AuthorId");

            migrationBuilder.RenameIndex(
                name: "IX_Matches_Team2Player2Id",
                table: "662_Matches",
                newName: "IX_662_Matches_Team2Player2Id");

            migrationBuilder.RenameIndex(
                name: "IX_Matches_Team2Player1Id",
                table: "662_Matches",
                newName: "IX_662_Matches_Team2Player1Id");

            migrationBuilder.RenameIndex(
                name: "IX_Matches_Team1Player2Id",
                table: "662_Matches",
                newName: "IX_662_Matches_Team1Player2Id");

            migrationBuilder.RenameIndex(
                name: "IX_Matches_Team1Player1Id",
                table: "662_Matches",
                newName: "IX_662_Matches_Team1Player1Id");

            migrationBuilder.RenameIndex(
                name: "IX_Matches_CourtId",
                table: "662_Matches",
                newName: "IX_662_Matches_CourtId");

            migrationBuilder.RenameIndex(
                name: "IX_Duels_OpponentPartnerId",
                table: "662_Duels",
                newName: "IX_662_Duels_OpponentPartnerId");

            migrationBuilder.RenameIndex(
                name: "IX_Duels_OpponentId",
                table: "662_Duels",
                newName: "IX_662_Duels_OpponentId");

            migrationBuilder.RenameIndex(
                name: "IX_Duels_CourtId",
                table: "662_Duels",
                newName: "IX_662_Duels_CourtId");

            migrationBuilder.RenameIndex(
                name: "IX_Duels_ChallengerPartnerId",
                table: "662_Duels",
                newName: "IX_662_Duels_ChallengerPartnerId");

            migrationBuilder.RenameIndex(
                name: "IX_Duels_ChallengerId",
                table: "662_Duels",
                newName: "IX_662_Duels_ChallengerId");

            migrationBuilder.RenameIndex(
                name: "IX_Bookings_MemberId",
                table: "662_Bookings",
                newName: "IX_662_Bookings_MemberId");

            migrationBuilder.RenameIndex(
                name: "IX_Bookings_CourtId",
                table: "662_Bookings",
                newName: "IX_662_Bookings_CourtId");

            migrationBuilder.AddColumn<string>(
                name: "RelatedId",
                table: "662_WalletTransactions",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Settings",
                table: "662_Tournaments",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Details",
                table: "662_TournamentMatches",
                type: "nvarchar(max)",
                nullable: true);

            // Clean up old data before converting type
            migrationBuilder.Sql("DELETE FROM [662_Notifications]");

            migrationBuilder.AlterColumn<int>(
                name: "Type",
                table: "662_Notifications",
                type: "int",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)");

            migrationBuilder.AddColumn<string>(
                name: "LinkUrl",
                table: "662_Notifications",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Details",
                table: "662_Matches",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsRanked",
                table: "662_Matches",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<int>(
                name: "ParentBookingId",
                table: "662_Bookings",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "RecurrenceRule",
                table: "662_Bookings",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddPrimaryKey(
                name: "PK_662_WalletTransactions",
                table: "662_WalletTransactions",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_662_UserTokens",
                table: "662_UserTokens",
                columns: new[] { "UserId", "LoginProvider", "Name" });

            migrationBuilder.AddPrimaryKey(
                name: "PK_662_UserRoles",
                table: "662_UserRoles",
                columns: new[] { "UserId", "RoleId" });

            migrationBuilder.AddPrimaryKey(
                name: "PK_662_UserLogins",
                table: "662_UserLogins",
                columns: new[] { "LoginProvider", "ProviderKey" });

            migrationBuilder.AddPrimaryKey(
                name: "PK_662_UserClaims",
                table: "662_UserClaims",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_662_Tournaments",
                table: "662_Tournaments",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_662_TournamentParticipants",
                table: "662_TournamentParticipants",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_662_TournamentMatches",
                table: "662_TournamentMatches",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_662_Roles",
                table: "662_Roles",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_662_RoleClaims",
                table: "662_RoleClaims",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_662_Notifications",
                table: "662_Notifications",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_662_News",
                table: "662_News",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_662_Matches",
                table: "662_Matches",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_662_Duels",
                table: "662_Duels",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_662_Courts",
                table: "662_Courts",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_662_Bookings",
                table: "662_Bookings",
                column: "Id");

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

            migrationBuilder.AddForeignKey(
                name: "FK_662_Duels_662_Courts_CourtId",
                table: "662_Duels",
                column: "CourtId",
                principalTable: "662_Courts",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_662_Duels_662_Members_ChallengerId",
                table: "662_Duels",
                column: "ChallengerId",
                principalTable: "662_Members",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_662_Duels_662_Members_ChallengerPartnerId",
                table: "662_Duels",
                column: "ChallengerPartnerId",
                principalTable: "662_Members",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_662_Duels_662_Members_OpponentId",
                table: "662_Duels",
                column: "OpponentId",
                principalTable: "662_Members",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_662_Duels_662_Members_OpponentPartnerId",
                table: "662_Duels",
                column: "OpponentPartnerId",
                principalTable: "662_Members",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_662_Matches_662_Courts_CourtId",
                table: "662_Matches",
                column: "CourtId",
                principalTable: "662_Courts",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_662_Matches_662_Members_Team1Player1Id",
                table: "662_Matches",
                column: "Team1Player1Id",
                principalTable: "662_Members",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_662_Matches_662_Members_Team1Player2Id",
                table: "662_Matches",
                column: "Team1Player2Id",
                principalTable: "662_Members",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_662_Matches_662_Members_Team2Player1Id",
                table: "662_Matches",
                column: "Team2Player1Id",
                principalTable: "662_Members",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_662_Matches_662_Members_Team2Player2Id",
                table: "662_Matches",
                column: "Team2Player2Id",
                principalTable: "662_Members",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_662_News_662_Members_AuthorId",
                table: "662_News",
                column: "AuthorId",
                principalTable: "662_Members",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_662_Notifications_662_Members_MemberId",
                table: "662_Notifications",
                column: "MemberId",
                principalTable: "662_Members",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_662_RoleClaims_662_Roles_RoleId",
                table: "662_RoleClaims",
                column: "RoleId",
                principalTable: "662_Roles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_662_TournamentMatches_662_Courts_CourtId",
                table: "662_TournamentMatches",
                column: "CourtId",
                principalTable: "662_Courts",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_662_TournamentMatches_662_Members_Team1Player1Id",
                table: "662_TournamentMatches",
                column: "Team1Player1Id",
                principalTable: "662_Members",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_662_TournamentMatches_662_Members_Team1Player2Id",
                table: "662_TournamentMatches",
                column: "Team1Player2Id",
                principalTable: "662_Members",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_662_TournamentMatches_662_Members_Team2Player1Id",
                table: "662_TournamentMatches",
                column: "Team2Player1Id",
                principalTable: "662_Members",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_662_TournamentMatches_662_Members_Team2Player2Id",
                table: "662_TournamentMatches",
                column: "Team2Player2Id",
                principalTable: "662_Members",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_662_TournamentMatches_662_Tournaments_TournamentId",
                table: "662_TournamentMatches",
                column: "TournamentId",
                principalTable: "662_Tournaments",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_662_TournamentParticipants_662_Members_MemberId",
                table: "662_TournamentParticipants",
                column: "MemberId",
                principalTable: "662_Members",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_662_TournamentParticipants_662_Tournaments_TournamentId",
                table: "662_TournamentParticipants",
                column: "TournamentId",
                principalTable: "662_Tournaments",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_662_UserClaims_662_Members_UserId",
                table: "662_UserClaims",
                column: "UserId",
                principalTable: "662_Members",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_662_UserLogins_662_Members_UserId",
                table: "662_UserLogins",
                column: "UserId",
                principalTable: "662_Members",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_662_UserRoles_662_Members_UserId",
                table: "662_UserRoles",
                column: "UserId",
                principalTable: "662_Members",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_662_UserRoles_662_Roles_RoleId",
                table: "662_UserRoles",
                column: "RoleId",
                principalTable: "662_Roles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_662_UserTokens_662_Members_UserId",
                table: "662_UserTokens",
                column: "UserId",
                principalTable: "662_Members",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_662_Bookings_662_Courts_CourtId",
                table: "662_Bookings");

            migrationBuilder.DropForeignKey(
                name: "FK_662_Bookings_662_Members_MemberId",
                table: "662_Bookings");

            migrationBuilder.DropForeignKey(
                name: "FK_662_Duels_662_Courts_CourtId",
                table: "662_Duels");

            migrationBuilder.DropForeignKey(
                name: "FK_662_Duels_662_Members_ChallengerId",
                table: "662_Duels");

            migrationBuilder.DropForeignKey(
                name: "FK_662_Duels_662_Members_ChallengerPartnerId",
                table: "662_Duels");

            migrationBuilder.DropForeignKey(
                name: "FK_662_Duels_662_Members_OpponentId",
                table: "662_Duels");

            migrationBuilder.DropForeignKey(
                name: "FK_662_Duels_662_Members_OpponentPartnerId",
                table: "662_Duels");

            migrationBuilder.DropForeignKey(
                name: "FK_662_Matches_662_Courts_CourtId",
                table: "662_Matches");

            migrationBuilder.DropForeignKey(
                name: "FK_662_Matches_662_Members_Team1Player1Id",
                table: "662_Matches");

            migrationBuilder.DropForeignKey(
                name: "FK_662_Matches_662_Members_Team1Player2Id",
                table: "662_Matches");

            migrationBuilder.DropForeignKey(
                name: "FK_662_Matches_662_Members_Team2Player1Id",
                table: "662_Matches");

            migrationBuilder.DropForeignKey(
                name: "FK_662_Matches_662_Members_Team2Player2Id",
                table: "662_Matches");

            migrationBuilder.DropForeignKey(
                name: "FK_662_News_662_Members_AuthorId",
                table: "662_News");

            migrationBuilder.DropForeignKey(
                name: "FK_662_Notifications_662_Members_MemberId",
                table: "662_Notifications");

            migrationBuilder.DropForeignKey(
                name: "FK_662_RoleClaims_662_Roles_RoleId",
                table: "662_RoleClaims");

            migrationBuilder.DropForeignKey(
                name: "FK_662_TournamentMatches_662_Courts_CourtId",
                table: "662_TournamentMatches");

            migrationBuilder.DropForeignKey(
                name: "FK_662_TournamentMatches_662_Members_Team1Player1Id",
                table: "662_TournamentMatches");

            migrationBuilder.DropForeignKey(
                name: "FK_662_TournamentMatches_662_Members_Team1Player2Id",
                table: "662_TournamentMatches");

            migrationBuilder.DropForeignKey(
                name: "FK_662_TournamentMatches_662_Members_Team2Player1Id",
                table: "662_TournamentMatches");

            migrationBuilder.DropForeignKey(
                name: "FK_662_TournamentMatches_662_Members_Team2Player2Id",
                table: "662_TournamentMatches");

            migrationBuilder.DropForeignKey(
                name: "FK_662_TournamentMatches_662_Tournaments_TournamentId",
                table: "662_TournamentMatches");

            migrationBuilder.DropForeignKey(
                name: "FK_662_TournamentParticipants_662_Members_MemberId",
                table: "662_TournamentParticipants");

            migrationBuilder.DropForeignKey(
                name: "FK_662_TournamentParticipants_662_Tournaments_TournamentId",
                table: "662_TournamentParticipants");

            migrationBuilder.DropForeignKey(
                name: "FK_662_UserClaims_662_Members_UserId",
                table: "662_UserClaims");

            migrationBuilder.DropForeignKey(
                name: "FK_662_UserLogins_662_Members_UserId",
                table: "662_UserLogins");

            migrationBuilder.DropForeignKey(
                name: "FK_662_UserRoles_662_Members_UserId",
                table: "662_UserRoles");

            migrationBuilder.DropForeignKey(
                name: "FK_662_UserRoles_662_Roles_RoleId",
                table: "662_UserRoles");

            migrationBuilder.DropForeignKey(
                name: "FK_662_UserTokens_662_Members_UserId",
                table: "662_UserTokens");

            migrationBuilder.DropPrimaryKey(
                name: "PK_662_WalletTransactions",
                table: "662_WalletTransactions");

            migrationBuilder.DropPrimaryKey(
                name: "PK_662_UserTokens",
                table: "662_UserTokens");

            migrationBuilder.DropPrimaryKey(
                name: "PK_662_UserRoles",
                table: "662_UserRoles");

            migrationBuilder.DropPrimaryKey(
                name: "PK_662_UserLogins",
                table: "662_UserLogins");

            migrationBuilder.DropPrimaryKey(
                name: "PK_662_UserClaims",
                table: "662_UserClaims");

            migrationBuilder.DropPrimaryKey(
                name: "PK_662_Tournaments",
                table: "662_Tournaments");

            migrationBuilder.DropPrimaryKey(
                name: "PK_662_TournamentParticipants",
                table: "662_TournamentParticipants");

            migrationBuilder.DropPrimaryKey(
                name: "PK_662_TournamentMatches",
                table: "662_TournamentMatches");

            migrationBuilder.DropPrimaryKey(
                name: "PK_662_Roles",
                table: "662_Roles");

            migrationBuilder.DropPrimaryKey(
                name: "PK_662_RoleClaims",
                table: "662_RoleClaims");

            migrationBuilder.DropPrimaryKey(
                name: "PK_662_Notifications",
                table: "662_Notifications");

            migrationBuilder.DropPrimaryKey(
                name: "PK_662_News",
                table: "662_News");

            migrationBuilder.DropPrimaryKey(
                name: "PK_662_Matches",
                table: "662_Matches");

            migrationBuilder.DropPrimaryKey(
                name: "PK_662_Duels",
                table: "662_Duels");

            migrationBuilder.DropPrimaryKey(
                name: "PK_662_Courts",
                table: "662_Courts");

            migrationBuilder.DropPrimaryKey(
                name: "PK_662_Bookings",
                table: "662_Bookings");

            migrationBuilder.DropColumn(
                name: "RelatedId",
                table: "662_WalletTransactions");

            migrationBuilder.DropColumn(
                name: "Settings",
                table: "662_Tournaments");

            migrationBuilder.DropColumn(
                name: "Details",
                table: "662_TournamentMatches");

            migrationBuilder.DropColumn(
                name: "LinkUrl",
                table: "662_Notifications");

            migrationBuilder.DropColumn(
                name: "Details",
                table: "662_Matches");

            migrationBuilder.DropColumn(
                name: "IsRanked",
                table: "662_Matches");

            migrationBuilder.DropColumn(
                name: "ParentBookingId",
                table: "662_Bookings");

            migrationBuilder.DropColumn(
                name: "RecurrenceRule",
                table: "662_Bookings");

            migrationBuilder.RenameTable(
                name: "662_WalletTransactions",
                newName: "WalletTransactions");

            migrationBuilder.RenameTable(
                name: "662_UserTokens",
                newName: "UserTokens");

            migrationBuilder.RenameTable(
                name: "662_UserRoles",
                newName: "UserRoles");

            migrationBuilder.RenameTable(
                name: "662_UserLogins",
                newName: "UserLogins");

            migrationBuilder.RenameTable(
                name: "662_UserClaims",
                newName: "UserClaims");

            migrationBuilder.RenameTable(
                name: "662_Tournaments",
                newName: "Tournaments");

            migrationBuilder.RenameTable(
                name: "662_TournamentParticipants",
                newName: "TournamentParticipants");

            migrationBuilder.RenameTable(
                name: "662_TournamentMatches",
                newName: "TournamentMatches");

            migrationBuilder.RenameTable(
                name: "662_Roles",
                newName: "Roles");

            migrationBuilder.RenameTable(
                name: "662_RoleClaims",
                newName: "RoleClaims");

            migrationBuilder.RenameTable(
                name: "662_Notifications",
                newName: "Notifications");

            migrationBuilder.RenameTable(
                name: "662_News",
                newName: "News");

            migrationBuilder.RenameTable(
                name: "662_Matches",
                newName: "Matches");

            migrationBuilder.RenameTable(
                name: "662_Duels",
                newName: "Duels");

            migrationBuilder.RenameTable(
                name: "662_Courts",
                newName: "Courts");

            migrationBuilder.RenameTable(
                name: "662_Bookings",
                newName: "Bookings");

            migrationBuilder.RenameIndex(
                name: "IX_662_UserRoles_RoleId",
                table: "UserRoles",
                newName: "IX_UserRoles_RoleId");

            migrationBuilder.RenameIndex(
                name: "IX_662_UserLogins_UserId",
                table: "UserLogins",
                newName: "IX_UserLogins_UserId");

            migrationBuilder.RenameIndex(
                name: "IX_662_UserClaims_UserId",
                table: "UserClaims",
                newName: "IX_UserClaims_UserId");

            migrationBuilder.RenameIndex(
                name: "IX_662_TournamentParticipants_TournamentId",
                table: "TournamentParticipants",
                newName: "IX_TournamentParticipants_TournamentId");

            migrationBuilder.RenameIndex(
                name: "IX_662_TournamentParticipants_MemberId",
                table: "TournamentParticipants",
                newName: "IX_TournamentParticipants_MemberId");

            migrationBuilder.RenameIndex(
                name: "IX_662_TournamentMatches_TournamentId",
                table: "TournamentMatches",
                newName: "IX_TournamentMatches_TournamentId");

            migrationBuilder.RenameIndex(
                name: "IX_662_TournamentMatches_Team2Player2Id",
                table: "TournamentMatches",
                newName: "IX_TournamentMatches_Team2Player2Id");

            migrationBuilder.RenameIndex(
                name: "IX_662_TournamentMatches_Team2Player1Id",
                table: "TournamentMatches",
                newName: "IX_TournamentMatches_Team2Player1Id");

            migrationBuilder.RenameIndex(
                name: "IX_662_TournamentMatches_Team1Player2Id",
                table: "TournamentMatches",
                newName: "IX_TournamentMatches_Team1Player2Id");

            migrationBuilder.RenameIndex(
                name: "IX_662_TournamentMatches_Team1Player1Id",
                table: "TournamentMatches",
                newName: "IX_TournamentMatches_Team1Player1Id");

            migrationBuilder.RenameIndex(
                name: "IX_662_TournamentMatches_CourtId",
                table: "TournamentMatches",
                newName: "IX_TournamentMatches_CourtId");

            migrationBuilder.RenameIndex(
                name: "IX_662_RoleClaims_RoleId",
                table: "RoleClaims",
                newName: "IX_RoleClaims_RoleId");

            migrationBuilder.RenameIndex(
                name: "IX_662_Notifications_MemberId",
                table: "Notifications",
                newName: "IX_Notifications_MemberId");

            migrationBuilder.RenameIndex(
                name: "IX_662_News_AuthorId",
                table: "News",
                newName: "IX_News_AuthorId");

            migrationBuilder.RenameIndex(
                name: "IX_662_Matches_Team2Player2Id",
                table: "Matches",
                newName: "IX_Matches_Team2Player2Id");

            migrationBuilder.RenameIndex(
                name: "IX_662_Matches_Team2Player1Id",
                table: "Matches",
                newName: "IX_Matches_Team2Player1Id");

            migrationBuilder.RenameIndex(
                name: "IX_662_Matches_Team1Player2Id",
                table: "Matches",
                newName: "IX_Matches_Team1Player2Id");

            migrationBuilder.RenameIndex(
                name: "IX_662_Matches_Team1Player1Id",
                table: "Matches",
                newName: "IX_Matches_Team1Player1Id");

            migrationBuilder.RenameIndex(
                name: "IX_662_Matches_CourtId",
                table: "Matches",
                newName: "IX_Matches_CourtId");

            migrationBuilder.RenameIndex(
                name: "IX_662_Duels_OpponentPartnerId",
                table: "Duels",
                newName: "IX_Duels_OpponentPartnerId");

            migrationBuilder.RenameIndex(
                name: "IX_662_Duels_OpponentId",
                table: "Duels",
                newName: "IX_Duels_OpponentId");

            migrationBuilder.RenameIndex(
                name: "IX_662_Duels_CourtId",
                table: "Duels",
                newName: "IX_Duels_CourtId");

            migrationBuilder.RenameIndex(
                name: "IX_662_Duels_ChallengerPartnerId",
                table: "Duels",
                newName: "IX_Duels_ChallengerPartnerId");

            migrationBuilder.RenameIndex(
                name: "IX_662_Duels_ChallengerId",
                table: "Duels",
                newName: "IX_Duels_ChallengerId");

            migrationBuilder.RenameIndex(
                name: "IX_662_Bookings_MemberId",
                table: "Bookings",
                newName: "IX_Bookings_MemberId");

            migrationBuilder.RenameIndex(
                name: "IX_662_Bookings_CourtId",
                table: "Bookings",
                newName: "IX_Bookings_CourtId");

            migrationBuilder.AlterColumn<string>(
                name: "Type",
                table: "Notifications",
                type: "nvarchar(max)",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AddPrimaryKey(
                name: "PK_WalletTransactions",
                table: "WalletTransactions",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_UserTokens",
                table: "UserTokens",
                columns: new[] { "UserId", "LoginProvider", "Name" });

            migrationBuilder.AddPrimaryKey(
                name: "PK_UserRoles",
                table: "UserRoles",
                columns: new[] { "UserId", "RoleId" });

            migrationBuilder.AddPrimaryKey(
                name: "PK_UserLogins",
                table: "UserLogins",
                columns: new[] { "LoginProvider", "ProviderKey" });

            migrationBuilder.AddPrimaryKey(
                name: "PK_UserClaims",
                table: "UserClaims",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Tournaments",
                table: "Tournaments",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_TournamentParticipants",
                table: "TournamentParticipants",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_TournamentMatches",
                table: "TournamentMatches",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Roles",
                table: "Roles",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_RoleClaims",
                table: "RoleClaims",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Notifications",
                table: "Notifications",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_News",
                table: "News",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Matches",
                table: "Matches",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Duels",
                table: "Duels",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Courts",
                table: "Courts",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Bookings",
                table: "Bookings",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Bookings_662_Members_MemberId",
                table: "Bookings",
                column: "MemberId",
                principalTable: "662_Members",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Bookings_Courts_CourtId",
                table: "Bookings",
                column: "CourtId",
                principalTable: "Courts",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Duels_662_Members_ChallengerId",
                table: "Duels",
                column: "ChallengerId",
                principalTable: "662_Members",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Duels_662_Members_ChallengerPartnerId",
                table: "Duels",
                column: "ChallengerPartnerId",
                principalTable: "662_Members",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Duels_662_Members_OpponentId",
                table: "Duels",
                column: "OpponentId",
                principalTable: "662_Members",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Duels_662_Members_OpponentPartnerId",
                table: "Duels",
                column: "OpponentPartnerId",
                principalTable: "662_Members",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Duels_Courts_CourtId",
                table: "Duels",
                column: "CourtId",
                principalTable: "Courts",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Matches_662_Members_Team1Player1Id",
                table: "Matches",
                column: "Team1Player1Id",
                principalTable: "662_Members",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Matches_662_Members_Team1Player2Id",
                table: "Matches",
                column: "Team1Player2Id",
                principalTable: "662_Members",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Matches_662_Members_Team2Player1Id",
                table: "Matches",
                column: "Team2Player1Id",
                principalTable: "662_Members",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Matches_662_Members_Team2Player2Id",
                table: "Matches",
                column: "Team2Player2Id",
                principalTable: "662_Members",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Matches_Courts_CourtId",
                table: "Matches",
                column: "CourtId",
                principalTable: "Courts",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_News_662_Members_AuthorId",
                table: "News",
                column: "AuthorId",
                principalTable: "662_Members",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Notifications_662_Members_MemberId",
                table: "Notifications",
                column: "MemberId",
                principalTable: "662_Members",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_RoleClaims_Roles_RoleId",
                table: "RoleClaims",
                column: "RoleId",
                principalTable: "Roles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_TournamentMatches_662_Members_Team1Player1Id",
                table: "TournamentMatches",
                column: "Team1Player1Id",
                principalTable: "662_Members",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_TournamentMatches_662_Members_Team1Player2Id",
                table: "TournamentMatches",
                column: "Team1Player2Id",
                principalTable: "662_Members",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_TournamentMatches_662_Members_Team2Player1Id",
                table: "TournamentMatches",
                column: "Team2Player1Id",
                principalTable: "662_Members",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_TournamentMatches_662_Members_Team2Player2Id",
                table: "TournamentMatches",
                column: "Team2Player2Id",
                principalTable: "662_Members",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_TournamentMatches_Courts_CourtId",
                table: "TournamentMatches",
                column: "CourtId",
                principalTable: "Courts",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_TournamentMatches_Tournaments_TournamentId",
                table: "TournamentMatches",
                column: "TournamentId",
                principalTable: "Tournaments",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_TournamentParticipants_662_Members_MemberId",
                table: "TournamentParticipants",
                column: "MemberId",
                principalTable: "662_Members",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_TournamentParticipants_Tournaments_TournamentId",
                table: "TournamentParticipants",
                column: "TournamentId",
                principalTable: "Tournaments",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserClaims_662_Members_UserId",
                table: "UserClaims",
                column: "UserId",
                principalTable: "662_Members",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserLogins_662_Members_UserId",
                table: "UserLogins",
                column: "UserId",
                principalTable: "662_Members",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserRoles_662_Members_UserId",
                table: "UserRoles",
                column: "UserId",
                principalTable: "662_Members",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserRoles_Roles_RoleId",
                table: "UserRoles",
                column: "RoleId",
                principalTable: "Roles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserTokens_662_Members_UserId",
                table: "UserTokens",
                column: "UserId",
                principalTable: "662_Members",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}

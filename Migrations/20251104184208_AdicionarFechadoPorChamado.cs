using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SistemaChamados.Migrations
{
    /// <inheritdoc />
    public partial class AdicionarFechadoPorChamado : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "FechadoPorId",
                table: "Chamados",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Chamados_FechadoPorId",
                table: "Chamados",
                column: "FechadoPorId");

            migrationBuilder.AddForeignKey(
                name: "FK_Chamados_Usuarios_FechadoPorId",
                table: "Chamados",
                column: "FechadoPorId",
                principalTable: "Usuarios",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Chamados_Usuarios_FechadoPorId",
                table: "Chamados");

            migrationBuilder.DropIndex(
                name: "IX_Chamados_FechadoPorId",
                table: "Chamados");

            migrationBuilder.DropColumn(
                name: "FechadoPorId",
                table: "Chamados");
        }
    }
}

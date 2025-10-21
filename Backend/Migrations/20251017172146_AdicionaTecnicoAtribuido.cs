using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SistemaChamados.Migrations
{
    /// <inheritdoc />
    public partial class AdicionaTecnicoAtribuido : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "TecnicoAtribuidoId",
                table: "Chamados",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Usuarios_EspecialidadeCategoriaId",
                table: "Usuarios",
                column: "EspecialidadeCategoriaId");

            migrationBuilder.CreateIndex(
                name: "IX_Chamados_TecnicoAtribuidoId",
                table: "Chamados",
                column: "TecnicoAtribuidoId");

            migrationBuilder.AddForeignKey(
                name: "FK_Chamados_Usuarios_TecnicoAtribuidoId",
                table: "Chamados",
                column: "TecnicoAtribuidoId",
                principalTable: "Usuarios",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Usuarios_Categorias_EspecialidadeCategoriaId",
                table: "Usuarios",
                column: "EspecialidadeCategoriaId",
                principalTable: "Categorias",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Chamados_Usuarios_TecnicoAtribuidoId",
                table: "Chamados");

            migrationBuilder.DropForeignKey(
                name: "FK_Usuarios_Categorias_EspecialidadeCategoriaId",
                table: "Usuarios");

            migrationBuilder.DropIndex(
                name: "IX_Usuarios_EspecialidadeCategoriaId",
                table: "Usuarios");

            migrationBuilder.DropIndex(
                name: "IX_Chamados_TecnicoAtribuidoId",
                table: "Chamados");

            migrationBuilder.DropColumn(
                name: "TecnicoAtribuidoId",
                table: "Chamados");
        }
    }
}

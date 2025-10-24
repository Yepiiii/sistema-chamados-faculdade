using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SistemaChamados.Migrations
{
    /// <inheritdoc />
    public partial class IntelligentAssignmentSystem : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // TecnicoTIPerfilId já foi removido, não precisa fazer DROP
            
            migrationBuilder.CreateTable(
                name: "AtribuicoesLog",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ChamadoId = table.Column<int>(type: "int", nullable: false),
                    TecnicoId = table.Column<int>(type: "int", nullable: false),
                    DataAtribuicao = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()"),
                    Score = table.Column<double>(type: "float", nullable: false),
                    MetodoAtribuicao = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    MotivoSelecao = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    CargaTrabalho = table.Column<int>(type: "int", nullable: false),
                    FallbackGenerico = table.Column<bool>(type: "bit", nullable: false),
                    DetalhesProcesso = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AtribuicoesLog", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AtribuicoesLog_Chamados_ChamadoId",
                        column: x => x.ChamadoId,
                        principalTable: "Chamados",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_AtribuicoesLog_Usuarios_TecnicoId",
                        column: x => x.TecnicoId,
                        principalTable: "Usuarios",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_AtribuicoesLog_ChamadoId",
                table: "AtribuicoesLog",
                column: "ChamadoId");

            migrationBuilder.CreateIndex(
                name: "IX_AtribuicoesLog_TecnicoId",
                table: "AtribuicoesLog",
                column: "TecnicoId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AtribuicoesLog");

            migrationBuilder.AddColumn<int>(
                name: "TecnicoTIPerfilId",
                table: "Chamados",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Chamados_TecnicoTIPerfilId",
                table: "Chamados",
                column: "TecnicoTIPerfilId");

            migrationBuilder.AddForeignKey(
                name: "FK_Chamados_TecnicoTIPerfis_TecnicoTIPerfilId",
                table: "Chamados",
                column: "TecnicoTIPerfilId",
                principalTable: "TecnicoTIPerfis",
                principalColumn: "Id");
        }
    }
}

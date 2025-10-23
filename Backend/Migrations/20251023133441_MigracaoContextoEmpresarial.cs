using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SistemaChamados.Migrations
{
    /// <inheritdoc />
    public partial class MigracaoContextoEmpresarial : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AlunoPerfis");

            migrationBuilder.DropTable(
                name: "ProfessorPerfis");

            migrationBuilder.AddColumn<int>(
                name: "TecnicoTIPerfilId",
                table: "Chamados",
                type: "int",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "ColaboradorPerfis",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UsuarioId = table.Column<int>(type: "int", nullable: false),
                    Matricula = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    Departamento = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    DataAdmissao = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ColaboradorPerfis", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ColaboradorPerfis_Usuarios_UsuarioId",
                        column: x => x.UsuarioId,
                        principalTable: "Usuarios",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "TecnicoTIPerfis",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UsuarioId = table.Column<int>(type: "int", nullable: false),
                    AreaAtuacao = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    DataContratacao = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETDATE()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TecnicoTIPerfis", x => x.Id);
                    table.ForeignKey(
                        name: "FK_TecnicoTIPerfis_Usuarios_UsuarioId",
                        column: x => x.UsuarioId,
                        principalTable: "Usuarios",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Chamados_TecnicoTIPerfilId",
                table: "Chamados",
                column: "TecnicoTIPerfilId");

            migrationBuilder.CreateIndex(
                name: "IX_ColaboradorPerfis_Matricula",
                table: "ColaboradorPerfis",
                column: "Matricula",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ColaboradorPerfis_UsuarioId",
                table: "ColaboradorPerfis",
                column: "UsuarioId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_TecnicoTIPerfis_UsuarioId",
                table: "TecnicoTIPerfis",
                column: "UsuarioId",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Chamados_TecnicoTIPerfis_TecnicoTIPerfilId",
                table: "Chamados",
                column: "TecnicoTIPerfilId",
                principalTable: "TecnicoTIPerfis",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Chamados_TecnicoTIPerfis_TecnicoTIPerfilId",
                table: "Chamados");

            migrationBuilder.DropTable(
                name: "ColaboradorPerfis");

            migrationBuilder.DropTable(
                name: "TecnicoTIPerfis");

            migrationBuilder.DropIndex(
                name: "IX_Chamados_TecnicoTIPerfilId",
                table: "Chamados");

            migrationBuilder.DropColumn(
                name: "TecnicoTIPerfilId",
                table: "Chamados");

            migrationBuilder.CreateTable(
                name: "AlunoPerfis",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UsuarioId = table.Column<int>(type: "int", nullable: false),
                    Curso = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    Matricula = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    Semestre = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AlunoPerfis", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AlunoPerfis_Usuarios_UsuarioId",
                        column: x => x.UsuarioId,
                        principalTable: "Usuarios",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ProfessorPerfis",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UsuarioId = table.Column<int>(type: "int", nullable: false),
                    CursoMinistrado = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    SemestreMinistrado = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ProfessorPerfis", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ProfessorPerfis_Usuarios_UsuarioId",
                        column: x => x.UsuarioId,
                        principalTable: "Usuarios",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_AlunoPerfis_Matricula",
                table: "AlunoPerfis",
                column: "Matricula",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_AlunoPerfis_UsuarioId",
                table: "AlunoPerfis",
                column: "UsuarioId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ProfessorPerfis_UsuarioId",
                table: "ProfessorPerfis",
                column: "UsuarioId",
                unique: true);
        }
    }
}

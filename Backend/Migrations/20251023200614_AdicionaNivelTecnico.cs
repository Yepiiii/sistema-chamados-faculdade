using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SistemaChamados.Migrations
{
    /// <inheritdoc />
    public partial class AdicionaNivelTecnico : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "NivelTecnico",
                table: "TecnicoTIPerfis",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "NivelTecnico",
                table: "TecnicoTIPerfis");
        }
    }
}

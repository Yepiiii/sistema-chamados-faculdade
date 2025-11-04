using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SistemaChamados.Migrations
{
    /// <inheritdoc />
    public partial class RemoverColunaIsInternoDeComentarios : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsInterno",
                table: "Comentarios");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsInterno",
                table: "Comentarios",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }
    }
}

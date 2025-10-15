using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;
using SistemaChamados.Data;

var optionsBuilder = new DbContextOptionsBuilder<ApplicationDbContext>();
optionsBuilder.UseSqlServer("Server=(localdb)\\MSSQLLocalDB;Database=SistemaChamados;Trusted_Connection=True;");

using (var db = new ApplicationDbContext(optionsBuilder.Options))
{
    var usuarios = db.Usuarios.ToList();
    Console.WriteLine($"\n=== TOTAL: {usuarios.Count} USUÁRIO(S) ===\n");
    foreach(var u in usuarios)
    {
        var tipo = u.TipoUsuario switch { 1 => "Aluno", 2 => "Professor", 3 => "Administrador", _ => "Desconhecido" };
        Console.WriteLine($"ID: {u.Id}");
        Console.WriteLine($"Nome: {u.NomeCompleto}");
        Console.WriteLine($"Email: {u.Email}");
        Console.WriteLine($"Tipo: {tipo} ({u.TipoUsuario})");
        Console.WriteLine($"Ativo: {u.Ativo}");
        Console.WriteLine($"Cadastro: {u.DataCadastro:dd/MM/yyyy HH:mm}");
        Console.WriteLine("-----------------------------------");
    }
}

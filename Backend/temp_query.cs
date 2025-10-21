using System;
using System.Linq;
using Microsoft.EntityFrameworkCore;
using SistemaChamados.Data;

namespace SistemaChamados.Temporario;

/// <summary>
/// Helper utility to inspect the current usuarios table without using top-level statements.
/// </summary>
public static class TempQuery
{
    public static void ImprimirUsuarios()
    {
        var optionsBuilder = new DbContextOptionsBuilder<ApplicationDbContext>();
        optionsBuilder.UseSqlServer("Server=(localdb)\\MSSQLLocalDB;Database=SistemaChamados;Trusted_Connection=True;");

        using var db = new ApplicationDbContext(optionsBuilder.Options);
        var usuarios = db.Usuarios.ToList();
        Console.WriteLine($"\n=== TOTAL: {usuarios.Count} USUARIO(S) ===\n");
        foreach (var u in usuarios)
        {
            var tipo = u.TipoUsuario switch
            {
                1 => "Aluno",
                2 => "Professor",
                3 => "Administrador",
                _ => "Desconhecido"
            };

            Console.WriteLine($"ID: {u.Id}");
            Console.WriteLine($"Nome: {u.NomeCompleto}");
            Console.WriteLine($"Email: {u.Email}");
            Console.WriteLine($"Tipo: {tipo} ({u.TipoUsuario})");
            Console.WriteLine($"Ativo: {u.Ativo}");
            Console.WriteLine($"Cadastro: {u.DataCadastro:dd/MM/yyyy HH:mm}");
            Console.WriteLine("-----------------------------------");
        }

        var categorias = db.Categorias.ToList();
        Console.WriteLine($"\n=== TOTAL: {categorias.Count} CATEGORIA(S) ===\n");
        foreach (var categoria in categorias)
        {
            Console.WriteLine($"ID: {categoria.Id}");
            Console.WriteLine($"Nome: {categoria.Nome}");
            Console.WriteLine($"Ativo: {categoria.Ativo}");
            Console.WriteLine("-----------------------------------");
        }

        var prioridades = db.Prioridades.OrderBy(p => p.Nivel).ToList();
        Console.WriteLine($"\n=== TOTAL: {prioridades.Count} PRIORIDADE(S) ===\n");
        foreach (var prioridade in prioridades)
        {
            Console.WriteLine($"ID: {prioridade.Id}");
            Console.WriteLine($"Nome: {prioridade.Nome} (Nível {prioridade.Nivel})");
            Console.WriteLine($"Ativo: {prioridade.Ativo}");
            Console.WriteLine("-----------------------------------");
        }
    }
}

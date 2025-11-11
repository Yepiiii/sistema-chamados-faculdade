// Script para gerar hashes BCrypt corretos
// Executar com: dotnet script GerarHashesBCrypt.csx

#r "nuget: BCrypt.Net-Next, 4.0.3"

using BCrypt.Net;

Console.WriteLine("==============================================");
Console.WriteLine("GERANDO HASHES BCRYPT");
Console.WriteLine("==============================================");
Console.WriteLine();

// Senhas a serem geradas
var senhas = new Dictionary<string, string>
{
    { "Admin@123", "Admin" },
    { "Tecnico@123", "Técnico" },
    { "User@123", "Usuário" }
};

foreach (var senha in senhas)
{
    var hash = BCrypt.Net.BCrypt.HashPassword(senha.Key);
    Console.WriteLine($"-- {senha.Value}");
    Console.WriteLine($"Senha: {senha.Key}");
    Console.WriteLine($"Hash:  {hash}");
    Console.WriteLine();
}

Console.WriteLine("==============================================");
Console.WriteLine("COPIE OS HASHES ACIMA E USE NO SCRIPT SQL");
Console.WriteLine("==============================================");

#!/usr/bin/env dotnet-script
#r "nuget: BCrypt.Net-Next, 4.0.3"

using BCrypt.Net;

// Gerar hash para a senha "testando"
var senha = "testando";
var hash = BCrypt.Net.BCrypt.HashPassword(senha);

Console.WriteLine($"Senha: {senha}");
Console.WriteLine($"Hash BCrypt: {hash}");
Console.WriteLine($"\nSQL para atualizar:");
Console.WriteLine($"UPDATE Usuarios SET SenhaHash = '{hash}' WHERE Email = 'lidov41564@agenra.com';");

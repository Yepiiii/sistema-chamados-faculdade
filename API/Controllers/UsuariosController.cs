using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SistemaChamados.Application.DTOs;
using SistemaChamados.Core.Entities;
using SistemaChamados.Data;
using BCrypt.Net;
using System.Security.Claims;

namespace SistemaChamados.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UsuariosController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public UsuariosController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpPost("registrar-admin")]
    public async Task<ActionResult<UsuarioResponseDto>> RegistrarAdmin(AdminRegisterDto dto)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        // Verificar se email já existe
        if (await _context.Usuarios.AnyAsync(u => u.Email == dto.Email))
        {
            return BadRequest(new { message = "Email já está em uso" });
        }

        // Criar usuário admin
        var usuario = new Usuario
        {
            NomeCompleto = dto.NomeCompleto,
            Email = dto.Email,
            SenhaHash = BCrypt.Net.BCrypt.HashPassword(dto.Senha),
            TipoUsuario = 3, // Admin
            DataCadastro = DateTime.Now,
            Ativo = true
        };

        _context.Usuarios.Add(usuario);
        await _context.SaveChangesAsync();

        var response = new UsuarioResponseDto
        {
            Id = usuario.Id,
            NomeCompleto = usuario.NomeCompleto,
            Email = usuario.Email,
            TipoUsuario = usuario.TipoUsuario,
            DataCadastro = usuario.DataCadastro,
            Ativo = usuario.Ativo
        };

        return CreatedAtAction(nameof(RegistrarAdmin), new { id = usuario.Id }, response);
    }

    [HttpGet("perfil")]
    [Authorize]
    public IActionResult ObterPerfilUsuario()
    {
        var userId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
        if (userId == null)
        {
            return Unauthorized();
        }
        return Ok($"Acesso autorizado. Perfil do usuário com ID: {userId}.");
    }
}
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SistemaChamados.Application.DTOs;
using SistemaChamados.Application.Services;
using SistemaChamados.Application.Services.Auth;
using SistemaChamados.Application.Services.Users;
using SistemaChamados.Core.Entities;
using SistemaChamados.Core.Interfaces.Auth;
using SistemaChamados.Data;
using SistemaChamados.Services;
using BCrypt.Net;
using System.Security.Cryptography;

namespace SistemaChamados.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UsuariosController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ITokenService _tokenService;
    private readonly IEmailService _emailService;
    private readonly ILogger<UsuariosController> _logger;
    private readonly ICurrentUserService _currentUserService;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IAuthenticationService _authenticationService;
    private readonly IUserRegistrationService _userRegistrationService;
    private readonly IPasswordResetService _passwordResetService;

    public UsuariosController(
        ApplicationDbContext context, 
        ITokenService tokenService, 
        IEmailService emailService, 
        ILogger<UsuariosController> logger,
        ICurrentUserService currentUserService,
        IPasswordHasher passwordHasher,
        IAuthenticationService authenticationService,
        IUserRegistrationService userRegistrationService,
        IPasswordResetService passwordResetService)
    {
        _context = context;
        _tokenService = tokenService;
        _emailService = emailService;
        _logger = logger;
        _currentUserService = currentUserService;
        _passwordHasher = passwordHasher;
        _authenticationService = authenticationService;
        _userRegistrationService = userRegistrationService;
        _passwordResetService = passwordResetService;
    }

    [HttpPost("registrar-admin")]
    public async Task<ActionResult<UsuarioResponseDto>> RegistrarAdmin(AdminRegisterDto dto)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        // Delegate registration logic to UserRegistrationService (Phase 3.2)
        var result = await _userRegistrationService.RegisterAdminAsync(dto.NomeCompleto, dto.Email, dto.Senha);

        if (!result.Success)
        {
            return BadRequest(new { message = result.ErrorMessage });
        }

        var response = new UsuarioResponseDto
        {
            Id = result.UserId!.Value,
            NomeCompleto = result.NomeCompleto!,
            Email = result.Email!,
            TipoUsuario = result.TipoUsuario!.Value,
            DataCadastro = result.DataCadastro!.Value,
            Ativo = result.Ativo!.Value
        };

        return CreatedAtAction(nameof(RegistrarAdmin), new { id = result.UserId }, response);
    }

    [HttpPost("registrar")]
    [AllowAnonymous]
    public async Task<ActionResult<UsuarioResponseDto>> Registrar([FromBody] RegistrarUsuarioDto dto)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        // Delegate registration logic to UserRegistrationService (Phase 3.2)
        var result = await _userRegistrationService.RegisterUserAsync(dto.NomeCompleto, dto.Email, dto.Senha);

        if (!result.Success)
        {
            return BadRequest(new { message = result.ErrorMessage });
        }

        var response = new UsuarioResponseDto
        {
            Id = result.UserId!.Value,
            NomeCompleto = result.NomeCompleto!,
            Email = result.Email!,
            TipoUsuario = result.TipoUsuario!.Value,
            DataCadastro = result.DataCadastro!.Value,
            Ativo = result.Ativo!.Value
        };

        return CreatedAtAction(nameof(Registrar), new { id = result.UserId }, response);
    }

    [HttpPost("registrar-tecnico")]
    [Authorize(Policy = "AdminOnly")]
    public async Task<ActionResult<UsuarioResponseDto>> RegistrarTecnico([FromBody] RegistrarTecnicoDto dto)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        // Delegate registration logic to UserRegistrationService (Phase 3.2)
        var result = await _userRegistrationService.RegisterTechnicianAsync(
            dto.NomeCompleto, 
            dto.Email, 
            dto.Senha, 
            dto.EspecialidadeCategoriaId);

        if (!result.Success)
        {
            return BadRequest(new { message = result.ErrorMessage });
        }

        var response = new UsuarioResponseDto
        {
            Id = result.UserId!.Value,
            NomeCompleto = result.NomeCompleto!,
            Email = result.Email!,
            TipoUsuario = result.TipoUsuario!.Value,
            DataCadastro = result.DataCadastro!.Value,
            Ativo = result.Ativo!.Value
        };

        return CreatedAtAction(nameof(Registrar), new { id = result.UserId }, response);
    }

    [HttpPost("login")]
    public async Task<ActionResult<LoginResponseDto>> Login([FromBody] LoginRequestDto loginRequest)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        // Delegate authentication logic to AuthenticationService (Phase 3.1)
        var result = await _authenticationService.AuthenticateAsync(loginRequest.Email, loginRequest.Senha);

        if (!result.Success)
        {
            return Unauthorized(result.ErrorMessage);
        }

        return Ok(new LoginResponseDto { Token = result.Token!, TipoUsuario = result.TipoUsuario!.Value });
    }

    [HttpGet("perfil")]
    [Authorize]
    public IActionResult ObterPerfilUsuario()
    {
        // ✅ REFATORADO: Usando ICurrentUserService (Anti-Corruption Layer)
        // Antes: User.FindFirst(ClaimTypes.NameIdentifier)?.Value
        // Agora: Abstraído do mecanismo JWT
        if (!_currentUserService.IsAuthenticated)
        {
            return Unauthorized();
        }

        var userId = _currentUserService.UserId;
        var userEmail = _currentUserService.Email;
        
        return Ok(new 
        { 
            message = "Acesso autorizado", 
            userId = userId,
            email = userEmail 
        });
    }

    [HttpPost("esqueci-senha")]
    [AllowAnonymous]
    public async Task<IActionResult> EsqueciSenha([FromBody] EsqueciSenhaDto request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        // Delegate password reset initiation to PasswordResetService (Phase 3.3)
        var result = await _passwordResetService.InitiatePasswordResetAsync(request.Email);

        if (!result.Success)
        {
            return StatusCode(500, new { message = result.ErrorMessage });
        }

        return Ok(new { message = result.Message });
    }

    [HttpPost("resetar-senha")]
    [AllowAnonymous]
    public async Task<IActionResult> ResetarSenha([FromBody] ResetarSenhaDto request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        // Delegate password reset completion to PasswordResetService (Phase 3.3)
        var result = await _passwordResetService.ResetPasswordAsync(request.Token, request.NovaSenha);

        if (!result.Success)
        {
            return BadRequest(new { message = result.ErrorMessage });
        }

        return Ok(new { message = result.Message });
    }

    [HttpGet("tecnicos")]
    [Authorize] // Apenas usuários logados podem ver a lista
    public async Task<ActionResult<IEnumerable<UsuarioResponseDto>>> GetTecnicosAtivos()
    {
        _logger.LogInformation("Buscando lista de técnicos (TipoUsuario == 2) ativos.");
        
        var tecnicos = await _context.Usuarios
            .Where(u => u.TipoUsuario == 2 && u.Ativo)
            .Select(u => new UsuarioResponseDto
            {
                Id = u.Id,
                NomeCompleto = u.NomeCompleto,
                Email = u.Email,
                TipoUsuario = u.TipoUsuario,
                DataCadastro = u.DataCadastro,
                Ativo = u.Ativo
            })
            .ToListAsync();
            
        _logger.LogInformation("Encontrados {Count} técnicos ativos.", tecnicos.Count);

        return Ok(tecnicos);
    }
}
// ========================================
// CONTROLLERS POST PARA ADICIONAR
// ========================================
// 
// Crie estes 3 arquivos na pasta API/Controllers/
// para poder criar os dados básicos via API

// ========================================
// 1. ARQUIVO: API/Controllers/CategoriasController.cs
// ========================================

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SistemaChamados.Core.Entities;
using SistemaChamados.Data;

namespace SistemaChamados.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class CategoriasController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public CategoriasController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetCategorias()
    {
        var categorias = await _context.Categorias
            .Where(c => c.Ativo)
            .ToListAsync();

        return Ok(categorias);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetCategoria(int id)
    {
        var categoria = await _context.Categorias
            .FirstOrDefaultAsync(c => c.Id == id);

        if (categoria == null)
        {
            return NotFound("Categoria não encontrada.");
        }

        return Ok(categoria);
    }

    [HttpPost]
    public async Task<IActionResult> CriarCategoria([FromBody] CriarCategoriaDto request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        var categoria = new Categoria
        {
            Nome = request.Nome,
            Descricao = request.Descricao,
            Ativo = true
        };

        _context.Categorias.Add(categoria);
        await _context.SaveChangesAsync();

        return Ok(categoria);
    }
}

// DTO para Categoria
public class CriarCategoriaDto
{
    public string Nome { get; set; } = string.Empty;
    public string? Descricao { get; set; }
}

// ========================================
// 2. ARQUIVO: API/Controllers/PrioridadesController.cs
// ========================================

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SistemaChamados.Core.Entities;
using SistemaChamados.Data;

namespace SistemaChamados.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class PrioridadesController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public PrioridadesController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetPrioridades()
    {
        var prioridades = await _context.Prioridades
            .Where(p => p.Ativo)
            .OrderBy(p => p.Nivel)
            .ToListAsync();

        return Ok(prioridades);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetPrioridade(int id)
    {
        var prioridade = await _context.Prioridades
            .FirstOrDefaultAsync(p => p.Id == id);

        if (prioridade == null)
        {
            return NotFound("Prioridade não encontrada.");
        }

        return Ok(prioridade);
    }

    [HttpPost]
    public async Task<IActionResult> CriarPrioridade([FromBody] CriarPrioridadeDto request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        var prioridade = new Prioridade
        {
            Nome = request.Nome,
            Nivel = request.Nivel,
            Descricao = request.Descricao,
            Ativo = true
        };

        _context.Prioridades.Add(prioridade);
        await _context.SaveChangesAsync();

        return Ok(prioridade);
    }
}

// DTO para Prioridade
public class CriarPrioridadeDto
{
    public string Nome { get; set; } = string.Empty;
    public int Nivel { get; set; }
    public string? Descricao { get; set; }
}

// ========================================
// 3. ARQUIVO: API/Controllers/StatusController.cs
// ========================================

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SistemaChamados.Core.Entities;
using SistemaChamados.Data;

namespace SistemaChamados.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class StatusController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public StatusController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetStatus()
    {
        var status = await _context.Status
            .Where(s => s.Ativo)
            .ToListAsync();

        return Ok(status);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetStatusPorId(int id)
    {
        var status = await _context.Status
            .FirstOrDefaultAsync(s => s.Id == id);

        if (status == null)
        {
            return NotFound("Status não encontrado.");
        }

        return Ok(status);
    }

    [HttpPost]
    public async Task<IActionResult> CriarStatus([FromBody] CriarStatusDto request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        var status = new Status
        {
            Nome = request.Nome,
            Descricao = request.Descricao,
            Ativo = true
        };

        _context.Status.Add(status);
        await _context.SaveChangesAsync();

        return Ok(status);
    }
}

// DTO para Status
public class CriarStatusDto
{
    public string Nome { get; set; } = string.Empty;
    public string? Descricao { get; set; }
}

// ========================================
// INSTRUÇÕES DE IMPLEMENTAÇÃO:
// ========================================
//
// 1. Crie 3 arquivos separados na pasta API/Controllers/:
//    - CategoriasController.cs
//    - PrioridadesController.cs  
//    - StatusController.cs
//
// 2. Copie o código correspondente para cada arquivo
//
// 3. Reinicie o servidor: dotnet run
//
// 4. Acesse o Swagger e você verá os novos endpoints:
//    - POST /api/categorias
//    - POST /api/prioridades
//    - POST /api/status
//    - GET /api/categorias
//    - GET /api/prioridades
//    - GET /api/status
//
// ========================================
// SEQUÊNCIA DE TESTE:
// ========================================
//
// 1. Fazer login e configurar autenticação
// 2. Criar categorias usando POST /api/categorias
// 3. Criar prioridades usando POST /api/prioridades
// 4. Criar status usando POST /api/status
// 5. Criar chamados usando POST /api/chamados
// 6. Testar endpoints GET dos chamados
//
// ========================================
// EXEMPLOS DE JSON PARA TESTE:
// ========================================
//
// POST /api/categorias:
// {
//   "nome": "Suporte Técnico",
//   "descricao": "Problemas técnicos gerais"
// }
//
// POST /api/prioridades:
// {
//   "nome": "Alta",
//   "nivel": 3,
//   "descricao": "Prioridade alta"
// }
//
// POST /api/status:
// {
//   "nome": "Aberto",
//   "descricao": "Chamado recém criado"
// }
//
// ========================================
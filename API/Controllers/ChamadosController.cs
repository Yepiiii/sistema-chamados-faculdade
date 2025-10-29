using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SistemaChamados.Application.DTOs;
using SistemaChamados.Core.Entities;
using SistemaChamados.Data;
using SistemaChamados.Services;
using System.Security.Claims;

namespace SistemaChamados.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ChamadosController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly IOpenAIService _openAIService;
    private readonly ILogger<ChamadosController> _logger;

    public ChamadosController(ApplicationDbContext context, IOpenAIService openAIService, ILogger<ChamadosController> logger)
    {
        _context = context;
        _openAIService = openAIService;
        _logger = logger;
    }

    [HttpPost]
    public async Task<IActionResult> CriarChamado([FromBody] CriarChamadoRequestDto request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        // Pega o ID do usuário logado a partir do token JWT.
        var solicitanteIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (solicitanteIdStr == null)
        {
            return Unauthorized(); // Token inválido ou não contém o ID
        }

        // Validar se a categoria existe e está ativa
        var categoria = await _context.Categorias.FindAsync(request.CategoriaId);
        if (categoria == null)
        {
            return BadRequest("Categoria não encontrada ou inativa");
        }

        // Validar se a prioridade existe e está ativa
        var prioridade = await _context.Prioridades.FindAsync(request.PrioridadeId);
        if (prioridade == null)
        {
            return BadRequest("Prioridade não encontrada ou inativa");
        }

        // Validar se o usuário existe
        var solicitanteId = int.Parse(solicitanteIdStr);
        var usuario = await _context.Usuarios.FindAsync(solicitanteId);
        if (usuario == null)
        {
            return Unauthorized("Usuário não encontrado ou inativo");
        }

        var novoChamado = new Chamado
        {
            Titulo = request.Titulo,
            Descricao = request.Descricao,
            DataAbertura = DateTime.UtcNow,
            SolicitanteId = solicitanteId,
            StatusId = 1, // Assumindo que o ID 1 seja "Aberto"
            PrioridadeId = request.PrioridadeId,
            CategoriaId = request.CategoriaId
        };

        _context.Chamados.Add(novoChamado);
        await _context.SaveChangesAsync();

        return Ok(novoChamado);
    }
[HttpGet]
public async Task<IActionResult> GetChamados([FromQuery] int? statusId, [FromQuery] int? tecnicoId)
{
    // Começa com a consulta base SEM includes desnecessários para a lista
    var query = _context.Chamados.AsQueryable(); 
    
    // Aplica filtro de StatusId se fornecido
    if (statusId.HasValue)
    {
        query = query.Where(c => c.StatusId == statusId.Value);
    }
    
    // Aplica filtro de TecnicoId se fornecido (LÓGICA CORRIGIDA)
    if (tecnicoId.HasValue)
    {
        if (tecnicoId.Value == 0) 
        {
           // Busca chamados onde TecnicoId é NULL
           query = query.Where(c => c.TecnicoId == null); 
        }
        else 
        {
           // Busca chamados para o TecnicoId específico
           query = query.Where(c => c.TecnicoId == tecnicoId.Value); 
        }
    }
    
    // AGORA, após aplicar TODOS os filtros, fazemos os Includes necessários
    // e a projeção para o DTO.
    var chamadosDto = await query
        .Include(c => c.Categoria) // Inclui Categoria para obter o Nome
        .Include(c => c.Status)    // Inclui Status para obter o Nome
        .OrderByDescending(c => c.DataAbertura) 
        .Select(c => new ChamadoListDto 
        {
            Id = c.Id,
            Titulo = c.Titulo,
            CategoriaNome = c.Categoria.Nome, 
            StatusNome = c.Status.Nome       
        })
        .ToListAsync();
    
    // Log para depuração no backend
    _logger.LogInformation("GetChamados - Filtros: statusId={StatusId}, tecnicoId={TecnicoId}. Resultados encontrados: {Count}", statusId, tecnicoId, chamadosDto.Count);
    
    return Ok(chamadosDto); 
}

[HttpGet("{id}")]
public async Task<IActionResult> GetChamadoPorId(int id)
{
    var chamado = await _context.Chamados
        .Include(c => c.Solicitante)
        .Include(c => c.Tecnico) // Inclui o técnico também, se houver
        .Include(c => c.Status)
        .Include(c => c.Prioridade)
        .Include(c => c.Categoria)
        .FirstOrDefaultAsync(c => c.Id == id);

    if (chamado == null)
    {
        return NotFound("Chamado não encontrado.");
    }

    return Ok(chamado);
}

[HttpPut("{id}")]
public async Task<IActionResult> AtualizarChamado(int id, [FromBody] AtualizarChamadoDto request)
{
    var chamado = await _context.Chamados.FindAsync(id);
    if (chamado == null)
    {
        return NotFound("Chamado não encontrado.");
    }

    // Valida se o novo StatusId existe
    var statusExiste = await _context.Status.AnyAsync(s => s.Id == request.StatusId);
    if (!statusExiste)
    {
        return BadRequest("O StatusId fornecido é inválido.");
    }

    // --- INÍCIO DA NOVA LÓGICA ---
    // 1. Atualiza sempre a data da última modificação
    chamado.DataUltimaAtualizacao = DateTime.UtcNow;

    // 2. Verifica se o novo status é 'Fechado' (vamos assumir que o ID 4 é "Fechado")
    if (request.StatusId == 4) 
    {
        chamado.DataFechamento = DateTime.UtcNow;
    }
    else
    {
        // Garante que a data de fechamento seja nula se o chamado for reaberto
        chamado.DataFechamento = null;
    }
    // --- FIM DA NOVA LÓGICA ---

    // Atualiza os campos do chamado
    chamado.StatusId = request.StatusId;

    if (request.TecnicoId.HasValue)
    {
        var tecnicoExiste = await _context.Usuarios.AnyAsync(u => u.Id == request.TecnicoId.Value && u.Ativo);
        if (!tecnicoExiste)
        {
            return BadRequest("O TecnicoId fornecido é inválido ou o usuário está inativo.");
        }
        chamado.TecnicoId = request.TecnicoId;
    }

    _context.Chamados.Update(chamado);
    await _context.SaveChangesAsync();

    return Ok(chamado);
}

[HttpPost("analisar")]
public async Task<IActionResult> AnalisarChamado([FromBody] AnalisarChamadoRequestDto request)
{
    if (string.IsNullOrWhiteSpace(request.DescricaoProblema))
    {
        return BadRequest("Descrição do problema é obrigatória.");
    }

    try
    {
        // 1. Pede a análise da IA (como antes)
        var analise = await _openAIService.AnalisarChamadoAsync(request.DescricaoProblema);
        
        if (analise == null)
        {
            return StatusCode(500, "Erro ao obter análise da IA. Tente novamente.");
        }

        // 2. Pega o ID do usuário que fez a requisição
        var solicitanteIdStr = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
        if (solicitanteIdStr == null)
        {
            return Unauthorized();
        }
        var solicitanteId = int.Parse(solicitanteIdStr);

        // 3. Cria o novo chamado com os dados da IA e do usuário
        var novoChamado = new Chamado
        {
            Titulo = analise.TituloSugerido,
            Descricao = request.DescricaoProblema,
            DataAbertura = DateTime.UtcNow,
            SolicitanteId = solicitanteId,
            StatusId = 1, // Padrão: "Aberto"
            PrioridadeId = analise.PrioridadeId,
            CategoriaId = analise.CategoriaId,
            TecnicoId = analise.TecnicoId // Adicionar esta linha
        };

        // 4. Salva o novo chamado no banco de dados
        _context.Chamados.Add(novoChamado);
        await _context.SaveChangesAsync();

        // 5. Retorna o chamado que foi CRIADO no banco (com seu novo ID)
        return CreatedAtAction(nameof(GetChamadoPorId), new { id = novoChamado.Id }, novoChamado);
    }
    catch (Exception ex)
    {
        // Logar o erro real no seu console
        _logger.LogError(ex, "Erro no processo de análise e criação de chamado.");
        return StatusCode(500, "Ocorreu um erro inesperado ao processar seu chamado.");
    }
}
}

// DTO para requisição de análise
public class AnalisarChamadoRequestDto
{
    public string DescricaoProblema { get; set; } = string.Empty;
}
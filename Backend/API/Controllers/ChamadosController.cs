using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using SistemaChamados.Application.DTOs;
using SistemaChamados.Core.Entities;
using SistemaChamados.Data;
using SistemaChamados.Services;
using System.Security.Claims;
using System.Linq;

namespace SistemaChamados.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ChamadosController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly IOpenAIService _openAIService;
    private readonly IAIService _aiService;
    private readonly IHandoffService _handoffService;
    private readonly ILogger<ChamadosController> _logger;

    public ChamadosController(ApplicationDbContext context, IOpenAIService openAIService, IAIService aiService, IHandoffService handoffService, ILogger<ChamadosController> logger)
    {
        _context = context;
        _openAIService = openAIService;
        _aiService = aiService;
        _handoffService = handoffService;
        _logger = logger;
    }

    private const int StatusFechadoIdFallback = 4;

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

    var tipoUsuarioValor = User.FindFirst("TipoUsuario")?.Value;
    var isAdmin = tipoUsuarioValor == "3";
    var tipoUsuario = int.TryParse(tipoUsuarioValor, out var tipo) ? tipo : 0;

    var usarAnaliseAutomatica = request.UsarAnaliseAutomatica ?? true;

    // REGRA: Apenas Admin (tipo 3) pode criar chamados com classificação manual
    if (!usarAnaliseAutomatica && tipoUsuario != 3)
    {
        _logger.LogWarning("Usuário tipo {TipoUsuario} tentou criar chamado com classificação manual.", tipoUsuario);
        return StatusCode(StatusCodes.Status403Forbidden, 
            "Apenas administradores podem criar chamados com classificação manual. Use a análise automática por IA.");
    }

    var categoriaSelecionada = 0;
    var prioridadeSelecionada = 0;
    var tituloChamado = request.Titulo?.Trim();

        if (usarAnaliseAutomatica)
        {
            _logger.LogInformation("Criando chamado com análise automática por IA.");

            var tituloParaAnalise = string.IsNullOrWhiteSpace(request.Titulo)
                ? request.Descricao
                : request.Titulo;

            var analise = await _aiService.AnalisarChamadoAsync(tituloParaAnalise, request.Descricao);
            if (analise == null)
            {
                return StatusCode(500, "Erro ao obter análise da IA. Tente novamente.");
            }

            categoriaSelecionada = analise.CategoriaId;
            prioridadeSelecionada = analise.PrioridadeId;

            if (!string.IsNullOrWhiteSpace(analise.TituloSugerido) && string.IsNullOrWhiteSpace(tituloChamado))
            {
                tituloChamado = analise.TituloSugerido;
            }

            _logger.LogInformation(
                "Gemini AI sugeriu categoria {CategoriaId} e prioridade {PrioridadeId}",
                categoriaSelecionada,
                prioridadeSelecionada
            );
        }
        else
        {
            _logger.LogInformation("Admin criando chamado com classificação manual fornecida.");
            categoriaSelecionada = request.CategoriaId!.Value;
            prioridadeSelecionada = request.PrioridadeId!.Value;
        }

        if (string.IsNullOrWhiteSpace(tituloChamado))
        {
            tituloChamado = GerarTituloFallback(request.Descricao);
            _logger.LogInformation("Título original vazio. Gerando fallback automático: {TituloFallback}", tituloChamado);
        }

        var categoria = await _context.Categorias.FindAsync(categoriaSelecionada);
        if (categoria == null)
        {
            return BadRequest("Categoria não encontrada ou inativa");
        }

        var prioridade = await _context.Prioridades.FindAsync(prioridadeSelecionada);
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
            Titulo = tituloChamado,
            Descricao = request.Descricao,
            DataAbertura = DateTime.UtcNow,
            SolicitanteId = solicitanteId,
            StatusId = 1,
            PrioridadeId = prioridadeSelecionada,
            CategoriaId = categoriaSelecionada
        };

        var tecnicoId = await _handoffService.AtribuirTecnicoAsync(categoriaSelecionada);
        if (tecnicoId.HasValue)
        {
            novoChamado.TecnicoAtribuidoId = tecnicoId.Value;
            novoChamado.TecnicoId = tecnicoId.Value;
        }

        _context.Chamados.Add(novoChamado);
        await _context.SaveChangesAsync();

        var chamadoCompleto = await ObterChamadoCompletoAsync(novoChamado.Id);
        if (chamadoCompleto == null)
        {
            return StatusCode(StatusCodes.Status500InternalServerError, "Não foi possível carregar o chamado recém-criado.");
        }

        return Ok(MapToResponseDto(chamadoCompleto, isAdmin));
    }
[HttpGet]
public async Task<IActionResult> GetChamados()
{
    // Obter informações do usuário autenticado
    var usuarioIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
    if (string.IsNullOrEmpty(usuarioIdClaim))
    {
        return Unauthorized("Usuário não autenticado.");
    }

    if (!int.TryParse(usuarioIdClaim, out var usuarioId))
    {
        return Unauthorized("Identificador de usuário inválido.");
    }

    // Obter tipo de usuário do token JWT
    var tipoUsuarioClaim = User.FindFirst("TipoUsuario")?.Value;
    if (string.IsNullOrEmpty(tipoUsuarioClaim) || !int.TryParse(tipoUsuarioClaim, out var tipoUsuario))
    {
        return Unauthorized("Tipo de usuário não encontrado no token.");
    }

    // Query base com includes
    IQueryable<Chamado> query = _context.Chamados
        .Include(c => c.Solicitante)
        .Include(c => c.Tecnico)
        .Include(c => c.Status)
        .Include(c => c.Prioridade)
        .Include(c => c.Categoria);

    // Aplicar filtro baseado no tipo de usuário
    switch (tipoUsuario)
    {
        case 1: // Aluno - vê apenas seus próprios chamados
            query = query.Where(c => c.SolicitanteId == usuarioId);
            _logger.LogInformation($"Aluno {usuarioId} visualizando apenas seus próprios chamados.");
            break;

        case 2: // Professor - vê seus chamados + chamados onde é técnico
            query = query.Where(c => c.SolicitanteId == usuarioId || c.TecnicoId == usuarioId);
            _logger.LogInformation($"Professor {usuarioId} visualizando seus chamados e chamados atribuídos.");
            break;

        case 3: // Admin - vê todos os chamados
            _logger.LogInformation($"Admin {usuarioId} visualizando todos os chamados do sistema.");
            // Sem filtro - admin vê tudo
            break;

        default:
            return StatusCode(StatusCodes.Status403Forbidden, "Tipo de usuário inválido.");
    }

    var chamados = await query
        .OrderByDescending(c => c.DataAbertura)
        .ToListAsync();

    _logger.LogInformation($"Usuário {usuarioId} (Tipo {tipoUsuario}) recuperou {chamados.Count} chamados.");

    var isAdmin = tipoUsuario == 3;
    var response = chamados.Select(chamado => MapToResponseDto(chamado, isAdmin)).ToList();

    return Ok(response);
}

[HttpGet("{id}")]
public async Task<IActionResult> GetChamadoPorId(int id)
{
    // Obter informações do usuário autenticado
    var usuarioIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
    if (string.IsNullOrEmpty(usuarioIdClaim))
    {
        return Unauthorized("Usuário não autenticado.");
    }

    if (!int.TryParse(usuarioIdClaim, out var usuarioId))
    {
        return Unauthorized("Identificador de usuário inválido.");
    }

    // Obter tipo de usuário do token JWT
    var tipoUsuarioClaim = User.FindFirst("TipoUsuario")?.Value;
    if (string.IsNullOrEmpty(tipoUsuarioClaim) || !int.TryParse(tipoUsuarioClaim, out var tipoUsuario))
    {
        return Unauthorized("Tipo de usuário não encontrado no token.");
    }

    var chamado = await ObterChamadoCompletoAsync(id);

    if (chamado == null)
    {
        return NotFound("Chamado não encontrado.");
    }

    // Validar permissão de acesso ao chamado
    bool temPermissao = tipoUsuario switch
    {
        1 => chamado.SolicitanteId == usuarioId, // Aluno: só seus próprios
        2 => chamado.SolicitanteId == usuarioId || chamado.TecnicoId == usuarioId, // Professor: seus + atribuídos
        3 => true, // Admin: todos
        _ => false
    };

    if (!temPermissao)
    {
        _logger.LogWarning($"Usuário {usuarioId} (Tipo {tipoUsuario}) tentou acessar chamado {id} sem permissão.");
        return StatusCode(StatusCodes.Status403Forbidden, "Acesso negado ao chamado solicitado.");
    }

    _logger.LogInformation($"Usuário {usuarioId} (Tipo {tipoUsuario}) acessou chamado {id}.");

    return Ok(MapToResponseDto(chamado, tipoUsuario == 3));
}

[HttpPut("{id}")]
public async Task<IActionResult> AtualizarChamado(int id, [FromBody] AtualizarChamadoDto request)
{
    // Obter informações do usuário autenticado
    var usuarioIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
    if (string.IsNullOrEmpty(usuarioIdClaim))
    {
        return Unauthorized("Usuário não autenticado.");
    }

    if (!int.TryParse(usuarioIdClaim, out var usuarioId))
    {
        return Unauthorized("Identificador de usuário inválido.");
    }

    // Obter tipo de usuário do token JWT
    var tipoUsuarioClaim = User.FindFirst("TipoUsuario")?.Value;
    if (string.IsNullOrEmpty(tipoUsuarioClaim) || !int.TryParse(tipoUsuarioClaim, out var tipoUsuario))
    {
        return Unauthorized("Tipo de usuário não encontrado no token.");
    }

    var chamado = await _context.Chamados.FindAsync(id);
    if (chamado == null)
    {
        return NotFound("Chamado não encontrado.");
    }

    // Validar permissão: Apenas Admin pode atualizar chamados
    if (tipoUsuario != 3)
    {
        _logger.LogWarning($"Usuário {usuarioId} (Tipo {tipoUsuario}) tentou atualizar chamado {id} sem permissão de admin.");
    return StatusCode(StatusCodes.Status403Forbidden, "Apenas administradores podem atualizar chamados.");
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

    var chamadoAtualizado = await ObterChamadoCompletoAsync(id);
    if (chamadoAtualizado == null)
    {
        return NotFound("Chamado não encontrado após atualização.");
    }

    return Ok(MapToResponseDto(chamadoAtualizado, true));
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
        // 1. Usa o AIService (simulado) ao invés do Gemini para análise
        var analise = await _aiService.AnalisarChamadoAsync(request.DescricaoProblema, request.DescricaoProblema);
        
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
            Titulo = string.IsNullOrWhiteSpace(analise.TituloSugerido)
                ? "Chamado sem título"
                : analise.TituloSugerido,
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

    var isAdmin = User.FindFirst("TipoUsuario")?.Value == "3";

        var chamadoCompleto = await ObterChamadoCompletoAsync(novoChamado.Id);
        if (chamadoCompleto == null)
        {
            return StatusCode(StatusCodes.Status500InternalServerError, "Não foi possível carregar o chamado recém-criado.");
        }

        // 5. Retorna o chamado que foi CRIADO no banco (com seu novo ID)
        return CreatedAtAction(nameof(GetChamadoPorId), new { id = novoChamado.Id }, MapToResponseDto(chamadoCompleto, isAdmin));
    }
    catch (Exception ex)
    {
        // Logar o erro real no seu console
        _logger.LogError(ex, "Erro no processo de análise e criação de chamado.");
        return StatusCode(500, "Ocorreu um erro inesperado ao processar seu chamado.");
    }
}

    [HttpPost("{id}/fechar")]
    public async Task<IActionResult> FecharChamado(int id)
    {
        var usuarioIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(usuarioIdClaim))
        {
            return Unauthorized("Usuário não autenticado.");
        }

        if (!int.TryParse(usuarioIdClaim, out var usuarioId))
        {
            return Unauthorized("Identificador de usuário inválido.");
        }

        var usuario = await _context.Usuarios.AsNoTracking().FirstOrDefaultAsync(u => u.Id == usuarioId && u.Ativo);
        if (usuario == null)
        {
            return Unauthorized("Usuário não encontrado ou inativo.");
        }

        if (usuario.TipoUsuario != 3)
        {
            return StatusCode(StatusCodes.Status403Forbidden, "Apenas administradores podem encerrar chamados.");
        }

        var chamado = await _context.Chamados.FirstOrDefaultAsync(c => c.Id == id);
        if (chamado == null)
        {
            return NotFound("Chamado não encontrado.");
        }

        if (chamado.DataFechamento.HasValue)
        {
            return BadRequest("Chamado já está encerrado.");
        }

        var statusFechado = await _context.Status.AsNoTracking().FirstOrDefaultAsync(s => s.Nome == "Fechado");
        var statusFechadoId = statusFechado?.Id ?? StatusFechadoIdFallback;

        var statusExiste = await _context.Status.AnyAsync(s => s.Id == statusFechadoId);
        if (!statusExiste)
        {
            _logger.LogError("Status 'Fechado' não configurado na base de dados.");
            return StatusCode(500, "Status 'Fechado' não está configurado.");
        }

        chamado.StatusId = statusFechadoId;
        chamado.DataFechamento = DateTime.UtcNow;
        chamado.DataUltimaAtualizacao = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        var chamadoAtualizado = await ObterChamadoCompletoAsync(id);
        if (chamadoAtualizado == null)
        {
            return NotFound("Chamado não encontrado após atualização.");
        }

        return Ok(MapToResponseDto(chamadoAtualizado, true));
    }

    [HttpDelete("limpar-todos")]
    public async Task<IActionResult> LimparTodosChamados()
    {
        var usuarioIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(usuarioIdClaim))
        {
            return Unauthorized("Usuário não autenticado.");
        }

        if (!int.TryParse(usuarioIdClaim, out var usuarioId))
        {
            return Unauthorized("Identificador de usuário inválido.");
        }

        var usuario = await _context.Usuarios.AsNoTracking().FirstOrDefaultAsync(u => u.Id == usuarioId && u.Ativo);
        if (usuario == null)
        {
            return Unauthorized("Usuário não encontrado ou inativo.");
        }

        if (usuario.TipoUsuario != 3)
        {
            return StatusCode(StatusCodes.Status403Forbidden, "Apenas administradores podem excluir todos os chamados.");
        }

        var total = await _context.Chamados.CountAsync();
        
        _logger.LogWarning($"Admin {usuario.Email} está excluindo TODOS os {total} chamados do sistema.");

        await _context.Database.ExecuteSqlRawAsync("DELETE FROM [Chamados]");
        await _context.Database.ExecuteSqlRawAsync("DBCC CHECKIDENT ('[Chamados]', RESEED, 0)");

        return Ok(new { message = $"{total} chamados excluídos com sucesso.", totalExcluido = total });
    }

    private async Task<Chamado?> ObterChamadoCompletoAsync(int id)
    {
        return await _context.Chamados
            .Include(c => c.Solicitante)
            .Include(c => c.Tecnico)
            .Include(c => c.TecnicoAtribuido)
            .Include(c => c.Status)
            .Include(c => c.Prioridade)
            .Include(c => c.Categoria)
            .FirstOrDefaultAsync(c => c.Id == id);
    }

    private static ChamadoResponseDto MapToResponseDto(Chamado chamado, bool incluirSolicitante)
    {
        var dto = new ChamadoResponseDto
        {
            Id = chamado.Id,
            Titulo = chamado.Titulo,
            Descricao = chamado.Descricao,
            DataAbertura = chamado.DataAbertura,
            DataUltimaAtualizacao = chamado.DataUltimaAtualizacao,
            DataFechamento = chamado.DataFechamento,
            Categoria = chamado.Categoria != null
                ? new CategoriaResumoDto
                {
                    Id = chamado.Categoria.Id,
                    Nome = chamado.Categoria.Nome
                }
                : null,
            Prioridade = chamado.Prioridade != null
                ? new PrioridadeResumoDto
                {
                    Id = chamado.Prioridade.Id,
                    Nome = chamado.Prioridade.Nome
                }
                : null,
            Status = chamado.Status != null
                ? new StatusResumoDto
                {
                    Id = chamado.Status.Id,
                    Nome = chamado.Status.Nome
                }
                : null,
            Tecnico = chamado.Tecnico != null
                ? new UsuarioResumoDto
                {
                    Id = chamado.Tecnico.Id,
                    NomeCompleto = chamado.Tecnico.NomeCompleto,
                    Email = chamado.Tecnico.Email
                }
                : null
        };

        if (incluirSolicitante && chamado.Solicitante != null)
        {
            dto.Solicitante = new UsuarioResumoDto
            {
                Id = chamado.Solicitante.Id,
                NomeCompleto = chamado.Solicitante.NomeCompleto,
                Email = chamado.Solicitante.Email
            };
        }

        return dto;
    }

    private static string GerarTituloFallback(string? descricao)
    {
        if (string.IsNullOrWhiteSpace(descricao))
        {
            return "Chamado sem título";
        }

        const int limite = 80;
        var texto = descricao.Trim();

        if (texto.Length <= limite)
        {
            return texto;
        }

        var truncado = texto.Substring(0, limite).TrimEnd();
        return string.Concat(truncado, "...");
    }
}

// DTO para requisição de análise
public class AnalisarChamadoRequestDto
{
    public string DescricaoProblema { get; set; } = string.Empty;
}
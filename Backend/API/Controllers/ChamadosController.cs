using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using SistemaChamados.Application.DTOs;
using SistemaChamados.Application.Services;
using SistemaChamados.Core.Entities;
using SistemaChamados.Core.Enums;
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
    if (!int.TryParse(tipoUsuarioValor, out var tipoUsuarioInt))
    {
        return Unauthorized("Tipo de usuário inválido no token.");
    }
    
    var tipoUsuario = (TipoUsuario)tipoUsuarioInt;

    // REGRA: Colaborador, Técnico e Admin podem criar chamados
    if (!PermissoesService.PodeCriarChamado(tipoUsuario))
    {
        _logger.LogWarning("Usuário tipo {TipoUsuario} (ID: {SolicitanteId}) tentou criar chamado sem permissão.", tipoUsuario, solicitanteIdStr);
        return StatusCode(StatusCodes.Status403Forbidden, 
            "Você não tem permissão para criar chamados.");
    }

    var usarAnaliseAutomatica = request.UsarAnaliseAutomatica ?? true;

    // REGRA: Apenas Admin e Técnico podem criar chamados com classificação manual
    // Colaboradores devem sempre usar a IA
    if (!usarAnaliseAutomatica && tipoUsuario == TipoUsuario.Colaborador)
    {
        _logger.LogWarning("Colaborador tentou criar chamado com classificação manual.");
        return StatusCode(StatusCodes.Status403Forbidden, 
            "Colaboradores devem usar a análise automática por IA. Apenas Técnicos e Administradores podem fazer classificação manual.");
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

        _context.Chamados.Add(novoChamado);
        await _context.SaveChangesAsync();
        
        // Atribuição inteligente de técnico
        _logger.LogInformation("🤖 Iniciando atribuição automática de técnico...");
        var usouIA = request.UsarAnaliseAutomatica ?? true;
        var atribuicao = await _handoffService.AtribuirTecnicoInteligenteAsync(
            novoChamado.Id,
            categoriaSelecionada,
            prioridadeSelecionada,
            usouIA ? "IA+Automatico" : "Automatico");
        
        if (atribuicao.Sucesso && atribuicao.TecnicoId.HasValue)
        {
            novoChamado.TecnicoAtribuidoId = atribuicao.TecnicoId.Value;
            novoChamado.TecnicoId = atribuicao.TecnicoId.Value;
            await _context.SaveChangesAsync();
            
            _logger.LogInformation($"✅ Técnico atribuído: {atribuicao.TecnicoNome} (Score: {atribuicao.Score:F2})");
            _logger.LogInformation($"   Motivo: {atribuicao.Motivo}");
        }
        else
        {
            _logger.LogWarning($"⚠️ Nenhum técnico atribuído: {atribuicao.MensagemErro}");
        }

        var chamadoCompleto = await ObterChamadoCompletoAsync(novoChamado.Id);
        if (chamadoCompleto == null)
        {
            return StatusCode(StatusCodes.Status500InternalServerError, "Não foi possível carregar o chamado recém-criado.");
        }

        return Ok(MapToResponseDto(chamadoCompleto, tipoUsuario == TipoUsuario.Admin));
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
    if (string.IsNullOrEmpty(tipoUsuarioClaim) || !int.TryParse(tipoUsuarioClaim, out var tipoUsuarioInt))
    {
        return Unauthorized("Tipo de usuário não encontrado no token.");
    }

    var tipoUsuario = (TipoUsuario)tipoUsuarioInt;

    // Query base com includes
    IQueryable<Chamado> query = _context.Chamados
        .Include(c => c.Solicitante)
        .Include(c => c.Tecnico!)
            .ThenInclude(t => t.TecnicoTIPerfil)
        .Include(c => c.Status)
        .Include(c => c.Prioridade)
        .Include(c => c.Categoria);

    // Aplicar filtro baseado no tipo de usuário usando serviço de permissões
    switch (tipoUsuario)
    {
        case TipoUsuario.Colaborador: // Vê apenas seus próprios chamados
            query = query.Where(c => c.SolicitanteId == usuarioId);
            _logger.LogInformation($"Colaborador {usuarioId} visualizando apenas seus próprios chamados.");
            break;

        case TipoUsuario.TecnicoTI: // Vê apenas chamados atribuídos a ele
            query = query.Where(c => c.TecnicoId == usuarioId);
            _logger.LogInformation($"Técnico {usuarioId} visualizando apenas chamados atribuídos a ele.");
            break;

        case TipoUsuario.Admin: // Vê todos os chamados
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

    var response = chamados.Select(chamado => MapToResponseDto(chamado, tipoUsuario == TipoUsuario.Admin)).ToList();

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
    if (string.IsNullOrEmpty(tipoUsuarioClaim) || !int.TryParse(tipoUsuarioClaim, out var tipoUsuarioInt))
    {
        return Unauthorized("Tipo de usuário não encontrado no token.");
    }

    var tipoUsuario = (TipoUsuario)tipoUsuarioInt;

    var chamado = await ObterChamadoCompletoAsync(id);

    if (chamado == null)
    {
        return NotFound("Chamado não encontrado.");
    }

    // Validar permissão de acesso ao chamado usando serviço de permissões
    if (!PermissoesService.PodeVisualizarChamado(chamado, usuarioId, tipoUsuario))
    {
        _logger.LogWarning($"Usuário {usuarioId} (Tipo {tipoUsuario}) tentou acessar chamado {id} sem permissão.");
        return StatusCode(StatusCodes.Status403Forbidden, "Acesso negado ao chamado solicitado.");
    }

    _logger.LogInformation($"Usuário {usuarioId} (Tipo {tipoUsuario}) acessou chamado {id}.");

    return Ok(MapToResponseDto(chamado, tipoUsuario == TipoUsuario.Admin));
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
    if (string.IsNullOrEmpty(tipoUsuarioClaim) || !int.TryParse(tipoUsuarioClaim, out var tipoUsuarioInt))
    {
        return Unauthorized("Tipo de usuário não encontrado no token.");
    }

    var tipoUsuario = (TipoUsuario)tipoUsuarioInt;

    var chamado = await _context.Chamados.FindAsync(id);
    if (chamado == null)
    {
        return NotFound("Chamado não encontrado.");
    }

    // Validar permissão: Verificar se pode editar usando serviço de permissões
    if (!PermissoesService.PodeEditarChamado(chamado, usuarioId, tipoUsuario))
    {
        _logger.LogWarning($"Usuário {usuarioId} (Tipo {tipoUsuario}) tentou atualizar chamado {id} sem permissão.");
        return StatusCode(StatusCodes.Status403Forbidden, 
            "Você não tem permissão para editar este chamado. Apenas o criador (em chamados abertos) ou administradores podem editá-lo.");
    }

    // Valida se o novo StatusId existe
    var statusExiste = await _context.Status.AnyAsync(s => s.Id == request.StatusId);
    if (!statusExiste)
    {
        return BadRequest("O StatusId fornecido é inválido.");
    }

    // Validar mudança de status
    if (!PermissoesService.PodeMudarStatus(chamado, usuarioId, tipoUsuario, request.StatusId))
    {
        _logger.LogWarning($"Usuário {usuarioId} (Tipo {tipoUsuario}) tentou mudar status do chamado {id} sem permissão.");
        return StatusCode(StatusCodes.Status403Forbidden, 
            "Você não tem permissão para mudar o status deste chamado.");
    }

    // --- INÍCIO DA NOVA LÓGICA ---
    // 1. Atualiza sempre a data da última modificação
    chamado.DataUltimaAtualizacao = DateTime.UtcNow;

    // 2. Verifica se o novo status é 'Fechado' (vamos assumir que o ID 3 é "Encerrado")
    if (request.StatusId == 3) 
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

    // Apenas Admin pode reatribuir técnico
    if (request.TecnicoId.HasValue)
    {
        if (!PermissoesService.PodeAtribuirTecnico(tipoUsuario))
        {
            return StatusCode(StatusCodes.Status403Forbidden, 
                "Apenas administradores podem atribuir ou reatribuir técnicos.");
        }

        var tecnicoExiste = await _context.Usuarios.AnyAsync(u => u.Id == request.TecnicoId.Value && u.Ativo && u.TipoUsuario == 2);
        if (!tecnicoExiste)
        {
            return BadRequest("O TecnicoId fornecido é inválido ou o usuário não é um técnico ativo.");
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

    return Ok(MapToResponseDto(chamadoAtualizado, tipoUsuario == TipoUsuario.Admin));
}

/// <summary>
/// Endpoint específico para técnicos encerrarem seus chamados
/// </summary>
[HttpPost("{id}/encerrar")]
public async Task<IActionResult> EncerrarChamado(int id, [FromBody] EncerrarChamadoDto? request)
{
    // Obter informações do usuário autenticado
    var usuarioIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
    if (string.IsNullOrEmpty(usuarioIdClaim) || !int.TryParse(usuarioIdClaim, out var usuarioId))
    {
        return Unauthorized("Usuário não autenticado.");
    }

    // Obter tipo de usuário
    var tipoUsuarioClaim = User.FindFirst("TipoUsuario")?.Value;
    if (string.IsNullOrEmpty(tipoUsuarioClaim) || !int.TryParse(tipoUsuarioClaim, out var tipoUsuarioInt))
    {
        return Unauthorized("Tipo de usuário não encontrado no token.");
    }

    var tipoUsuario = (TipoUsuario)tipoUsuarioInt;

    var chamado = await _context.Chamados
        .Include(c => c.Solicitante)
        .Include(c => c.Tecnico)
        .Include(c => c.Status)
        .Include(c => c.Prioridade)
        .Include(c => c.Categoria)
        .FirstOrDefaultAsync(c => c.Id == id);

    if (chamado == null)
    {
        return NotFound("Chamado não encontrado.");
    }

    // Validar permissão para encerrar
    if (!PermissoesService.PodeEncerrarChamado(chamado, usuarioId, tipoUsuario))
    {
        _logger.LogWarning($"Usuário {usuarioId} (Tipo {tipoUsuario}) tentou encerrar chamado {id} sem permissão.");
        return StatusCode(StatusCodes.Status403Forbidden, 
            "Você não tem permissão para encerrar este chamado. Apenas o técnico atribuído ou administradores podem encerrá-lo.");
    }

    // Verificar se já está encerrado
    if (chamado.StatusId == 3) // Status Encerrado
    {
        return BadRequest("Este chamado já está encerrado.");
    }

    // Encerrar o chamado
    chamado.StatusId = 3; // Status Encerrado
    chamado.DataFechamento = DateTime.UtcNow;
    chamado.DataUltimaAtualizacao = DateTime.UtcNow;

    // TODO: Quando implementar comentários, salvar a solução aqui
    // if (request != null && !string.IsNullOrWhiteSpace(request.Solucao)) { ... }

    await _context.SaveChangesAsync();

    var chamadoAtualizado = await ObterChamadoCompletoAsync(id);
    if (chamadoAtualizado == null)
    {
        return NotFound("Chamado não encontrado após encerramento.");
    }

    _logger.LogInformation($"Chamado {id} encerrado por usuário {usuarioId} (Tipo {tipoUsuario}).");

    return Ok(MapToResponseDto(chamadoAtualizado, tipoUsuario == TipoUsuario.Admin));
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
                .ThenInclude(t => t!.TecnicoTIPerfil)
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
                : null,
            
            // Campos adicionais para atribuição inteligente
            TecnicoAtribuidoId = chamado.TecnicoAtribuidoId,
            TecnicoAtribuidoNome = chamado.TecnicoAtribuido?.NomeCompleto,
            TecnicoAtribuidoNivel = chamado.TecnicoAtribuido?.TecnicoTIPerfil?.NivelTecnico,
            CategoriaNome = chamado.Categoria?.Nome,
            PrioridadeNome = chamado.Prioridade?.Nome
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
    
    #region Endpoints de Atribuição e Métricas
    
    /// <summary>
    /// Calcula scores de técnicos disponíveis para uma categoria/prioridade
    /// </summary>
    [HttpGet("tecnicos/scores")]
    [AllowAnonymous] // Permitir acesso para testes
    public async Task<IActionResult> GetTecnicosScores(
        [FromQuery] int categoriaId,
        [FromQuery] int prioridadeId)
    {
        try
        {
            var scores = await _handoffService.CalcularScoresTecnicosAsync(categoriaId, prioridadeId);
            
            return Ok(new
            {
                Success = true,
                TotalTecnicos = scores.Count,
                Tecnicos = scores.Select(t => new
                {
                    t.TecnicoId,
                    t.NomeCompleto,
                    t.AreaAtuacao,
                    Score = Math.Round(t.ScoreTotal, 2),
                    Breakdown = new
                    {
                        Especialidade = Math.Round(t.Breakdown.Especialidade, 2),
                        Disponibilidade = Math.Round(t.Breakdown.Disponibilidade, 2),
                        Performance = Math.Round(t.Breakdown.Performance, 2),
                        Prioridade = Math.Round(t.Breakdown.Prioridade, 2)
                    },
                    t.Estatisticas.ChamadosAtivos,
                    t.Estatisticas.ChamadosResolvidos,
                    t.Estatisticas.TempoMedioResolucao,
                    t.Estatisticas.CapacidadeRestante
                })
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao calcular scores de técnicos");
            return StatusCode(500, new { Error = "Erro ao calcular scores" });
        }
    }
    
    /// <summary>
    /// Redistribui chamados de um técnico indisponível
    /// </summary>
    [HttpPost("tecnicos/{tecnicoId}/redistribuir")]
    [Authorize(Roles = "3")] // Apenas Admin
    public async Task<IActionResult> RedistribuirChamados(int tecnicoId)
    {
        try
        {
            var quantidade = await _handoffService.RedistribuirChamadosAsync(tecnicoId);
            
            return Ok(new
            {
                Success = true,
                Message = $"{quantidade} chamados redistribuídos com sucesso",
                ChamadosRedistribuidos = quantidade
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao redistribuir chamados do técnico {tecnicoId}");
            return StatusCode(500, new { Error = "Erro ao redistribuir chamados" });
        }
    }
    
    /// <summary>
    /// Obtém métricas de distribuição de carga entre técnicos
    /// </summary>
    [HttpGet("metricas/distribuicao")]
    [Authorize(Roles = "3")] // Apenas Admin
    public async Task<IActionResult> GetDistribuicaoCarga()
    {
        try
        {
            var distribuicao = await _handoffService.ObterDistribuicaoCargaAsync();
            
            // Obter nomes dos técnicos
            var tecnicosIds = distribuicao.Keys.ToList();
            var tecnicos = await _context.Usuarios
                .Where(u => tecnicosIds.Contains(u.Id))
                .Select(u => new { u.Id, u.NomeCompleto })
                .ToDictionaryAsync(u => u.Id, u => u.NomeCompleto);
            
            var resultado = distribuicao.Select(d => new
            {
                TecnicoId = d.Key,
                TecnicoNome = tecnicos.ContainsKey(d.Key) ? tecnicos[d.Key] : "Desconhecido",
                ChamadosAtivos = d.Value,
                CapacidadeRestante = Math.Max(0, 10 - d.Value), // MAX_CHAMADOS_POR_TECNICO = 10
                PercentualCarga = Math.Round((d.Value / 10.0) * 100, 1)
            }).OrderByDescending(x => x.ChamadosAtivos);
            
            return Ok(new
            {
                Success = true,
                TotalTecnicos = distribuicao.Count,
                CargaTotal = distribuicao.Values.Sum(),
                CargaMedia = distribuicao.Any() ? Math.Round(distribuicao.Values.Average(), 1) : 0,
                Tecnicos = resultado
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter distribuição de carga");
            return StatusCode(500, new { Error = "Erro ao obter métricas" });
        }
    }
    
    /// <summary>
    /// Obtém histórico de atribuições de um chamado
    /// </summary>
    [HttpGet("{id}/atribuicoes")]
    public async Task<IActionResult> GetHistoricoAtribuicoes(int id)
    {
        try
        {
            var atribuicoes = await _context.AtribuicoesLog
                .Include(a => a.Tecnico)
                .Where(a => a.ChamadoId == id)
                .OrderByDescending(a => a.DataAtribuicao)
                .Select(a => new
                {
                    a.Id,
                    a.DataAtribuicao,
                    TecnicoId = a.TecnicoId,
                    TecnicoNome = a.Tecnico!.NomeCompleto,
                    Score = Math.Round(a.Score, 2),
                    a.MetodoAtribuicao,
                    a.MotivoSelecao,
                    a.CargaTrabalho,
                    a.FallbackGenerico
                })
                .ToListAsync();
            
            return Ok(new
            {
                Success = true,
                TotalAtribuicoes = atribuicoes.Count,
                Atribuicoes = atribuicoes
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao obter histórico de atribuições do chamado {id}");
            return StatusCode(500, new { Error = "Erro ao obter histórico" });
        }
    }
    
    #endregion
}

// DTO para requisição de análise
public class AnalisarChamadoRequestDto
{
    public string DescricaoProblema { get; set; } = string.Empty;
}
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SistemaChamados.Application.DTOs;
using SistemaChamados.Core.Entities;
using SistemaChamados.Data;
using SistemaChamados.Services;
using System.Collections.Generic;
using System.Linq;
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
        
        // --- INÍCIO LÓGICA SLA (POST) ---
        // Busca o 'Nivel' da prioridade para o cálculo
        var prioridadeSla = await _context.Prioridades.FindAsync(request.PrioridadeId);
        if (prioridadeSla == null)
        {
            return BadRequest("PrioridadeId inválido.");
        }
        // --- FIM LÓGICA SLA (POST) ---

        var agora = DateTime.UtcNow;
        var novoChamado = new Chamado
        {
            Titulo = request.Titulo,
            Descricao = request.Descricao,
            DataAbertura = agora,
            DataUltimaAtualizacao = agora,
            SolicitanteId = solicitanteId,
            StatusId = 1, // Assumindo que o ID 1 seja "Aberto"
            PrioridadeId = request.PrioridadeId,
            CategoriaId = request.CategoriaId,
            // --- ADICIONAR ESTA LINHA ---
            SlaDataExpiracao = CalcularSla(prioridadeSla.Nivel, DateTime.UtcNow)
        };

        _context.Chamados.Add(novoChamado);
        await _context.SaveChangesAsync();

    var chamadoCriado = await LoadChamadoDtoAsync(novoChamado.Id);
        if (chamadoCriado == null)
        {
            _logger.LogError("Falha ao projetar o chamado criado (ID: {ChamadoId}).", novoChamado.Id);
            return StatusCode(500, "Erro ao projetar o chamado criado.");
        }

        return Ok(chamadoCriado);
    }
[HttpGet]
public async Task<IActionResult> GetChamados([FromQuery] int? statusId, [FromQuery] int? tecnicoId, [FromQuery] int? solicitanteId, [FromQuery] int? prioridadeId, [FromQuery] string? termoBusca)
{
    _logger.LogInformation("GetChamados - Recebido pedido com filtros: statusId={StatusId}, tecnicoId={TecnicoId}, solicitanteId={SolicitanteId}, prioridadeId={PrioridadeId}, termoBusca={TermoBusca}", statusId, tecnicoId, solicitanteId, prioridadeId, termoBusca);
    try
    {
        // --- INÍCIO LÓGICA VERIFICAÇÃO SLA ---
        // IDs: 1=Aberto, 2=Em Andamento, 3=Aguardando Resposta, 5=Violado
        var statusParaVerificar = new[] { 1, 2, 3 };
        var statusVioladoId = 5; 
        
        // Busca chamados abertos/em andamento/aguardando que passaram do prazo
        var chamadosViolados = await _context.Chamados
            .Where(c => statusParaVerificar.Contains(c.StatusId) &&
                        c.SlaDataExpiracao.HasValue &&
                        c.SlaDataExpiracao < DateTime.UtcNow)
            .ToListAsync();

        if (chamadosViolados.Any())
        {
            foreach (var chamado in chamadosViolados)
            {
                _logger.LogWarning("SLA VIOLADO: Chamado ID {ChamadoId} movido para status 'Violado'.", chamado.Id);
                chamado.StatusId = statusVioladoId;
                chamado.DataUltimaAtualizacao = DateTime.UtcNow;
            }
            await _context.SaveChangesAsync(); // Salva as alterações de status
        }
        // --- FIM LÓGICA VERIFICAÇÃO SLA ---

        // 1. Começa com a consulta base
    var query = _context.Chamados.AsQueryable();
        // 2. Aplica filtro de StatusId se fornecido
        if (statusId.HasValue)
        {
            query = query.Where(c => c.StatusId == statusId.Value);
            _logger.LogInformation("Filtro StatusId={StatusId} aplicado.", statusId.Value);
        }
        // 3. Aplica filtro de TecnicoId se fornecido
        if (tecnicoId.HasValue)
        {
            if (tecnicoId.Value == 0) 
            {
               query = query.Where(c => c.TecnicoId == null); // Busca não atribuídos
               _logger.LogInformation("Filtro TecnicoId=NULL aplicado.");
            }
            else 
            {
               query = query.Where(c => c.TecnicoId == tecnicoId.Value); // Busca por técnico específico
               _logger.LogInformation("Filtro TecnicoId={TecnicoId} aplicado.", tecnicoId.Value);
            }
        }
        // 4. Aplica filtro de SolicitanteId se fornecido
        if (solicitanteId.HasValue)
        {
            query = query.Where(c => c.SolicitanteId == solicitanteId.Value);
            _logger.LogInformation("Filtro SolicitanteId={SolicitanteId} aplicado.", solicitanteId.Value);
        }

        // 5. Aplica filtro de PrioridadeId se fornecido
        if (prioridadeId.HasValue)
        {
            query = query.Where(c => c.PrioridadeId == prioridadeId.Value);
            _logger.LogInformation("Filtro PrioridadeId={PrioridadeId} aplicado.", prioridadeId.Value);
        }

        // 6. Aplica filtro de Termo de Busca se fornecido
        if (!string.IsNullOrWhiteSpace(termoBusca))
        {
            string busca = termoBusca.ToLower().Trim();
            _logger.LogInformation("Filtro termoBusca='{TermoBusca}' aplicado.", busca);

            // Tenta converter a busca para ID
            int.TryParse(busca, out int idBusca);

            query = query.Where(c => 
                c.Id == idBusca || // Busca por ID
                c.Titulo.ToLower().Contains(busca) || // Busca no Título
                c.Categoria.Nome.ToLower().Contains(busca) // Busca no Nome da Categoria
            );
        }

        // 7. Restrição por usuário autenticado (exceto quando admin solicitar todos)
        var usuarioIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (!int.TryParse(usuarioIdClaim, out var usuarioAutenticadoId))
        {
            _logger.LogWarning("Token sem NameIdentifier ou inválido ao acessar GetChamados.");
            return Unauthorized("Token inválido.");
        }

        var tipoUsuarioClaim = User.FindFirst("TipoUsuario")?.Value;
        var incluirTodos = false;
        if (tipoUsuarioClaim == "3" && Request.Query.TryGetValue("incluirTodos", out var incluirTodosRaw))
        {
            if (bool.TryParse(incluirTodosRaw.ToString(), out var parsed))
            {
                incluirTodos = parsed;
            }
        }

        if (!incluirTodos)
        {
            query = query.Where(c => c.SolicitanteId == usuarioAutenticadoId || c.TecnicoId == usuarioAutenticadoId);
            _logger.LogInformation("Filtro de usuário aplicado em GetChamados para o usuário {UsuarioId}", usuarioAutenticadoId);
        }

        // 8. Executa a consulta com todos os filtros e projeta para o DTO utilizando o mesmo mapeador central
        var chamados = await query
            .Include(c => c.Categoria)
            .Include(c => c.Status)
            .Include(c => c.Prioridade)
            .Include(c => c.Solicitante)
            .Include(c => c.Tecnico)
            .Include(c => c.FechadoPor)
            .Include(c => c.Comentarios)
                .ThenInclude(com => com.Usuario)
            .AsNoTracking()
            .OrderByDescending(c => c.DataAbertura)
            .ToListAsync();

        var categoriasLookup = await BuildCategoriasLookupAsync(
            chamados.Select(c => c.Tecnico?.EspecialidadeCategoriaId));

        var chamadosDto = chamados
            .Select(chamado =>
            {
                var historico = MapHistorico(chamado);
                var tecnicoEspecialidadeNome = ResolveTecnicoEspecialidadeNome(
                    chamado.Tecnico?.EspecialidadeCategoriaId,
                    categoriasLookup);
                return MapChamadoToDto(chamado, tecnicoEspecialidadeNome, historico);
            })
            .ToList();

        _logger.LogInformation("GetChamados - Consulta finalizada. Resultados encontrados: {Count}", chamadosDto.Count);
        return Ok(chamadosDto); 
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Erro ao buscar chamados com filtros.");
        return StatusCode(500, "Erro interno ao buscar chamados.");
    }
}

[HttpGet("{id}")]
public async Task<IActionResult> GetChamadoPorId(int id)
{
    var chamado = await _context.Chamados
        .Include(c => c.Solicitante)
        .Include(c => c.Tecnico) // Inclui o técnico também, se houver
        .Include(c => c.FechadoPor)
        .Include(c => c.Status)
        .Include(c => c.Prioridade)
        .Include(c => c.Categoria)
        .Include(c => c.Comentarios)
            .ThenInclude(com => com.Usuario)
        .FirstOrDefaultAsync(c => c.Id == id);

    if (chamado == null)
    {
        return NotFound("Chamado não encontrado.");
    }

    if (!TryObterUsuarioContexto(out var usuarioAutenticadoId, out var incluirTodos, out var contextoFalha))
    {
        return contextoFalha!;
    }

    if (!UsuarioTemAcessoAoChamado(chamado, usuarioAutenticadoId, incluirTodos))
    {
        _logger.LogWarning("GetChamadoPorId: Acesso negado ao usuário {UsuarioId} para o chamado {ChamadoId}", usuarioAutenticadoId, id);
        return Forbid();
    }

    var categoriasLookup = await BuildCategoriasLookupAsync(new[] { chamado.Tecnico?.EspecialidadeCategoriaId });
    var historico = MapHistorico(chamado);
    var tecnicoEspecialidadeNome = ResolveTecnicoEspecialidadeNome(chamado.Tecnico?.EspecialidadeCategoriaId, categoriasLookup);
    var dto = MapChamadoToDto(chamado, tecnicoEspecialidadeNome, historico);
    return Ok(dto);
}

[HttpPut("{id}")]
public async Task<IActionResult> AtualizarChamado(int id, [FromBody] AtualizarChamadoDto request)
{
    var chamado = await _context.Chamados.FindAsync(id);
    if (chamado == null)
    {
        return NotFound("Chamado não encontrado.");
    }

    if (!TryObterUsuarioContexto(out var usuarioAutenticadoId, out var incluirTodos, out var contextoFalha))
    {
        return contextoFalha!;
    }

    if (!UsuarioTemAcessoAoChamado(chamado, usuarioAutenticadoId, incluirTodos))
    {
        _logger.LogWarning("AtualizarChamado: Acesso negado ao usuário {UsuarioId} para o chamado {ChamadoId}", usuarioAutenticadoId, id);
        return Forbid();
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

    // 2. Verifica se o novo status é 'Fechado' (StatusId = 5)
    if (request.StatusId == 5 && chamado.StatusId != 5) 
    {
        // Registra data e usuário que fechou o chamado
        chamado.DataFechamento = DateTime.UtcNow;
        
        // Captura o usuário autenticado que está fechando o chamado
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (!string.IsNullOrEmpty(userIdClaim) && int.TryParse(userIdClaim, out int userId))
        {
            chamado.FechadoPorId = userId;
        }
    }
    else if (request.StatusId != 5)
    {
        // Garante que a data de fechamento e usuário sejam nulos se o chamado for reaberto
        chamado.DataFechamento = null;
        chamado.FechadoPorId = null;
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

    var chamadoAtualizado = await LoadChamadoDtoAsync(chamado.Id);
    if (chamadoAtualizado == null)
    {
        _logger.LogError("Falha ao projetar o chamado fechado (ID: {ChamadoId}).", chamado.Id);
        return StatusCode(500, "Erro ao projetar o chamado fechado.");
    }

    return Ok(chamadoAtualizado);
}

[HttpPost("{id}/fechar")]
public async Task<IActionResult> FecharChamado(int id)
{
    var chamado = await _context.Chamados.FindAsync(id);
    if (chamado == null)
    {
        return NotFound("Chamado não encontrado.");
    }

    if (!TryObterUsuarioContexto(out var usuarioAutenticadoId, out var incluirTodos, out var contextoFalha))
    {
        return contextoFalha!;
    }

    if (!UsuarioTemAcessoAoChamado(chamado, usuarioAutenticadoId, incluirTodos))
    {
        _logger.LogWarning("FecharChamado: Acesso negado ao usuário {UsuarioId} para o chamado {ChamadoId}", usuarioAutenticadoId, id);
        return Forbid();
    }

    if (chamado.StatusId == 5 && chamado.DataFechamento.HasValue)
    {
        return BadRequest("Chamado já está fechado.");
    }

    var statusFechado = await _context.Status.FirstOrDefaultAsync(s => s.Id == 5);
    if (statusFechado == null)
    {
        return StatusCode(500, "Status 'Fechado' não está configurado.");
    }

    chamado.StatusId = statusFechado.Id;
    chamado.DataUltimaAtualizacao = DateTime.UtcNow;
    chamado.DataFechamento = DateTime.UtcNow;
    chamado.FechadoPorId = usuarioAutenticadoId;

    _context.Chamados.Update(chamado);
    await _context.SaveChangesAsync();

    var dto = await LoadChamadoDtoAsync(chamado.Id);
    if (dto == null)
    {
        return StatusCode(500, "Erro ao projetar o chamado fechado.");
    }

    return Ok(dto);
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
            _logger.LogWarning("Falha ao obter análise da IA para o chamado. Descrição: {Descricao}", request.DescricaoProblema);
            return StatusCode(503, new 
            { 
                erro = "Serviço de IA indisponível",
                mensagem = "Não foi possível obter análise da IA no momento. Verifique se as chaves de API estão configuradas no appsettings.json (Gemini:ApiKey ou OpenAI:ApiKey).",
                sugestao = "Tente usar a classificação manual ou entre em contato com o administrador do sistema."
            });
        }

        // 2. Pega o ID do usuário que fez a requisição
        var solicitanteIdStr = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
        if (solicitanteIdStr == null)
        {
            return Unauthorized();
        }
        var solicitanteId = int.Parse(solicitanteIdStr);

        // --- INÍCIO LÓGICA SLA (ANALISAR) ---
        // Busca o 'Nivel' da prioridade para o cálculo
        var prioridadeSla = await _context.Prioridades.FindAsync(analise.PrioridadeId);
        if (prioridadeSla == null)
        {
            return StatusCode(500, "A IA retornou uma PrioridadeId inválida.");
        }
        // --- FIM LÓGICA SLA (ANALISAR) ---

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
            TecnicoId = analise.TecnicoId,
             // --- ADICIONAR ESTA LINHA ---
            SlaDataExpiracao = CalcularSla(prioridadeSla.Nivel, DateTime.UtcNow)
        };

        // 4. Salva o novo chamado no banco de dados
        _context.Chamados.Add(novoChamado);
        await _context.SaveChangesAsync();

        // 5. Reprojeta o chamado criado para o DTO completo esperado pelos clientes
    var chamadoCriado = await LoadChamadoDtoAsync(novoChamado.Id, analise);
        if (chamadoCriado == null)
        {
            _logger.LogError("Falha ao projetar o chamado analisado (ID: {ChamadoId}).", novoChamado.Id);
            return StatusCode(500, "Erro ao projetar o chamado criado pela análise.");
        }

        return CreatedAtAction(nameof(GetChamadoPorId), new { id = novoChamado.Id }, chamadoCriado);
    }
    catch (Exception ex)
    {
        // Logar o erro real no seu console
        _logger.LogError(ex, "Erro no processo de análise e criação de chamado.");
        return StatusCode(500, "Ocorreu um erro inesperado ao processar seu chamado.");
    }
}

// ===============================================
// INÍCIO - NOVOS ENDPOINTS DE COMENTÁRIOS
// ===============================================

[HttpGet("{chamadoId}/comentarios")]
public async Task<IActionResult> GetComentarios(int chamadoId)
{
    var chamado = await _context.Chamados
        .AsNoTracking()
        .FirstOrDefaultAsync(c => c.Id == chamadoId);
    if (chamado == null)
    {
        return NotFound("Chamado não encontrado.");
    }

    if (!TryObterUsuarioContexto(out var usuarioAutenticadoId, out var incluirTodos, out var contextoFalha))
    {
        return contextoFalha!;
    }

    if (!UsuarioTemAcessoAoChamado(chamado, usuarioAutenticadoId, incluirTodos))
    {
        _logger.LogWarning("GetComentarios: Acesso negado ao usuário {UsuarioId} para o chamado {ChamadoId}", usuarioAutenticadoId, chamadoId);
        return Forbid();
    }

    var comentarios = await _context.Comentarios
        .Where(c => c.ChamadoId == chamadoId)
        .Include(c => c.Usuario) // Inclui dados do usuário
        .OrderBy(c => c.DataCriacao)
        .Select(c => new ComentarioResponseDto
        {
            Id = c.Id,
            ChamadoId = c.ChamadoId,
            Texto = c.Texto,
            DataCriacao = c.DataCriacao,
            DataHora = c.DataCriacao,
            UsuarioId = c.UsuarioId,
            UsuarioNome = c.Usuario == null ? string.Empty : c.Usuario.NomeCompleto,
            Usuario = c.Usuario == null ? null : new UsuarioResumoDto
            {
                Id = c.Usuario.Id,
                NomeCompleto = c.Usuario.NomeCompleto,
                Email = c.Usuario.Email,
                TipoUsuario = c.Usuario.TipoUsuario
            }
        })
        .ToListAsync();
        
    // Lidar com a serialização $values
    if (!comentarios.Any())
    {
        return Ok(new List<ComentarioResponseDto>());
    }

    return Ok(comentarios);
}

[HttpPost("{chamadoId}/comentarios")]
public async Task<IActionResult> AdicionarComentario(int chamadoId, [FromBody] CriarComentarioDto request)
{
    if (!ModelState.IsValid)
    {
        return BadRequest(ModelState);
    }

    var chamado = await _context.Chamados.FindAsync(chamadoId);
    if (chamado == null)
    {
        return NotFound("Chamado não encontrado.");
    }

    if (!TryObterUsuarioContexto(out var usuarioAutenticadoId, out var incluirTodos, out var contextoFalha))
    {
        return contextoFalha!;
    }

    if (!UsuarioTemAcessoAoChamado(chamado, usuarioAutenticadoId, incluirTodos))
    {
        _logger.LogWarning("AdicionarComentario: Acesso negado ao usuário {UsuarioId} para o chamado {ChamadoId}", usuarioAutenticadoId, chamadoId);
        return Forbid();
    }

    var novoComentario = new Comentario
    {
        Texto = request.Texto,
        ChamadoId = chamadoId,
        UsuarioId = usuarioAutenticadoId,
        DataCriacao = DateTime.UtcNow
    };

    // Atualiza a data de última atualização do chamado
    chamado.DataUltimaAtualizacao = DateTime.UtcNow;
    _context.Chamados.Update(chamado);

    _context.Comentarios.Add(novoComentario);
    await _context.SaveChangesAsync();

    var usuarioDto = await _context.Usuarios
        .Where(u => u.Id == usuarioAutenticadoId)
        .Select(u => new UsuarioResumoDto
        {
            Id = u.Id,
            NomeCompleto = u.NomeCompleto,
            Email = u.Email,
            TipoUsuario = u.TipoUsuario
        })
        .FirstOrDefaultAsync();

    var responseDto = new ComentarioResponseDto
    {
        Id = novoComentario.Id,
        ChamadoId = novoComentario.ChamadoId,
        Texto = novoComentario.Texto,
        DataCriacao = novoComentario.DataCriacao,
        DataHora = novoComentario.DataCriacao,
        UsuarioId = usuarioAutenticadoId,
        UsuarioNome = usuarioDto?.NomeCompleto ?? "Usuário",
        Usuario = usuarioDto
    };

    return CreatedAtAction(nameof(GetComentarios), new { chamadoId = chamadoId }, responseDto);
}

// ===============================================
// FIM - NOVOS ENDPOINTS DE COMENTÁRIOS
// ===============================================

private async Task<ChamadoDto?> LoadChamadoDtoAsync(int chamadoId, AnaliseChamadoResponseDto? analise = null)
{
    var chamado = await _context.Chamados
        .Include(c => c.Categoria)
        .Include(c => c.Status)
        .Include(c => c.Prioridade)
        .Include(c => c.Solicitante)
        .Include(c => c.Tecnico)
        .Include(c => c.FechadoPor)
        .Include(c => c.Comentarios)
            .ThenInclude(com => com.Usuario)
        .AsNoTracking()
        .FirstOrDefaultAsync(c => c.Id == chamadoId);

    if (chamado == null)
    {
        return null;
    }

    var categoriasLookup = await BuildCategoriasLookupAsync(new[] { chamado.Tecnico?.EspecialidadeCategoriaId });
    var historico = MapHistorico(chamado);
    var tecnicoEspecialidadeNome = ResolveTecnicoEspecialidadeNome(chamado.Tecnico?.EspecialidadeCategoriaId, categoriasLookup);

    return MapChamadoToDto(chamado, tecnicoEspecialidadeNome, historico, analise);
}

private static ChamadoDto MapChamadoToDto(Chamado chamado, string? tecnicoEspecialidadeNome, List<HistoricoItemDto>? historico = null, AnaliseChamadoResponseDto? analise = null)
{
    return new ChamadoDto
    {
        Id = chamado.Id,
        Titulo = chamado.Titulo,
        Descricao = chamado.Descricao,
        DataAbertura = chamado.DataAbertura,
        DataUltimaAtualizacao = chamado.DataUltimaAtualizacao,
        DataFechamento = chamado.DataFechamento,
        Categoria = chamado.Categoria == null ? null : new CategoriaDto
        {
            Id = chamado.Categoria.Id,
            Nome = chamado.Categoria.Nome,
            Descricao = chamado.Categoria.Descricao
        },
        Prioridade = chamado.Prioridade == null ? null : new PrioridadeDto
        {
            Id = chamado.Prioridade.Id,
            Nome = chamado.Prioridade.Nome,
            Nivel = chamado.Prioridade.Nivel,
            Descricao = chamado.Prioridade.Descricao
        },
        Status = chamado.Status == null ? null : new StatusDto
        {
            Id = chamado.Status.Id,
            Nome = chamado.Status.Nome,
            Descricao = chamado.Status.Descricao
        },
        Solicitante = chamado.Solicitante == null ? null : new UsuarioResumoDto
        {
            Id = chamado.Solicitante.Id,
            NomeCompleto = chamado.Solicitante.NomeCompleto,
            Email = chamado.Solicitante.Email,
            TipoUsuario = chamado.Solicitante.TipoUsuario
        },
        Tecnico = chamado.Tecnico == null ? null : new UsuarioResumoDto
        {
            Id = chamado.Tecnico.Id,
            NomeCompleto = chamado.Tecnico.NomeCompleto,
            Email = chamado.Tecnico.Email,
            TipoUsuario = chamado.Tecnico.TipoUsuario
        },
        FechadoPor = chamado.FechadoPor == null ? null : new UsuarioResumoDto
        {
            Id = chamado.FechadoPor.Id,
            NomeCompleto = chamado.FechadoPor.NomeCompleto,
            Email = chamado.FechadoPor.Email,
            TipoUsuario = chamado.FechadoPor.TipoUsuario
        },
        TecnicoAtribuidoId = chamado.TecnicoId,
        TecnicoAtribuidoNome = chamado.Tecnico?.NomeCompleto,
        TecnicoAtribuidoNivel = chamado.Tecnico?.EspecialidadeCategoriaId,
        TecnicoAtribuidoNivelDescricao = tecnicoEspecialidadeNome,
        Historico = historico ?? new List<HistoricoItemDto>(),
        Analise = analise
    };
}

private static List<HistoricoItemDto> MapHistorico(Chamado chamado)
{
    var historico = new List<HistoricoItemDto>();

    // Evento inicial de criação do chamado
    historico.Add(new HistoricoItemDto
    {
        Id = -1, // identificador sintético para eventos do sistema
        DataHora = chamado.DataAbertura,
        TipoEvento = "Criacao",
        Descricao = "Chamado criado",
        Usuario = chamado.Solicitante?.NomeCompleto
    });

    // Comentários anexados ao chamado
    if (chamado.Comentarios != null)
    {
        historico.AddRange(
            chamado.Comentarios
                .OrderBy(com => com.DataCriacao)
                .Select(com => new HistoricoItemDto
                {
                    Id = com.Id,
                    DataHora = com.DataCriacao,
                    TipoEvento = "Comentario",
                    Descricao = com.Texto,
                    Usuario = com.Usuario?.NomeCompleto
                }));
    }

    // Evento de fechamento, quando aplicável
    if (chamado.DataFechamento.HasValue)
    {
        historico.Add(new HistoricoItemDto
        {
            Id = -2,
            DataHora = chamado.DataFechamento.Value,
            TipoEvento = "Fechamento",
            Descricao = "Chamado encerrado",
            Usuario = chamado.FechadoPor?.NomeCompleto ?? "Sistema"
        });
    }

    // Evento de mudança de status (utiliza DataUltimaAtualizacao quando disponível)
    if (chamado.Status != null)
    {
        var dataStatus = chamado.DataUltimaAtualizacao ?? chamado.DataAbertura;
        historico.Add(new HistoricoItemDto
        {
            Id = -3,
            DataHora = dataStatus,
            TipoEvento = "MudancaStatus",
            Descricao = $"Status atualizado para '{chamado.Status.Nome}'",
            Usuario = chamado.Tecnico?.NomeCompleto
        });
    }

    return historico
        .OrderBy(item => item.DataHora)
        .ToList();
}

private async Task<IReadOnlyDictionary<int, string>> BuildCategoriasLookupAsync(IEnumerable<int?> categoriaIds)
{
    var ids = categoriaIds
        .Where(id => id.HasValue && id.Value > 0)
        .Select(id => id!.Value)
        .Distinct()
        .ToList();

    if (!ids.Any())
    {
        return new Dictionary<int, string>();
    }

    return await _context.Categorias
        .AsNoTracking()
        .Where(cat => ids.Contains(cat.Id))
        .ToDictionaryAsync(cat => cat.Id, cat => cat.Nome);
}

private static string? ResolveTecnicoEspecialidadeNome(int? especialidadeCategoriaId, IReadOnlyDictionary<int, string> categoriasLookup)
{
    if (!especialidadeCategoriaId.HasValue || especialidadeCategoriaId.Value <= 0)
    {
        return null;
    }

    return categoriasLookup.TryGetValue(especialidadeCategoriaId.Value, out var nome)
        ? nome
        : null;
}

private bool TryObterUsuarioContexto(out int usuarioAutenticadoId, out bool incluirTodos, out IActionResult? failureResult)
{
    usuarioAutenticadoId = 0;
    incluirTodos = false;
    failureResult = null;

    var usuarioIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
    if (!int.TryParse(usuarioIdClaim, out usuarioAutenticadoId))
    {
        _logger.LogWarning("Token sem NameIdentifier ou inválido para a requisição atual.");
        failureResult = Unauthorized("Token inválido.");
        return false;
    }

    var tipoUsuarioClaim = User.FindFirst("TipoUsuario")?.Value;
    if (tipoUsuarioClaim == "3" && Request.Query.TryGetValue("incluirTodos", out var incluirTodosRaw))
    {
        if (bool.TryParse(incluirTodosRaw.ToString(), out var parsed))
        {
            incluirTodos = parsed;
        }
    }

    return true;
}

private static bool UsuarioTemAcessoAoChamado(Chamado chamado, int usuarioAutenticadoId, bool incluirTodos)
{
    if (incluirTodos)
    {
        return true;
    }

    var isSolicitante = chamado.SolicitanteId == usuarioAutenticadoId;
    var isTecnico = chamado.TecnicoId.HasValue && chamado.TecnicoId.Value == usuarioAutenticadoId;

    return isSolicitante || isTecnico;
}

// ===============================================
// INÍCIO - FUNÇÕES HELPER DO SLA
// ===============================================

/**
 * Calcula a data de expiração do SLA baseado no nível de prioridade.
 * Nivel 3 (Alto) = 1 dia útil
 * Nivel 2 (Médio) = 3 dias úteis
 * Nivel 1 (Baixo) = 5 dias úteis
 */
private DateTime? CalcularSla(int nivelPrioridade, DateTime dataAbertura)
{
    int diasUteisParaAdicionar;

    switch (nivelPrioridade)
    {
        case 3: // Alta
            diasUteisParaAdicionar = 1;
            break;
        case 2: // Média
            diasUteisParaAdicionar = 3;
            break;
        case 1: // Baixa
            diasUteisParaAdicionar = 5;
            break;
        default: // Prioridade desconhecida, não define SLA
            return null;
    }

    // Define a data de expiração para o final do dia de trabalho
    var dataExpiracao = AddBusinessDays(dataAbertura, diasUteisParaAdicionar);
    
    // Retorna a data no final do dia (ex: 23:59:59)
    return dataExpiracao.Date.AddDays(1).AddTicks(-1);
}

/**
 * Adiciona um número de dias úteis (Seg-Sex) a uma data.
 */
private DateTime AddBusinessDays(DateTime date, int days)
{
    if (days == 0) return date;

    DateTime result = date;
    int daysAdded = 0;
    
    while (daysAdded < days)
    {
        result = result.AddDays(1);
        // Só incrementa o contador se o dia não for Sábado (6) ou Domingo (0)
        if (result.DayOfWeek != DayOfWeek.Saturday && result.DayOfWeek != DayOfWeek.Sunday)
        {
            daysAdded++;
        }
    }
    return result;
}

// ===============================================
// FIM - FUNÇÕES HELPER DO SLA
// ===============================================

}

// DTO para requisição de análise
public class AnalisarChamadoRequestDto
{
    public string DescricaoProblema { get; set; } = string.Empty;
}
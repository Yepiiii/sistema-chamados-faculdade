using System.Linq;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SistemaChamados.Application.DTOs;
using SistemaChamados.Core.Entities;
using SistemaChamados.Data;

namespace SistemaChamados.Services;

public class HandoffService : IHandoffService
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<HandoffService> _logger;
    
    // Constantes de configuração
    private const int MAX_CHAMADOS_POR_TECNICO = 10; // Limite de carga
    private const double PESO_ESPECIALIDADE = 30.0;
    private const double PESO_DISPONIBILIDADE = 25.0;
    private const double PESO_PERFORMANCE = 25.0;
    private const double PESO_PRIORIDADE = 20.0;

    public HandoffService(ApplicationDbContext context, ILogger<HandoffService> logger)
    {
        _context = context;
        _logger = logger;
    }

    #region Método Legado (Compatibilidade)
    
    /// <summary>
    /// Método legado mantido para compatibilidade com código existente
    /// </summary>
    public async Task<int?> AtribuirTecnicoAsync(int categoriaId)
    {
        var tecnicos = await _context.Usuarios
            .Where(u => u.Ativo && u.TipoUsuario == 2 && u.CategoriaEspecialidadeId == categoriaId)
            .ToListAsync();

        if (tecnicos.Count == 0)
        {
            _logger.LogWarning("Nenhum tecnico encontrado para a categoria {CategoriaId}", categoriaId);
            return null;
        }

        var statusIgnorados = await _context.Status
            .Where(s => s.Nome == "Fechado" || s.Nome == "Cancelado")
            .Select(s => s.Id)
            .ToListAsync();

        var menorCarga = int.MaxValue;
        int? tecnicoSelecionado = null;

        foreach (var tecnico in tecnicos)
        {
            var carga = await _context.Chamados.CountAsync(c =>
                (c.TecnicoAtribuidoId == tecnico.Id || c.TecnicoId == tecnico.Id) &&
                !statusIgnorados.Contains(c.StatusId));

            if (carga < menorCarga)
            {
                menorCarga = carga;
                tecnicoSelecionado = tecnico.Id;
            }
        }

        _logger.LogInformation("Tecnico {TecnicoId} selecionado com carga {Carga}", tecnicoSelecionado, menorCarga);
        return tecnicoSelecionado;
    }
    
    #endregion

    #region Atribuição Inteligente
    
    /// <summary>
    /// Atribui técnico com algoritmo inteligente baseado em score
    /// </summary>
    public async Task<AtribuicaoResultadoDto> AtribuirTecnicoInteligenteAsync(
        int chamadoId, 
        int categoriaId, 
        int prioridadeId,
        string metodoAtribuicao = "Automatico")
    {
        _logger.LogInformation("═══════════════════════════════════════════════════════");
        _logger.LogInformation("🎯 [ATRIBUIÇÃO INTELIGENTE] Iniciando processo");
        _logger.LogInformation($"   Chamado ID: {chamadoId}");
        _logger.LogInformation($"   Categoria ID: {categoriaId}");
        _logger.LogInformation($"   Prioridade ID: {prioridadeId}");
        _logger.LogInformation("═══════════════════════════════════════════════════════");

        var resultado = new AtribuicaoResultadoDto();

        try
        {
            // ETAPA 1: Calcular scores de todos técnicos elegíveis
            _logger.LogInformation("📊 [ETAPA 1] Calculando scores...");
            var tecnicosComScore = await CalcularScoresTecnicosAsync(categoriaId, prioridadeId);
            resultado.TecnicosAvaliados = tecnicosComScore;
            
            if (tecnicosComScore.Count == 0)
            {
                _logger.LogWarning("⚠️ Nenhum técnico elegível encontrado!");
                
                // FALLBACK: Buscar técnico genérico (sem especialidade específica)
                _logger.LogInformation("🔄 [FALLBACK] Buscando técnico genérico...");
                var tecnicoGenerico = await BuscarTecnicoGenericoAsync();
                
                if (tecnicoGenerico != null)
                {
                    resultado.Sucesso = true;
                    resultado.TecnicoId = tecnicoGenerico.TecnicoId;
                    resultado.TecnicoNome = tecnicoGenerico.NomeCompleto;
                    resultado.Score = tecnicoGenerico.ScoreTotal;
                    resultado.Motivo = "Fallback: Técnico genérico (sem especialista disponível)";
                    resultado.FallbackGenerico = true;
                    
                    await RegistrarAtribuicaoAsync(chamadoId, tecnicoGenerico, metodoAtribuicao, true);
                    
                    _logger.LogInformation($"✅ Técnico genérico atribuído: {tecnicoGenerico.NomeCompleto}");
                    return resultado;
                }
                
                resultado.Sucesso = false;
                resultado.MensagemErro = "Nenhum técnico disponível no momento";
                _logger.LogError("❌ Falha: Nenhum técnico disponível!");
                return resultado;
            }
            
            // ETAPA 2: Selecionar técnico com maior score
            _logger.LogInformation($"📋 [ETAPA 2] {tecnicosComScore.Count} técnicos avaliados");
            var melhorTecnico = tecnicosComScore.OrderByDescending(t => t.ScoreTotal).First();
            
            _logger.LogInformation($"🏆 [SELECIONADO] {melhorTecnico.NomeCompleto}");
            _logger.LogInformation($"   Score Total: {melhorTecnico.ScoreTotal:F2}");
            _logger.LogInformation($"   Especialidade: {melhorTecnico.Breakdown.Especialidade:F2}");
            _logger.LogInformation($"   Disponibilidade: {melhorTecnico.Breakdown.Disponibilidade:F2}");
            _logger.LogInformation($"   Performance: {melhorTecnico.Breakdown.Performance:F2}");
            _logger.LogInformation($"   Prioridade: {melhorTecnico.Breakdown.Prioridade:F2}");
            _logger.LogInformation($"   Chamados Ativos: {melhorTecnico.Estatisticas.ChamadosAtivos}");
            
            // ETAPA 3: Registrar atribuição
            await RegistrarAtribuicaoAsync(chamadoId, melhorTecnico, metodoAtribuicao, false);
            
            resultado.Sucesso = true;
            resultado.TecnicoId = melhorTecnico.TecnicoId;
            resultado.TecnicoNome = melhorTecnico.NomeCompleto;
            resultado.Score = melhorTecnico.ScoreTotal;
            resultado.Motivo = GerarMotivoSelecao(melhorTecnico);
            resultado.FallbackGenerico = false;
            
            _logger.LogInformation("═══════════════════════════════════════════════════════");
            _logger.LogInformation("🎉 [SUCESSO] Atribuição concluída!");
            _logger.LogInformation("═══════════════════════════════════════════════════════");
            
            return resultado;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "❌ [ERRO] Falha na atribuição inteligente");
            resultado.Sucesso = false;
            resultado.MensagemErro = $"Erro interno: {ex.Message}";
            return resultado;
        }
    }
    
    /// <summary>
    /// Calcula score de adequação para cada técnico disponível
    /// </summary>
    public async Task<List<TecnicoScoreDto>> CalcularScoresTecnicosAsync(
        int categoriaId, 
        int prioridadeId)
    {
        var resultado = new List<TecnicoScoreDto>();
        
        // Buscar prioridade para determinar nível
        var prioridade = await _context.Prioridades.FindAsync(prioridadeId);
        var nivelPrioridade = prioridade?.Nivel ?? 1;
        
        // Buscar técnicos ativos
        var tecnicos = await _context.Usuarios
            .Include(u => u.TecnicoTIPerfil)
            .Where(u => u.Ativo && u.TipoUsuario == 2)
            .ToListAsync();
        
        if (tecnicos.Count == 0)
        {
            _logger.LogWarning("Nenhum técnico ativo encontrado");
            return resultado;
        }
        
        // IDs de status que indicam chamado fechado
        var statusFechados = await _context.Status
            .Where(s => s.Nome == "Fechado" || s.Nome == "Resolvido" || s.Nome == "Cancelado")
            .Select(s => s.Id)
            .ToListAsync();
        
        foreach (var tecnico in tecnicos)
        {
            var scoreDto = new TecnicoScoreDto
            {
                TecnicoId = tecnico.Id,
                NomeCompleto = tecnico.NomeCompleto,
                AreaAtuacao = tecnico.TecnicoTIPerfil?.AreaAtuacao,
                NivelTecnico = tecnico.TecnicoTIPerfil?.NivelTecnico ?? 1
            };
            
            // === SCORE 1: ESPECIALIDADE (0-30 pontos) ===
            scoreDto.Breakdown.Especialidade = CalcularScoreEspecialidade(tecnico, categoriaId);
            
            // === SCORE 2: DISPONIBILIDADE/CARGA (0-25 pontos) ===
            var chamadosAtivos = await _context.Chamados
                .Where(c => (c.TecnicoAtribuidoId == tecnico.Id || c.TecnicoId == tecnico.Id) 
                            && !statusFechados.Contains(c.StatusId))
                .CountAsync();
            
            scoreDto.Estatisticas.ChamadosAtivos = chamadosAtivos;
            scoreDto.Estatisticas.CapacidadeRestante = Math.Max(0, MAX_CHAMADOS_POR_TECNICO - chamadosAtivos);
            scoreDto.Breakdown.Disponibilidade = CalcularScoreDisponibilidade(chamadosAtivos);
            
            // Se técnico está sobrecarregado, skip
            if (chamadosAtivos >= MAX_CHAMADOS_POR_TECNICO)
            {
                _logger.LogDebug($"Técnico {tecnico.NomeCompleto} está sobrecarregado ({chamadosAtivos} chamados)");
                continue;
            }
            
            // === SCORE 3: PERFORMANCE HISTÓRICA (0-25 pontos) ===
            var stats = await CalcularEstatisticasPerformanceAsync(tecnico.Id, statusFechados);
            scoreDto.Estatisticas.ChamadosResolvidos = stats.ChamadosResolvidos;
            scoreDto.Estatisticas.TempoMedioResolucao = stats.TempoMedioResolucao;
            scoreDto.Estatisticas.TaxaResolucao = stats.TaxaResolucao;
            scoreDto.Breakdown.Performance = CalcularScorePerformance(stats);
            
            // === SCORE 4: ADEQUAÇÃO À PRIORIDADE (0-20 pontos) ===
            scoreDto.Breakdown.Prioridade = CalcularScorePrioridade(tecnico, nivelPrioridade, stats);
            
            // === SCORE TOTAL ===
            scoreDto.ScoreTotal = 
                scoreDto.Breakdown.Especialidade +
                scoreDto.Breakdown.Disponibilidade +
                scoreDto.Breakdown.Performance +
                scoreDto.Breakdown.Prioridade;
            
            resultado.Add(scoreDto);
            
            _logger.LogDebug($"Técnico: {tecnico.NomeCompleto} | Score: {scoreDto.ScoreTotal:F2} " +
                           $"(Esp:{scoreDto.Breakdown.Especialidade:F0} Disp:{scoreDto.Breakdown.Disponibilidade:F0} " +
                           $"Perf:{scoreDto.Breakdown.Performance:F0} Prior:{scoreDto.Breakdown.Prioridade:F0})");
        }
        
        return resultado.OrderByDescending(t => t.ScoreTotal).ToList();
    }
    
    #endregion

    #region Cálculos de Score
    
    private double CalcularScoreEspecialidade(Usuario tecnico, int categoriaId)
    {
        // Especialista perfeito: 30 pontos
        if (tecnico.CategoriaEspecialidadeId == categoriaId)
            return PESO_ESPECIALIDADE;
        
        // Técnico genérico (sem especialidade): 10 pontos
        if (tecnico.CategoriaEspecialidadeId == null)
            return PESO_ESPECIALIDADE * 0.33;
        
        // Especialista em outra área: 5 pontos
        return PESO_ESPECIALIDADE * 0.17;
    }
    
    private double CalcularScoreDisponibilidade(int chamadosAtivos)
    {
        // Técnico livre: 25 pontos
        if (chamadosAtivos == 0)
            return PESO_DISPONIBILIDADE;
        
        // Pontuação decresce linearmente com a carga
        var percentualDisponivel = 1.0 - (chamadosAtivos / (double)MAX_CHAMADOS_POR_TECNICO);
        return PESO_DISPONIBILIDADE * Math.Max(0, percentualDisponivel);
    }
    
    private double CalcularScorePerformance(TecnicoEstatisticas stats)
    {
        double score = 0;
        
        // Taxa de resolução (até 15 pontos)
        score += stats.TaxaResolucao * 15;
        
        // Tempo médio de resolução (até 10 pontos)
        // Quanto menor o tempo, maior o score
        if (stats.TempoMedioResolucao.HasValue)
        {
            var tempoHoras = stats.TempoMedioResolucao.Value;
            
            if (tempoHoras < 4) score += 10;        // Muito rápido
            else if (tempoHoras < 8) score += 8;     // Rápido
            else if (tempoHoras < 24) score += 6;    // Normal
            else if (tempoHoras < 48) score += 4;    // Lento
            else score += 2;                          // Muito lento
        }
        else if (stats.ChamadosResolvidos > 0)
        {
            // Se não tem tempo médio mas tem resoluções, dá pontuação média
            score += 5;
        }
        
        return Math.Min(score, PESO_PERFORMANCE);
    }
    
    private double CalcularScorePrioridade(Usuario tecnico, int nivelPrioridade, TecnicoEstatisticas stats)
    {
        // Obter nível do técnico (1=Básico, 3=Sênior/Especialista)
        // NOTA: Nível 2 foi removido do sistema (apenas 2 técnicos)
        var nivelTecnico = tecnico.TecnicoTIPerfil?.NivelTecnico ?? 1;
        
        // ===== PRIORIDADE ALTA (nível 3): Requer Técnico Sênior =====
        if (nivelPrioridade >= 3)
        {
            if (nivelTecnico == 3) // Técnico Sênior - IDEAL
                return PESO_PRIORIDADE; // 20 pontos
            
            // Técnico Básico (nível 1) não deve atender prioridade alta
            return PESO_PRIORIDADE * 0.1; // 2 pontos (apenas em emergência)
        }
        
        // ===== PRIORIDADE MÉDIA (nível 2): Vai para Sênior (sem nível intermediário) =====
        if (nivelPrioridade == 2)
        {
            if (nivelTecnico == 3) // Técnico Sênior atende problemas médios
                return PESO_PRIORIDADE * 0.8; // 16 pontos (bom match)
            
            if (nivelTecnico == 1) // Técnico Básico pode tentar com supervisão
                return PESO_PRIORIDADE * 0.4; // 8 pontos (se Sênior ocupado)
        }
        
        // ===== PRIORIDADE BAIXA (nível 1): Ideal para Técnico Básico =====
        if (nivelTecnico == 1) // Técnico Básico - IDEAL para problemas simples
            return PESO_PRIORIDADE; // 20 pontos
        
        // Técnico Sênior para prioridade baixa (desperdício, mas aceitável)
        return PESO_PRIORIDADE * 0.5; // 10 pontos (se Básico estiver ocupado)
    }
    
    private async Task<TecnicoEstatisticas> CalcularEstatisticasPerformanceAsync(
        int tecnicoId, 
        List<int> statusFechados)
    {
        var stats = new TecnicoEstatisticas();
        
        // Total de chamados resolvidos
        stats.ChamadosResolvidos = await _context.Chamados
            .Where(c => (c.TecnicoAtribuidoId == tecnicoId || c.TecnicoId == tecnicoId)
                        && statusFechados.Contains(c.StatusId))
            .CountAsync();
        
        if (stats.ChamadosResolvidos > 0)
        {
            // Tempo médio de resolução
            var chamadosResolvidos = await _context.Chamados
                .Where(c => (c.TecnicoAtribuidoId == tecnicoId || c.TecnicoId == tecnicoId)
                            && c.DataFechamento.HasValue)
                .Select(c => new { c.DataAbertura, c.DataFechamento })
                .ToListAsync();
            
            if (chamadosResolvidos.Any())
            {
                var temposTotais = chamadosResolvidos
                    .Select(c => (c.DataFechamento!.Value - c.DataAbertura).TotalHours)
                    .ToList();
                
                stats.TempoMedioResolucao = temposTotais.Average();
            }
            
            // Taxa de resolução
            var totalChamados = await _context.Chamados
                .Where(c => c.TecnicoAtribuidoId == tecnicoId || c.TecnicoId == tecnicoId)
                .CountAsync();
            
            stats.TaxaResolucao = totalChamados > 0 
                ? (double)stats.ChamadosResolvidos / totalChamados 
                : 0;
        }
        
        return stats;
    }
    
    #endregion

    #region Métodos Auxiliares
    
    private async Task<TecnicoScoreDto?> BuscarTecnicoGenericoAsync()
    {
        // Buscar técnico sem especialidade específica e com menor carga
        var tecnicos = await _context.Usuarios
            .Where(u => u.Ativo && u.TipoUsuario == 2 && u.CategoriaEspecialidadeId == null)
            .ToListAsync();
        
        if (tecnicos.Count == 0)
            return null;
        
        var statusFechados = await _context.Status
            .Where(s => s.Nome == "Fechado" || s.Nome == "Resolvido")
            .Select(s => s.Id)
            .ToListAsync();
        
        TecnicoScoreDto? melhor = null;
        int menorCarga = int.MaxValue;
        
        foreach (var tecnico in tecnicos)
        {
            var carga = await _context.Chamados
                .Where(c => (c.TecnicoAtribuidoId == tecnico.Id || c.TecnicoId == tecnico.Id)
                            && !statusFechados.Contains(c.StatusId))
                .CountAsync();
            
            if (carga < menorCarga && carga < MAX_CHAMADOS_POR_TECNICO)
            {
                menorCarga = carga;
                melhor = new TecnicoScoreDto
                {
                    TecnicoId = tecnico.Id,
                    NomeCompleto = tecnico.NomeCompleto,
                    ScoreTotal = 50, // Score médio para genérico
                    Estatisticas = new TecnicoEstatisticas { ChamadosAtivos = carga }
                };
            }
        }
        
        return melhor;
    }
    
    private async Task RegistrarAtribuicaoAsync(
        int chamadoId,
        TecnicoScoreDto tecnico,
        string metodo,
        bool fallback)
    {
        var log = new AtribuicaoLog
        {
            ChamadoId = chamadoId,
            TecnicoId = tecnico.TecnicoId,
            Score = tecnico.ScoreTotal,
            MetodoAtribuicao = metodo,
            MotivoSelecao = GerarMotivoSelecao(tecnico),
            CargaTrabalho = tecnico.Estatisticas.ChamadosAtivos,
            FallbackGenerico = fallback,
            DetalhesProcesso = JsonSerializer.Serialize(new
            {
                Breakdown = tecnico.Breakdown,
                Estatisticas = tecnico.Estatisticas
            })
        };
        
        _context.AtribuicoesLog.Add(log);
        await _context.SaveChangesAsync();
        
        _logger.LogInformation($"📝 Atribuição registrada no log (ID: {log.Id})");
    }
    
    private string GerarMotivoSelecao(TecnicoScoreDto tecnico)
    {
        var motivos = new List<string>();
        
        if (tecnico.Breakdown.Especialidade >= PESO_ESPECIALIDADE * 0.9)
            motivos.Add("Especialista na categoria");
        
        if (tecnico.Breakdown.Disponibilidade >= PESO_DISPONIBILIDADE * 0.8)
            motivos.Add("Alta disponibilidade");
        
        if (tecnico.Breakdown.Performance >= PESO_PERFORMANCE * 0.7)
            motivos.Add("Excelente performance histórica");
        
        if (tecnico.Estatisticas.ChamadosAtivos == 0)
            motivos.Add("Técnico livre");
        
        return motivos.Any() 
            ? string.Join(", ", motivos) 
            : $"Maior score geral ({tecnico.ScoreTotal:F2})";
    }
    
    #endregion

    #region Redistribuição e Métricas
    
    public async Task<int> RedistribuirChamadosAsync(int tecnicoId)
    {
        _logger.LogInformation($"🔄 Redistribuindo chamados do técnico {tecnicoId}...");
        
        var statusAbertos = await _context.Status
            .Where(s => s.Nome == "Aberto" || s.Nome == "Em andamento")
            .Select(s => s.Id)
            .ToListAsync();
        
        var chamados = await _context.Chamados
            .Where(c => (c.TecnicoAtribuidoId == tecnicoId || c.TecnicoId == tecnicoId)
                        && statusAbertos.Contains(c.StatusId))
            .ToListAsync();
        
        int redistribuidos = 0;
        
        foreach (var chamado in chamados)
        {
            var resultado = await AtribuirTecnicoInteligenteAsync(
                chamado.Id,
                chamado.CategoriaId,
                chamado.PrioridadeId,
                "Redistribuicao");
            
            if (resultado.Sucesso && resultado.TecnicoId.HasValue)
            {
                chamado.TecnicoId = resultado.TecnicoId.Value;
                chamado.TecnicoAtribuidoId = resultado.TecnicoId.Value;
                redistribuidos++;
            }
        }
        
        await _context.SaveChangesAsync();
        
        _logger.LogInformation($"✅ {redistribuidos} chamados redistribuídos");
        return redistribuidos;
    }
    
    public async Task<Dictionary<int, int>> ObterDistribuicaoCargaAsync()
    {
        var statusFechados = await _context.Status
            .Where(s => s.Nome == "Fechado" || s.Nome == "Resolvido")
            .Select(s => s.Id)
            .ToListAsync();
        
        var distribuicao = await _context.Chamados
            .Where(c => c.TecnicoId.HasValue && !statusFechados.Contains(c.StatusId))
            .GroupBy(c => c.TecnicoId!.Value)
            .Select(g => new { TecnicoId = g.Key, Quantidade = g.Count() })
            .ToDictionaryAsync(x => x.TecnicoId, x => x.Quantidade);
        
        _logger.LogInformation($"📊 Distribuição de carga: {distribuicao.Count} técnicos com chamados ativos");
        
        return distribuicao;
    }
    
    #endregion
}

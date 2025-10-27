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
        string metodoAtribuicao = "Automatico",
        string titulo = "",
        string descricao = "")
    {
        _logger.LogInformation("═══════════════════════════════════════════════════════");
        _logger.LogInformation("🎯 [ATRIBUIÇÃO INTELIGENTE] Iniciando processo");
        _logger.LogInformation($"   Chamado ID: {chamadoId}");
        _logger.LogInformation($"   Categoria ID: {categoriaId}");
        _logger.LogInformation($"   Prioridade ID (IA): {prioridadeId}");
        
        // VALIDAÇÃO: Detectar inconsistência grave entre prioridade da IA e palavras-chave
        var prioridadeAjustada = ValidarPrioridadeIA(prioridadeId, titulo, descricao);
        if (prioridadeAjustada != prioridadeId)
        {
            _logger.LogWarning($"⚠️ CORREÇÃO: IA sugeriu prioridade {prioridadeId}, mas palavras-chave indicam {prioridadeAjustada}");
            prioridadeId = prioridadeAjustada;
        }
        
        _logger.LogInformation($"   Prioridade Final: {prioridadeId}");
        _logger.LogInformation("═══════════════════════════════════════════════════════");

        var resultado = new AtribuicaoResultadoDto();

        try
        {
            // ETAPA 1: Calcular scores de todos técnicos elegíveis
            _logger.LogInformation("📊 [ETAPA 1] Calculando scores...");
            var tecnicosComScore = await CalcularScoresTecnicosAsync(categoriaId, prioridadeId, titulo, descricao);
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
        int prioridadeId,
        string titulo = "",
        string descricao = "")
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
                NivelTecnico = tecnico.TecnicoTIPerfil?.NivelTecnico ?? 2  // Default: Nível 2 (Intermediário)
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
            
            // === BÔNUS: ANÁLISE DE COMPLEXIDADE POR PALAVRAS-CHAVE (±10 pontos) ===
            double bonusComplexidade = 0;
            if (!string.IsNullOrEmpty(titulo) || !string.IsNullOrEmpty(descricao))
            {
                bonusComplexidade = CalcularBonusComplexidade(titulo, descricao, scoreDto.NivelTecnico);
                scoreDto.Breakdown.BonusComplexidade = bonusComplexidade;
                _logger.LogDebug($"   Bônus complexidade para {tecnico.NomeCompleto}: {bonusComplexidade:F1}");
            }
            
            // === SCORE TOTAL ===
            scoreDto.ScoreTotal = 
                scoreDto.Breakdown.Especialidade +
                scoreDto.Breakdown.Disponibilidade +
                scoreDto.Breakdown.Performance +
                scoreDto.Breakdown.Prioridade +
                bonusComplexidade;
            
            resultado.Add(scoreDto);
            
            _logger.LogDebug($"Técnico: {tecnico.NomeCompleto} | Score: {scoreDto.ScoreTotal:F2} " +
                           $"(Esp:{scoreDto.Breakdown.Especialidade:F0} Disp:{scoreDto.Breakdown.Disponibilidade:F0} " +
                           $"Perf:{scoreDto.Breakdown.Performance:F0} Prior:{scoreDto.Breakdown.Prioridade:F0} Bonus:{bonusComplexidade:F1})");
        }
        
        return resultado.OrderByDescending(t => t.ScoreTotal).ToList();
    }
    
    #endregion

    #region Cálculos de Score
    
    /// <summary>
    /// Valida se a prioridade sugerida pela IA está consistente com palavras-chave críticas
    /// Previne erros graves da IA que poderiam causar má distribuição
    /// </summary>
    private int ValidarPrioridadeIA(int prioridadeIA, string titulo, string descricao)
    {
        var textoCompleto = $"{titulo} {descricao}".ToLowerInvariant();
        
        // === DETECTAR PROBLEMAS CRÍTICOS que IA pode ter classificado errado ===
        string[] palavrasCriticas = {
            "servidor", "caiu", "fora do ar", "sistema caiu", "banco de dados",
            "rede", "todos", "empresa inteira", "crítico", "parou"
        };
        
        int countCriticas = palavrasCriticas.Count(p => textoCompleto.Contains(p));
        
        // Se tem 2+ palavras críticas mas IA disse Baixa (1) ou Média (2), corrigir para Alta (3)
        if (countCriticas >= 2 && prioridadeIA < 3)
        {
            _logger.LogWarning($"   🚨 CORREÇÃO CRÍTICA: Detectadas {countCriticas} palavras de alta gravidade. Forçando prioridade ALTA.");
            return 3; // Alta
        }
        
        // === DETECTAR PROBLEMAS SIMPLES que IA pode ter superestimado ===
        string[] palavrasSimples = {
            "meu", "minha", "senha", "esqueci", "mouse", "teclado", "como faço", "dúvida"
        };
        
        int countSimples = palavrasSimples.Count(p => textoCompleto.Contains(p));
        
        // Se tem 3+ palavras simples, NENHUMA crítica, e IA disse Alta (3), corrigir para Média (2)
        if (countSimples >= 3 && countCriticas == 0 && prioridadeIA == 3)
        {
            _logger.LogWarning($"   🔧 CORREÇÃO: Detectadas {countSimples} palavras simples sem criticidade. Ajustando de ALTA para MÉDIA.");
            return 2; // Média
        }
        
        // Caso contrário, confiar na IA
        return prioridadeIA;
    }
    
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
    
    /// <summary>
    /// Analisa palavras-chave no título e descrição para ajustar score de complexidade
    /// NÍVEIS: 2=Intermediário (rotina), 3=Sênior (complexo/crítico)
    /// </summary>
    private double CalcularBonusComplexidade(string titulo, string descricao, int nivelTecnico)
    {
        var textoCompleto = $"{titulo} {descricao}".ToLowerInvariant();
        double bonus = 0;
        int contadorAltaComplexidade = 0;
        int contadorBaixaComplexidade = 0;
        
        // === INDICADORES DE ALTA COMPLEXIDADE (favorece Sênior) ===
        string[] palavrasAltaComplexidade = {
            "servidor", "rede", "compartilhado", "todos", "empresa inteira", "setor inteiro",
            "departamento", "crítico", "fora do ar", "indisponível",
            "sistema caiu", "sistema parou", "banco de dados", "erp", "firewall", "vpn", "caiu"
        };
        
        foreach (var palavra in palavrasAltaComplexidade)
        {
            if (textoCompleto.Contains(palavra))
            {
                contadorAltaComplexidade++;
                bonus += nivelTecnico == 3 ? 3 : (nivelTecnico == 2 ? -1 : -2); // Favorece Sênior, neutraliza Intermediário
            }
        }
        
        // === INDICADORES DE BAIXA COMPLEXIDADE (favorece Intermediário) ===
        string[] palavrasBaixaComplexidade = {
            "meu", "minha", "senha", "esqueci", "trocar", "mouse", "teclado",
            "dúvida", "como faço", "não sei", "ajuda", "solicito", "preciso",
            "instalar", "desinstalar", "configurar email", "impressora", "celular",
            "pessoal", "individual", "básica", "simples", "travando"
        };
        
        foreach (var palavra in palavrasBaixaComplexidade)
        {
            if (textoCompleto.Contains(palavra))
            {
                contadorBaixaComplexidade++;
                bonus += nivelTecnico == 2 ? 3 : -1; // Favorece Intermediário, penaliza Sênior
            }
        }
        
        // === BOOST/PENALIDADE: Problema simples não deve ir para Sênior ===
        if (contadorBaixaComplexidade >= 2 && contadorAltaComplexidade == 0)
        {
            if (nivelTecnico == 3)
            {
                _logger.LogDebug($"   ⚠️ BLOQUEIO: Problema simples detectado ({contadorBaixaComplexidade} indicadores). Penalidade severa para Sênior: -30 pontos");
                bonus -= 30; // Penalidade severa
            }
            else if (nivelTecnico == 2)
            {
                _logger.LogDebug($"   ✅ BOOST: Problema simples ideal para Intermediário (+15 pontos)");
                bonus += 15; // Boost para Intermediário
            }
        }
        
        return bonus;
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
        // Obter nível do técnico (2=Intermediário, 3=Sênior/Especialista)
        // SISTEMA COM 2 TÉCNICOS:
        // - Nível 2: Problemas BÁSICOS e INTERMEDIÁRIOS BAIXOS (rotina, configurações, instalações)
        // - Nível 3: Problemas INTERMEDIÁRIOS ALTOS e CRÍTICOS (servidores, rede, sistemas complexos)
        var nivelTecnico = tecnico.TecnicoTIPerfil?.NivelTecnico ?? 2;
        
        // ===== PRIORIDADE ALTA/CRÍTICA (nível 3): Requer Técnico Sênior =====
        if (nivelPrioridade >= 3)
        {
            if (nivelTecnico == 3) // Técnico Sênior - IDEAL para problemas críticos
                return PESO_PRIORIDADE; // 20 pontos
            
            // Técnico Intermediário (nível 2) pode atender APENAS em emergência (Sênior sobrecarregado)
            if (stats.ChamadosAtivos < 2) // Se estiver muito livre
                return PESO_PRIORIDADE * 0.25; // 5 pontos (última opção)
            else
                return PESO_PRIORIDADE * 0.05; // 1 ponto (bloqueio virtual)
        }
        
        // ===== PRIORIDADE MÉDIA (nível 2): Distribuir baseado em carga e complexidade =====
        if (nivelPrioridade == 2)
        {
            // ESTRATÉGIA: Técnico Intermediário é IDEAL para problemas médios simples
            //             Técnico Sênior entra apenas se Intermediário estiver ocupado
            
            if (nivelTecnico == 2) // Técnico Intermediário - PERFEITO para rotina
            {
                // Sempre priorizar Intermediário para problemas médios
                if (stats.ChamadosAtivos < 3)
                    return PESO_PRIORIDADE; // 20 pontos (ideal!)
                else if (stats.ChamadosAtivos < 6)
                    return PESO_PRIORIDADE * 0.85; // 17 pontos (ainda ótimo)
                else
                    return PESO_PRIORIDADE * 0.60; // 12 pontos (ocupado mas ok)
            }
            
            // Técnico Sênior para prioridade média (usar apenas se Intermediário ocupado)
            if (nivelTecnico == 3)
            {
                // Se Intermediário está sobrecarregado, Sênior pode ajudar
                if (stats.ChamadosAtivos < 2)
                    return PESO_PRIORIDADE * 0.70; // 14 pontos (disponível)
                else if (stats.ChamadosAtivos < 4)
                    return PESO_PRIORIDADE * 0.50; // 10 pontos (pode ajudar)
                else
                    return PESO_PRIORIDADE * 0.30; // 6 pontos (evitar desperdício)
            }
        }
        
        // ===== PRIORIDADE BAIXA (nível 1): Ideal para Técnico Intermediário =====
        if (nivelTecnico == 2) // Técnico Intermediário - PERFEITO para problemas simples/rotina
            return PESO_PRIORIDADE; // 20 pontos (treinamento e manutenção de carga)
        
        // Técnico Sênior para prioridade baixa (desperdício de recurso qualificado)
        // Só aceita se Intermediário estiver completamente sobrecarregado
        if (stats.ChamadosAtivos < 2)
            return PESO_PRIORIDADE * 0.40; // 8 pontos (muito disponível, pode ajudar)
        else if (stats.ChamadosAtivos < 4)
            return PESO_PRIORIDADE * 0.25; // 5 pontos (aceita se necessário)
        else
            return PESO_PRIORIDADE * 0.10; // 2 pontos (evitar ao máximo)
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

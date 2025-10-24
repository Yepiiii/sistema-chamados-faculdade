namespace SistemaChamados.Application.DTOs;

/// <summary>
/// DTO com score de adequação de um técnico para um chamado
/// </summary>
public class TecnicoScoreDto
{
    public int TecnicoId { get; set; }
    public string NomeCompleto { get; set; } = string.Empty;
    public string? AreaAtuacao { get; set; }
    
    /// <summary>
    /// Nível do técnico: 1=Básico, 3=Sênior/Especialista
    /// NOTA: Nível 2 foi removido
    /// </summary>
    public int NivelTecnico { get; set; }
    
    /// <summary>
    /// Descrição do nível do técnico
    /// </summary>
    public string NivelDescricao => NivelTecnico switch
    {
        1 => "Nível 1 - Suporte Básico",
        2 => "Nível 2 - Suporte Intermediário (DESATIVADO)",
        3 => "Nível 3 - Especialista Sênior",
        _ => "Nível Desconhecido"
    };
    
    /// <summary>
    /// Score total de adequação (0-100)
    /// </summary>
    public double ScoreTotal { get; set; }
    
    /// <summary>
    /// Breakdown do score
    /// </summary>
    public ScoreBreakdown Breakdown { get; set; } = new();
    
    /// <summary>
    /// Estatísticas do técnico
    /// </summary>
    public TecnicoEstatisticas Estatisticas { get; set; } = new();
}

public class ScoreBreakdown
{
    /// <summary>
    /// Pontos por especialidade (0-30)
    /// </summary>
    public double Especialidade { get; set; }
    
    /// <summary>
    /// Pontos por disponibilidade/carga (0-25)
    /// </summary>
    public double Disponibilidade { get; set; }
    
    /// <summary>
    /// Pontos por performance histórica (0-25)
    /// </summary>
    public double Performance { get; set; }
    
    /// <summary>
    /// Pontos por prioridade adequada (0-20)
    /// </summary>
    public double Prioridade { get; set; }
    
    /// <summary>
    /// Bônus de complexidade baseado em palavras-chave (±10)
    /// </summary>
    public double BonusComplexidade { get; set; }
}

public class TecnicoEstatisticas
{
    /// <summary>
    /// Número de chamados ativos atualmente
    /// </summary>
    public int ChamadosAtivos { get; set; }
    
    /// <summary>
    /// Número total de chamados resolvidos
    /// </summary>
    public int ChamadosResolvidos { get; set; }
    
    /// <summary>
    /// Tempo médio de resolução em horas
    /// </summary>
    public double? TempoMedioResolucao { get; set; }
    
    /// <summary>
    /// Taxa de resolução (chamados resolvidos / total)
    /// </summary>
    public double TaxaResolucao { get; set; }
    
    /// <summary>
    /// Capacidade restante (chamados que ainda pode pegar)
    /// </summary>
    public int CapacidadeRestante { get; set; }
}

/// <summary>
/// DTO com resultado detalhado da atribuição
/// </summary>
public class AtribuicaoResultadoDto
{
    public bool Sucesso { get; set; }
    public int? TecnicoId { get; set; }
    public string? TecnicoNome { get; set; }
    public double? Score { get; set; }
    public string? Motivo { get; set; }
    public bool FallbackGenerico { get; set; }
    public List<TecnicoScoreDto> TecnicosAvaliados { get; set; } = new();
    public string? MensagemErro { get; set; }
}

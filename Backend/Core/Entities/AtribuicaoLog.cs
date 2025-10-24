using System.ComponentModel.DataAnnotations;

namespace SistemaChamados.Core.Entities;

/// <summary>
/// Entidade para auditoria de atribuições automáticas de técnicos
/// </summary>
public class AtribuicaoLog
{
    public int Id { get; set; }
    
    [Required]
    public int ChamadoId { get; set; }
    
    [Required]
    public int TecnicoId { get; set; }
    
    [Required]
    public DateTime DataAtribuicao { get; set; } = DateTime.Now;
    
    /// <summary>
    /// Score calculado para este técnico (0-100)
    /// </summary>
    [Required]
    public double Score { get; set; }
    
    /// <summary>
    /// Método de atribuição: IA, Automatico, Manual
    /// </summary>
    [Required]
    [MaxLength(50)]
    public string MetodoAtribuicao { get; set; } = "Automatico";
    
    /// <summary>
    /// Motivo da seleção (especialidade, menor carga, etc)
    /// </summary>
    [MaxLength(500)]
    public string? MotivoSelecao { get; set; }
    
    /// <summary>
    /// Número de chamados ativos do técnico no momento da atribuição
    /// </summary>
    public int CargaTrabalho { get; set; }
    
    /// <summary>
    /// Se houve fallback para técnico genérico
    /// </summary>
    public bool FallbackGenerico { get; set; }
    
    /// <summary>
    /// JSON com detalhes completos do processo de seleção
    /// </summary>
    [MaxLength(2000)]
    public string? DetalhesProcesso { get; set; }
    
    // Navegação
    public Chamado? Chamado { get; set; }
    public Usuario? Tecnico { get; set; }
}

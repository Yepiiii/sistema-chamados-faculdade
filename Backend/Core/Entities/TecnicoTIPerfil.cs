using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SistemaChamados.Core.Entities;

public class TecnicoTIPerfil
{
    public int Id { get; set; }
    
    [Required]
    public int UsuarioId { get; set; }
    
    [MaxLength(50)]
    public string? AreaAtuacao { get; set; } // Hardware, Software, Rede
    
    /// <summary>
    /// Nível do técnico: 1=Básico (Suporte Nível 1), 3=Sênior/Especialista (Suporte Nível 3)
    /// NOTA: Nível 2 (Intermediário) foi removido - sistema opera com 2 técnicos
    /// </summary>
    [Required]
    public int NivelTecnico { get; set; } = 1; // Default: Nível 1 (Básico)
    
    public DateTime DataContratacao { get; set; } = DateTime.Now;
    
    // Propriedade de navegação
    [ForeignKey("UsuarioId")]
    public Usuario Usuario { get; set; } = null!;
    
    // Relacionamento com chamados atribuídos
    public ICollection<Chamado>? ChamadosAtribuidos { get; set; }
}

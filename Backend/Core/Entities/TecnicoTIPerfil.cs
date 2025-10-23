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
    
    public DateTime DataContratacao { get; set; } = DateTime.Now;
    
    // Propriedade de navegação
    [ForeignKey("UsuarioId")]
    public Usuario Usuario { get; set; } = null!;
    
    // Relacionamento com chamados atribuídos
    public ICollection<Chamado>? ChamadosAtribuidos { get; set; }
}

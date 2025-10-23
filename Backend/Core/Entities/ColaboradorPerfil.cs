using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SistemaChamados.Core.Entities;

public class ColaboradorPerfil
{
    public int Id { get; set; }
    
    [Required]
    public int UsuarioId { get; set; }
    
    [Required]
    [MaxLength(20)]
    public string Matricula { get; set; } = string.Empty;
    
    [MaxLength(100)]
    public string? Departamento { get; set; }
    
    public DateTime DataAdmissao { get; set; } = DateTime.Now;
    
    // Propriedade de navegação
    [ForeignKey("UsuarioId")]
    public Usuario Usuario { get; set; } = null!;
}

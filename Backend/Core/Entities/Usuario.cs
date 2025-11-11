using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace SistemaChamados.Core.Entities;

public class Usuario
{
    public int Id { get; set; }
    
    [Required]
    [MaxLength(150)]
    public string NomeCompleto { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(150)]
    public string Email { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(255)]
    [JsonIgnore]
    public string SenhaHash { get; set; } = string.Empty;
    
    [Required]
    public int TipoUsuario { get; set; }
    
    public bool IsInterno { get; set; } = true;
    
    [MaxLength(100)]
    public string? Especialidade { get; set; }
    
    public int? EspecialidadeCategoriaId { get; set; }
    
    public bool Ativo { get; set; } = true;
    
    [JsonIgnore]
    public string? PasswordResetToken { get; set; }
    
    [JsonIgnore]
    public DateTime? ResetTokenExpires { get; set; }
    
    public DateTime DataCadastro { get; set; } = DateTime.UtcNow;
    
    public virtual Categoria? EspecialidadeCategoria { get; set; }
    public virtual ICollection<Chamado> ChamadosSolicitados { get; set; } = new List<Chamado>();
    public virtual ICollection<Chamado> ChamadosAtribuidos { get; set; } = new List<Chamado>();
    public virtual ICollection<Comentario> Comentarios { get; set; } = new List<Comentario>();
}

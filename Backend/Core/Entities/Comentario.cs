namespace SistemaChamados.Core.Entities;

public class Comentario
{
    public int Id { get; set; }
    public string Texto { get; set; } = string.Empty;
    public DateTime DataCriacao { get; set; } = DateTime.UtcNow;
    public bool IsInterno { get; set; }
    
    public int ChamadoId { get; set; }
    public int UsuarioId { get; set; }
    
    public virtual Chamado Chamado { get; set; } = null!;
    public virtual Usuario Usuario { get; set; } = null!;
}

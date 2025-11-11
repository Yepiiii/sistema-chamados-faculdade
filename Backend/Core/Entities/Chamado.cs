namespace SistemaChamados.Core.Entities;

public class Chamado
{
    public int Id { get; set; }
    public string Titulo { get; set; } = string.Empty;
    public string Descricao { get; set; } = string.Empty;
    
    public DateTime DataAbertura { get; set; } = DateTime.UtcNow;
    public DateTime? DataFechamento { get; set; }
    public DateTime? DataUltimaAtualizacao { get; set; }
    
    public DateTime? SlaDataExpiracao { get; set; }
    public int? FechadoPorId { get; set; }
    
    public int SolicitanteId { get; set; }
    public int? TecnicoId { get; set; }
    public int CategoriaId { get; set; }
    public int PrioridadeId { get; set; }
    public int StatusId { get; set; }
    
    public virtual Usuario Solicitante { get; set; } = null!;
    public virtual Usuario? Tecnico { get; set; }
    public virtual Categoria Categoria { get; set; } = null!;
    public virtual Prioridade Prioridade { get; set; } = null!;
    public virtual Status Status { get; set; } = null!;
    
    public virtual ICollection<Comentario> Comentarios { get; set; } = new List<Comentario>();
    public virtual ICollection<Anexo> Anexos { get; set; } = new List<Anexo>();
    public virtual Usuario? FechadoPor { get; set; }
}

namespace SistemaChamados.Core.Entities;

public class Anexo
{
    public int Id { get; set; }
    public string NomeArquivo { get; set; } = string.Empty;
    public string CaminhoArquivo { get; set; } = string.Empty;
    public long TamanhoBytes { get; set; }
    public string TipoMime { get; set; } = string.Empty;
    public DateTime DataUpload { get; set; } = DateTime.UtcNow;
    
    public int ChamadoId { get; set; }
    public int UsuarioId { get; set; }
    
    public virtual Chamado Chamado { get; set; } = null!;
    public virtual Usuario Usuario { get; set; } = null!;
}

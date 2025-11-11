namespace SistemaChamados.Core.Entities;

public class Categoria
{
    public int Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public string? Descricao { get; set; }
    public bool Ativo { get; set; } = true;
    public DateTime DataCadastro { get; set; } = DateTime.UtcNow;
    
    public virtual ICollection<Chamado> Chamados { get; set; } = new List<Chamado>();
    public virtual ICollection<Usuario> TecnicosEspecializados { get; set; } = new List<Usuario>();
}

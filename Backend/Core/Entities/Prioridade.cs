namespace SistemaChamados.Core.Entities;

public class Prioridade
{
    public int Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public int Nivel { get; set; }
    public string? Descricao { get; set; }
    public int TempoRespostaHoras { get; set; }
    public bool Ativo { get; set; } = true;
    public DateTime DataCadastro { get; set; } = DateTime.UtcNow;
    
    /// <summary>
    /// Cor hexadecimal para exibição visual da prioridade.
    /// Usado no Mobile e Frontend para destacar cards.
    /// </summary>
    public string CorHexadecimal => Nivel switch
    {
        1 => "#10B981", // Baixa - Verde
        2 => "#F59E0B", // Média - Amarelo
        3 => "#EF4444", // Alta - Vermelho
        4 => "#DC2626", // Crítica - Vermelho Escuro
        _ => "#6B7280"  // Padrão - Cinza
    };
    
    public virtual ICollection<Chamado> Chamados { get; set; } = new List<Chamado>();
}


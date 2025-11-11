namespace SistemaChamados.Core.Entities;

public class Status
{
    public int Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public string? Descricao { get; set; }
    public bool Ativo { get; set; } = true;
    public DateTime DataCadastro { get; set; } = DateTime.UtcNow;
    
    /// <summary>
    /// Cor hexadecimal para exibição visual do status.
    /// Usado no Mobile e Frontend para badges e indicadores.
    /// </summary>
    public string CorHexadecimal => Nome.ToLower() switch
    {
        "aberto" => "#3B82F6",           // Azul
        "em andamento" => "#F59E0B",     // Amarelo
        "aguardando cliente" => "#8B5CF6", // Roxo
        "resolvido" => "#10B981",        // Verde
        "fechado" => "#6B7280",          // Cinza
        "violado" => "#DC2626",          // Vermelho (SLA violado)
        _ => "#6B7280"                   // Padrão - Cinza
    };
    
    public virtual ICollection<Chamado> Chamados { get; set; } = new List<Chamado>();
}


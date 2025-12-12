using SistemaChamados.Core.Shared.Extensions;

namespace SistemaChamados.Core.Entities;

/// <summary>
/// Entidade de domínio Chamado (Ticket) seguindo DDD.
/// Encapsula lógica de negócio e garante invariantes do domínio.
/// </summary>
public class Chamado
{
    // Construtor interno para Entity Framework e Seeders
    // O código de aplicação deve usar o método de fábrica Criar()
    internal Chamado() { }

    public int Id { get; internal set; }
    public string Titulo { get; internal set; } = string.Empty;
    public string Descricao { get; internal set; } = string.Empty;
    
    public DateTime DataAbertura { get; internal set; } = DateTime.UtcNow;
    public DateTime? DataFechamento { get; internal set; }
    public DateTime? DataUltimaAtualizacao { get; internal set; }
    
    public DateTime? SlaDataExpiracao { get; internal set; }
    public int? FechadoPorId { get; internal set; }
    
    public int SolicitanteId { get; internal set; }
    public int? TecnicoId { get; internal set; }
    public int CategoriaId { get; internal set; }
    public int PrioridadeId { get; internal set; }
    public int StatusId { get; internal set; }
    
    public virtual Usuario Solicitante { get; internal set; } = null!;
    public virtual Usuario? Tecnico { get; internal set; }
    public virtual Categoria Categoria { get; internal set; } = null!;
    public virtual Prioridade Prioridade { get; internal set; } = null!;
    public virtual Status Status { get; internal set; } = null!;
    
    public virtual ICollection<Comentario> Comentarios { get; internal set; } = new List<Comentario>();
    public virtual ICollection<Anexo> Anexos { get; internal set; } = new List<Anexo>();
    public virtual Usuario? FechadoPor { get; internal set; }

    /// <summary>
    /// Método de fábrica para criar um novo chamado seguindo DDD.
    /// Garante que apenas chamados válidos sejam criados.
    /// </summary>
    /// <param name="titulo">Título do chamado (obrigatório)</param>
    /// <param name="descricao">Descrição detalhada (obrigatório)</param>
    /// <param name="solicitanteId">ID do usuário solicitante</param>
    /// <param name="categoriaId">ID da categoria</param>
    /// <param name="prioridadeId">ID da prioridade</param>
    /// <param name="statusAberto">Status inicial "Aberto"</param>
    /// <param name="slaDataExpiracao">Data de expiração do SLA (opcional)</param>
    /// <returns>Instância válida de Chamado</returns>
    /// <exception cref="ArgumentException">Lançada quando os dados são inválidos</exception>
    public static Chamado Criar(
        string titulo,
        string descricao,
        int solicitanteId,
        int categoriaId,
        int prioridadeId,
        int statusAberto,
        DateTime? slaDataExpiracao = null)
    {
        // Validações de domínio usando Guard Clauses
        var validTitulo = titulo.RequiredWithMaxLength(200, nameof(titulo));
        var validDescricao = descricao.RequiredWithMaxLength(5000, nameof(descricao));

        if (solicitanteId <= 0)
            throw new ArgumentException("O ID do solicitante deve ser um valor positivo.", nameof(solicitanteId));

        if (categoriaId <= 0)
            throw new ArgumentException("O ID da categoria deve ser um valor positivo.", nameof(categoriaId));

        if (prioridadeId <= 0)
            throw new ArgumentException("O ID da prioridade deve ser um valor positivo.", nameof(prioridadeId));

        if (statusAberto <= 0)
            throw new ArgumentException("O ID do status deve ser um valor positivo.", nameof(statusAberto));

        // Cria instância válida
        return new Chamado
        {
            Titulo = titulo.Trim(),
            Descricao = descricao.Trim(),
            SolicitanteId = solicitanteId,
            CategoriaId = categoriaId,
            PrioridadeId = prioridadeId,
            StatusId = statusAberto,
            DataAbertura = DateTime.UtcNow,
            SlaDataExpiracao = slaDataExpiracao
        };
    }

    /// <summary>
    /// Atribui um técnico ao chamado.
    /// </summary>
    public void AtribuirTecnico(int? tecnicoId)
    {
        TecnicoId = tecnicoId;
        DataUltimaAtualizacao = DateTime.UtcNow;
    }

    /// <summary>
    /// Atualiza o status do chamado.
    /// </summary>
    public void AtualizarStatus(int novoStatusId, bool isFechado = false, int? fechadoPorId = null)
    {
        StatusId = novoStatusId;
        DataUltimaAtualizacao = DateTime.UtcNow;

        if (isFechado)
        {
            DataFechamento = DateTime.UtcNow;
            FechadoPorId = fechadoPorId;
        }
        else
        {
            DataFechamento = null;
            FechadoPorId = null;
        }
    }

    /// <summary>
    /// Adiciona um comentário ao chamado.
    /// </summary>
    public void AdicionarComentario(Comentario comentario)
    {
        if (comentario == null)
            throw new ArgumentNullException(nameof(comentario));

        Comentarios.Add(comentario);
        DataUltimaAtualizacao = DateTime.UtcNow;
    }
}

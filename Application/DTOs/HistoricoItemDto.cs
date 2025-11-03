using System;

namespace SistemaChamados.Application.DTOs;

public class HistoricoItemDto
{
    public int Id { get; set; }
    public DateTime DataHora { get; set; }
    public string TipoEvento { get; set; } = string.Empty;
    public string Descricao { get; set; } = string.Empty;
    public string? Usuario { get; set; }
    public string? ValorAnterior { get; set; }
    public string? ValorNovo { get; set; }
}

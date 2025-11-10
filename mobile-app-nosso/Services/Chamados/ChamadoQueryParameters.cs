using System;
using System.Collections.Generic;

namespace SistemaChamados.Mobile.Services.Chamados;

public class ChamadoQueryParameters
{
    public int? StatusId { get; set; }
    public int? TecnicoId { get; set; }
    public int? SolicitanteId { get; set; }
    public int? PrioridadeId { get; set; }
    public string? TermoBusca { get; set; }
    public bool? IncluirTodos { get; set; }

    public ChamadoQueryParameters Clone()
    {
        return new ChamadoQueryParameters
        {
            StatusId = StatusId,
            TecnicoId = TecnicoId,
            SolicitanteId = SolicitanteId,
            PrioridadeId = PrioridadeId,
            TermoBusca = TermoBusca,
            IncluirTodos = IncluirTodos
        };
    }

    public string? ToQueryString()
    {
        var parts = new List<string>();

        if (StatusId.HasValue)
        {
            parts.Add($"statusId={StatusId.Value}");
        }

        if (TecnicoId.HasValue)
        {
            parts.Add($"tecnicoId={TecnicoId.Value}");
        }

        if (SolicitanteId.HasValue)
        {
            parts.Add($"solicitanteId={SolicitanteId.Value}");
        }

        if (PrioridadeId.HasValue)
        {
            parts.Add($"prioridadeId={PrioridadeId.Value}");
        }

        if (!string.IsNullOrWhiteSpace(TermoBusca))
        {
            parts.Add($"termoBusca={Uri.EscapeDataString(TermoBusca)}");
        }

        if (IncluirTodos.HasValue)
        {
            parts.Add($"incluirTodos={IncluirTodos.Value.ToString().ToLowerInvariant()}");
        }

        return parts.Count == 0 ? null : string.Join("&", parts);
    }
}

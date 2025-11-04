using System;
using System.Collections.Generic;
using Newtonsoft.Json;

namespace SistemaChamados.Mobile.Models.DTOs;

public class ChamadoDto
{
    public int Id { get; set; }
    public string Titulo { get; set; } = string.Empty;
    public string Descricao { get; set; } = string.Empty;
    public DateTime DataAbertura { get; set; }
    public DateTime? DataUltimaAtualizacao { get; set; }
    public DateTime? DataFechamento { get; set; }
    
    // Usuário que fechou o chamado
    public UsuarioResumoDto? FechadoPor { get; set; }
    
    public CategoriaDto? Categoria { get; set; }
    public PrioridadeDto? Prioridade { get; set; }
    public StatusDto? Status { get; set; }
    public UsuarioResumoDto? Solicitante { get; set; }
    public UsuarioResumoDto? Tecnico { get; set; }
    
    // Informações do Técnico Atribuído
    public int? TecnicoAtribuidoId { get; set; }
    public string? TecnicoAtribuidoNome { get; set; }
    public int? TecnicoAtribuidoNivel { get; set; }
    public string? TecnicoAtribuidoNivelDescricao { get; set; }
    
    // Histórico de atualizações
    public List<HistoricoItemDto>? Historico { get; set; }

    private AnaliseChamadoResponseDto? _analiseInterna;

    [JsonProperty("analise")]
    public AnaliseChamadoResponseDto? Analise
    {
        get => _analiseInterna;
        set => _analiseInterna = value;
    }

    // Alias para compatibilidade com possíveis nomes diferentes enviados pela API.
    [JsonProperty("analiseAutomatica")]
    private AnaliseChamadoResponseDto? AnaliseAutomaticaAlias
    {
        get => _analiseInterna;
        set => _analiseInterna = value;
    }

    // Convenience helpers for UI bindings.
    public bool HasSolicitante => Solicitante != null;
    public string SolicitanteDisplay => Solicitante is null
        ? string.Empty
        : $"{Solicitante.NomeCompleto} ({Solicitante.Email})";
    
    public bool HasTecnicoAtribuido => !string.IsNullOrEmpty(TecnicoAtribuidoNome);
    
    public bool HasFechadoPor => FechadoPor != null;
    public string FechadoPorDisplay => FechadoPor is null
        ? "Sistema"
        : $"{FechadoPor.NomeCompleto}";
    
    public bool HasHistorico => Historico != null && Historico.Count > 0;

    public bool HasAnalise => Analise != null;
}

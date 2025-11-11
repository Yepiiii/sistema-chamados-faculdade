using System;
using System.Collections.Generic;
using Newtonsoft.Json;
using SistemaChamados.Mobile.Helpers;

namespace SistemaChamados.Mobile.Models.DTOs;

public class ChamadoDto
{
    public int Id { get; set; }
    public string Titulo { get; set; } = string.Empty;
    public string Descricao { get; set; } = string.Empty;
    public DateTime DataAbertura { get; set; }
    public DateTime? DataUltimaAtualizacao { get; set; }
    public DateTime? DataFechamento { get; set; }
    
    /// <summary>
    /// Data de expiração do SLA (calculada pelo backend).
    /// Null se não houver SLA definido.
    /// </summary>
    public DateTime? SlaDataExpiracao { get; set; }
    
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
    
    /// <summary>
    /// Verifica se o SLA está violado (expirou e não está fechado).
    /// </summary>
    [JsonIgnore]
    public bool SlaViolado => SlaDataExpiracao.HasValue && 
                               SlaDataExpiracao.Value < DateTime.UtcNow &&
                               Status?.Id != StatusConstants.Fechado &&
                               Status?.Id != StatusConstants.Violado;

    /// <summary>
    /// Tempo restante para o SLA em formato legível.
    /// </summary>
    [JsonIgnore]
    public string SlaTempoRestante
    {
        get
        {
            if (!SlaDataExpiracao.HasValue)
                return "Sem SLA definido";

            var diferenca = SlaDataExpiracao.Value - DateTime.UtcNow;
            
            if (diferenca.TotalSeconds < 0)
                return "⚠️ SLA Violado";
            
            if (diferenca.TotalMinutes < 60)
                return $"⏱️ {(int)diferenca.TotalMinutes} min restantes";
            
            if (diferenca.TotalHours < 24)
                return $"⏱️ {(int)diferenca.TotalHours}h {(int)diferenca.Minutes}min restantes";
            
            if (diferenca.TotalDays < 7)
                return $"⏱️ {(int)diferenca.TotalDays}d {diferenca.Hours}h restantes";
            
            return $"⏱️ {(int)diferenca.TotalDays} dias restantes";
        }
    }

    /// <summary>
    /// Cor de alerta do SLA (vermelho se violado, amarelo se próximo, verde se ok).
    /// </summary>
    [JsonIgnore]
    public string SlaCorAlerta
    {
        get
        {
            if (!SlaDataExpiracao.HasValue)
                return "#6B7280"; // Gray

            var diferenca = SlaDataExpiracao.Value - DateTime.UtcNow;
            
            if (diferenca.TotalSeconds < 0)
                return "#DC2626"; // Red (violado)
            
            if (diferenca.TotalHours < 2)
                return "#F59E0B"; // Amber (crítico)
            
            if (diferenca.TotalHours < 24)
                return "#FBBF24"; // Yellow (atenção)
            
            return "#10B981"; // Green (ok)
        }
    }
}

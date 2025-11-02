using System;

namespace SistemaChamados.Mobile.Models.DTOs;

/// <summary>
/// DTO para verificação de atualizações de chamados
/// </summary>
public class AtualizacaoDto
{
    public int ChamadoId { get; set; }
    public string TituloResumido { get; set; } = string.Empty;
    public string TipoAtualizacao { get; set; } = string.Empty; // "NovoComentario", "MudancaStatus", "AtribuicaoTecnico", etc
    public DateTime DataHora { get; set; }
    public string? NomeTecnico { get; set; }
    public string? NovoStatus { get; set; }
    public int? PrioridadeId { get; set; }
    public string? CorPrioridade { get; set; } // Hex color para notificação
    
    // Helper para mensagem da notificação
    public string MensagemNotificacao
    {
        get
        {
            return TipoAtualizacao switch
            {
                "NovoComentario" => $"💬 Novo comentário em '{TituloResumido}'",
                "MudancaStatus" => $"📊 Status alterado para '{NovoStatus}' em '{TituloResumido}'",
                "AtribuicaoTecnico" => $"👤 {NomeTecnico} foi atribuído ao chamado '{TituloResumido}'",
                "Fechamento" => $"✅ Chamado '{TituloResumido}' foi encerrado",
                "Reabertura" => $"🔄 Chamado '{TituloResumido}' foi reaberto",
                _ => $"🔔 Atualização em '{TituloResumido}'"
            };
        }
    }
}

/// <summary>
/// Resposta do endpoint de verificação de atualizações
/// </summary>
public class VerificacaoAtualizacoesDto
{
    public bool HasUpdates { get; set; }
    public int TotalAtualizacoes { get; set; }
    public DateTime UltimaVerificacao { get; set; }
    public List<AtualizacaoDto> Atualizacoes { get; set; } = new();
}

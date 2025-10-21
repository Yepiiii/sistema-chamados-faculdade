using System.Threading.Tasks;
using SistemaChamados.Mobile.Models.DTOs;

namespace SistemaChamados.Mobile.Services.Notifications;

/// <summary>
/// Interface para serviço de notificações locais multiplataforma
/// </summary>
public interface INotificationService
{
    /// <summary>
    /// Exibe uma notificação local simples
    /// </summary>
    void ExibirNotificacao(string titulo, string mensagem, int notificationId = 0);

    /// <summary>
    /// Exibe notificação de atualização de chamado
    /// </summary>
    void ExibirNotificacaoAtualizacao(AtualizacaoDto atualizacao);

    /// <summary>
    /// Exibe notificação com ação de navegação
    /// </summary>
    void ExibirNotificacaoComAcao(string titulo, string mensagem, int chamadoId, string corPrioridade);

    /// <summary>
    /// Cancela uma notificação específica
    /// </summary>
    void CancelarNotificacao(int notificationId);

    /// <summary>
    /// Cancela todas as notificações
    /// </summary>
    void CancelarTodasNotificacoes();

    /// <summary>
    /// Verifica se permissão de notificação foi concedida
    /// </summary>
    Task<bool> VerificarPermissaoAsync();

    /// <summary>
    /// Solicita permissão de notificação (Android 13+)
    /// </summary>
    Task<bool> SolicitarPermissaoAsync();
}

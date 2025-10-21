using System.Threading.Tasks;
using SistemaChamados.Mobile.Models.DTOs;

namespace SistemaChamados.Mobile.Services.Notifications;

/// <summary>
/// Windows/desktop fallback that safely ignores notification requests.
/// </summary>
public sealed class NoOpNotificationService : INotificationService
{
    public void ExibirNotificacao(string titulo, string mensagem, int notificationId = 0)
    {
        // Notifications are not supported on this platform.
    }

    public void ExibirNotificacaoAtualizacao(AtualizacaoDto atualizacao)
    {
        // Notifications are not supported on this platform.
    }

    public void ExibirNotificacaoComAcao(string titulo, string mensagem, int chamadoId, string corPrioridade)
    {
        // Notifications are not supported on this platform.
    }

    public void CancelarNotificacao(int notificationId)
    {
        // Notifications are not supported on this platform.
    }

    public void CancelarTodasNotificacoes()
    {
        // Notifications are not supported on this platform.
    }

    public Task<bool> VerificarPermissaoAsync() => Task.FromResult(false);

    public Task<bool> SolicitarPermissaoAsync() => Task.FromResult(false);
}

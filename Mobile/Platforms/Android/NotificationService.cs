using Android.App;
using Android.Content;
using Android.OS;
using AndroidX.Core.App;
using SistemaChamados.Mobile.Models.DTOs;
using SistemaChamados.Mobile.Services.Notifications;
using System.Threading.Tasks;
using AndroidColor = Android.Graphics.Color;

[assembly: Dependency(typeof(SistemaChamados.Mobile.Platforms.Android.NotificationService))]

namespace SistemaChamados.Mobile.Platforms.Android;

/// <summary>
/// Implementação Android do serviço de notificações locais
/// </summary>
public class NotificationService : INotificationService
{
    private const string CHANNEL_ID = "chamados_channel";
    private const string CHANNEL_NAME = "Atualizações de Chamados";
    private const string CHANNEL_DESCRIPTION = "Notificações sobre atualizações em seus chamados";
    
    private static Context? _context;
    private static NotificationManagerCompat? _notificationManager;

    public NotificationService()
    {
        _context = global::Android.App.Application.Context;
        _notificationManager = NotificationManagerCompat.From(_context);
        CriarCanalNotificacao();
    }

    /// <summary>
    /// Cria o canal de notificação (Android 8.0+)
    /// </summary>
    private void CriarCanalNotificacao()
    {
        if (Build.VERSION.SdkInt < BuildVersionCodes.O)
            return;

        var channel = new NotificationChannel(CHANNEL_ID, CHANNEL_NAME, NotificationImportance.High)
        {
            Description = CHANNEL_DESCRIPTION,
            LightColor = AndroidColor.ParseColor("#2A5FDF"), // Primary color
        };
        channel.EnableLights(true);
        channel.EnableVibration(true);
        channel.SetVibrationPattern(new long[] { 0, 200, 100, 200 });
        channel.SetShowBadge(true);

        var manager = (NotificationManager?)_context?.GetSystemService(Context.NotificationService);
        manager?.CreateNotificationChannel(channel);
    }

    /// <summary>
    /// Exibe notificação simples
    /// </summary>
    public void ExibirNotificacao(string titulo, string mensagem, int notificationId = 0)
    {
        if (_context == null || _notificationManager == null) return;

        var builder = new NotificationCompat.Builder(_context, CHANNEL_ID)
            .SetContentTitle(titulo)
            .SetContentText(mensagem)
            .SetSmallIcon(Resource.Drawable.notification_icon) // Precisa adicionar ícone
            .SetPriority(NotificationCompat.PriorityHigh)
            .SetAutoCancel(true)
            .SetDefaults(NotificationCompat.DefaultAll);

        _notificationManager.Notify(notificationId, builder.Build());
    }

    /// <summary>
    /// Exibe notificação de atualização com navegação
    /// </summary>
    public void ExibirNotificacaoAtualizacao(AtualizacaoDto atualizacao)
    {
        ExibirNotificacaoComAcao(
            "Sistema de Chamados",
            atualizacao.MensagemNotificacao,
            atualizacao.ChamadoId,
            atualizacao.CorPrioridade ?? "#2A5FDF"
        );
    }

    /// <summary>
    /// Exibe notificação com ação de abrir chamado
    /// </summary>
    public void ExibirNotificacaoComAcao(string titulo, string mensagem, int chamadoId, string corPrioridade)
    {
        if (_context == null || _notificationManager == null) return;

        // Intent para abrir o app
        var intent = new Intent(_context, typeof(MainActivity));
        intent.SetFlags(ActivityFlags.NewTask | ActivityFlags.ClearTask);
        intent.PutExtra("chamadoId", chamadoId);
        intent.PutExtra("openDetail", true);

        var pendingIntent = PendingIntent.GetActivity(
            _context,
            chamadoId,
            intent,
            PendingIntentFlags.UpdateCurrent | PendingIntentFlags.Immutable
        );

        // Cor da notificação baseada na prioridade
        var cor = ParseColor(corPrioridade);

        var builder = new NotificationCompat.Builder(_context, CHANNEL_ID)
            .SetContentTitle(titulo)
            .SetContentText(mensagem)
            .SetSmallIcon(Resource.Drawable.notification_icon)
            .SetColor(cor)
            .SetPriority(NotificationCompat.PriorityHigh)
            .SetCategory(NotificationCompat.CategoryMessage)
            .SetAutoCancel(true)
            .SetContentIntent(pendingIntent)
            .SetDefaults(NotificationCompat.DefaultAll)
            .SetStyle(new NotificationCompat.BigTextStyle().BigText(mensagem));

        _notificationManager.Notify(chamadoId, builder.Build());
    }

    /// <summary>
    /// Cancela notificação específica
    /// </summary>
    public void CancelarNotificacao(int notificationId)
    {
        _notificationManager?.Cancel(notificationId);
    }

    /// <summary>
    /// Cancela todas as notificações
    /// </summary>
    public void CancelarTodasNotificacoes()
    {
        _notificationManager?.CancelAll();
    }

    /// <summary>
    /// Verifica permissão de notificação (Android 13+)
    /// </summary>
    public async Task<bool> VerificarPermissaoAsync()
    {
        if (Build.VERSION.SdkInt >= BuildVersionCodes.Tiramisu)
        {
            var status = await Microsoft.Maui.ApplicationModel.Permissions.CheckStatusAsync<NotificationPermission>();
            return status == Microsoft.Maui.ApplicationModel.PermissionStatus.Granted;
        }
        return true; // Versões antigas não precisam de permissão
    }

    /// <summary>
    /// Solicita permissão de notificação
    /// </summary>
    public async Task<bool> SolicitarPermissaoAsync()
    {
        if (Build.VERSION.SdkInt >= BuildVersionCodes.Tiramisu)
        {
            var status = await Microsoft.Maui.ApplicationModel.Permissions.RequestAsync<NotificationPermission>();
            return status == Microsoft.Maui.ApplicationModel.PermissionStatus.Granted;
        }
        return true;
    }

    /// <summary>
    /// Converte string hex para Color Android
    /// </summary>
    private int ParseColor(string hexColor)
    {
        try
        {
            return AndroidColor.ParseColor(hexColor);
        }
        catch
        {
            return AndroidColor.ParseColor("#2A5FDF"); // Cor padrão
        }
    }
}

/// <summary>
/// Permissão customizada para notificações (Android 13+)
/// </summary>
public class NotificationPermission : Microsoft.Maui.ApplicationModel.Permissions.BasePlatformPermission
{
    public override (string androidPermission, bool isRuntime)[] RequiredPermissions =>
        Build.VERSION.SdkInt >= BuildVersionCodes.Tiramisu
            ? new[] { ("android.permission.POST_NOTIFICATIONS", true) }
            : Array.Empty<(string, bool)>();
}

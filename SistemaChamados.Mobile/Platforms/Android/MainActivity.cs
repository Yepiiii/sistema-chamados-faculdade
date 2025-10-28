using Android.App;
using Android.Content;
using Android.Content.PM;
using Android.OS;

namespace SistemaChamados.Mobile;

[Activity(Theme = "@style/Maui.SplashTheme", MainLauncher = true, LaunchMode = LaunchMode.SingleTop, ConfigurationChanges = ConfigChanges.ScreenSize | ConfigChanges.Orientation | ConfigChanges.UiMode | ConfigChanges.ScreenLayout | ConfigChanges.SmallestScreenSize | ConfigChanges.Density)]
public class MainActivity : MauiAppCompatActivity
{
    protected override void OnCreate(Bundle? savedInstanceState)
    {
        base.OnCreate(savedInstanceState);
        ProcessarIntentNotificacao(Intent);
    }

    protected override void OnNewIntent(Intent? intent)
    {
        base.OnNewIntent(intent);
        ProcessarIntentNotificacao(intent);
    }

    private void ProcessarIntentNotificacao(Intent? intent)
    {
        if (intent == null) return;

        var openDetail = intent.GetBooleanExtra("openDetail", false);
        var chamadoId = intent.GetIntExtra("chamadoId", 0);

        if (openDetail && chamadoId > 0)
        {
            // Navega para o detalhe do chamado
            MainThread.BeginInvokeOnMainThread(async () =>
            {
                await Task.Delay(500); // Aguarda app inicializar
                await Shell.Current.GoToAsync($"//ChamadosListPage/ChamadoDetailPage?id={chamadoId}");
            });
        }
    }
}

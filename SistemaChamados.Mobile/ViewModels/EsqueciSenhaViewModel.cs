using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows.Input;
using Microsoft.Maui.ApplicationModel;
using Microsoft.Maui.Controls;
using SistemaChamados.Mobile.Services.Auth;

namespace SistemaChamados.Mobile.ViewModels;

public class EsqueciSenhaViewModel : BaseViewModel
{
    private readonly IAuthService _authService;
    private static readonly Regex EmailRegex = new(@"^[^\s@]+@[^\s@]+\.[^\s@]+$", RegexOptions.Compiled | RegexOptions.IgnoreCase);

    public string Email { get; set; } = string.Empty;

    public ICommand EnviarCommand { get; }

    public EsqueciSenhaViewModel(IAuthService authService)
    {
        _authService = authService;
        EnviarCommand = new Command(async () => await EnviarAsync());
    }

    private async Task EnviarAsync()
    {
        if (IsBusy)
        {
            return;
        }

        var email = Email.Trim();
        if (string.IsNullOrWhiteSpace(email))
        {
            await MostrarAlertaAsync("Recuperação de senha", "Por favor, informe o seu e-mail.");
            return;
        }

        if (!EmailRegex.IsMatch(email))
        {
            await MostrarAlertaAsync("Recuperação de senha", "Digite um e-mail válido.");
            return;
        }

        try
        {
            IsBusy = true;
            var (sucesso, mensagem) = await _authService.SolicitarResetSenhaAsync(email);
            await MostrarAlertaAsync("Recuperação de senha", mensagem);

            if (sucesso)
            {
                await MainThread.InvokeOnMainThreadAsync(async () =>
                {
                    if (Application.Current?.MainPage is NavigationPage navigationPage)
                    {
                        await navigationPage.PopToRootAsync();
                    }
                });
            }
        }
        catch (System.Exception ex)
        {
            await MostrarAlertaAsync("Recuperação de senha", ex.Message);
        }
        finally
        {
            IsBusy = false;
        }
    }

    private static Task MostrarAlertaAsync(string titulo, string mensagem)
    {
        if (Application.Current?.MainPage != null)
        {
            return MainThread.InvokeOnMainThreadAsync(() => Application.Current.MainPage.DisplayAlert(titulo, mensagem, "OK"));
        }

        return Task.CompletedTask;
    }
}

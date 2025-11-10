using System.Threading.Tasks;
using System.Windows.Input;
using Microsoft.Maui.ApplicationModel;
using Microsoft.Maui.Controls;
using SistemaChamados.Mobile.Services.Auth;
using SistemaChamados.Mobile;

namespace SistemaChamados.Mobile.ViewModels;

public class LoginViewModel : BaseViewModel
{
    private readonly IAuthService _authService;

    public string Email { get; set; } = string.Empty;
    public string Senha { get; set; } = string.Empty;

    public ICommand LoginCommand { get; }

    public LoginViewModel(IAuthService authService)
    {
        _authService = authService;
        LoginCommand = new Command(async () => await Login());
    }

    private async Task Login()
    {
        if (IsBusy) return;
        if (string.IsNullOrEmpty(Email) || string.IsNullOrEmpty(Senha))
        {
            await ShowAlertAsync("Erro", "Email e senha são obrigatórios");
            return;
        }

        try
        {
            IsBusy = true;
            var ok = await _authService.Login(Email, Senha);
            if (!ok)
            {
                await ShowAlertAsync("Erro", "Falha ao autenticar");
                return;
            }

            if (Application.Current is App app)
            {
                app.NavigateToDashboard();
            }
        }
        catch (UnauthorizedAccessException ex)
        {
            await ShowAlertAsync("Acesso Negado", ex.Message);
        }
        catch (Exception ex)
        {
            await ShowAlertAsync("Erro", ex.Message);
        }
        finally
        {
            IsBusy = false;
        }
    }

    private static Task ShowAlertAsync(string title, string message)
    {
        if (Application.Current?.MainPage is Page page)
        {
            return MainThread.InvokeOnMainThreadAsync(() => page.DisplayAlert(title, message, "OK"));
        }

        return Task.CompletedTask;
    }
}

using System;
using System.Threading.Tasks;
using System.Windows.Input;
using Microsoft.Maui.ApplicationModel;
using Microsoft.Maui.Controls;
using SistemaChamados.Mobile.Services.Auth;

namespace SistemaChamados.Mobile.ViewModels;

public class ResetarSenhaViewModel : BaseViewModel
{
    private readonly IAuthService _authService;

    public string Token { get; set; } = string.Empty;
    public string NovaSenha { get; set; } = string.Empty;
    public string ConfirmarSenha { get; set; } = string.Empty;

    public ICommand ResetarCommand { get; }

    public ResetarSenhaViewModel(IAuthService authService)
    {
        _authService = authService;
        ResetarCommand = new Command(async () => await ResetarAsync());
    }

    private async Task ResetarAsync()
    {
        if (IsBusy)
        {
            return;
        }

        var token = Token.Trim();
        var novaSenha = NovaSenha?.Trim() ?? string.Empty;
        var confirmarSenha = ConfirmarSenha?.Trim() ?? string.Empty;

        if (string.IsNullOrWhiteSpace(token) || string.IsNullOrWhiteSpace(novaSenha) || string.IsNullOrWhiteSpace(confirmarSenha))
        {
            await MostrarAlertaAsync("Redefinir senha", "Preencha todos os campos.");
            return;
        }

        if (novaSenha.Length < 6)
        {
            await MostrarAlertaAsync("Redefinir senha", "A senha deve ter pelo menos 6 caracteres.");
            return;
        }

        if (!string.Equals(novaSenha, confirmarSenha, StringComparison.Ordinal))
        {
            await MostrarAlertaAsync("Redefinir senha", "As senhas informadas não coincidem.");
            return;
        }

        try
        {
            IsBusy = true;
            var (sucesso, mensagem) = await _authService.ResetarSenhaAsync(token, novaSenha);
            await MostrarAlertaAsync("Redefinir senha", mensagem);

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
            await MostrarAlertaAsync("Redefinir senha", ex.Message);
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

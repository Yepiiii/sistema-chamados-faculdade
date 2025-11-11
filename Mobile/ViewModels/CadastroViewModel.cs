using System.Threading.Tasks;
using System.Windows.Input;
using Microsoft.Maui.ApplicationModel;
using Microsoft.Maui.Controls;
using SistemaChamados.Mobile.Services.Auth;
using SistemaChamados.Mobile;

namespace SistemaChamados.Mobile.ViewModels;

public class CadastroViewModel : BaseViewModel
{
    private readonly IAuthService _authService;

    public string NomeCompleto { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Senha { get; set; } = string.Empty;
    public string ConfirmarSenha { get; set; } = string.Empty;

    public ICommand CadastroCommand { get; }

    public CadastroViewModel(IAuthService authService)
    {
        _authService = authService;
        CadastroCommand = new Command(async () => await Cadastrar());
    }

    private async Task Cadastrar()
    {
        if (IsBusy) return;

        // Validações
        if (string.IsNullOrWhiteSpace(NomeCompleto))
        {
            await ShowAlertAsync("Erro", "Nome completo é obrigatório");
            return;
        }

        if (string.IsNullOrWhiteSpace(Email))
        {
            await ShowAlertAsync("Erro", "Email é obrigatório");
            return;
        }

        if (!Email.Contains("@"))
        {
            await ShowAlertAsync("Erro", "Email inválido");
            return;
        }

        if (string.IsNullOrWhiteSpace(Senha))
        {
            await ShowAlertAsync("Erro", "Senha é obrigatória");
            return;
        }

        if (Senha.Length < 6)
        {
            await ShowAlertAsync("Erro", "A senha deve ter no mínimo 6 caracteres");
            return;
        }

        if (Senha != ConfirmarSenha)
        {
            await ShowAlertAsync("Erro", "As senhas não conferem");
            return;
        }

        try
        {
            IsBusy = true;
            var (sucesso, mensagem) = await _authService.Cadastrar(NomeCompleto, Email, Senha);
            
            if (!sucesso)
            {
                await ShowAlertAsync("Erro", mensagem);
                return;
            }

            await ShowAlertAsync("Sucesso", mensagem);
            
            // Voltar para a tela de login
            if (Application.Current?.MainPage?.Navigation != null)
            {
                await MainThread.InvokeOnMainThreadAsync(async () =>
                {
                    await Application.Current.MainPage.Navigation.PopAsync();
                });
            }
        }
        catch (Exception ex)
        {
            await ShowAlertAsync("Erro", $"Erro ao cadastrar: {ex.Message}");
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

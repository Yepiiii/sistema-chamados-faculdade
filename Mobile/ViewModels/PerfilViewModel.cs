using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using SistemaChamados.Mobile.Helpers;

namespace SistemaChamados.Mobile.ViewModels;

public partial class PerfilViewModel : ObservableObject
{
    [ObservableProperty]
    private string nomeCompleto = "";

    [ObservableProperty]
    private string email = "";

    [ObservableProperty]
    private string tipoUsuario = "";

    [ObservableProperty]
    private string iniciaisNome = "";

    [ObservableProperty]
    private string usuarioId = "";

    [ObservableProperty]
    private string curso = "Não informado";

    [ObservableProperty]
    private bool mostrarDadosExtras = false;

    [ObservableProperty]
    private int totalChamadosAbertos;

    [ObservableProperty]
    private int totalChamadosEncerrados;

    [ObservableProperty]
    private bool notificacoesAtivas = true;

    [ObservableProperty]
    private bool temaEscuro = false;

    [ObservableProperty]
    private string versaoApp = "1.0.0";

    [ObservableProperty]
    private string errorMessage = string.Empty;

    [ObservableProperty]
    private bool isBusy;

    [ObservableProperty]
    private string title = "";

    public PerfilViewModel()
    {
        Title = "Perfil";
    }

    [RelayCommand]
    private Task LoadData()
    {
        if (IsBusy)
            return Task.CompletedTask;

        try
        {
            IsBusy = true;

            // Carrega dados do usuário do Settings
            NomeCompleto = Settings.NomeUsuario ?? "Usuário";
            Email = Settings.EmailUsuario ?? "email@exemplo.com";
            UsuarioId = Settings.UserId.ToString();

            // Determina tipo de usuário
            var tipo = Settings.TipoUsuario;
            TipoUsuario = tipo switch
            {
                1 => "👨‍🎓 Aluno",
                2 => "🔧 Técnico",
                3 => "👨‍💼 Administrador",
                _ => "Usuário"
            };

            // Mostra dados extras apenas para alunos
            MostrarDadosExtras = tipo == 1;

            // Gera iniciais do nome
            var nomes = NomeCompleto.Split(' ', StringSplitOptions.RemoveEmptyEntries);
            if (nomes.Length >= 2)
            {
                IniciaisNome = $"{nomes[0][0]}{nomes[^1][0]}".ToUpper();
            }
            else if (nomes.Length == 1)
            {
                IniciaisNome = nomes[0].Length >= 2 
                    ? nomes[0].Substring(0, 2).ToUpper() 
                    : nomes[0].ToUpper();
            }

            // TODO: Carregar estatísticas reais do backend
            TotalChamadosAbertos = 3;
            TotalChamadosEncerrados = 12;

            // Carrega versão do app
            VersaoApp = AppInfo.Current.VersionString;

        }
        catch (Exception ex)
        {
            ErrorMessage = $"Erro ao carregar perfil: {ex.Message}";
        }
        finally
        {
            IsBusy = false;
        }

        return Task.CompletedTask;
    }

    [RelayCommand]
    private async Task Logout()
    {
        var confirma = await Application.Current?.MainPage?.DisplayAlert(
            "Sair",
            "Tem certeza que deseja sair?",
            "Sim",
            "Não"
        )!;

        if (confirma)
        {
            // Limpa dados do usuário
            Settings.AccessToken = string.Empty;
            Settings.RefreshToken = string.Empty;
            Settings.NomeUsuario = string.Empty;
            Settings.EmailUsuario = string.Empty;
            Settings.UserId = 0;
            Settings.TipoUsuario = 0;

            // Navega para login
            Application.Current!.MainPage = new AppShell();
            await Shell.Current.GoToAsync("//login");
        }
    }
}

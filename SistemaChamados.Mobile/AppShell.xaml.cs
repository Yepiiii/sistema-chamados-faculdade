using Microsoft.Maui.Controls;
using Microsoft.Maui.ApplicationModel;
using SistemaChamados.Mobile.Helpers;
using SistemaChamados.Mobile.Services.Auth;

namespace SistemaChamados.Mobile;

public partial class AppShell : Shell
{
    public AppShell()
    {
        try
        {
            App.Log("AppShell constructor start");
            InitializeComponent();
            App.Log("AppShell InitializeComponent ok");
            
            // Configura o estado inicial do switch de tema
            InitializeThemeSwitch();
            App.Log("AppShell InitializeThemeSwitch called");
            
            RegisterRoutes();
            App.Log("AppShell routes registered");
            App.Log("AppShell constructor complete");
        }
        catch (Exception ex)
        {
            App.Log($"AppShell constructor ERROR: {ex.Message}");
            App.Log($"AppShell constructor STACK: {ex.StackTrace}");
            throw;
        }
    }

    private void InitializeThemeSwitch()
    {
        try
        {
            // Aguarda um pouco para garantir que o XAML está carregado
            MainThread.BeginInvokeOnMainThread(() =>
            {
                try
                {
                    if (ThemeSwitch != null)
                    {
                        // Verifica o tema atual e configura o switch
                        var currentTheme = Application.Current?.RequestedTheme ?? AppTheme.Light;
                        ThemeSwitch.IsToggled = currentTheme == AppTheme.Dark;
                        
                        App.Log($"AppShell theme initialized: {currentTheme}");
                    }
                    else
                    {
                        App.Log("AppShell InitializeThemeSwitch: ThemeSwitch is null");
                    }
                }
                catch (Exception ex)
                {
                    App.Log($"AppShell InitializeThemeSwitch inner ERROR: {ex.Message}");
                }
            });
        }
        catch (Exception ex)
        {
            App.Log($"AppShell InitializeThemeSwitch ERROR: {ex.Message}");
        }
    }

    private void OnThemeToggled(object sender, ToggledEventArgs e)
    {
        try
        {
            App.Log($"AppShell OnThemeToggled start: {e.Value}");
            
            // Executa no main thread para evitar problemas de concorrência
            MainThread.BeginInvokeOnMainThread(() =>
            {
                try
                {
                    if (Application.Current == null)
                    {
                        App.Log("AppShell OnThemeToggled: Application.Current is null");
                        return;
                    }
                    
                    // Alterna entre Light e Dark mode
                    var newTheme = e.Value ? AppTheme.Dark : AppTheme.Light;
                    
                    App.Log($"AppShell setting theme to: {newTheme}");
                    Application.Current.UserAppTheme = newTheme;
                    
                    // Salva a preferência do usuário
                    Preferences.Set("app_theme", newTheme.ToString());
                    
                    App.Log($"AppShell theme changed successfully to: {newTheme}");
                }
                catch (Exception innerEx)
                {
                    App.Log($"AppShell OnThemeToggled inner ERROR: {innerEx.Message}");
                    App.Log($"AppShell OnThemeToggled inner STACK: {innerEx.StackTrace}");
                }
            });
        }
        catch (Exception ex)
        {
            App.Log($"AppShell OnThemeToggled ERROR: {ex.Message}");
            App.Log($"AppShell OnThemeToggled STACK: {ex.StackTrace}");
        }
    }

    private async void OnLogoutTapped(object sender, EventArgs e)
    {
        try
        {
            App.Log("AppShell OnLogoutTapped start");
            
            // Fecha o menu lateral
            FlyoutIsPresented = false;
            
            // Aguarda um pouco para a animação do menu
            await Task.Delay(200);
            
            // Confirmação do logout
            bool confirm = await DisplayAlert(
                "Sair da Conta", 
                "Você será desconectado e precisará fazer login novamente para acessar o sistema.\n\nDeseja continuar?", 
                "Sim, sair", 
                "Cancelar"
            );
            
            if (!confirm)
            {
                App.Log("AppShell OnLogoutTapped cancelled by user");
                return;
            }
            
            // Realiza o logout
            var authService = ServiceHelper.GetService<IAuthService>();
            await authService.Logout();
            
            App.Log("AppShell OnLogoutTapped logout complete");
            
            // Navega para a tela de login
            if (Application.Current is App app)
            {
                app.NavigateToLogin();
            }
            
            App.Log("AppShell OnLogoutTapped navigation to login complete");
        }
        catch (Exception ex)
        {
            App.Log($"AppShell OnLogoutTapped ERROR: {ex.GetType().Name} - {ex.Message}");
            
            await DisplayAlert("Erro", $"Não foi possível sair da conta. Tente novamente.\n\nDetalhes: {ex.Message}", "OK");
        }
    }

    private static void RegisterRoutes()
    {
        // Rotas modais (push) - não são parte do TabBar
        Routing.RegisterRoute("chamados/detail", typeof(Views.ChamadoDetailPage));
        Routing.RegisterRoute("chamados/novo", typeof(Views.NovoChamadoPage));
        Routing.RegisterRoute("login", typeof(Views.Auth.LoginPage));
    }
}

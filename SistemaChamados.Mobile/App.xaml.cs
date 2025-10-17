using Microsoft.Extensions.DependencyInjection;
using Microsoft.Maui.Controls;
using Microsoft.Maui.ApplicationModel;
using SistemaChamados.Mobile.Services.Auth;

namespace SistemaChamados.Mobile;

public partial class App : Application
{
    private readonly IServiceProvider _services;

    public App(IServiceProvider services, IAuthService authService)
    {
        InitializeComponent();
        _services = services;

        // Sempre fazer logout ao iniciar o app
        _ = authService.Logout();

        // Sempre navegar para login
        NavigateToLogin();
    }

    public void NavigateToDashboard()
    {
        MainThread.BeginInvokeOnMainThread(() =>
        {
            MainPage = _services.GetRequiredService<AppShell>();
        });
    }

    public void NavigateToLogin()
    {
        MainThread.BeginInvokeOnMainThread(() =>
        {
            var loginPage = _services.GetRequiredService<Views.Auth.LoginPage>();
            MainPage = new NavigationPage(loginPage);
        });
    }
}

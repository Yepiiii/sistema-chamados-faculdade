using Microsoft.Maui.Controls;

namespace SistemaChamados.Mobile;

public partial class AppShell : Shell
{
    public AppShell()
    {
        App.Log("AppShell constructor start");
        InitializeComponent();
        App.Log("AppShell InitializeComponent ok");
        RegisterRoutes();
        App.Log("AppShell routes registered");
    }

    private static void RegisterRoutes()
    {
        // Rotas modais (push) - não são parte do TabBar
        Routing.RegisterRoute("chamados/detail", typeof(Views.ChamadoDetailPage));
        Routing.RegisterRoute("chamados/confirmacao", typeof(Views.ChamadoConfirmacaoPage));
        Routing.RegisterRoute("chamados/novo", typeof(Views.NovoChamadoPage));
        Routing.RegisterRoute("login", typeof(Views.Auth.LoginPage));
    }
}

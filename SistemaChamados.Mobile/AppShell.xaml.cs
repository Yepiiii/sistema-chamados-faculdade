using Microsoft.Maui.Controls;

namespace SistemaChamados.Mobile;

public partial class AppShell : Shell
{
    private const string ChamadosListRoute = "chamados/list";
    private const string ChamadoDetailRoute = "chamados/detail";
    private const string NovoChamadoRoute = "chamados/novo";
    private const string ChamadoConfirmacaoRoute = "chamados/confirmacao";

    public AppShell()
    {
        InitializeComponent();
        RegisterRoutes();
    }

    private static void RegisterRoutes()
    {
        Routing.RegisterRoute(ChamadosListRoute, typeof(Views.ChamadosListPage));
        Routing.RegisterRoute(ChamadoDetailRoute, typeof(Views.ChamadoDetailPage));
        Routing.RegisterRoute(NovoChamadoRoute, typeof(Views.NovoChamadoPage));
        Routing.RegisterRoute(ChamadoConfirmacaoRoute, typeof(Views.ChamadoConfirmacaoPage));
    }
}

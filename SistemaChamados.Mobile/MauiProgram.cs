using System;
using System.Net.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Maui.Controls.Hosting;
using Microsoft.Maui.Hosting;
using SistemaChamados.Mobile.Helpers;
using SistemaChamados.Mobile.Services.Auth;
using SistemaChamados.Mobile.Services.Api;
using SistemaChamados.Mobile.Services.Chamados;
using SistemaChamados.Mobile.Services.Categorias;
using SistemaChamados.Mobile.Services.Comentarios;
using SistemaChamados.Mobile.Services.Prioridades;
using SistemaChamados.Mobile.Services.Status;
using SistemaChamados.Mobile.ViewModels;

namespace SistemaChamados.Mobile;

public static class MauiProgram
{
    public static MauiApp CreateMauiApp()
    {
        var builder = MauiApp.CreateBuilder();
        builder
            .UseMauiApp<App>()
            .ConfigureFonts(fonts => { })
            ;

        // Configuration from appsettings.json
        var a = new ConfigurationBuilder()
            .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
            .AddEnvironmentVariables()
            .Build();

        builder.Configuration.AddConfiguration(a);

        // Shared HttpClient so auth header updates propagate to every service instance
        builder.Services.AddSingleton(new HttpClient
        {
            BaseAddress = new Uri(Constants.BaseUrl),
            Timeout = TimeSpan.FromSeconds(30)
        });
        builder.Services.AddSingleton<IApiService, ApiService>();

        // Auth and domain services
        builder.Services.AddSingleton<IAuthService, AuthService>();
    builder.Services.AddSingleton<IChamadoService, ChamadoService>();
    builder.Services.AddSingleton<IComentarioService, ComentarioService>();
        builder.Services.AddSingleton<ICategoriaService, CategoriaService>();
        builder.Services.AddSingleton<IPrioridadeService, PrioridadeService>();
        builder.Services.AddSingleton<IStatusService, StatusService>();

        // ViewModels
        builder.Services.AddTransient<LoginViewModel>();
        builder.Services.AddTransient<ChamadosListViewModel>();
        builder.Services.AddTransient<ChamadoDetailViewModel>();
        builder.Services.AddTransient<NovoChamadoViewModel>();
        builder.Services.AddTransient<EsqueciSenhaViewModel>();
        builder.Services.AddTransient<ResetarSenhaViewModel>();

        // Pages
        builder.Services.AddTransient<AppShell>();
        builder.Services.AddTransient<Views.Auth.LoginPage>();
        builder.Services.AddTransient<Views.ChamadosListPage>();
        builder.Services.AddTransient<Views.ChamadoDetailPage>();
        builder.Services.AddTransient<Views.NovoChamadoPage>();
        builder.Services.AddTransient<Views.Auth.EsqueciSenhaPage>();
        builder.Services.AddTransient<Views.Auth.ResetarSenhaPage>();

        return builder.Build();
    }
}

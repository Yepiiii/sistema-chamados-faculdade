using System;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Maui.Controls.Hosting;
using Microsoft.Maui.Hosting;
using SistemaChamados.Mobile.Extensions;

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

        // ========================================
        // DEPENDENCY INJECTION
        // ========================================
        // Registra toda a infraestrutura (HttpClient, API Services)
        // e camada de apresentação (Views + ViewModels) através de extension methods
        builder.Services.AddMobileInfrastructure();
        // ========================================

        return builder.Build();
    }
}

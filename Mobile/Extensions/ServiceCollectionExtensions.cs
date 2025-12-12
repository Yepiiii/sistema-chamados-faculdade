using System;
using System.Net.Http;
using Microsoft.Extensions.DependencyInjection;
using SistemaChamados.Mobile.Helpers;
using SistemaChamados.Mobile.Services.Api;
using SistemaChamados.Mobile.Services.Auth;
using SistemaChamados.Mobile.Services.Categorias;
using SistemaChamados.Mobile.Services.Chamados;
using SistemaChamados.Mobile.Services.Comentarios;
using SistemaChamados.Mobile.Services.Prioridades;
using SistemaChamados.Mobile.Services.Status;
using SistemaChamados.Mobile.ViewModels;

namespace SistemaChamados.Mobile.Extensions;

/// <summary>
/// Extension methods para configuração de injeção de dependências da aplicação Mobile.
/// Centraliza todos os registros de serviços, mantendo o MauiProgram.cs limpo e focado.
/// Segue o princípio de Separação de Responsabilidades (SRP).
/// </summary>
public static class ServiceCollectionExtensions
{
    /// <summary>
    /// Registra toda a infraestrutura necessária para a aplicação Mobile:
    /// - HttpClient configurado com BaseAddress
    /// - Serviços de API (Auth, Tickets, Categorias, etc.)
    /// - ViewModels (com ciclo de vida Transient)
    /// - Pages (com ciclo de vida Transient)
    /// </summary>
    /// <param name="services">A coleção de serviços do DI container</param>
    /// <param name="baseUrl">URL base da API (opcional, usa Constants.BaseUrl se não fornecido)</param>
    /// <returns>A mesma coleção de serviços para method chaining</returns>
    public static IServiceCollection AddMobileInfrastructure(
        this IServiceCollection services, 
        string? baseUrl = null)
    {
        // ========================================
        // HTTP CLIENT CONFIGURATION
        // ========================================
        // Singleton: HttpClient compartilhado para que atualizações no header de autenticação
        // se propaguem para todas as instâncias de serviços que o utilizam
        services.AddSingleton(new HttpClient
        {
            BaseAddress = new Uri(baseUrl ?? Constants.BaseUrl),
            Timeout = TimeSpan.FromSeconds(30)
        });

        // ========================================
        // API SERVICES (Infrastructure Layer)
        // ========================================
        // Singleton: Mantém estado de autenticação e configurações HTTP
        services.AddSingleton<IApiService, ApiService>();
        services.AddSingleton<IAuthService, AuthService>();
        
        // Domain API Services
        services.AddSingleton<IChamadoService, ChamadoService>();
        services.AddSingleton<IComentarioService, ComentarioService>();
        services.AddSingleton<ICategoriaService, CategoriaService>();
        services.AddSingleton<IPrioridadeService, PrioridadeService>();
        services.AddSingleton<IStatusService, StatusService>();

        // ========================================
        // PRESENTATION LAYER (Views + ViewModels)
        // ========================================
        services.AddMobilePresentation();

        return services;
    }

    /// <summary>
    /// Registra toda a camada de apresentação (Views + ViewModels) organizados por funcionalidade.
    /// Todos os registros usam ciclo de vida Transient para evitar acúmulo de estado entre navegações.
    /// Pares View/ViewModel são registrados juntos para facilitar manutenção.
    /// </summary>
    /// <param name="services">A coleção de serviços do DI container</param>
    /// <returns>A mesma coleção de serviços para method chaining</returns>
    public static IServiceCollection AddMobilePresentation(this IServiceCollection services)
    {
        // ========================================
        // SHELL (Navigation Container)
        // ========================================
        services.AddTransient<AppShell>();

        // ========================================
        // AUTH FEATURE (Login, Cadastro, Recuperação de Senha)
        // ========================================
        // Login
        services.AddTransient<LoginViewModel>();
        services.AddTransient<Views.Auth.LoginPage>();

        // Cadastro
        services.AddTransient<CadastroViewModel>();
        services.AddTransient<Views.Auth.CadastroPage>();

        // Esqueci Senha
        services.AddTransient<EsqueciSenhaViewModel>();
        services.AddTransient<Views.Auth.EsqueciSenhaPage>();

        // Resetar Senha
        services.AddTransient<ResetarSenhaViewModel>();
        services.AddTransient<Views.Auth.ResetarSenhaPage>();

        // ========================================
        // TICKETS FEATURE (Chamados)
        // ========================================
        // Lista de Chamados
        services.AddTransient<ChamadosListViewModel>();
        services.AddTransient<Views.ChamadosListPage>();

        // Detalhes do Chamado
        services.AddTransient<ChamadoDetailViewModel>();
        services.AddTransient<Views.ChamadoDetailPage>();

        // Novo Chamado
        services.AddTransient<NovoChamadoViewModel>();
        services.AddTransient<Views.NovoChamadoPage>();

        return services;
    }

    /// <summary>
    /// Método alternativo para configuração de serviços de API apenas.
    /// Útil para testes ou configurações customizadas.
    /// </summary>
    /// <param name="services">A coleção de serviços do DI container</param>
    /// <param name="baseUrl">URL base da API</param>
    /// <returns>A mesma coleção de serviços para method chaining</returns>
    public static IServiceCollection AddApiServices(
        this IServiceCollection services,
        string baseUrl)
    {
        services.AddSingleton(new HttpClient
        {
            BaseAddress = new Uri(baseUrl),
            Timeout = TimeSpan.FromSeconds(30)
        });

        services.AddSingleton<IApiService, ApiService>();
        services.AddSingleton<IAuthService, AuthService>();
        services.AddSingleton<IChamadoService, ChamadoService>();
        services.AddSingleton<IComentarioService, ComentarioService>();
        services.AddSingleton<ICategoriaService, CategoriaService>();
        services.AddSingleton<IPrioridadeService, PrioridadeService>();
        services.AddSingleton<IStatusService, StatusService>();

        return services;
    }

    /// <summary>
    /// Método alternativo para configuração de ViewModels apenas.
    /// Útil para testes ou configurações customizadas.
    /// </summary>
    /// <param name="services">A coleção de serviços do DI container</param>
    /// <returns>A mesma coleção de serviços para method chaining</returns>
    public static IServiceCollection AddViewModels(this IServiceCollection services)
    {
        services.AddTransient<LoginViewModel>();
        services.AddTransient<CadastroViewModel>();
        services.AddTransient<ChamadosListViewModel>();
        services.AddTransient<ChamadoDetailViewModel>();
        services.AddTransient<NovoChamadoViewModel>();
        services.AddTransient<EsqueciSenhaViewModel>();
        services.AddTransient<ResetarSenhaViewModel>();

        return services;
    }

    /// <summary>
    /// Método alternativo para configuração de Pages apenas.
    /// Útil para testes ou configurações customizadas.
    /// </summary>
    /// <param name="services">A coleção de serviços do DI container</param>
    /// <returns>A mesma coleção de serviços para method chaining</returns>
    public static IServiceCollection AddPages(this IServiceCollection services)
    {
        services.AddTransient<AppShell>();
        services.AddTransient<Views.Auth.LoginPage>();
        services.AddTransient<Views.Auth.CadastroPage>();
        services.AddTransient<Views.ChamadosListPage>();
        services.AddTransient<Views.ChamadoDetailPage>();
        services.AddTransient<Views.NovoChamadoPage>();
        services.AddTransient<Views.Auth.EsqueciSenhaPage>();
        services.AddTransient<Views.Auth.ResetarSenhaPage>();

        return services;
    }
}

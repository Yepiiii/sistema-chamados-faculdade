using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Maui.ApplicationModel;
using Microsoft.Maui.Controls;
using Microsoft.Maui.Storage;
using SistemaChamados.Mobile.Services.Auth;

namespace SistemaChamados.Mobile;

public partial class App : Application
{
    private readonly IServiceProvider _services;

    public static IServiceProvider Services { get; private set; } = default!;

    public App(IServiceProvider services, IAuthService authService)
    {
        try
        {
            Log("App constructor: start");
            InitializeComponent();
            Log("App constructor: InitializeComponent done");
            
            _services = services;
            Services = services;
            Log("App constructor: services set");

            AppDomain.CurrentDomain.UnhandledException += OnUnhandledException;
            TaskScheduler.UnobservedTaskException += OnUnobservedTaskException;
            Log("App constructor: exception handlers registered");

            // Sempre fazer logout ao iniciar o app
            _ = authService.Logout();
            Log("App constructor: logout called");

            // Sempre navegar para login
            Log("App constructor: navigating to login");
            NavigateToLogin();
            Log("App constructor: complete");
        }
        catch (Exception ex)
        {
            Log($"App constructor FATAL: {ex}");
            throw;
        }
    }

    public void NavigateToDashboard()
    {
        Log("NavigateToDashboard invoked");
        MainThread.BeginInvokeOnMainThread(() =>
        {
            Log("Navigating to dashboard");
            MainPage = _services.GetRequiredService<AppShell>();
        });
    }

    public void NavigateToLogin()
    {
        Log("NavigateToLogin invoked");
        MainThread.BeginInvokeOnMainThread(() =>
        {
            Log("Navigating to login");
            var loginPage = _services.GetRequiredService<Views.Auth.LoginPage>();
            MainPage = new NavigationPage(loginPage);
        });
    }

    private static void OnUnhandledException(object sender, UnhandledExceptionEventArgs e)
    {
        Log($"FATAL: {e.ExceptionObject}");
    }

    private static void OnUnobservedTaskException(object? sender, UnobservedTaskExceptionEventArgs e)
    {
        Log($"TASK: {e.Exception}");
        e.SetObserved();
    }

    internal static void Log(string message)
    {
        try
        {
            var path = Path.Combine(FileSystem.AppDataDirectory, "app-log.txt");
            var line = $"{DateTime.Now:yyyy-MM-dd HH:mm:ss} {message}{Environment.NewLine}";
            File.AppendAllText(path, line);

            var fallbackPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "SistemaChamados.Mobile-app-log.txt");
            File.AppendAllText(fallbackPath, line);
        }
        catch
        {
            // ignored
        }
    }
}

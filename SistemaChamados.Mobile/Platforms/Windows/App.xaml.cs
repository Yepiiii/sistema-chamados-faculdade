using Microsoft.UI.Xaml;
using System;
using System.Diagnostics;

// To learn more about WinUI, the WinUI project structure,
// and more about our project templates, see: http://aka.ms/winui-project-info.

namespace SistemaChamados.Mobile.WinUI;

/// <summary>
/// Provides application-specific behavior to supplement the default Application class.
/// </summary>
public partial class App : MauiWinUIApplication
{
	/// <summary>
	/// Initializes the singleton application object.  This is the first line of authored code
	/// executed, and as such is the logical equivalent of main() or WinMain().
	/// </summary>
	public App()
	{
		try
		{
			Debug.WriteLine("[WinUI.App] Constructor start");
			this.InitializeComponent();
			Debug.WriteLine("[WinUI.App] InitializeComponent done");
		}
		catch (Exception ex)
		{
			Debug.WriteLine($"[WinUI.App] FATAL: {ex}");
			throw;
		}
	}

	protected override MauiApp CreateMauiApp()
	{
		try
		{
			Debug.WriteLine("[WinUI.App] CreateMauiApp start");
			var app = MauiProgram.CreateMauiApp();
			Debug.WriteLine("[WinUI.App] CreateMauiApp done");
			return app;
		}
		catch (Exception ex)
		{
			Debug.WriteLine($"[WinUI.App] CreateMauiApp FATAL: {ex}");
			throw;
		}
	}
}


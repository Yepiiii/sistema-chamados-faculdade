using System.Threading.Tasks;
using System.Windows.Input;
using Microsoft.Maui.Controls;
using SistemaChamados.Mobile.Services.Auth;
using SistemaChamados.Mobile;

namespace SistemaChamados.Mobile.ViewModels;

public class MainViewModel : BaseViewModel
{
	private readonly IAuthService _authService;

	public MainViewModel(IAuthService authService)
	{
		_authService = authService;
		LogoutCommand = new Command(async () => await LogoutAsync());
		GoChamadosCommand = new Command(async () => await GoChamadosAsync());
		NovoChamadoCommand = new Command(async () => await NovoChamadoAsync());
	}

	public string Welcome => _authService.CurrentUser?.NomeCompleto ?? "Usuário";

	public ICommand LogoutCommand { get; }

	public ICommand GoChamadosCommand { get; }

	public ICommand NovoChamadoCommand { get; }

	private async Task LogoutAsync()
	{
		await _authService.Logout();

		if (Application.Current is App app)
		{
			app.NavigateToLogin();
		}
	}

	private static async Task GoChamadosAsync()
	{
		if (Shell.Current is not null)
		{
			await Shell.Current.GoToAsync("chamados/list");
		}
	}

	private static async Task NovoChamadoAsync()
	{
		if (Shell.Current is not null)
		{
			await Shell.Current.GoToAsync("chamados/novo");
		}
	}
}

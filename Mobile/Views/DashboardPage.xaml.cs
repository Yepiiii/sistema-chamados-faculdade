using SistemaChamados.Mobile.Helpers;
using SistemaChamados.Mobile.ViewModels;
using System;

namespace SistemaChamados.Mobile.Views;

public partial class DashboardPage : ContentPage
{
    private readonly DashboardViewModel _viewModel;

    public DashboardPage(DashboardViewModel? viewModel = null)
    {
        InitializeComponent();
        App.Log("DashboardPage InitializeComponent");
        _viewModel = viewModel ?? ServiceHelper.GetService<DashboardViewModel>();
        BindingContext = _viewModel;
    }

    protected override async void OnAppearing()
    {
        base.OnAppearing();
        App.Log("DashboardPage OnAppearing start");
        await _viewModel.LoadDataCommand.ExecuteAsync(null);
        App.Log("DashboardPage OnAppearing end");
    }

    private async void OnNovoChamadoClicked(object sender, EventArgs e)
    {
        try
        {
            App.Log("DashboardPage OnNovoChamadoClicked start");
            var route = "///chamados/novo";
            App.Log($"DashboardPage navigating to: {route}");
            await Shell.Current.GoToAsync(route);
            App.Log("DashboardPage OnNovoChamadoClicked navigation complete");
        }
        catch (Exception ex)
        {
            App.Log($"DashboardPage OnNovoChamadoClicked ERROR: {ex.GetType().Name} - {ex.Message}");
            App.Log($"DashboardPage OnNovoChamadoClicked STACK: {ex.StackTrace}");
            
            await MainThread.InvokeOnMainThreadAsync(async () =>
            {
                await DisplayAlert("Erro", $"Não foi possível abrir o formulário: {ex.Message}", "OK");
            });
        }
    }
}

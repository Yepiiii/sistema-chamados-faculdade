using SistemaChamados.Mobile.Helpers;
using SistemaChamados.Mobile.Models.DTOs;
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

    private async void OnChamadoTapped(object sender, EventArgs e)
    {
        try
        {
            App.Log("DashboardPage OnChamadoTapped start");
            
            // Obtém o chamado do BindingContext do Frame
            if (sender is Frame frame && frame.BindingContext is ChamadoDto chamado)
            {
                App.Log($"DashboardPage tapped chamado {chamado.Id}");

                // Navega para detalhes usando navegação relativa modal
                App.Log($"DashboardPage navigating to chamados/detail?id={chamado.Id}");
                await Shell.Current.GoToAsync($"chamados/detail?id={chamado.Id}");
                App.Log("DashboardPage navigation complete");
            }
            else
            {
                App.Log($"DashboardPage OnChamadoTapped: sender type={sender?.GetType().Name}, BindingContext type={((Frame)sender)?.BindingContext?.GetType().Name}");
            }
        }
        catch (Exception ex)
        {
            App.Log($"DashboardPage OnChamadoTapped FATAL: {ex}");
            await Application.Current?.MainPage?.DisplayAlert("Erro", "Não foi possível abrir o chamado. Tente novamente.", "OK");
        }
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

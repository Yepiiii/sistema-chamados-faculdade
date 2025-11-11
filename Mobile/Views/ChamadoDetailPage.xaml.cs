using Microsoft.Maui.Controls;
using SistemaChamados.Mobile.Helpers;
using SistemaChamados.Mobile.ViewModels;
using System;

namespace SistemaChamados.Mobile.Views;

[QueryProperty("ChamadoId","Id")]
public partial class ChamadoDetailPage : ContentPage
{
    private readonly ChamadoDetailViewModel _vm;

    public ChamadoDetailPage(ChamadoDetailViewModel? vm = null)
    {
        try
        {
            App.Log("ChamadoDetailPage constructor start");
            InitializeComponent();
            App.Log("ChamadoDetailPage InitializeComponent done");
            _vm = vm ?? ServiceHelper.GetService<ChamadoDetailViewModel>();
            App.Log("ChamadoDetailPage ViewModel resolved");
            BindingContext = _vm;
            App.Log("ChamadoDetailPage BindingContext set");
        }
        catch (Exception ex)
        {
            App.Log($"ChamadoDetailPage constructor FATAL: {ex}");
            throw;
        }
    }

    public string ChamadoId
    {
        set
        {
            try
            {
                App.Log($"ChamadoDetailPage ChamadoId setter: {value}");
                if (int.TryParse(value, out var id))
                {
                    App.Log($"ChamadoDetailPage calling LoadChamadoAsync({id})");
                    MainThread.BeginInvokeOnMainThread(async () =>
                    {
                        try
                        {
                            await _vm.LoadChamadoAsync(id);
                            // Inicia o auto-refresh após carregar
                            _vm.StartAutoRefresh();
                            App.Log("ChamadoDetailPage auto-refresh started");
                        }
                        catch (Exception ex)
                        {
                            App.Log($"ChamadoDetailPage LoadChamadoAsync FATAL: {ex}");
                            await DisplayAlert("Erro", $"Erro ao carregar chamado: {ex.Message}", "OK");
                            await Shell.Current.GoToAsync("..");
                        }
                    });
                }
            }
            catch (Exception ex)
            {
                App.Log($"ChamadoDetailPage ChamadoId setter FATAL: {ex}");
            }
        }
    }

    protected override void OnDisappearing()
    {
        base.OnDisappearing();
        App.Log("ChamadoDetailPage OnDisappearing");
        // Para o auto-refresh quando sair da página
        _vm.StopAutoRefresh();
        App.Log("ChamadoDetailPage auto-refresh stopped");
    }

    protected override void OnAppearing()
    {
        base.OnAppearing();
        App.Log("ChamadoDetailPage OnAppearing");
        // Reinicia o auto-refresh se voltou para a página
        if (_vm.Id > 0)
        {
            _vm.StartAutoRefresh();
            App.Log("ChamadoDetailPage auto-refresh restarted");
        }
    }
}

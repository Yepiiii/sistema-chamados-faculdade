using System;
using System.Linq;
using Microsoft.Maui.Controls;
using SistemaChamados.Mobile.Helpers;
using SistemaChamados.Mobile.Models.DTOs;
using SistemaChamados.Mobile.ViewModels;

namespace SistemaChamados.Mobile.Views;

public partial class ChamadosListPage : ContentPage
{
    private readonly ChamadosListViewModel _vm;

    public ChamadosListPage(ChamadosListViewModel? vm = null)
    {
        InitializeComponent();
        App.Log("ChamadosListPage InitializeComponent");
        _vm = vm ?? ServiceHelper.GetService<ChamadosListViewModel>();
        BindingContext = _vm;
        // Removido: Load() será chamado apenas no OnAppearing()
    }

    protected override void OnAppearing()
    {
        base.OnAppearing();
        System.Diagnostics.Debug.WriteLine("========================================");
        System.Diagnostics.Debug.WriteLine("ChamadosListPage.OnAppearing() - FIRED");
        System.Diagnostics.Debug.WriteLine("========================================");
        App.Log("ChamadosListPage OnAppearing - Loading data");
        _ = _vm.Load();
    }

    private async void OnSelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        try
        {
            App.Log("ChamadosListPage OnSelectionChanged start");
            
            var item = e.CurrentSelection.FirstOrDefault() as ChamadoDto;
            App.Log($"ChamadosListPage OnSelectionChanged item: {item?.Id ?? 0}");
            
            if (item == null)
            {
                App.Log("ChamadosListPage OnSelectionChanged item is null, returning");
                return;
            }
            
            if (sender is CollectionView collectionView)
            {
                collectionView.SelectedItem = null;
                App.Log("ChamadosListPage OnSelectionChanged cleared selection");
            }

            var route = $"///chamados/detail?Id={item.Id}";
            App.Log($"ChamadosListPage navigating to: {route}");
            
            await Shell.Current.GoToAsync(route);
            
            App.Log("ChamadosListPage navigation completed");
        }
        catch (Exception ex)
        {
            App.Log($"ChamadosListPage OnSelectionChanged ERROR: {ex.GetType().Name} - {ex.Message}");
            App.Log($"ChamadosListPage OnSelectionChanged STACK: {ex.StackTrace}");
            
            await MainThread.InvokeOnMainThreadAsync(async () =>
            {
                await DisplayAlert("Erro", $"Não foi possível abrir o chamado: {ex.Message}", "OK");
            });
        }
    }

    private async void OnNovoClicked(object sender, EventArgs e)
    {
        try
        {
            App.Log("ChamadosListPage OnNovoClicked start");
            var route = "///chamados/novo";
            App.Log($"ChamadosListPage navigating to: {route}");
            
            await Shell.Current.GoToAsync(route);
            
            App.Log("ChamadosListPage OnNovoClicked navigation complete");
        }
        catch (Exception ex)
        {
            App.Log($"ChamadosListPage OnNovoClicked ERROR: {ex.GetType().Name} - {ex.Message}");
            App.Log($"ChamadosListPage OnNovoClicked STACK: {ex.StackTrace}");
            
            await MainThread.InvokeOnMainThreadAsync(async () =>
            {
                await DisplayAlert("Erro", $"Não foi possível abrir o formulário: {ex.Message}", "OK");
            });
        }
    }
}

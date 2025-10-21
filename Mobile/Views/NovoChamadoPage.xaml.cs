using System;
using System.Linq;
using Microsoft.Maui.Controls;
using SistemaChamados.Mobile.Helpers;
using SistemaChamados.Mobile.Models.DTOs;
using SistemaChamados.Mobile.ViewModels;

namespace SistemaChamados.Mobile.Views;

public partial class NovoChamadoPage : ContentPage
{
    public NovoChamadoPage(NovoChamadoViewModel? vm = null)
    {
        try
        {
            App.Log("NovoChamadoPage constructor start");
            InitializeComponent();
            App.Log("NovoChamadoPage InitializeComponent done");
            BindingContext = vm ?? ServiceHelper.GetService<NovoChamadoViewModel>();
            App.Log("NovoChamadoPage BindingContext set");
        }
        catch (Exception ex)
        {
            App.Log($"NovoChamadoPage constructor FATAL: {ex}");
            throw;
        }
    }

    private NovoChamadoViewModel ViewModel => (NovoChamadoViewModel)BindingContext;

    protected override async void OnAppearing()
    {
        base.OnAppearing();
        App.Log("NovoChamadoPage OnAppearing start");

        if ((!ViewModel.Categorias.Any() || !ViewModel.Prioridades.Any()) && !ViewModel.IsBusy)
        {
            App.Log("NovoChamadoPage calling Init");
            await ViewModel.Init();
            App.Log("NovoChamadoPage Init complete");
        }
        
        App.Log("NovoChamadoPage OnAppearing end");
    }

    private void OnCategoriaChanged(object sender, EventArgs e)
    {
        if (sender is Picker picker && picker.SelectedItem is CategoriaDto categoria)
        {
            ViewModel.CategoriaSelecionada = categoria;
        }
    }

    private void OnPrioridadeChanged(object sender, EventArgs e)
    {
        if (sender is Picker picker && picker.SelectedItem is PrioridadeDto prioridade)
        {
            ViewModel.PrioridadeSelecionada = prioridade;
        }
    }
}

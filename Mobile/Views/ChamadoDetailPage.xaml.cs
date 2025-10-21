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
                    App.Log($"ChamadoDetailPage calling Load({id})");
                    _ = _vm.Load(id);
                }
            }
            catch (Exception ex)
            {
                App.Log($"ChamadoDetailPage ChamadoId setter FATAL: {ex}");
                throw;
            }
        }
    }

    protected override void OnDisappearing()
    {
        base.OnDisappearing();
        App.Log("ChamadoDetailPage OnDisappearing - clearing data");
        // Limpa os dados ao sair da página para evitar cache
        _vm.ClearData();
    }
}

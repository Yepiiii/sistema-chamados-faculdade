using Microsoft.Maui.Controls;
using SistemaChamados.Mobile.Helpers;
using SistemaChamados.Mobile.ViewModels;

namespace SistemaChamados.Mobile.Views.Auth;

public partial class CadastroPage : ContentPage
{
    public CadastroPage(CadastroViewModel? vm = null)
    {
        App.Log("CadastroPage constructor start");
        InitializeComponent();
        App.Log("CadastroPage InitializeComponent done");
        BindingContext = vm ?? ServiceHelper.GetService<CadastroViewModel>();
        App.Log("CadastroPage BindingContext set");
        NavigationPage.SetHasNavigationBar(this, false);
        App.Log("CadastroPage constructor complete");
    }
    
    protected override void OnAppearing()
    {
        base.OnAppearing();
        App.Log("CadastroPage OnAppearing");
    }

    private async void OnLoginTapped(object? sender, TappedEventArgs e)
    {
        await Navigation.PopAsync();
    }
}

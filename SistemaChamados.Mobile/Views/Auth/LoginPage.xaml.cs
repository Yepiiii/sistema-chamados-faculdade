using Microsoft.Maui.Controls;
using SistemaChamados.Mobile.Helpers;
using SistemaChamados.Mobile.ViewModels;

namespace SistemaChamados.Mobile.Views.Auth;

public partial class LoginPage : ContentPage
{
    public LoginPage(LoginViewModel? vm = null)
    {
        App.Log("LoginPage constructor start");
        InitializeComponent();
        App.Log("LoginPage InitializeComponent done");
        BindingContext = vm ?? ServiceHelper.GetService<LoginViewModel>();
        App.Log("LoginPage BindingContext set");
        NavigationPage.SetHasNavigationBar(this, false);
        App.Log("LoginPage constructor complete");
    }
    
    protected override void OnAppearing()
    {
        base.OnAppearing();
        App.Log("LoginPage OnAppearing");
    }

    private async void OnForgotPasswordTapped(object? sender, TappedEventArgs e)
    {
        var page = ServiceHelper.GetService<EsqueciSenhaPage>();
        await Navigation.PushAsync(page);
    }
}

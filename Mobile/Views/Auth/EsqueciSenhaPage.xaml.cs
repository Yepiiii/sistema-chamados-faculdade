using Microsoft.Maui.Controls;
using SistemaChamados.Mobile.Helpers;
using SistemaChamados.Mobile.ViewModels;

namespace SistemaChamados.Mobile.Views.Auth;

public partial class EsqueciSenhaPage : ContentPage
{
    public EsqueciSenhaPage(EsqueciSenhaViewModel? vm = null)
    {
        InitializeComponent();
        BindingContext = vm ?? ServiceHelper.GetService<EsqueciSenhaViewModel>();
        NavigationPage.SetHasNavigationBar(this, false);
    }

    private async void OnNavigateToReset(object? sender, TappedEventArgs e)
    {
        var resetPage = ServiceHelper.GetService<ResetarSenhaPage>();
        if (Application.Current?.MainPage is NavigationPage navigationPage)
        {
            await navigationPage.Navigation.PushAsync(resetPage);
        }
    }
}

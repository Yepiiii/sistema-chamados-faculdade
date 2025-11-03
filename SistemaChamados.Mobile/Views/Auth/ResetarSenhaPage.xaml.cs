using Microsoft.Maui.Controls;
using SistemaChamados.Mobile.Helpers;
using SistemaChamados.Mobile.ViewModels;

namespace SistemaChamados.Mobile.Views.Auth;

public partial class ResetarSenhaPage : ContentPage
{
    public ResetarSenhaPage(ResetarSenhaViewModel? vm = null)
    {
        InitializeComponent();
        BindingContext = vm ?? ServiceHelper.GetService<ResetarSenhaViewModel>();
        NavigationPage.SetHasNavigationBar(this, false);
    }
}

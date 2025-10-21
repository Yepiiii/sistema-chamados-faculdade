using Microsoft.Maui.Controls;
using SistemaChamados.Mobile.Helpers;
using SistemaChamados.Mobile.ViewModels;

namespace SistemaChamados.Mobile.Views;

public partial class MainPage : ContentPage
{
    public MainPage(MainViewModel? vm = null)
    {
        InitializeComponent();
        BindingContext = vm ?? ServiceHelper.GetService<MainViewModel>();
    }
}

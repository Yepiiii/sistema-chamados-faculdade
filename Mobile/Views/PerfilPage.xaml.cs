using SistemaChamados.Mobile.Helpers;
using SistemaChamados.Mobile.ViewModels;

namespace SistemaChamados.Mobile.Views;

public partial class PerfilPage : ContentPage
{
    private readonly PerfilViewModel _viewModel;

    public PerfilPage(PerfilViewModel? viewModel = null)
    {
        InitializeComponent();
        _viewModel = viewModel ?? ServiceHelper.GetService<PerfilViewModel>();
        BindingContext = _viewModel;
    }

    protected override async void OnAppearing()
    {
        base.OnAppearing();
        await _viewModel.LoadDataCommand.ExecuteAsync(null);
    }
}

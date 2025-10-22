using System;
using System.Threading.Tasks;
using System.Windows.Input;
using Microsoft.Maui.Controls;
using SistemaChamados.Mobile.Models.DTOs;
using SistemaChamados.Mobile.Services.Auth;
using SistemaChamados.Mobile.Services.Chamados;

namespace SistemaChamados.Mobile.ViewModels;

public class ChamadoDetailViewModel : BaseViewModel
{
    private readonly IChamadoService _chamadoService;
    private readonly IAuthService _authService;
    private ChamadoDto? _chamado;

    public ChamadoDetailViewModel(IChamadoService chamadoService, IAuthService authService)
    {
        _chamadoService = chamadoService;
        _authService = authService;
        CloseChamadoCommand = new Command(async () => await CloseChamadoAsync(), () => !IsBusy && ShowCloseButton);
    }

    public int Id { get; private set; }

    public ChamadoDto? Chamado
    {
        get => _chamado;
        set
        {
            if (_chamado == value) return;
            _chamado = value;
            OnPropertyChanged();
            OnPropertyChanged(nameof(ShowCloseButton));
        }
    }

    public bool ShowCloseButton => Chamado != null && Chamado.Status?.Id != 3;

    public ICommand CloseChamadoCommand { get; }

    public async Task LoadChamadoAsync(int id)
    {
        Id = id;

        if (IsBusy) return;

        IsBusy = true;
        try
        {
            Chamado = await _chamadoService.GetById(id);
        }
        catch (Exception ex)
        {
            await Application.Current.MainPage.DisplayAlert("Erro", $"Erro ao carregar chamado: {ex.Message}", "OK");
        }
        finally
        {
            IsBusy = false;
        }
    }

    private async Task CloseChamadoAsync()
    {
        if (Chamado == null) return;

        bool confirm = await Application.Current.MainPage.DisplayAlert(
            "Confirmar",
            "Deseja realmente fechar este chamado?",
            "Sim",
            "Não");

        if (!confirm) return;

        IsBusy = true;
        try
        {
            await _chamadoService.Close(Chamado.Id);
            await Application.Current.MainPage.DisplayAlert("Sucesso", "Chamado fechado com sucesso!", "OK");
            await Shell.Current.GoToAsync("..");
        }
        catch (Exception ex)
        {
            await Application.Current.MainPage.DisplayAlert("Erro", $"Erro ao fechar chamado: {ex.Message}", "OK");
        }
        finally
        {
            IsBusy = false;
        }
    }
}

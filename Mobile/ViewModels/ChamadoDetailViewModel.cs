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
            OnPropertyChanged(nameof(HasFechamento));
            OnPropertyChanged(nameof(IsChamadoEncerrado));
        }
    }

    // Indica se o chamado está encerrado (Status = "Fechado" ou DataFechamento preenchida)
    public bool IsChamadoEncerrado => Chamado?.DataFechamento != null || Chamado?.Status?.Id == 3;

    // Indica se há data de fechamento para exibir
    public bool HasFechamento => Chamado?.DataFechamento != null;

    // Mostra botão apenas se NÃO estiver encerrado
    public bool ShowCloseButton => Chamado != null && !IsChamadoEncerrado;

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
            System.Diagnostics.Debug.WriteLine($"ChamadoDetailViewModel.LoadChamadoAsync ERROR: {ex.Message}");
            if (Application.Current?.MainPage != null)
            {
                await Application.Current.MainPage.DisplayAlert("Erro", $"Erro ao carregar chamado: {ex.Message}", "OK");
            }
        }
        finally
        {
            IsBusy = false;
        }
    }

    private async Task CloseChamadoAsync()
    {
        if (Chamado == null) return;

        if (Application.Current?.MainPage == null) return;

        bool confirm = await Application.Current.MainPage.DisplayAlert(
            "Confirmar Encerramento",
            "Deseja realmente encerrar este chamado? Esta ação não poderá ser desfeita.",
            "Sim, Encerrar",
            "Cancelar");

        if (!confirm) return;

        IsBusy = true;
        try
        {
            await _chamadoService.Close(Chamado.Id);
            
            // Recarrega os detalhes do chamado para mostrar status atualizado
            await LoadChamadoAsync(Chamado.Id);
            
            await Application.Current.MainPage.DisplayAlert(
                "Sucesso", 
                "Chamado encerrado com sucesso!", 
                "OK");
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"ChamadoDetailViewModel.CloseChamadoAsync ERROR: {ex.Message}");
            if (Application.Current?.MainPage != null)
            {
                await Application.Current.MainPage.DisplayAlert(
                    "Erro", 
                    $"Erro ao encerrar chamado: {ex.Message}", 
                    "OK");
            }
        }
        finally
        {
            IsBusy = false;
        }
    }
}

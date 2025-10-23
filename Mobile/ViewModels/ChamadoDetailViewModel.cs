using System;
using System.Threading;
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
    private CancellationTokenSource? _autoRefreshCts;
    private bool _isRefreshing;

    public ChamadoDetailViewModel(IChamadoService chamadoService, IAuthService authService)
    {
        _chamadoService = chamadoService;
        _authService = authService;
        
        // Comandos
        CloseChamadoCommand = new Command(async () => await CloseChamadoAsync());
        RefreshCommand = new Command(async () => await RefreshAsync());
    }

    public int Id { get; private set; }

    public bool IsRefreshing
    {
        get => _isRefreshing;
        set
        {
            _isRefreshing = value;
            OnPropertyChanged();
        }
    }

    public ChamadoDto? Chamado
    {
        get => _chamado;
        set
        {
            if (_chamado == value) return;
            _chamado = value;
            
            System.Diagnostics.Debug.WriteLine($"ChamadoDetailViewModel.Chamado SET - ID: {value?.Id}, Status: {value?.Status?.Nome}, DataFechamento: {value?.DataFechamento}");
            
            OnPropertyChanged();
            OnPropertyChanged(nameof(ShowCloseButton));
            OnPropertyChanged(nameof(HasFechamento));
            OnPropertyChanged(nameof(IsChamadoEncerrado));
            
            System.Diagnostics.Debug.WriteLine($"  → IsChamadoEncerrado: {IsChamadoEncerrado}");
            System.Diagnostics.Debug.WriteLine($"  → HasFechamento: {HasFechamento}");
            System.Diagnostics.Debug.WriteLine($"  → ShowCloseButton: {ShowCloseButton}");
        }
    }

    // Indica se o chamado está encerrado (Status = "Fechado" ou DataFechamento preenchida)
    public bool IsChamadoEncerrado => Chamado?.DataFechamento != null || Chamado?.Status?.Id == 3;

    // Indica se há data de fechamento para exibir
    public bool HasFechamento => Chamado?.DataFechamento != null;

    // Mostra botão apenas se NÃO estiver encerrado
    public bool ShowCloseButton => Chamado != null && !IsChamadoEncerrado;

    public ICommand CloseChamadoCommand { get; }
    public ICommand RefreshCommand { get; }

    // Timer de auto-refresh (10 segundos)
    private const int AutoRefreshIntervalSeconds = 10;

    public async Task LoadChamadoAsync(int id)
    {
        Id = id;

        if (IsBusy) return;

        IsBusy = true;
        try
        {
            System.Diagnostics.Debug.WriteLine($"ChamadoDetailViewModel.LoadChamadoAsync - Loading ID: {id}");
            var chamadoAtualizado = await _chamadoService.GetById(id);
            
            System.Diagnostics.Debug.WriteLine($"ChamadoDetailViewModel.LoadChamadoAsync - API returned:");
            System.Diagnostics.Debug.WriteLine($"  → Status: {chamadoAtualizado?.Status?.Nome} (ID: {chamadoAtualizado?.Status?.Id})");
            System.Diagnostics.Debug.WriteLine($"  → DataFechamento: {chamadoAtualizado?.DataFechamento}");
            
            Chamado = chamadoAtualizado;
            
            System.Diagnostics.Debug.WriteLine($"ChamadoDetailViewModel.LoadChamadoAsync - Chamado property updated");
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

    private async Task RefreshAsync()
    {
        if (Id == 0) return;

        IsRefreshing = true;
        try
        {
            System.Diagnostics.Debug.WriteLine($"ChamadoDetailViewModel.RefreshAsync - Refreshing ID: {Id}");
            var chamadoAtualizado = await _chamadoService.GetById(Id);
            Chamado = chamadoAtualizado;
            System.Diagnostics.Debug.WriteLine("ChamadoDetailViewModel.RefreshAsync - Refresh completed");
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"ChamadoDetailViewModel.RefreshAsync ERROR: {ex.Message}");
        }
        finally
        {
            IsRefreshing = false;
        }
    }

    public void StartAutoRefresh()
    {
        // Cancela qualquer timer anterior
        StopAutoRefresh();

        _autoRefreshCts = new CancellationTokenSource();
        var token = _autoRefreshCts.Token;

        System.Diagnostics.Debug.WriteLine("ChamadoDetailViewModel.StartAutoRefresh - Timer iniciado");

        // Inicia o loop de auto-refresh
        Task.Run(async () =>
        {
            while (!token.IsCancellationRequested)
            {
                try
                {
                    await Task.Delay(TimeSpan.FromSeconds(AutoRefreshIntervalSeconds), token);
                    
                    if (!token.IsCancellationRequested && Id > 0 && !IsRefreshing)
                    {
                        System.Diagnostics.Debug.WriteLine($"ChamadoDetailViewModel - Auto-refresh triggered (every {AutoRefreshIntervalSeconds}s)");
                        await RefreshAsync();
                    }
                }
                catch (TaskCanceledException)
                {
                    // Timer foi cancelado, é esperado
                    System.Diagnostics.Debug.WriteLine("ChamadoDetailViewModel - Auto-refresh cancelled");
                    break;
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"ChamadoDetailViewModel - Auto-refresh error: {ex.Message}");
                }
            }
        }, token);
    }

    public void StopAutoRefresh()
    {
        if (_autoRefreshCts != null)
        {
            System.Diagnostics.Debug.WriteLine("ChamadoDetailViewModel.StopAutoRefresh - Stopping timer");
            _autoRefreshCts.Cancel();
            _autoRefreshCts.Dispose();
            _autoRefreshCts = null;
        }
    }

    private async Task CloseChamadoAsync()
    {
        // Proteção contra execução dupla
        if (IsBusy)
        {
            System.Diagnostics.Debug.WriteLine("ChamadoDetailViewModel.CloseChamadoAsync - Already busy, skipping");
            return;
        }

        if (Chamado == null)
        {
            System.Diagnostics.Debug.WriteLine("ChamadoDetailViewModel.CloseChamadoAsync - No chamado loaded");
            return;
        }

        if (IsChamadoEncerrado)
        {
            System.Diagnostics.Debug.WriteLine("ChamadoDetailViewModel.CloseChamadoAsync - Already closed");
            return;
        }

        if (Application.Current?.MainPage == null) return;

        System.Diagnostics.Debug.WriteLine($"ChamadoDetailViewModel.CloseChamadoAsync - Starting for Chamado ID: {Chamado.Id}");

        bool confirm = await Application.Current.MainPage.DisplayAlert(
            "Confirmar Encerramento",
            "Deseja realmente encerrar este chamado? Esta ação não poderá ser desfeita.",
            "Sim, Encerrar",
            "Cancelar");

        if (!confirm)
        {
            System.Diagnostics.Debug.WriteLine("ChamadoDetailViewModel.CloseChamadoAsync - User cancelled");
            return;
        }

        IsBusy = true;
        try
        {
            System.Diagnostics.Debug.WriteLine($"ChamadoDetailViewModel.CloseChamadoAsync - Calling API to close {Chamado.Id}");
            await _chamadoService.Close(Chamado.Id);
            System.Diagnostics.Debug.WriteLine("ChamadoDetailViewModel.CloseChamadoAsync - API call successful");
            
            // Aguarda um pouco para garantir que a API processou (evita cache)
            System.Diagnostics.Debug.WriteLine("ChamadoDetailViewModel.CloseChamadoAsync - Waiting 500ms before reload");
            await Task.Delay(500);
            
            // Recarrega os detalhes do chamado para mostrar status atualizado
            System.Diagnostics.Debug.WriteLine("ChamadoDetailViewModel.CloseChamadoAsync - Reloading details with visual feedback");
            IsRefreshing = true; // Mostra o indicador de refresh
            await LoadChamadoAsync(Id); // Recarrega completamente
            System.Diagnostics.Debug.WriteLine("ChamadoDetailViewModel.CloseChamadoAsync - Details reloaded");
            
            await Application.Current.MainPage.DisplayAlert(
                "✅ Chamado Encerrado", 
                "O chamado foi encerrado com sucesso! A página foi atualizada.", 
                "OK");
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"ChamadoDetailViewModel.CloseChamadoAsync ERROR: {ex.Message}");
            System.Diagnostics.Debug.WriteLine($"ChamadoDetailViewModel.CloseChamadoAsync STACK: {ex.StackTrace}");
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
            System.Diagnostics.Debug.WriteLine("ChamadoDetailViewModel.CloseChamadoAsync - Finished");
        }
    }
}

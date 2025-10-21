using System;
using System.Threading.Tasks;
using System.Windows.Input;
using Microsoft.Maui.ApplicationModel;
using Microsoft.Maui.Controls;
using SistemaChamados.Mobile.Models.DTOs;

namespace SistemaChamados.Mobile.ViewModels;

public class ChamadoConfirmacaoViewModel : BaseViewModel
{
    private ChamadoDto? _chamado;

    public ChamadoDto? Chamado
    {
        get => _chamado;
        private set
        {
            _chamado = value;
            OnPropertyChanged();
            OnPropertyChanged(nameof(ProtocoloDisplay));
            OnPropertyChanged(nameof(TituloDisplay));
            OnPropertyChanged(nameof(CategoriaDisplay));
            OnPropertyChanged(nameof(PrioridadeDisplay));
            OnPropertyChanged(nameof(StatusDisplay));
            OnPropertyChanged(nameof(TemChamado));
            if (VerDetalhesCommand is Command verCommand)
            {
                verCommand.ChangeCanExecute();
            }
        }
    }

    public bool TemChamado => Chamado != null;

    public string ProtocoloDisplay => Chamado?.Id.ToString() ?? "--";

    public string TituloDisplay => string.IsNullOrWhiteSpace(Chamado?.Titulo)
        ? "Título sugerido automaticamente"
        : Chamado.Titulo;

    public string CategoriaDisplay => Chamado?.Categoria?.Nome ?? "Categoria pendente";

    public string PrioridadeDisplay => Chamado?.Prioridade?.Nome ?? "Prioridade pendente";

    public string StatusDisplay => Chamado?.Status?.Nome ?? "Status pendente";

    public ICommand VerDetalhesCommand { get; }

    public ChamadoConfirmacaoViewModel()
    {
        VerDetalhesCommand = new Command(async () => await IrParaDetalhesAsync(), () => TemChamado);
        PropertyChanged += (_, args) =>
        {
            if (args.PropertyName == nameof(TemChamado) && VerDetalhesCommand is Command command)
            {
                command.ChangeCanExecute();
            }
        };
    }

    public void Initialize(ChamadoDto chamado)
    {
        Chamado = chamado;
    }

    private async Task IrParaDetalhesAsync()
    {
        try
        {
            App.Log("ChamadoConfirmacaoViewModel.IrParaDetalhes start");
            
            if (Chamado == null)
            {
                App.Log("ChamadoConfirmacaoViewModel.IrParaDetalhes: Chamado is null");
                return;
            }

            if (Shell.Current is null)
            {
                App.Log("ChamadoConfirmacaoViewModel.IrParaDetalhes: Shell.Current is null");
                await MostrarAlertaAsync("Navegação", "Não foi possível abrir os detalhes.");
                return;
            }

            var route = $"///chamados/detail?Id={Chamado.Id}";
            App.Log($"ChamadoConfirmacaoViewModel.IrParaDetalhes: navigating to {route}");
            
            await Shell.Current.GoToAsync(route);
            
            App.Log("ChamadoConfirmacaoViewModel.IrParaDetalhes: navigation complete");
        }
        catch (Exception ex)
        {
            App.Log($"ChamadoConfirmacaoViewModel.IrParaDetalhes FATAL: {ex.GetType().Name} - {ex.Message}");
            App.Log($"ChamadoConfirmacaoViewModel.IrParaDetalhes STACK: {ex.StackTrace}");
            
            await MainThread.InvokeOnMainThreadAsync(async () =>
            {
                await MostrarAlertaAsync("Erro", $"Não foi possível abrir os detalhes: {ex.Message}");
            });
        }
    }

    private static Task MostrarAlertaAsync(string title, string message)
    {
        if (Application.Current?.MainPage is Page page)
        {
            return MainThread.InvokeOnMainThreadAsync(() => page.DisplayAlert(title, message, "OK"));
        }

        return Task.CompletedTask;
    }
}

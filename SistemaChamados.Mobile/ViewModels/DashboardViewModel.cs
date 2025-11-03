using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using SistemaChamados.Mobile.Models.DTOs;
using SistemaChamados.Mobile.Services.Chamados;
using System.Collections.ObjectModel;
using SistemaChamados.Mobile.Services.Api;
using Microsoft.Maui.Controls;

namespace SistemaChamados.Mobile.ViewModels;

public partial class DashboardViewModel : ObservableObject
{
    private readonly IChamadoService _chamadoService;

    [ObservableProperty]
    private string saudacao = "Bem-vindo!";

    [ObservableProperty]
    private string nomeUsuario = "";

    [ObservableProperty]
    private int totalAbertos;

    [ObservableProperty]
    private int totalEmAndamento;

    [ObservableProperty]
    private int totalEncerrados;

    [ObservableProperty]
    private int totalViolados;

    [ObservableProperty]
    private string tempoMedioAtendimento = "N/A";

    [ObservableProperty]
    private ObservableCollection<ChamadoDto> chamadosRecentes = new();

    [ObservableProperty]
    private string errorMessage = string.Empty;

    [ObservableProperty]
    private bool isBusy;

    [ObservableProperty]
    private string title = "";

    public DashboardViewModel(IChamadoService chamadoService)
    {
        _chamadoService = chamadoService;
        Title = "Dashboard";
        
        // Define saudação baseada no horário
        var hora = DateTime.Now.Hour;
        Saudacao = hora < 12 ? "☀️ Bom dia!" : hora < 18 ? "🌤️ Boa tarde!" : "🌙 Boa noite!";
    }

    [RelayCommand]
    private async Task LoadData()
    {
        if (IsBusy)
            return;

        try
        {
            IsBusy = true;
            ErrorMessage = string.Empty;

            // Carrega nome do usuário
            NomeUsuario = Helpers.Settings.NomeUsuario ?? "Usuário";

            // Carrega todos os chamados
            var chamados = await _chamadoService.GetMeusChamados();

            if (chamados != null)
            {
                var listaUsuario = chamados.ToList();

                static string NormalizeStatus(ChamadoDto chamado) => string.IsNullOrWhiteSpace(chamado.Status?.Nome)
                    ? string.Empty
                    : chamado.Status.Nome.Trim().ToLowerInvariant();

                // Calcula estatísticas
                TotalAbertos = listaUsuario.Count(c => NormalizeStatus(c) == "aberto");
                TotalEmAndamento = listaUsuario.Count(c => NormalizeStatus(c) == "em andamento");
                TotalEncerrados = listaUsuario.Count(c => NormalizeStatus(c) == "fechado");
                TotalViolados = listaUsuario.Count(c => NormalizeStatus(c) == "violado");

                // Calcula tempo médio (chamados encerrados)
                var encerrados = listaUsuario
                    .Where(c => NormalizeStatus(c) == "fechado" && c.DataFechamento.HasValue)
                    .ToList();
                if (encerrados.Any())
                {
                    var tempoMedio = encerrados.Average(c => (c.DataFechamento!.Value - c.DataAbertura).TotalHours);
                    TempoMedioAtendimento = tempoMedio < 1 
                        ? $"{(int)(tempoMedio * 60)}m" 
                        : $"{(int)tempoMedio}h";
                }

                // Carrega 5 chamados mais recentes
                ChamadosRecentes = new ObservableCollection<ChamadoDto>(
                    listaUsuario.OrderByDescending(c => c.DataAbertura).Take(5)
                );
            }
            else
            {
                ErrorMessage = "Erro ao carregar dados";
            }
        }
        catch (ApiException ex)
        {
            ErrorMessage = ex.Message;
            if (Application.Current?.MainPage != null)
            {
                await Application.Current.MainPage.DisplayAlert("Erro", ErrorMessage, "OK");
            }
        }
        catch (Exception ex)
        {
            ErrorMessage = $"Erro: {ex.Message}";
            if (Application.Current?.MainPage != null)
            {
                await Application.Current.MainPage.DisplayAlert("Erro", ErrorMessage, "OK");
            }
        }
        finally
        {
            IsBusy = false;
        }
    }

    [RelayCommand]
    private async Task VerTodosChamados()
    {
        await Shell.Current.GoToAsync("//chamados");
    }

    [RelayCommand]
    private async Task AbrirChamado(ChamadoDto chamado)
    {
        if (chamado == null)
        {
            return;
        }

        try
        {
            await Shell.Current.GoToAsync($"///chamados/detail?id={chamado.Id}");
        }
        catch (ApiException ex)
        {
            ErrorMessage = ex.Message;
            if (Application.Current?.MainPage != null)
            {
                await Application.Current.MainPage.DisplayAlert("Erro", ErrorMessage, "OK");
            }
        }
        catch (Exception ex)
        {
            ErrorMessage = $"Erro ao abrir chamado: {ex.Message}";
            if (Application.Current?.MainPage != null)
            {
                await Application.Current.MainPage.DisplayAlert("Erro", ErrorMessage, "OK");
            }
        }
    }
}

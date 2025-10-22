using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Input;
using Microsoft.Maui.Controls;
using SistemaChamados.Mobile.Models.DTOs;
using SistemaChamados.Mobile.Services.Categorias;
using SistemaChamados.Mobile.Services.Chamados;
using SistemaChamados.Mobile.Services.Prioridades;
using SistemaChamados.Mobile.Services.Status;

namespace SistemaChamados.Mobile.ViewModels;

public class ChamadosListViewModel : BaseViewModel
{
    private readonly IChamadoService _chamadoService;

    private readonly List<ChamadoDto> _allChamados = new();
    private string _searchTerm = string.Empty;

    public ObservableCollection<ChamadoDto> Chamados { get; } = new();

    public ICommand RefreshCommand { get; }
    public ICommand ItemTappedCommand { get; }

    public string SearchTerm
    {
        get => _searchTerm;
        set
        {
            if (_searchTerm == value) return;
            _searchTerm = value;
            OnPropertyChanged();
            ApplyFilters();
        }
    }

    public ChamadosListViewModel(IChamadoService chamadoService)
    {
        _chamadoService = chamadoService;
        RefreshCommand = new Command(async () => await Load());
        ItemTappedCommand = new Command<ChamadoDto>(async c => await OpenDetail(c));
    }

    public async Task Load()
    {
        if (IsBusy) return;

        IsBusy = true;
        try
        {
            var chamados = await _chamadoService.GetMeusChamados();
            _allChamados.Clear();
            if (chamados != null)
            {
                _allChamados.AddRange(chamados);
            }

            ApplyFilters();
        }
        catch (Exception ex)
        {
            await Application.Current.MainPage.DisplayAlert("Erro", $"Erro ao carregar chamados: {ex.Message}", "OK");
        }
        finally
        {
            IsBusy = false;
        }
    }

    private void ApplyFilters()
    {
        var filtered = _allChamados.AsEnumerable();

        if (!string.IsNullOrWhiteSpace(_searchTerm))
        {
            var term = _searchTerm.ToLowerInvariant();
            filtered = filtered.Where(c =>
                (c.Titulo?.ToLowerInvariant().Contains(term) ?? false) ||
                (c.Descricao?.ToLowerInvariant().Contains(term) ?? false));
        }

        Chamados.Clear();
        foreach (var chamado in filtered.OrderByDescending(c => c.DataAbertura))
        {
            Chamados.Add(chamado);
        }

        OnPropertyChanged(nameof(Chamados));
    }

    private async Task OpenDetail(ChamadoDto chamado)
    {
        if (chamado == null) return;
        await Shell.Current.GoToAsync($"//chamados/detail?id={chamado.Id}");
    }
}

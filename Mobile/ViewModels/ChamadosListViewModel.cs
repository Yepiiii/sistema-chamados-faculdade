using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Input;
using Microsoft.Maui.Controls;
using SistemaChamados.Mobile.Models.DTOs;
using SistemaChamados.Mobile.Services.Categorias;
using SistemaChamados.Mobile.Services.Chamados;
using SistemaChamados.Mobile.Services.Prioridades;
using SistemaChamados.Mobile.Services.Status;
using SistemaChamados.Mobile.Services.Polling;
using SistemaChamados.Mobile.Services.Notifications;

namespace SistemaChamados.Mobile.ViewModels;

public class ChamadosListViewModel : BaseViewModel
{
    private readonly IChamadoService _chamadoService;
    private readonly ICategoriaService _categoriaService;
    private readonly IPrioridadeService _prioridadeService;
    private readonly IStatusService _statusService;
    private readonly PollingService _pollingService;
    private readonly INotificationService _notificationService;

    private readonly List<ChamadoDto> _allChamados = new();
    private bool _filtersLoaded;
    private bool _suppressFilter;
    private string _searchTerm = string.Empty;
    private CategoriaDto? _selectedCategoria;
    private PrioridadeDto? _selectedPrioridade;
    private StatusDto? _selectedStatus;
    private bool _showAdvancedFilters = false;
    private int _activeFiltersCount = 0;

    public ObservableCollection<ChamadoDto> Chamados { get; } = new();
    public ObservableCollection<CategoriaDto> Categorias { get; } = new();
    public ObservableCollection<PrioridadeDto> Prioridades { get; } = new();
    public ObservableCollection<StatusDto> Statuses { get; } = new();

    public ICommand RefreshCommand { get; }
    public ICommand ItemTappedCommand { get; }
    public ICommand ClearFiltersCommand { get; }
    public ICommand ToggleAdvancedFiltersCommand { get; }
    public ICommand SelectCategoriaCommand { get; }
    public ICommand SelectStatusCommand { get; }
    public ICommand SelectPrioridadeCommand { get; }
    public ICommand TestarNotificacaoCommand { get; }

    public string SearchTerm
    {
        get => _searchTerm;
        set
        {
            var sanitized = value ?? string.Empty;
            if (_searchTerm.Equals(sanitized, StringComparison.Ordinal)) return;
            _searchTerm = sanitized;
            OnPropertyChanged();
            if (!_suppressFilter)
            {
                ApplyFilters();
            }
        }
    }

    public CategoriaDto? SelectedCategoria
    {
        get => _selectedCategoria;
        set
        {
            if (_selectedCategoria == value) return;
            _selectedCategoria = value;
            OnPropertyChanged();
            if (!_suppressFilter)
            {
                ApplyFilters();
            }
        }
    }

    public PrioridadeDto? SelectedPrioridade
    {
        get => _selectedPrioridade;
        set
        {
            if (_selectedPrioridade == value) return;
            _selectedPrioridade = value;
            OnPropertyChanged();
            if (!_suppressFilter)
            {
                ApplyFilters();
            }
        }
    }

    public StatusDto? SelectedStatus
    {
        get => _selectedStatus;
        set
        {
            if (_selectedStatus == value) return;
            _selectedStatus = value;
            OnPropertyChanged();
            if (!_suppressFilter)
            {
                ApplyFilters();
            }
        }
    }

    public bool ShowAdvancedFilters
    {
        get => _showAdvancedFilters;
        set
        {
            if (_showAdvancedFilters == value) return;
            _showAdvancedFilters = value;
            OnPropertyChanged();
        }
    }

    public int ActiveFiltersCount
    {
        get => _activeFiltersCount;
        set
        {
            if (_activeFiltersCount == value) return;
            _activeFiltersCount = value;
            OnPropertyChanged();
        }
    }

    public ChamadosListViewModel(
        IChamadoService chamadoService,
        ICategoriaService categoriaService,
        IPrioridadeService prioridadeService,
        IStatusService statusService,
        PollingService pollingService,
        INotificationService notificationService)
    {
        _chamadoService = chamadoService;
        _categoriaService = categoriaService;
        _prioridadeService = prioridadeService;
        _statusService = statusService;
        _pollingService = pollingService;
        _notificationService = notificationService;

        RefreshCommand = new Command(async () => await Load());
        ItemTappedCommand = new Command<ChamadoDto>(async c => await OpenDetail(c));
        ClearFiltersCommand = new Command(ClearFilters);
        ToggleAdvancedFiltersCommand = new Command(ToggleAdvancedFilters);
        SelectCategoriaCommand = new Command<CategoriaDto>(SelectCategoria);
        SelectStatusCommand = new Command<StatusDto>(SelectStatus);
        SelectPrioridadeCommand = new Command<PrioridadeDto>(SelectPrioridade);
        TestarNotificacaoCommand = new Command(TestarNotificacao);

        // Subscrever ao evento de novas atualizações
        _pollingService.NovasAtualizacoesDetectadas += OnNovasAtualizacoesDetectadas;
        
        Debug.WriteLine("[ChamadosListViewModel] Polling configurado e evento subscrito.");
    }

    private void TestarNotificacao()
    {
        try
        {
            Debug.WriteLine("[ChamadosListViewModel] 🔔 TESTE: Simulando atualizações mock...");
            PollingService.SimularAtualizacao(); // Método estático
            
            // Feedback visual
            MainThread.BeginInvokeOnMainThread(async () =>
            {
                await Application.Current.MainPage.DisplayAlert(
                    "🔔 Teste de Notificação",
                    "Atualizações simuladas! Verifique a barra de notificações do Android.",
                    "OK");
            });
        }
        catch (Exception ex)
        {
            Debug.WriteLine($"[ChamadosListViewModel] Erro ao testar notificação: {ex.Message}");
        }
    }

    private async void OnNovasAtualizacoesDetectadas(object sender, List<AtualizacaoDto> atualizacoes)
    {
        try
        {
            Debug.WriteLine($"[ChamadosListViewModel] {atualizacoes.Count} novas atualizações detectadas!");

            // Exibir notificações para cada atualização
            foreach (var atualizacao in atualizacoes)
            {
                _notificationService?.ExibirNotificacaoAtualizacao(atualizacao);
                Debug.WriteLine($"[ChamadosListViewModel] Notificação exibida: {atualizacao.MensagemNotificacao}");
            }

            // Atualizar a lista de chamados
            await MainThread.InvokeOnMainThreadAsync(async () =>
            {
                await Load();
                Debug.WriteLine("[ChamadosListViewModel] Lista de chamados atualizada após polling.");
            });
        }
        catch (Exception ex)
        {
            Debug.WriteLine($"[ChamadosListViewModel] Erro ao processar atualizações: {ex.Message}");
        }
    }

    public async Task Load()
    {
        if (IsBusy) return;
        try
        {
            IsBusy = true;
            Debug.WriteLine("[ChamadosListViewModel] Buscando chamados...");
            Console.WriteLine("[ChamadosListViewModel] Buscando chamados...");

            await EnsureFiltersLoadedAsync();

            _allChamados.Clear();

            var list = await _chamadoService.GetMeusChamados();

            if (list != null)
            {
                var count = 0;
                foreach (var c in list)
                {
                    count++;
                    Debug.WriteLine($"[ChamadosListViewModel] Chamado {count}: Id={c.Id}, Titulo='{c.Titulo}', Categoria={c.Categoria?.Nome ?? "NULL"}, Prioridade={c.Prioridade?.Nome ?? "NULL"}, Status={c.Status?.Nome ?? "NULL"}");
                    Console.WriteLine($"[ChamadosListViewModel] Chamado {count}: Id={c.Id}, Titulo='{c.Titulo}', Categoria={c.Categoria?.Nome ?? "NULL"}, Prioridade={c.Prioridade?.Nome ?? "NULL"}, Status={c.Status?.Nome ?? "NULL"}");
                    _allChamados.Add(c);
                }
                Debug.WriteLine($"[ChamadosListViewModel] Total de chamados carregados: {count}");
                Console.WriteLine($"[ChamadosListViewModel] Total de chamados carregados: {count}");
            }
            else
            {
                Debug.WriteLine("[ChamadosListViewModel] Lista de chamados retornou NULL");
                Console.WriteLine("[ChamadosListViewModel] Lista de chamados retornou NULL");
            }

            ApplyFilters();

            // Iniciar polling após o primeiro carregamento
            if (_pollingService != null)
            {
                _pollingService.IniciarPolling();
                Debug.WriteLine("[ChamadosListViewModel] Polling iniciado.");
            }
        }
        finally { IsBusy = false; }
    }

    private async Task OpenDetail(ChamadoDto c)
    {
        if (c == null) return;
        await Shell.Current.GoToAsync($"chamados/detail?Id={c.Id}");
    }

    private async Task EnsureFiltersLoadedAsync()
    {
        if (_filtersLoaded) return;

        _suppressFilter = true;

        await LoadCategoriasAsync();
        await LoadStatusesAsync();
        await LoadPrioridadesAsync();

        _filtersLoaded = true;
        _suppressFilter = false;
    }

    private async Task LoadCategoriasAsync()
    {
        Categorias.Clear();
        Categorias.Add(new CategoriaDto { Id = 0, Nome = "Todas as categorias" });

        var categorias = await _categoriaService.GetAll();
        if (categorias != null)
        {
            foreach (var categoria in categorias.OrderBy(c => c.Nome))
            {
                Categorias.Add(categoria);
            }
        }

        SelectedCategoria = Categorias.FirstOrDefault();
    }

    private async Task LoadPrioridadesAsync()
    {
        Prioridades.Clear();
        Prioridades.Add(new PrioridadeDto { Id = 0, Nome = "Todas as prioridades" });

        var prioridades = await _prioridadeService.GetAll();
        if (prioridades != null)
        {
            foreach (var prioridade in prioridades.OrderBy(p => p.Nome))
            {
                Prioridades.Add(prioridade);
            }
        }

        SelectedPrioridade = Prioridades.FirstOrDefault();
    }

    private async Task LoadStatusesAsync()
    {
        Statuses.Clear();
        Statuses.Add(new StatusDto { Id = 0, Nome = "Todos os status" });

        var statuses = await _statusService.GetAll();
        if (statuses != null)
        {
            foreach (var status in statuses.OrderBy(s => s.Nome))
            {
                Statuses.Add(status);
            }
        }

        SelectedStatus = Statuses.FirstOrDefault();
    }

    private void ApplyFilters()
    {
        if (_suppressFilter) return;

        IEnumerable<ChamadoDto> filtered = _allChamados;
        int filterCount = 0;

        if (!string.IsNullOrWhiteSpace(_searchTerm))
        {
            var term = _searchTerm.Trim();
            filtered = filtered.Where(c =>
                (!string.IsNullOrEmpty(c.Titulo) && c.Titulo.Contains(term, StringComparison.OrdinalIgnoreCase)) ||
                (!string.IsNullOrEmpty(c.Descricao) && c.Descricao.Contains(term, StringComparison.OrdinalIgnoreCase)));
            filterCount++;
        }

        if (_selectedCategoria != null && _selectedCategoria.Id > 0)
        {
            filtered = filtered.Where(c => c.Categoria?.Id == _selectedCategoria.Id);
            filterCount++;
        }

        if (_selectedStatus != null && _selectedStatus.Id > 0)
        {
            filtered = filtered.Where(c => c.Status?.Id == _selectedStatus.Id);
            filterCount++;
        }

        if (_selectedPrioridade != null && _selectedPrioridade.Id > 0)
        {
            filtered = filtered.Where(c => c.Prioridade?.Id == _selectedPrioridade.Id);
            filterCount++;
        }

        filtered = filtered.OrderByDescending(c => c.DataAbertura);

        Chamados.Clear();

        var count = 0;
        foreach (var chamado in filtered)
        {
            count++;
            Chamados.Add(chamado);
        }

        ActiveFiltersCount = filterCount;

        Debug.WriteLine($"[ChamadosListViewModel] Chamados após filtros: {count}");
        Console.WriteLine($"[ChamadosListViewModel] Chamados após filtros: {count}");
    }

    private void ClearFilters()
    {
        _suppressFilter = true;

        _searchTerm = string.Empty;
        OnPropertyChanged(nameof(SearchTerm));

        SelectedCategoria = Categorias.FirstOrDefault();
        SelectedStatus = Statuses.FirstOrDefault();
        SelectedPrioridade = Prioridades.FirstOrDefault();

        _suppressFilter = false;
        ApplyFilters();
    }

    private void ToggleAdvancedFilters()
    {
        ShowAdvancedFilters = !ShowAdvancedFilters;
    }

    private void SelectCategoria(CategoriaDto categoria)
    {
        SelectedCategoria = categoria;
    }

    private void SelectStatus(StatusDto status)
    {
        SelectedStatus = status;
    }

    private void SelectPrioridade(PrioridadeDto prioridade)
    {
        SelectedPrioridade = prioridade;
    }

    /// <summary>
    /// Para o polling quando a ViewModel não está mais em uso.
    /// Chame este método quando a página for destruída ou desativada.
    /// </summary>
    public void StopPolling()
    {
        if (_pollingService != null)
        {
            _pollingService.PararPolling();
            Debug.WriteLine("[ChamadosListViewModel] Polling parado.");
        }
    }

    /// <summary>
    /// Dessubscreve eventos e limpa recursos.
    /// </summary>
    public void Cleanup()
    {
        if (_pollingService != null)
        {
            _pollingService.NovasAtualizacoesDetectadas -= OnNovasAtualizacoesDetectadas;
            _pollingService.PararPolling();
        }
        Debug.WriteLine("[ChamadosListViewModel] Cleanup executado.");
    }
}

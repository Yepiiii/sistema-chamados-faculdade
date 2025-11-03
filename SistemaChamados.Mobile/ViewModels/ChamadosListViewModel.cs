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
using SistemaChamados.Mobile.Services.Api;
using SistemaChamados.Mobile.Services.Prioridades;
using SistemaChamados.Mobile.Services.Status;

namespace SistemaChamados.Mobile.ViewModels;

public class ChamadosListViewModel : BaseViewModel
{
    private readonly IChamadoService _chamadoService;
    private readonly ICategoriaService _categoriaService;
    private readonly IPrioridadeService _prioridadeService;
    private readonly IStatusService _statusService;

    private readonly List<ChamadoDto> _allChamados = new();
    private string _searchTerm = string.Empty;
    private bool _showAdvancedFilters = false;
    private bool _isRefreshing = false;
    private bool _isLoading = false; // Flag para evitar reentrada
    private bool _filtersLoaded;

    // Collections
    public ObservableCollection<ChamadoDto> Chamados { get; } = new();
    public ObservableCollection<CategoriaDto> Categorias { get; } = new();
    public ObservableCollection<StatusDto> Statuses { get; } = new();
    public ObservableCollection<PrioridadeDto> Prioridades { get; } = new();

    // Selected Items for Filters
    private CategoriaDto? _selectedCategoria;
    private StatusDto? _selectedStatus;
    private PrioridadeDto? _selectedPrioridade;

    public CategoriaDto? SelectedCategoria
    {
        get => _selectedCategoria;
        set
        {
            if (_selectedCategoria == value) return;
            _selectedCategoria = value;
            OnPropertyChanged();
            UpdateActiveFiltersCount();
            ApplyFilters();
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
            UpdateActiveFiltersCount();
            ApplyFilters();
            _ = FetchChamadosFromApiAsync(showErrors: false);
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
            UpdateActiveFiltersCount();
            ApplyFilters();
            _ = FetchChamadosFromApiAsync(showErrors: false);
        }
    }

    // Advanced Filters Toggle
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

    // IsRefreshing - Separado de IsBusy para evitar loop infinito
    public bool IsRefreshing
    {
        get => _isRefreshing;
        set
        {
            if (_isRefreshing == value) return;
            _isRefreshing = value;
            OnPropertyChanged();
        }
    }

    // Active Filters Count
    private int _activeFiltersCount;
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

    // Commands
    public ICommand RefreshCommand { get; }
    public ICommand ItemTappedCommand { get; }
    public ICommand ToggleAdvancedFiltersCommand { get; }
    public ICommand SelectCategoriaCommand { get; }
    public ICommand SelectStatusCommand { get; }
    public ICommand SelectPrioridadeCommand { get; }
    public ICommand ClearFiltersCommand { get; }

    public string SearchTerm
    {
        get => _searchTerm;
        set
        {
            if (_searchTerm == value) return;
            _searchTerm = value;
            OnPropertyChanged();
            HandleSearchTermChanged();
        }
    }

    public ChamadosListViewModel(
        IChamadoService chamadoService,
        ICategoriaService categoriaService,
        IPrioridadeService prioridadeService,
        IStatusService statusService)
    {
        _chamadoService = chamadoService;
        _categoriaService = categoriaService;
        _prioridadeService = prioridadeService;
        _statusService = statusService;

        RefreshCommand = new Command(async () => await RefreshAsync());
        ItemTappedCommand = new Command<ChamadoDto>(async c => await OpenDetail(c));
        ToggleAdvancedFiltersCommand = new Command(ToggleAdvancedFilters);
        SelectCategoriaCommand = new Command<CategoriaDto>(SelectCategoria);
        SelectStatusCommand = new Command<StatusDto>(SelectStatus);
        SelectPrioridadeCommand = new Command<PrioridadeDto>(SelectPrioridade);
        ClearFiltersCommand = new Command(ClearFilters);
    }

    public async Task Load()
    {
        System.Diagnostics.Debug.WriteLine($"ChamadosListViewModel.Load() - START (IsBusy={IsBusy}, _isLoading={_isLoading})");

        if (IsBusy)
        {
            System.Diagnostics.Debug.WriteLine("ChamadosListViewModel.Load() - Already busy, skipping");
            return;
        }

        if (_isLoading)
        {
            System.Diagnostics.Debug.WriteLine("ChamadosListViewModel.Load() - Already loading, skipping");
            return;
        }

        IsBusy = true;
        try
        {
            await EnsureFilterOptionsAsync();
            await FetchChamadosFromApiAsync();
        }
        catch (ApiException ex)
        {
            System.Diagnostics.Debug.WriteLine($"ChamadosListViewModel.Load() API ERROR: {ex.Message} (Status: {(int)ex.StatusCode})");
            if (Application.Current?.MainPage != null)
            {
                await Application.Current.MainPage.DisplayAlert("Erro", ex.Message, "OK");
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"ChamadosListViewModel.Load() ERROR: {ex.Message}");
            if (Application.Current?.MainPage != null)
            {
                await Application.Current.MainPage.DisplayAlert("Erro", $"Erro ao carregar chamados: {ex.Message}", "OK");
            }
        }
        finally
        {
            IsBusy = false;
        }
    }

    // Método separado para RefreshView - força reload completo
    private async Task RefreshAsync()
    {
        System.Diagnostics.Debug.WriteLine("========================================");
        System.Diagnostics.Debug.WriteLine("ChamadosListViewModel.RefreshAsync() - PULL TO REFRESH");
        System.Diagnostics.Debug.WriteLine("========================================");
        
        // Não verifica _isLoading aqui - queremos forçar o refresh
        if (IsBusy)
        {
            System.Diagnostics.Debug.WriteLine("RefreshAsync - Already busy, skipping");
            IsRefreshing = false;
            return;
        }

        try
        {
            System.Diagnostics.Debug.WriteLine("RefreshAsync - Clearing local cache");
            _allChamados.Clear();
            Chamados.Clear();

            await FetchChamadosFromApiAsync();

            System.Diagnostics.Debug.WriteLine($"RefreshAsync - Complete! {Chamados.Count} chamados loaded");
        }
        catch (ApiException ex)
        {
            System.Diagnostics.Debug.WriteLine($"RefreshAsync API ERROR: {ex.Message}");
            if (Application.Current?.MainPage != null)
            {
                await Application.Current.MainPage.DisplayAlert("Erro", ex.Message, "OK");
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"RefreshAsync ERROR: {ex.Message}");
            if (Application.Current?.MainPage != null)
            {
                await Application.Current.MainPage.DisplayAlert("Erro", "Erro ao atualizar chamados. Tente novamente.", "OK");
            }
        }
        finally
        {
            IsRefreshing = false;
            System.Diagnostics.Debug.WriteLine("RefreshAsync - IsRefreshing set to false");
        }
    }

    private async Task EnsureFilterOptionsAsync()
    {
        if (_filtersLoaded)
        {
            return;
        }

        if (!Categorias.Any())
        {
            await LoadCategoriasAsync();
        }

        if (!Statuses.Any())
        {
            await LoadStatusesAsync();
        }

        if (!Prioridades.Any())
        {
            await LoadPrioridadesAsync();
        }

        _filtersLoaded = true;
    }

    private ChamadoQueryParameters BuildQueryParameters()
    {
        var parameters = new ChamadoQueryParameters();

        if (SelectedStatus != null)
        {
            parameters.StatusId = SelectedStatus.Id;
        }

        if (SelectedPrioridade != null)
        {
            parameters.PrioridadeId = SelectedPrioridade.Id;
        }

        var termo = _searchTerm?.Trim();
        if (!string.IsNullOrWhiteSpace(termo) && termo.Length >= 3)
        {
            parameters.TermoBusca = termo;
        }

        return parameters;
    }

    private async Task FetchChamadosFromApiAsync(bool showErrors = true)
    {
        if (_isLoading)
        {
            System.Diagnostics.Debug.WriteLine("FetchChamadosFromApiAsync - Already loading, skipping");
            return;
        }

        _isLoading = true;
        try
        {
            var parameters = BuildQueryParameters();
            var chamados = await _chamadoService.GetMeusChamados(parameters);

            _allChamados.Clear();
            if (chamados != null)
            {
                _allChamados.AddRange(chamados);
                System.Diagnostics.Debug.WriteLine($"FetchChamadosFromApiAsync - Loaded {_allChamados.Count} chamados");
            }
            else
            {
                System.Diagnostics.Debug.WriteLine("FetchChamadosFromApiAsync - API returned null");
            }

            ApplyFilters();
        }
        catch (ApiException ex)
        {
            System.Diagnostics.Debug.WriteLine($"FetchChamadosFromApiAsync API ERROR: {ex.Message} (Status: {(int)ex.StatusCode})");
            if (showErrors && Application.Current?.MainPage != null)
            {
                await Application.Current.MainPage.DisplayAlert("Erro", ex.Message, "OK");
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"FetchChamadosFromApiAsync ERROR: {ex.Message}");
            if (showErrors && Application.Current?.MainPage != null)
            {
                await Application.Current.MainPage.DisplayAlert("Erro", "Erro inesperado ao carregar chamados. Tente novamente.", "OK");
            }
        }
        finally
        {
            _isLoading = false;
        }
    }

    private void HandleSearchTermChanged()
    {
        var termo = _searchTerm?.Trim() ?? string.Empty;

        if (string.IsNullOrEmpty(termo))
        {
            ApplyFilters();
            _ = FetchChamadosFromApiAsync(showErrors: false);
            return;
        }

        if (termo.Length >= 3)
        {
            ApplyFilters();
            _ = FetchChamadosFromApiAsync(showErrors: false);
        }
        else
        {
            ApplyFilters();
        }
    }

    private async Task LoadCategoriasAsync()
    {
        try
        {
            var categorias = await _categoriaService.GetAll();
            Categorias.Clear();
            if (categorias != null)
            {
                foreach (var cat in categorias)
                {
                    Categorias.Add(cat);
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Erro ao carregar categorias: {ex.Message}");
        }
    }

    private async Task LoadStatusesAsync()
    {
        try
        {
            var statuses = await _statusService.GetAll();
            Statuses.Clear();
            if (statuses != null)
            {
                foreach (var status in statuses)
                {
                    Statuses.Add(status);
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Erro ao carregar status: {ex.Message}");
        }
    }

    private async Task LoadPrioridadesAsync()
    {
        try
        {
            var prioridades = await _prioridadeService.GetAll();
            Prioridades.Clear();
            if (prioridades != null)
            {
                foreach (var pri in prioridades)
                {
                    Prioridades.Add(pri);
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Erro ao carregar prioridades: {ex.Message}");
        }
    }

    private void ToggleAdvancedFilters()
    {
        ShowAdvancedFilters = !ShowAdvancedFilters;
    }

    private void SelectCategoria(CategoriaDto categoria)
    {
        // Toggle: se já estava selecionada, desmarca
        if (SelectedCategoria?.Id == categoria?.Id)
        {
            SelectedCategoria = null;
        }
        else
        {
            SelectedCategoria = categoria;
        }
    }

    private void SelectStatus(StatusDto status)
    {
        // Toggle: se já estava selecionado, desmarca
        if (SelectedStatus?.Id == status?.Id)
        {
            SelectedStatus = null;
        }
        else
        {
            SelectedStatus = status;
        }
    }

    private void SelectPrioridade(PrioridadeDto prioridade)
    {
        // Toggle: se já estava selecionada, desmarca
        if (SelectedPrioridade?.Id == prioridade?.Id)
        {
            SelectedPrioridade = null;
        }
        else
        {
            SelectedPrioridade = prioridade;
        }
    }

    private void ClearFilters()
    {
        SelectedCategoria = null;
        SelectedStatus = null;
        SelectedPrioridade = null;
        SearchTerm = string.Empty;
    }

    private void UpdateActiveFiltersCount()
    {
        int count = 0;
        if (SelectedCategoria != null) count++;
        if (SelectedStatus != null) count++;
        if (SelectedPrioridade != null) count++;
        ActiveFiltersCount = count;
    }

    private void ApplyFilters()
    {
        System.Diagnostics.Debug.WriteLine($"ApplyFilters() - START: _allChamados.Count={_allChamados.Count}");
        
        var filtered = _allChamados.AsEnumerable();

        // Search Term Filter
        if (!string.IsNullOrWhiteSpace(_searchTerm))
        {
            var term = _searchTerm.ToLowerInvariant();
            filtered = filtered.Where(c =>
                (c.Titulo?.ToLowerInvariant().Contains(term) ?? false) ||
                (c.Descricao?.ToLowerInvariant().Contains(term) ?? false));
            System.Diagnostics.Debug.WriteLine($"ApplyFilters() - After SearchTerm: {filtered.Count()} chamados");
        }

        // Categoria Filter
        if (SelectedCategoria != null)
        {
            filtered = filtered.Where(c => c.Categoria?.Id == SelectedCategoria.Id);
            System.Diagnostics.Debug.WriteLine($"ApplyFilters() - After Categoria: {filtered.Count()} chamados");
        }

        // Status Filter
        if (SelectedStatus != null)
        {
            filtered = filtered.Where(c => c.Status?.Id == SelectedStatus.Id);
            System.Diagnostics.Debug.WriteLine($"ApplyFilters() - After Status: {filtered.Count()} chamados");
        }

        // Prioridade Filter
        if (SelectedPrioridade != null)
        {
            filtered = filtered.Where(c => c.Prioridade?.Id == SelectedPrioridade.Id);
            System.Diagnostics.Debug.WriteLine($"ApplyFilters() - After Prioridade: {filtered.Count()} chamados");
        }

        Chamados.Clear();
        foreach (var chamado in filtered.OrderByDescending(c => c.DataAbertura))
        {
            Chamados.Add(chamado);
            System.Diagnostics.Debug.WriteLine($"  - Chamado #{chamado.Id}: {chamado.Titulo} (Status: {chamado.Status?.Nome})");
        }

        OnPropertyChanged(nameof(Chamados));
        System.Diagnostics.Debug.WriteLine($"ApplyFilters() - COMPLETE: Chamados.Count={Chamados.Count}");
    }

    private async Task OpenDetail(ChamadoDto chamado)
    {
        if (chamado == null) return;
        await Shell.Current.GoToAsync($"//chamados/detail?id={chamado.Id}");
    }
}

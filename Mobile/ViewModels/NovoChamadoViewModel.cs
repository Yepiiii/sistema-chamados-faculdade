using System.Collections.ObjectModel;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Input;
using Microsoft.Maui.Controls;
using SistemaChamados.Mobile.Models.DTOs;
using SistemaChamados.Mobile.Services.Chamados;
using SistemaChamados.Mobile.Services.Categorias;
using SistemaChamados.Mobile.Services.Prioridades;

namespace SistemaChamados.Mobile.ViewModels;

public class NovoChamadoViewModel : BaseViewModel
{
    private readonly IChamadoService _chamadoService;
    private readonly ICategoriaService _categoriaService;
    private readonly IPrioridadeService _prioridadeService;

    public string Descricao { get; set; } = string.Empty;
    public string Titulo { get; set; } = string.Empty;
    public int? CategoriaId { get; set; }
    public int? PrioridadeId { get; set; }

    public ObservableCollection<CategoriaDto> Categorias { get; } = new ObservableCollection<CategoriaDto>();
    public ObservableCollection<PrioridadeDto> Prioridades { get; } = new ObservableCollection<PrioridadeDto>();

    private CategoriaDto? _categoriaSelecionada;
    public CategoriaDto? CategoriaSelecionada
    {
        get => _categoriaSelecionada;
        set
        {
            if (_categoriaSelecionada == value) return;
            _categoriaSelecionada = value;
            OnPropertyChanged();
            CategoriaId = value?.Id;
        }
    }

    private PrioridadeDto? _prioridadeSelecionada;
    public PrioridadeDto? PrioridadeSelecionada
    {
        get => _prioridadeSelecionada;
        set
        {
            if (_prioridadeSelecionada == value) return;
            _prioridadeSelecionada = value;
            OnPropertyChanged();
            PrioridadeId = value?.Id;
        }
    }

    // Propriedades para controle de IA
    private bool _usarAnaliseAutomatica = true;
    public bool UsarAnaliseAutomatica
    {
        get => _usarAnaliseAutomatica;
        set
        {
            if (_usarAnaliseAutomatica == value) return;
            _usarAnaliseAutomatica = value;
            OnPropertyChanged();
            OnPropertyChanged(nameof(ExibirClassificacaoManual));
        }
    }

    public bool PodeUsarClassificacaoManual => true; // Sempre true para Admin/Técnico
    
    public bool ExibirClassificacaoManual => !UsarAnaliseAutomatica && PodeUsarClassificacaoManual;

    public bool HasCategorias => Categorias.Any();
    public bool IsCategoriasEmpty => !HasCategorias;
    public bool HasPrioridades => Prioridades.Any();
    public bool IsPrioridadesEmpty => !HasPrioridades;

    // Propriedades para Empty State com recursos localizáveis
    public string EmptyCategoriasText => "Nenhuma categoria disponível";
    public string EmptyCategoriasIcon => "📋";
    public string EmptyPrioridadesText => "Nenhuma prioridade disponível";
    public string EmptyPrioridadesIcon => "⚠️";
    public string RetryIcon => "🔄";
    public string RetryText => "Tentar novamente";

    public string DescricaoHeader => "Preencha os campos abaixo para criar um novo chamado";

    public ICommand CriarCommand { get; }
    public ICommand RetryLoadCommand { get; }

    public NovoChamadoViewModel(
        IChamadoService chamadoService,
        ICategoriaService categoriaService,
        IPrioridadeService prioridadeService)
    {
        _chamadoService = chamadoService;
        _categoriaService = categoriaService;
        _prioridadeService = prioridadeService;

        CriarCommand = new Command(async () => await CriarChamadoAsync());
        RetryLoadCommand = new Command(async () => await LoadDataAsync());
    }

    public async Task LoadDataAsync()
    {
        if (IsBusy) return;

        IsBusy = true;
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
            OnPropertyChanged(nameof(HasCategorias));
            OnPropertyChanged(nameof(IsCategoriasEmpty));

            var prioridades = await _prioridadeService.GetAll();
            Prioridades.Clear();
            if (prioridades != null)
            {
                foreach (var pri in prioridades)
                {
                    Prioridades.Add(pri);
                }
            }
            OnPropertyChanged(nameof(HasPrioridades));
            OnPropertyChanged(nameof(IsPrioridadesEmpty));
        }
        catch (System.Exception ex)
        {
            await Application.Current?.MainPage?.DisplayAlert("Erro", $"Erro ao carregar dados: {ex.Message}", "OK");
        }
        finally
        {
            IsBusy = false;
        }
    }

    private async Task CriarChamadoAsync()
    {
        if (string.IsNullOrWhiteSpace(Descricao))
        {
            await Application.Current?.MainPage?.DisplayAlert("Atenção", "Por favor, informe a descrição do chamado.", "OK");
            return;
        }

        // Se IA desativada, validar seleção manual
        if (!UsarAnaliseAutomatica)
        {
            if (!CategoriaId.HasValue)
            {
                await Application.Current?.MainPage?.DisplayAlert("Atenção", "Por favor, selecione uma categoria.", "OK");
                return;
            }

            if (!PrioridadeId.HasValue)
            {
                await Application.Current?.MainPage?.DisplayAlert("Atenção", "Por favor, selecione uma prioridade.", "OK");
                return;
            }
        }

        IsBusy = true;
        try
        {
            var dto = new CriarChamadoRequestDto
            {
                Titulo = string.IsNullOrWhiteSpace(Titulo) ? "Chamado sem título" : Titulo,
                Descricao = Descricao,
                CategoriaId = CategoriaId ?? 1, // Valor padrão se IA ativada
                PrioridadeId = PrioridadeId ?? 1 // Valor padrão se IA ativada
            };

            var chamado = await _chamadoService.Create(dto);
            if (chamado != null)
            {
                await Application.Current?.MainPage?.DisplayAlert("Sucesso", "Chamado criado com sucesso!", "OK");
                await Shell.Current.GoToAsync("..");
            }
        }
        catch (System.Exception ex)
        {
            await Application.Current?.MainPage?.DisplayAlert("Erro", $"Erro ao criar chamado: {ex.Message}", "OK");
        }
        finally
        {
            IsBusy = false;
        }
    }
}

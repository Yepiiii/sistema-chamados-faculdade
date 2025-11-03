using System.Collections.ObjectModel;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Input;
using Microsoft.Maui.Controls;
using SistemaChamados.Mobile.Helpers;
using SistemaChamados.Mobile.Models.DTOs;
using SistemaChamados.Mobile.Services.Chamados;
using SistemaChamados.Mobile.Services.Categorias;
using SistemaChamados.Mobile.Services.Api;
using SistemaChamados.Mobile.Services.Prioridades;

namespace SistemaChamados.Mobile.ViewModels;

public class NovoChamadoViewModel : BaseViewModel
{
    private readonly IChamadoService _chamadoService;
    private readonly ICategoriaService _categoriaService;
    private readonly IPrioridadeService _prioridadeService;
    private readonly bool _podeClassificacaoManual;

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
            OnPropertyChanged(nameof(DeveExibirMensagemAnaliseAutomatica));
        }
    }

    public bool PodeUsarClassificacaoManual => _podeClassificacaoManual;

    public bool MostrarTituloOpcional => PodeUsarClassificacaoManual;

    public bool ExibirClassificacaoManual => !UsarAnaliseAutomatica && PodeUsarClassificacaoManual;

    public bool DeveExibirMensagemAnaliseAutomatica => !PodeUsarClassificacaoManual || UsarAnaliseAutomatica;

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

    public string DescricaoHeader => PodeUsarClassificacaoManual
        ? "Descreva o problema ou ajuste a classificação manualmente."
        : "Descreva o problema; a IA fará a triagem completa para você.";

    public string MensagemModoAutomatico => "A IA analisará sua descrição e definirá categoria, prioridade e técnico automaticamente.";

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

        _podeClassificacaoManual = Settings.TipoUsuario != 1;

        CriarCommand = new Command(async () => await CriarChamadoAsync());
        RetryLoadCommand = new Command(async () => await LoadDataAsync());
    }

    public async Task LoadDataAsync()
    {
        if (!_podeClassificacaoManual)
        {
            // Usuário comum não utiliza classificação manual, então não carrega listas.
            Categorias.Clear();
            Prioridades.Clear();
            OnPropertyChanged(nameof(HasCategorias));
            OnPropertyChanged(nameof(IsCategoriasEmpty));
            OnPropertyChanged(nameof(HasPrioridades));
            OnPropertyChanged(nameof(IsPrioridadesEmpty));
            return;
        }

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
        catch (ApiException ex)
        {
            if (Application.Current?.MainPage != null)
            {
                await Application.Current.MainPage.DisplayAlert("Erro", ex.Message, "OK");
            }
        }
        catch (System.Exception ex)
        {
            if (Application.Current?.MainPage != null)
            {
                await Application.Current.MainPage.DisplayAlert("Erro", $"Erro ao carregar dados: {ex.Message}", "OK");
            }
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
            if (Application.Current?.MainPage != null)
            {
                await Application.Current.MainPage.DisplayAlert("Atenção", "Por favor, informe a descrição do chamado.", "OK");
            }
            return;
        }

        var usarAnaliseAutomatica = UsarAnaliseAutomatica || !PodeUsarClassificacaoManual;

        if (!usarAnaliseAutomatica)
        {
            if (!CategoriaId.HasValue)
            {
                if (Application.Current?.MainPage != null)
                {
                    await Application.Current.MainPage.DisplayAlert("Atenção", "Por favor, selecione uma categoria.", "OK");
                }
                return;
            }

            if (!PrioridadeId.HasValue)
            {
                if (Application.Current?.MainPage != null)
                {
                    await Application.Current.MainPage.DisplayAlert("Atenção", "Por favor, selecione uma prioridade.", "OK");
                }
                return;
            }
        }

        IsBusy = true;
        try
        {
            if (usarAnaliseAutomatica)
            {
                await CriarChamadoComAnaliseAutomaticaAsync();
            }
            else
            {
                await CriarChamadoComClassificacaoManualAsync();
            }
        }
        catch (ApiException ex)
        {
            if (Application.Current?.MainPage != null)
            {
                await Application.Current.MainPage.DisplayAlert("Erro", ex.Message, "OK");
            }
        }
        catch (System.Exception ex)
        {
            if (Application.Current?.MainPage != null)
            {
                await Application.Current.MainPage.DisplayAlert("Erro", $"Erro ao criar chamado: {ex.Message}", "OK");
            }
        }
        finally
        {
            IsBusy = false;
        }
    }

    /// <summary>
    /// Gera um título automático baseado na descrição do chamado
    /// Extrai as primeiras palavras significativas da descrição
    /// </summary>
    private string GerarTituloAutomatico(string descricao)
    {
        if (string.IsNullOrWhiteSpace(descricao))
        {
            return "Chamado sem título";
        }

        // Remove quebras de linha e espaços extras
        string texto = descricao.Replace("\n", " ").Replace("\r", " ").Trim();
        
        // Limita a 60 caracteres
        const int maxLength = 60;
        if (texto.Length <= maxLength)
        {
            return texto;
        }

        // Corta no último espaço antes de 60 caracteres para não quebrar palavras
        int lastSpace = texto.LastIndexOf(' ', maxLength);
        if (lastSpace > 0)
        {
            return texto.Substring(0, lastSpace) + "...";
        }

        // Se não encontrou espaço, corta direto e adiciona reticências
        return texto.Substring(0, maxLength) + "...";
    }

    private async Task CriarChamadoComAnaliseAutomaticaAsync()
    {
        var chamado = await _chamadoService.CreateComAnaliseAutomatica(Descricao);
        await ExibirResultadoAsync(chamado);
    }

    private async Task CriarChamadoComClassificacaoManualAsync()
    {
        if (!CategoriaId.HasValue || !PrioridadeId.HasValue)
        {
            return;
        }

        var tituloFinal = string.IsNullOrWhiteSpace(Titulo)
            ? GerarTituloAutomatico(Descricao)
            : Titulo.Trim();

        var dto = new CriarChamadoRequestDto
        {
            Titulo = tituloFinal,
            Descricao = Descricao,
            CategoriaId = CategoriaId.Value,
            PrioridadeId = PrioridadeId.Value
        };

        var chamado = await _chamadoService.Create(dto);
        await ExibirResultadoAsync(chamado);
    }

    private static async Task ExibirResultadoAsync(ChamadoDto? chamado)
    {
        if (chamado == null)
        {
            if (Application.Current?.MainPage != null)
            {
                await Application.Current.MainPage.DisplayAlert("Erro", "Não foi possível criar o chamado. Tente novamente.", "OK");
            }
            return;
        }

        if (Application.Current?.MainPage != null)
        {
            await Application.Current.MainPage.DisplayAlert("Sucesso", "Chamado criado com sucesso!", "OK");
        }

        if (Shell.Current != null)
        {
            await Shell.Current.GoToAsync("..");
        }
    }
}

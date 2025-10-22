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

    public ICommand CriarCommand { get; }

    public NovoChamadoViewModel(
        IChamadoService chamadoService,
        ICategoriaService categoriaService,
        IPrioridadeService prioridadeService)
    {
        _chamadoService = chamadoService;
        _categoriaService = categoriaService;
        _prioridadeService = prioridadeService;

        CriarCommand = new Command(async () => await CriarChamadoAsync());
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
        catch (System.Exception ex)
        {
            await Application.Current.MainPage.DisplayAlert("Erro", $"Erro ao carregar dados: {ex.Message}", "OK");
        }
        finally
        {
            IsBusy = false;
        }
    }

    private async Task CriarChamadoAsync()
    {
        if (string.IsNullOrWhiteSpace(Titulo))
        {
            await Application.Current.MainPage.DisplayAlert("Atenção", "Por favor, informe o título do chamado.", "OK");
            return;
        }

        if (string.IsNullOrWhiteSpace(Descricao))
        {
            await Application.Current.MainPage.DisplayAlert("Atenção", "Por favor, informe a descrição do chamado.", "OK");
            return;
        }

        if (!CategoriaId.HasValue)
        {
            await Application.Current.MainPage.DisplayAlert("Atenção", "Por favor, selecione uma categoria.", "OK");
            return;
        }

        if (!PrioridadeId.HasValue)
        {
            await Application.Current.MainPage.DisplayAlert("Atenção", "Por favor, selecione uma prioridade.", "OK");
            return;
        }

        IsBusy = true;
        try
        {
            var dto = new CriarChamadoRequestDto
            {
                Titulo = Titulo,
                Descricao = Descricao,
                CategoriaId = CategoriaId.Value,
                PrioridadeId = PrioridadeId.Value
            };

            var chamado = await _chamadoService.Create(dto);
            if (chamado != null)
            {
                await Application.Current.MainPage.DisplayAlert("Sucesso", "Chamado criado com sucesso!", "OK");
                await Shell.Current.GoToAsync("..");
            }
        }
        catch (System.Exception ex)
        {
            await Application.Current.MainPage.DisplayAlert("Erro", $"Erro ao criar chamado: {ex.Message}", "OK");
        }
        finally
        {
            IsBusy = false;
        }
    }
}

using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Input;
using Microsoft.Maui.ApplicationModel;
using Microsoft.Maui.Controls;
using SistemaChamados.Mobile.Models.DTOs;
using SistemaChamados.Mobile.Services.Chamados;
using SistemaChamados.Mobile.Services.Categorias;
using SistemaChamados.Mobile.Services.Prioridades;
using SistemaChamados.Mobile.Services.Anexos;
using SistemaChamados.Mobile.Helpers;

namespace SistemaChamados.Mobile.ViewModels;

public class NovoChamadoViewModel : BaseViewModel
{
    private readonly IChamadoService _chamadoService;
    private readonly ICategoriaService _categoriaService;
    private readonly IPrioridadeService _prioridadeService;
    private readonly AnexoService _anexoService;

    // Tipos de usuário: 1 = Aluno, 2 = Técnico, 3 = Admin
    private int TipoUsuarioAtual => Settings.TipoUsuario;
    
    public bool IsAluno => TipoUsuarioAtual == 1;
    public bool IsTecnicoOuAdmin => TipoUsuarioAtual == 2 || TipoUsuarioAtual == 3;
    public bool IsAdmin => TipoUsuarioAtual == 3;

    public string Descricao { get; set; } = string.Empty;
    public string Titulo { get; set; } = string.Empty;
    public int? CategoriaId { get; set; }
    public int? PrioridadeId { get; set; }

    public ObservableCollection<CategoriaDto> Categorias { get; } = new ObservableCollection<CategoriaDto>();
    public ObservableCollection<PrioridadeDto> Prioridades { get; } = new ObservableCollection<PrioridadeDto>();

    public bool HasCategorias => Categorias.Any();
    public bool IsCategoriasEmpty => !HasCategorias;

    public bool HasPrioridades => Prioridades.Any();
    public bool IsPrioridadesEmpty => !HasPrioridades;

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
    public ICommand ToggleOpcoesAvancadasCommand { get; }

    private bool _exibirOpcoesAvancadas;
    public bool ExibirOpcoesAvancadas
    {
        get => _exibirOpcoesAvancadas;
        set
        {
            if (_exibirOpcoesAvancadas == value) return;
            _exibirOpcoesAvancadas = value;
            OnPropertyChanged();
            OnPropertyChanged(nameof(ToggleOpcoesAvancadasTexto));
            OnPropertyChanged(nameof(ExibirClassificacaoManual));
        }
    }

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

    public bool ExibirClassificacaoManual => ExibirOpcoesAvancadas && !UsarAnaliseAutomatica && IsTecnicoOuAdmin;

    public string ToggleOpcoesAvancadasTexto => ExibirOpcoesAvancadas ? "Ocultar opções avançadas" : "Mostrar opções avançadas";
    
    // Propriedade para mostrar/ocultar opções avançadas (apenas Técnicos e Admins)
    public bool PodeUsarClassificacaoManual => IsTecnicoOuAdmin;
    
    // Propriedade para mostrar descrição apropriada no header
    public string DescricaoHeader => IsAluno 
        ? "Descreva seu problema de forma clara para que possamos ajudá-lo rapidamente."
        : "Informe o contexto do problema e classifique o chamado para que o time possa priorizar corretamente.";

    // Propriedades para anexos
    public ObservableCollection<AnexoDto> AnexosTemporarios { get; } = new();
    public bool HasAnexos => AnexosTemporarios.Count > 0;
    public ICommand SelecionarImagemCommand { get; }
    public ICommand TirarFotoCommand { get; }
    public ICommand RemoverAnexoCommand { get; }

    public NovoChamadoViewModel(IChamadoService chamadoService, ICategoriaService categoriaService, IPrioridadeService prioridadeService, AnexoService anexoService)
    {
        _chamadoService = chamadoService;
        _categoriaService = categoriaService;
        _prioridadeService = prioridadeService;
        _anexoService = anexoService;

        CriarCommand = new Command(async () => await Criar());
        ToggleOpcoesAvancadasCommand = new Command(AlternarOpcoesAvancadas);
        SelecionarImagemCommand = new Command(async () => await SelecionarImagemAsync());
        TirarFotoCommand = new Command(async () => await TirarFotoAsync());
        RemoverAnexoCommand = new Command<AnexoDto>(async (anexo) => await RemoverAnexoAsync(anexo));

        // Log das permissões do usuário
        App.Log($"NovoChamadoViewModel constructor - UserId: {Settings.UserId}");
        App.Log($"NovoChamadoViewModel constructor - NomeUsuario: {Settings.NomeUsuario}");
        App.Log($"NovoChamadoViewModel constructor - Email: {Settings.Email}");
        App.Log($"NovoChamadoViewModel constructor - TipoUsuario: {Settings.TipoUsuario}");
        App.Log($"NovoChamadoViewModel constructor - IsAluno: {IsAluno}, IsTecnicoOuAdmin: {IsTecnicoOuAdmin}, IsAdmin: {IsAdmin}");
        App.Log($"NovoChamadoViewModel constructor - PodeUsarClassificacaoManual: {PodeUsarClassificacaoManual}");

        // Atualiza propriedades derivadas quando as coleções mudam
        Categorias.CollectionChanged += (s, e) =>
        {
            OnPropertyChanged(nameof(HasCategorias));
            OnPropertyChanged(nameof(IsCategoriasEmpty));
        };

        Prioridades.CollectionChanged += (s, e) =>
        {
            OnPropertyChanged(nameof(HasPrioridades));
            OnPropertyChanged(nameof(IsPrioridadesEmpty));
        };
        
        AnexosTemporarios.CollectionChanged += (s, e) =>
        {
            OnPropertyChanged(nameof(HasAnexos));
        };
    }

    public async Task Init()
    {
        if (IsBusy) return;
        try
        {
            IsBusy = true;

            var categoriasResult = await _categoriaService.GetAll();
            var prioridadesResult = await _prioridadeService.GetAll();

            var categoriasCount = categoriasResult?.Count() ?? 0;
            var prioridadesCount = prioridadesResult?.Count() ?? 0;
            Debug.WriteLine($"[NovoChamadoViewModel] Categorias recebidas: {categoriasCount}");
            Debug.WriteLine($"[NovoChamadoViewModel] Prioridades recebidas: {prioridadesCount}");
            Console.WriteLine($"[NovoChamadoViewModel] Categorias recebidas: {categoriasCount}");
            Console.WriteLine($"[NovoChamadoViewModel] Prioridades recebidas: {prioridadesCount}");

            MainThread.BeginInvokeOnMainThread(() =>
            {
                Categorias.Clear();
                if (categoriasResult != null)
                {
                    foreach (var categoria in categoriasResult)
                    {
                        Categorias.Add(categoria);
                    }
                    Debug.WriteLine($"[NovoChamadoViewModel] Categorias carregadas na UI: {Categorias.Count}");
                    Console.WriteLine($"[NovoChamadoViewModel] Categorias carregadas na UI: {Categorias.Count}");
                    CategoriaSelecionada = Categorias.FirstOrDefault();
                }

                Prioridades.Clear();
                if (prioridadesResult != null)
                {
                    foreach (var prioridade in prioridadesResult)
                    {
                        Prioridades.Add(prioridade);
                    }
                    Debug.WriteLine($"[NovoChamadoViewModel] Prioridades carregadas na UI: {Prioridades.Count}");
                    Console.WriteLine($"[NovoChamadoViewModel] Prioridades carregadas na UI: {Prioridades.Count}");
                    PrioridadeSelecionada = Prioridades.FirstOrDefault();
                }
            });
        }
        finally
        {
            IsBusy = false;
        }
    }

    private void AlternarOpcoesAvancadas()
    {
        ExibirOpcoesAvancadas = !ExibirOpcoesAvancadas;
        App.Log($"NovoChamadoViewModel AlternarOpcoesAvancadas - ExibirOpcoesAvancadas: {ExibirOpcoesAvancadas}");
        App.Log($"NovoChamadoViewModel AlternarOpcoesAvancadas - UsarAnaliseAutomatica: {UsarAnaliseAutomatica}");
        App.Log($"NovoChamadoViewModel AlternarOpcoesAvancadas - ExibirClassificacaoManual: {ExibirClassificacaoManual}");

        if (!ExibirOpcoesAvancadas)
        {
            UsarAnaliseAutomatica = true;
        }
    }

    private async Task Criar()
    {
        try
        {
            App.Log("NovoChamadoViewModel.Criar start");
            
            if (IsBusy)
            {
                App.Log("NovoChamadoViewModel.Criar already busy, returning");
                return;
            }
            
            if (string.IsNullOrWhiteSpace(Descricao))
            {
                App.Log("NovoChamadoViewModel.Criar validation failed: empty description");
                await ShowAlertAsync("Erro", "Descrição obrigatória");
                return;
            }
            
            if (ExibirClassificacaoManual && CategoriaSelecionada == null)
            {
                App.Log("NovoChamadoViewModel.Criar validation failed: no category selected");
                await ShowAlertAsync("Erro", "Selecione uma categoria");
                return;
            }
            
            if (ExibirClassificacaoManual && PrioridadeSelecionada == null)
            {
                App.Log("NovoChamadoViewModel.Criar validation failed: no priority selected");
                await ShowAlertAsync("Erro", "Selecione uma prioridade");
                return;
            }
            
            IsBusy = true;
            App.Log($"NovoChamadoViewModel.Criar creating DTO - UsarIA: {UsarAnaliseAutomatica}");
            
            var dto = new CriarChamadoRequestDto
            {
                Titulo = string.IsNullOrWhiteSpace(Titulo) ? null : Titulo,
                Descricao = Descricao,
                UsarAnaliseAutomatica = UsarAnaliseAutomatica
            };

            if (!UsarAnaliseAutomatica)
            {
                dto.CategoriaId = CategoriaId;
                dto.PrioridadeId = PrioridadeId;
                App.Log($"NovoChamadoViewModel.Criar manual classification - Cat: {CategoriaId}, Prior: {PrioridadeId}");
            }

            App.Log("NovoChamadoViewModel.Criar calling service.Create");
            var created = await _chamadoService.Create(dto);
            
            if (created != null)
            {
                App.Log($"NovoChamadoViewModel.Criar chamado created successfully, Id: {created.Id}");
                
                if (Shell.Current is Shell shell)
                {
                    LimparFormulario();

                    var parametros = new Dictionary<string, object>
                    {
                        { "Chamado", created }
                    };

                    App.Log("NovoChamadoViewModel.Criar navigating to confirmacao");
                    await shell.GoToAsync("///chamados/confirmacao", parametros);
                    App.Log("NovoChamadoViewModel.Criar navigation complete");
                }
                else
                {
                    App.Log("NovoChamadoViewModel.Criar ERROR: Shell.Current is null");
                    await ShowAlertAsync("Erro", "Erro ao navegar para confirmação.");
                }
            }
            else
            {
                App.Log("NovoChamadoViewModel.Criar ERROR: service returned null");
                await ShowAlertAsync("Erro", "Não foi possível registrar o chamado. Tente novamente.");
            }
        }
        catch (Exception ex)
        {
            App.Log($"NovoChamadoViewModel.Criar FATAL ERROR: {ex.GetType().Name} - {ex.Message}");
            App.Log($"NovoChamadoViewModel.Criar STACK: {ex.StackTrace}");
            await ShowAlertAsync("Erro", $"Erro ao criar chamado: {ex.Message}");
        }
        finally
        {
            IsBusy = false;
            App.Log("NovoChamadoViewModel.Criar end");
        }
    }

    private void LimparFormulario()
    {
        Descricao = string.Empty;
        Titulo = string.Empty;
        OnPropertyChanged(nameof(Descricao));
        OnPropertyChanged(nameof(Titulo));

        CategoriaSelecionada = Categorias.FirstOrDefault();
        PrioridadeSelecionada = Prioridades.FirstOrDefault();

        ExibirOpcoesAvancadas = false;
        UsarAnaliseAutomatica = true;
        
        // Limpa anexos temporários
        AnexosTemporarios.Clear();
    }

    /// <summary>
    /// Permite selecionar imagem da galeria
    /// </summary>
    private async Task SelecionarImagemAsync()
    {
        try
        {
            var resultado = await _anexoService.SelecionarImagemAsync();
            if (resultado != null)
            {
                var usuario = new UsuarioResumoDto
                {
                    Id = Settings.UserId,
                    NomeCompleto = Settings.NomeUsuario ?? "Usuário",
                    Email = Settings.Email ?? "",
                    TipoUsuario = Settings.TipoUsuario
                };

                var anexo = await _anexoService.SalvarAnexoAsync(resultado, 0, usuario);
                if (anexo != null)
                {
                    AnexosTemporarios.Add(anexo);
                    await ShowAlertAsync("Sucesso", $"Imagem '{anexo.NomeArquivo}' anexada com sucesso!");
                }
            }
        }
        catch (Exception ex)
        {
            await ShowAlertAsync("Erro", $"Erro ao selecionar imagem: {ex.Message}");
        }
    }

    /// <summary>
    /// Permite tirar foto com a câmera
    /// </summary>
    private async Task TirarFotoAsync()
    {
        try
        {
            var resultado = await _anexoService.TirarFotoAsync();
            if (resultado != null)
            {
                var usuario = new UsuarioResumoDto
                {
                    Id = Settings.UserId,
                    NomeCompleto = Settings.NomeUsuario ?? "Usuário",
                    Email = Settings.Email ?? "",
                    TipoUsuario = Settings.TipoUsuario
                };

                var anexo = await _anexoService.SalvarAnexoAsync(resultado, 0, usuario);
                if (anexo != null)
                {
                    AnexosTemporarios.Add(anexo);
                    await ShowAlertAsync("Sucesso", $"Foto capturada e anexada com sucesso!");
                }
            }
        }
        catch (Exception ex)
        {
            await ShowAlertAsync("Erro", $"Erro ao tirar foto: {ex.Message}");
        }
    }

    /// <summary>
    /// Remove um anexo temporário
    /// </summary>
    private async Task RemoverAnexoAsync(AnexoDto anexo)
    {
        if (anexo == null) return;

        var confirmar = false;
        if (Application.Current?.MainPage != null)
        {
            confirmar = await Application.Current.MainPage.DisplayAlert(
                "Confirmar",
                $"Deseja remover o anexo '{anexo.NomeArquivo}'?",
                "Sim", "Não");
        }

        if (confirmar)
        {
            AnexosTemporarios.Remove(anexo);
        }
    }

    private static Task ShowAlertAsync(string title, string message)
    {
        if (Application.Current?.MainPage is Page page)
        {
            return MainThread.InvokeOnMainThreadAsync(() => page.DisplayAlert(title, message, "OK"));
        }

        return Task.CompletedTask;
    }
}

using System;
using System.Collections.ObjectModel;
using System.Globalization;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Input;
using Microsoft.Maui.Controls;
using SistemaChamados.Mobile.Helpers;
using SistemaChamados.Mobile.Models.DTOs;
using SistemaChamados.Mobile.Services.Auth;
using SistemaChamados.Mobile.Services.Api;
using SistemaChamados.Mobile.Services.Chamados;
using SistemaChamados.Mobile.Services.Comentarios;

namespace SistemaChamados.Mobile.ViewModels;

public class ChamadoDetailViewModel : BaseViewModel
{
    private readonly IChamadoService _chamadoService;
    private readonly IAuthService _authService;
    private readonly IComentarioService _comentarioService;
    private ChamadoDto? _chamado;
    private AnaliseChamadoResponseDto? _analiseIa;
    private CancellationTokenSource? _autoRefreshCts;
    private bool _isRefreshing;
    private bool _isComentariosLoading;
    private bool _isSendingComentario;
    private string _novoComentarioTexto = string.Empty;
    private bool _novoComentarioIsInterno;

    public ChamadoDetailViewModel(IChamadoService chamadoService, IAuthService authService, IComentarioService comentarioService)
    {
        _chamadoService = chamadoService;
        _authService = authService;
        _comentarioService = comentarioService;

        Comentarios.CollectionChanged += (_, _) => OnPropertyChanged(nameof(HasComentarios));

        // Comandos
        CloseChamadoCommand = new Command(async () => await CloseChamadoAsync());
        RefreshCommand = new Command(async () => await RefreshAsync());
        AddComentarioCommand = new Command(async () => await AdicionarComentarioAsync(), () => PodeEnviarComentario());
    }

    public int Id { get; private set; }

    public ObservableCollection<ComentarioDto> Comentarios { get; } = new();

    public bool HasComentarios => Comentarios.Count > 0;

    public bool IsRefreshing
    {
        get => _isRefreshing;
        set
        {
            _isRefreshing = value;
            OnPropertyChanged();
        }
    }

    public bool IsComentariosLoading
    {
        get => _isComentariosLoading;
        set
        {
            if (_isComentariosLoading == value) return;
            _isComentariosLoading = value;
            OnPropertyChanged();
        }
    }

    public bool IsSendingComentario
    {
        get => _isSendingComentario;
        set
        {
            if (_isSendingComentario == value) return;
            _isSendingComentario = value;
            OnPropertyChanged();
            NotifyComentarioCommandCanExecute();
        }
    }

    public string NovoComentarioTexto
    {
        get => _novoComentarioTexto;
        set
        {
            if (_novoComentarioTexto == value) return;
            _novoComentarioTexto = value;
            OnPropertyChanged();
            NotifyComentarioCommandCanExecute();
        }
    }

    public bool NovoComentarioIsInterno
    {
        get => _novoComentarioIsInterno;
        set
        {
            if (_novoComentarioIsInterno == value) return;
            _novoComentarioIsInterno = value;
            OnPropertyChanged();
        }
    }

    public bool PodeDefinirComentarioInterno => Settings.TipoUsuario == 2 || Settings.TipoUsuario == 3;

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
            AtualizarAnalise(value?.Analise);
            
            System.Diagnostics.Debug.WriteLine($"  → IsChamadoEncerrado: {IsChamadoEncerrado}");
            System.Diagnostics.Debug.WriteLine($"  → HasFechamento: {HasFechamento}");
            System.Diagnostics.Debug.WriteLine($"  → ShowCloseButton: {ShowCloseButton}");
        }
    }

    // Indica se o chamado está encerrado (Status = "Fechado" ou DataFechamento preenchida)
    public bool IsChamadoEncerrado => Chamado?.DataFechamento != null || Chamado?.Status?.Id == 4;

    // Indica se há data de fechamento para exibir
    public bool HasFechamento => Chamado?.DataFechamento != null;

    // Mostra botão apenas se NÃO estiver encerrado
    public bool ShowCloseButton => Chamado != null && !IsChamadoEncerrado;

    public ICommand CloseChamadoCommand { get; }
    public ICommand RefreshCommand { get; }
    public ICommand AddComentarioCommand { get; }

    // Timer de auto-refresh (10 segundos)
    private const int AutoRefreshIntervalSeconds = 10;

    public AnaliseChamadoResponseDto? AnaliseIA
    {
        get => _analiseIa;
        private set
        {
            if (_analiseIa == value) return;
            _analiseIa = value;
            OnPropertyChanged();
            OnPropertyChanged(nameof(HasAnaliseIA));
            OnPropertyChanged(nameof(AnaliseCategoriaTexto));
            OnPropertyChanged(nameof(AnalisePrioridadeTexto));
            OnPropertyChanged(nameof(AnaliseJustificativa));
            OnPropertyChanged(nameof(AnaliseTecnicoTexto));
            OnPropertyChanged(nameof(AnaliseConfiancaCategoriaTexto));
            OnPropertyChanged(nameof(AnaliseConfiancaPrioridadeTexto));
        }
    }

    public bool HasAnaliseIA => AnaliseIA != null;

    public string? AnaliseCategoriaTexto => AnaliseIA == null
        ? null
        : $"{AnaliseIA.CategoriaNome} (ID: {AnaliseIA.CategoriaId})";

    public string? AnalisePrioridadeTexto => AnaliseIA == null
        ? null
        : $"{AnaliseIA.PrioridadeNome} (ID: {AnaliseIA.PrioridadeId})";

    public string? AnaliseJustificativa => AnaliseIA?.Justificativa;

    public string? AnaliseTecnicoTexto
    {
        get
        {
            if (AnaliseIA == null)
            {
                return null;
            }

            return AnaliseIA.TecnicoId.HasValue
                ? $"{AnaliseIA.TecnicoNome ?? "Não informado"} (ID: {AnaliseIA.TecnicoId})"
                : "Não houve sugestão de técnico";
        }
    }

    public string? AnaliseConfiancaCategoriaTexto => AnaliseIA == null
        ? null
        : ConverterConfiancaParaTexto(AnaliseIA.ConfiancaCategoria);

    public string? AnaliseConfiancaPrioridadeTexto => AnaliseIA == null
        ? null
        : ConverterConfiancaParaTexto(AnaliseIA.ConfiancaPrioridade);

    public async Task LoadChamadoAsync(int id)
    {
        Id = id;

        if (IsBusy) return;

        IsBusy = true;
        try
        {
            Comentarios.Clear();
            OnPropertyChanged(nameof(HasComentarios));

            System.Diagnostics.Debug.WriteLine($"ChamadoDetailViewModel.LoadChamadoAsync - Loading ID: {id}");
            var chamadoAtualizado = await _chamadoService.GetById(id);
            
            System.Diagnostics.Debug.WriteLine($"ChamadoDetailViewModel.LoadChamadoAsync - API returned:");
            System.Diagnostics.Debug.WriteLine($"  → Status: {chamadoAtualizado?.Status?.Nome} (ID: {chamadoAtualizado?.Status?.Id})");
            System.Diagnostics.Debug.WriteLine($"  → DataFechamento: {chamadoAtualizado?.DataFechamento}");
            
            Chamado = chamadoAtualizado;
            await LoadComentariosAsync(false);
            
            System.Diagnostics.Debug.WriteLine($"ChamadoDetailViewModel.LoadChamadoAsync - Chamado property updated");
        }
        catch (ApiException ex)
        {
            System.Diagnostics.Debug.WriteLine($"ChamadoDetailViewModel.LoadChamadoAsync API ERROR: {ex.Message} (Status: {(int)ex.StatusCode})");
            if (Application.Current?.MainPage != null)
            {
                await Application.Current.MainPage.DisplayAlert("Erro", ex.Message, "OK");
            }
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

    private void AtualizarAnalise(AnaliseChamadoResponseDto? analise)
    {
        AnaliseIA = analise;
    }

    private static string ConverterConfiancaParaTexto(double confianca)
    {
        var percentual = Math.Clamp(confianca, 0, 1);
        return percentual.ToString("P0", CultureInfo.CurrentCulture);
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
            await LoadComentariosAsync(false);
            System.Diagnostics.Debug.WriteLine("ChamadoDetailViewModel.RefreshAsync - Refresh completed");
        }
        catch (ApiException ex)
        {
            System.Diagnostics.Debug.WriteLine($"ChamadoDetailViewModel.RefreshAsync API ERROR: {ex.Message}");
            if (Application.Current?.MainPage != null)
            {
                await Application.Current.MainPage.DisplayAlert("Erro", ex.Message, "OK");
            }
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

    private void NotifyComentarioCommandCanExecute()
    {
        if (AddComentarioCommand is Command command)
        {
            command.ChangeCanExecute();
        }
    }

    private bool PodeEnviarComentario() => !string.IsNullOrWhiteSpace(NovoComentarioTexto?.Trim()) && !IsSendingComentario;

    private async Task LoadComentariosAsync(bool showErrors)
    {
        if (Id <= 0)
        {
            return;
        }

        if (IsComentariosLoading)
        {
            return;
        }

        IsComentariosLoading = true;

        try
        {
            System.Diagnostics.Debug.WriteLine($"ChamadoDetailViewModel.LoadComentariosAsync - Loading comments for chamado {Id}");
            var comentarios = await _comentarioService.GetComentarios(Id);

            Comentarios.Clear();

            if (comentarios != null)
            {
                foreach (var comentario in comentarios.OrderBy(c => c.DataCriacao))
                {
                    Comentarios.Add(comentario);
                }
            }
        }
        catch (ApiException ex)
        {
            System.Diagnostics.Debug.WriteLine($"ChamadoDetailViewModel.LoadComentariosAsync API ERROR: {ex.Message}");
            if (showErrors && Application.Current?.MainPage != null)
            {
                await Application.Current.MainPage.DisplayAlert("Erro", ex.Message, "OK");
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"ChamadoDetailViewModel.LoadComentariosAsync ERROR: {ex.Message}");
            if (showErrors && Application.Current?.MainPage != null)
            {
                await Application.Current.MainPage.DisplayAlert("Erro", $"Erro ao carregar comentários: {ex.Message}", "OK");
            }
        }
        finally
        {
            IsComentariosLoading = false;
        }
    }

    private async Task AdicionarComentarioAsync()
    {
        if (Id <= 0 || string.IsNullOrWhiteSpace(NovoComentarioTexto))
        {
            return;
        }

        if (IsSendingComentario)
        {
            return;
        }

        IsSendingComentario = true;

        try
        {
            var request = new CriarComentarioRequestDto
            {
                Texto = NovoComentarioTexto.Trim(),
                IsInterno = NovoComentarioIsInterno && PodeDefinirComentarioInterno
            };

            var comentarioCriado = await _comentarioService.AdicionarComentarioAsync(Id, request);

            if (comentarioCriado != null)
            {
                InserirComentarioOrdenado(comentarioCriado);
                OnPropertyChanged(nameof(HasComentarios));
            }
            else
            {
                await LoadComentariosAsync(false);
            }

            NovoComentarioTexto = string.Empty;

            if (!PodeDefinirComentarioInterno)
            {
                NovoComentarioIsInterno = false;
            }

            await AtualizarChamadoAposComentarioAsync();
        }
        catch (ApiException ex)
        {
            System.Diagnostics.Debug.WriteLine($"ChamadoDetailViewModel.AdicionarComentarioAsync API ERROR: {ex.Message}");
            if (Application.Current?.MainPage != null)
            {
                await Application.Current.MainPage.DisplayAlert("Erro", ex.Message, "OK");
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"ChamadoDetailViewModel.AdicionarComentarioAsync ERROR: {ex.Message}");
            if (Application.Current?.MainPage != null)
            {
                await Application.Current.MainPage.DisplayAlert("Erro", $"Erro ao adicionar comentário: {ex.Message}", "OK");
            }
        }
        finally
        {
            IsSendingComentario = false;
        }
    }

    private void InserirComentarioOrdenado(ComentarioDto comentario)
    {
        if (Comentarios.Count == 0)
        {
            Comentarios.Add(comentario);
            return;
        }

        var dataComparacao = comentario.DataCriacao;
        var index = 0;

        foreach (var existente in Comentarios)
        {
            var existenteData = existente.DataCriacao;
            if (existenteData > dataComparacao)
            {
                break;
            }

            index++;
        }

        if (index >= Comentarios.Count)
        {
            Comentarios.Add(comentario);
        }
        else
        {
            Comentarios.Insert(index, comentario);
        }
    }

    private async Task AtualizarChamadoAposComentarioAsync()
    {
        try
        {
            var chamadoAtualizado = await _chamadoService.GetById(Id);
            if (chamadoAtualizado != null)
            {
                Chamado = chamadoAtualizado;
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"ChamadoDetailViewModel.AtualizarChamadoAposComentarioAsync ERROR: {ex.Message}");
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
            var chamadoAtualizado = await _chamadoService.Close(Chamado.Id);
            System.Diagnostics.Debug.WriteLine("ChamadoDetailViewModel.CloseChamadoAsync - API call successful");

            if (chamadoAtualizado != null)
            {
                Chamado = chamadoAtualizado;
                System.Diagnostics.Debug.WriteLine("ChamadoDetailViewModel.CloseChamadoAsync - Chamado updated from API response");
            }
            else
            {
                System.Diagnostics.Debug.WriteLine("ChamadoDetailViewModel.CloseChamadoAsync - API returned null, reloading via service");
                await LoadChamadoAsync(Id);
            }
            
            await Application.Current.MainPage.DisplayAlert(
                "✅ Chamado Encerrado", 
                "O chamado foi encerrado com sucesso! A página foi atualizada.", 
                "OK");
        }
        catch (ApiException ex)
        {
            System.Diagnostics.Debug.WriteLine($"ChamadoDetailViewModel.CloseChamadoAsync API ERROR: {ex.Message} (Status: {(int)ex.StatusCode})");
            if (Application.Current?.MainPage != null)
            {
                await Application.Current.MainPage.DisplayAlert(
                    "Erro",
                    ex.Message,
                    "OK");
            }
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

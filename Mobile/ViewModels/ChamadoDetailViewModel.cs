using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Input;
using Microsoft.Maui.ApplicationModel;
using Microsoft.Maui.Controls;
using SistemaChamados.Mobile.Models.DTOs;
using SistemaChamados.Mobile.Services.Auth;
using SistemaChamados.Mobile.Services.Chamados;
using SistemaChamados.Mobile.Services.Comentarios;
using SistemaChamados.Mobile.Services.Anexos;

namespace SistemaChamados.Mobile.ViewModels;

public class ChamadoDetailViewModel : BaseViewModel
{
    private readonly IChamadoService _chamadoService;
    private readonly IAuthService _authService;
    private readonly ComentarioService _comentarioService;
    private readonly AnexoService _anexoService;
    private ChamadoDto? _chamado;
    private string _novoComentarioTexto = string.Empty;
    private bool _isEnviandoComentario;

    public ChamadoDetailViewModel(IChamadoService chamadoService, IAuthService authService, ComentarioService comentarioService, AnexoService anexoService)
    {
        _chamadoService = chamadoService;
        _authService = authService;
        _comentarioService = comentarioService;
        _anexoService = anexoService;
        CloseChamadoCommand = new Command(async () => await CloseChamadoAsync(), () => !IsBusy && ShowCloseButton);
        EnviarComentarioCommand = new Command(async () => await EnviarComentarioAsync(), () => !IsEnviandoComentario && !string.IsNullOrWhiteSpace(NovoComentarioTexto));
        AbrirAnexoCommand = new Command<AnexoDto>(async (anexo) => await AbrirAnexoAsync(anexo));
        CompartilharAnexoCommand = new Command<AnexoDto>(async (anexo) => await CompartilharAnexoAsync(anexo));
        
        PropertyChanged += (_, args) =>
        {
            if (args.PropertyName == nameof(IsBusy) || args.PropertyName == nameof(ShowCloseButton))
            {
                if (CloseChamadoCommand is Command command)
                {
                    command.ChangeCanExecute();
                }
            }
            if (args.PropertyName == nameof(IsEnviandoComentario) || args.PropertyName == nameof(NovoComentarioTexto))
            {
                if (EnviarComentarioCommand is Command cmd)
                {
                    cmd.ChangeCanExecute();
                }
            }
        };
    }

    public int Id { get; private set; }

    public ChamadoDto? Chamado
    {
        get => _chamado;
        private set
        {
            _chamado = value;
            OnPropertyChanged();
            OnPropertyChanged(nameof(HasFechamento));
            OnPropertyChanged(nameof(ShowCloseButton));
            if (CloseChamadoCommand is Command command)
            {
                command.ChangeCanExecute();
            }
        }
    }

    public bool IsAdmin => _authService.CurrentUser?.TipoUsuario == 3;

    public bool HasFechamento => Chamado?.DataFechamento != null;

    public bool ShowCloseButton => IsAdmin && Chamado?.Status?.Id != 4;

    public ICommand CloseChamadoCommand { get; }
    
    // Propriedades para Thread de Comentários
    public ObservableCollection<ComentarioDto> Comentarios { get; } = new();
    
    public string NovoComentarioTexto
    {
        get => _novoComentarioTexto;
        set
        {
            _novoComentarioTexto = value;
            OnPropertyChanged();
        }
    }
    
    public bool IsEnviandoComentario
    {
        get => _isEnviandoComentario;
        set
        {
            _isEnviandoComentario = value;
            OnPropertyChanged();
        }
    }
    
    public bool HasComentarios => Comentarios.Count > 0;
    
    public ICommand EnviarComentarioCommand { get; }
    
    // Propriedades para Anexos
    public ObservableCollection<AnexoDto> Anexos { get; } = new();
    public bool HasAnexos => Anexos.Count > 0;
    public ICommand AbrirAnexoCommand { get; }
    public ICommand CompartilharAnexoCommand { get; }

    public async Task Load(int id)
    {
        if (IsBusy) return;
        try
        {
            App.Log($"ChamadoDetailViewModel.Load({id}) start");
            IsBusy = true;
            Id = id;
            App.Log($"ChamadoDetailViewModel calling GetById({id})");
            Chamado = await _chamadoService.GetById(id);
            App.Log($"ChamadoDetailViewModel GetById done, Chamado={Chamado?.Id}");
            
            // Se a API não retornar histórico, cria dados mock para demonstração
            if (Chamado != null && (Chamado.Historico == null || Chamado.Historico.Count == 0))
            {
                App.Log("ChamadoDetailViewModel generating mock history");
                Chamado.Historico = GerarHistoricoMock(Chamado);
            }
            
            // Carrega comentários
            App.Log("ChamadoDetailViewModel loading comentarios");
            await CarregarComentariosAsync();
            App.Log("ChamadoDetailViewModel comentarios loaded");
            
            // Carrega anexos
            App.Log("ChamadoDetailViewModel loading anexos");
            await CarregarAnexosAsync();
            App.Log("ChamadoDetailViewModel anexos loaded");
            App.Log("ChamadoDetailViewModel.Load complete");
        }
        catch (Exception ex)
        {
            App.Log($"ChamadoDetailViewModel.Load FATAL: {ex}");
            throw;
        }
        finally
        {
            IsBusy = false;
        }
    }
    
    /// <summary>
    /// Carrega os comentários do chamado
    /// </summary>
    private async Task CarregarComentariosAsync()
    {
        if (Chamado == null) return;
        
        try
        {
            // REMOVIDO: Geração de comentários mock automáticos
            // A API real deve retornar apenas os comentários reais do chamado
            
            var comentarios = await _comentarioService.GetComentariosByChamadoIdAsync(Id);
            
            Comentarios.Clear();
            foreach (var comentario in comentarios)
            {
                // Filtra comentários internos para alunos
                if (comentario.IsInterno && !IsAdmin && _authService.CurrentUser?.TipoUsuario != 2)
                    continue;
                    
                Comentarios.Add(comentario);
            }
            
            OnPropertyChanged(nameof(HasComentarios));
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Erro ao carregar comentários: {ex.Message}");
        }
    }
    
    /// <summary>
    /// Envia um novo comentário
    /// </summary>
    private async Task EnviarComentarioAsync()
    {
        if (string.IsNullOrWhiteSpace(NovoComentarioTexto) || Chamado == null) return;
        
        try
        {
            IsEnviandoComentario = true;
            
            var usuario = new UsuarioResumoDto
            {
                Id = _authService.CurrentUser?.Id ?? 0,
                NomeCompleto = _authService.CurrentUser?.NomeCompleto ?? "Usuário",
                Email = _authService.CurrentUser?.Email ?? "",
                TipoUsuario = _authService.CurrentUser?.TipoUsuario ?? 1
            };
            
            var comentario = await _comentarioService.AddComentarioAsync(Id, NovoComentarioTexto, usuario, false);
            
            if (comentario != null)
            {
                Comentarios.Add(comentario);
                NovoComentarioTexto = string.Empty;
                OnPropertyChanged(nameof(HasComentarios));
                
                // Scroll para o final da lista (simulado via notificação)
                await Task.Delay(100);
            }
        }
        catch (Exception ex)
        {
            await ShowAlertAsync("Erro", $"Erro ao enviar comentário: {ex.Message}");
        }
        finally
        {
            IsEnviandoComentario = false;
        }
    }

    /// <summary>
    /// Gera histórico mock baseado nos dados do chamado para demonstração da timeline
    /// </summary>
    private List<HistoricoItemDto> GerarHistoricoMock(ChamadoDto chamado)
    {
        var historico = new List<HistoricoItemDto>();

        // 1. Evento de Criação (sempre existe)
        historico.Add(new HistoricoItemDto
        {
            Id = 1,
            DataHora = chamado.DataAbertura,
            TipoEvento = "Criacao",
            Descricao = "Chamado aberto",
            Usuario = chamado.Solicitante?.NomeCompleto ?? "Sistema",
            ValorAnterior = null,
            ValorNovo = chamado.Status?.Nome ?? "Aberto"
        });

        // 2. Se tem técnico, adiciona evento de atribuição
        if (chamado.Tecnico != null)
        {
            var dataAtribuicao = chamado.DataAbertura.AddHours(1);
            historico.Add(new HistoricoItemDto
            {
                Id = 2,
                DataHora = dataAtribuicao,
                TipoEvento = "Atribuicao",
                Descricao = "Técnico atribuído",
                Usuario = "Sistema",
                ValorAnterior = "Não atribuído",
                ValorNovo = chamado.Tecnico.NomeCompleto
            });
        }

        // 3. Adiciona alguns comentários mock
        var dataComentario1 = chamado.DataAbertura.AddHours(2);
        historico.Add(new HistoricoItemDto
        {
            Id = 3,
            DataHora = dataComentario1,
            TipoEvento = "Comentario",
            Descricao = "Em análise. Verificando a situação reportada.",
            Usuario = chamado.Tecnico?.NomeCompleto ?? "Técnico Responsável",
            ValorAnterior = null,
            ValorNovo = null
        });

        // 4. Se tem atualização, adiciona mudança de status
        if (chamado.DataUltimaAtualizacao.HasValue && 
            chamado.DataUltimaAtualizacao.Value > chamado.DataAbertura.AddHours(3))
        {
            historico.Add(new HistoricoItemDto
            {
                Id = 4,
                DataHora = chamado.DataUltimaAtualizacao.Value,
                TipoEvento = "MudancaStatus",
                Descricao = "Status atualizado",
                Usuario = chamado.Tecnico?.NomeCompleto ?? "Sistema",
                ValorAnterior = "Aberto",
                ValorNovo = "Em Andamento"
            });

            // Adiciona outro comentário após mudança de status
            var dataComentario2 = chamado.DataUltimaAtualizacao.Value.AddMinutes(30);
            historico.Add(new HistoricoItemDto
            {
                Id = 5,
                DataHora = dataComentario2,
                TipoEvento = "Comentario",
                Descricao = "Trabalhando na solução do problema identificado.",
                Usuario = chamado.Tecnico?.NomeCompleto ?? "Técnico Responsável",
                ValorAnterior = null,
                ValorNovo = null
            });
        }

        // 5. Se tem data de fechamento, adiciona evento de encerramento
        if (chamado.DataFechamento.HasValue)
        {
            historico.Add(new HistoricoItemDto
            {
                Id = 6,
                DataHora = chamado.DataFechamento.Value,
                TipoEvento = "Fechamento",
                Descricao = "Chamado encerrado",
                Usuario = chamado.Tecnico?.NomeCompleto ?? "Sistema",
                ValorAnterior = "Em Andamento",
                ValorNovo = "Encerrado"
            });

            historico.Add(new HistoricoItemDto
            {
                Id = 7,
                DataHora = chamado.DataFechamento.Value.AddMinutes(5),
                TipoEvento = "Comentario",
                Descricao = "Problema resolvido com sucesso. Chamado finalizado.",
                Usuario = chamado.Tecnico?.NomeCompleto ?? "Técnico Responsável",
                ValorAnterior = null,
                ValorNovo = null
            });
        }

        // Ordena por data (do mais antigo para o mais recente)
        return historico.OrderBy(h => h.DataHora).ToList();
    }

    private async Task CloseChamadoAsync()
    {
        if (!ShowCloseButton || Chamado == null) return;

        var confirmed = await ConfirmAsync("Encerrar chamado", "Tem certeza que deseja encerrar este chamado?");
        if (!confirmed) return;

        try
        {
            IsBusy = true;
            var atualizado = await _chamadoService.Close(Id);
            if (atualizado != null)
            {
                Chamado = atualizado;
                await ShowAlertAsync("Sucesso", "Chamado encerrado com sucesso.");
            }
            else
            {
                await ShowAlertAsync("Erro", "Não foi possível encerrar o chamado.");
            }
        }
        catch (Exception ex)
        {
            await ShowAlertAsync("Erro", ex.Message);
        }
        finally
        {
            IsBusy = false;
        }
    }
    
    /// <summary>
    /// Carrega os anexos do chamado
    /// </summary>
    private async Task CarregarAnexosAsync()
    {
        if (Chamado == null) return;
        
        try
        {
            var anexos = await _anexoService.GetAnexosByChamadoIdAsync(Id);
            
            Anexos.Clear();
            foreach (var anexo in anexos)
            {
                Anexos.Add(anexo);
            }
            
            OnPropertyChanged(nameof(HasAnexos));
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Erro ao carregar anexos: {ex.Message}");
        }
    }
    
    /// <summary>
    /// Abre o anexo no visualizador padrão
    /// </summary>
    private async Task AbrirAnexoAsync(AnexoDto? anexo)
    {
        if (anexo == null) return;
        
        try
        {
            await _anexoService.AbrirAnexoAsync(anexo);
        }
        catch (Exception ex)
        {
            await ShowAlertAsync("Erro", $"Erro ao abrir anexo: {ex.Message}");
        }
    }
    
    /// <summary>
    /// Compartilha o anexo
    /// </summary>
    private async Task CompartilharAnexoAsync(AnexoDto? anexo)
    {
        if (anexo == null) return;
        
        try
        {
            await _anexoService.CompartilharAnexoAsync(anexo);
        }
        catch (Exception ex)
        {
            await ShowAlertAsync("Erro", $"Erro ao compartilhar anexo: {ex.Message}");
        }
    }

    private static Task<bool> ConfirmAsync(string title, string message)
    {
        if (Application.Current?.MainPage is Page page)
        {
            return MainThread.InvokeOnMainThreadAsync(() => page.DisplayAlert(title, message, "Encerrar", "Cancelar"));
        }

        return Task.FromResult(false);
    }

    private static Task ShowAlertAsync(string title, string message)
    {
        if (Application.Current?.MainPage is Page page)
        {
            return MainThread.InvokeOnMainThreadAsync(() => page.DisplayAlert(title, message, "OK"));
        }

        return Task.CompletedTask;
    }

    /// <summary>
    /// Limpa os dados do chamado para evitar cache entre navegações
    /// </summary>
    public void ClearData()
    {
        App.Log("ChamadoDetailViewModel ClearData");
        Chamado = null;
        Id = 0;
        NovoComentarioTexto = string.Empty;
        Comentarios.Clear();
        Anexos.Clear();
        OnPropertyChanged(nameof(HasComentarios));
        OnPropertyChanged(nameof(HasAnexos));
    }
}

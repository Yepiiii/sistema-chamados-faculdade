using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using SistemaChamados.Mobile.Models.DTOs;
using SistemaChamados.Mobile.Helpers;

namespace SistemaChamados.Mobile.Services.Polling;

/// <summary>
/// Serviço de polling para verificar atualizações periódicas
/// </summary>
public class PollingService
{
    private Timer? _pollingTimer;
    private DateTime _ultimaVerificacao = DateTime.Now;
    private bool _isPollingAtivo = false;
    
    // Intervalo padrão: 5 minutos
    private readonly TimeSpan _intervaloPolling = TimeSpan.FromMinutes(5);
    
    // Mock de atualizações para demonstração
    private static readonly List<AtualizacaoDto> _atualizacoesMock = new();
    private static int _proximoId = 1;
    
    public event EventHandler<List<AtualizacaoDto>>? NovasAtualizacoesDetectadas;

    /// <summary>
    /// Inicia o polling automático
    /// </summary>
    public void IniciarPolling()
    {
        if (_isPollingAtivo) return;
        
        _isPollingAtivo = true;
        _ultimaVerificacao = DateTime.Now;
        
        // Configura timer para executar a cada intervalo
        _pollingTimer = new Timer(
            async _ => await ExecutarVerificacaoAsync(),
            null,
            _intervaloPolling, // Primeira execução após intervalo
            _intervaloPolling  // Repetir a cada intervalo
        );
        
        System.Diagnostics.Debug.WriteLine($"[Polling] Iniciado. Intervalo: {_intervaloPolling.TotalMinutes} minutos");
    }

    /// <summary>
    /// Para o polling automático
    /// </summary>
    public void PararPolling()
    {
        _isPollingAtivo = false;
        _pollingTimer?.Dispose();
        _pollingTimer = null;
        
        System.Diagnostics.Debug.WriteLine("[Polling] Parado");
    }

    /// <summary>
    /// Executa uma verificação manual imediata
    /// </summary>
    public async Task<VerificacaoAtualizacoesDto> VerificarAtualizacoesAsync()
    {
        try
        {
            // Em produção, fazer chamada à API:
            // var response = await _httpClient.GetAsync($"/api/updates/check?since={_ultimaVerificacao:O}");
            
            // Mock: simula resposta da API
            await Task.Delay(500); // Simula latência de rede
            
            var atualizacoes = _atualizacoesMock
                .Where(a => a.DataHora > _ultimaVerificacao)
                .OrderByDescending(a => a.DataHora)
                .ToList();
            
            var resultado = new VerificacaoAtualizacoesDto
            {
                HasUpdates = atualizacoes.Any(),
                TotalAtualizacoes = atualizacoes.Count,
                UltimaVerificacao = DateTime.Now,
                Atualizacoes = atualizacoes
            };
            
            _ultimaVerificacao = DateTime.Now;
            
            return resultado;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[Polling] Erro ao verificar atualizações: {ex.Message}");
            return new VerificacaoAtualizacoesDto
            {
                HasUpdates = false,
                TotalAtualizacoes = 0,
                UltimaVerificacao = DateTime.Now
            };
        }
    }

    /// <summary>
    /// Executa verificação automática (chamada pelo timer)
    /// </summary>
    private async Task ExecutarVerificacaoAsync()
    {
        if (!_isPollingAtivo) return;
        
        try
        {
            System.Diagnostics.Debug.WriteLine($"[Polling] Verificando atualizações... (Última: {_ultimaVerificacao:HH:mm:ss})");
            
            var resultado = await VerificarAtualizacoesAsync();
            
            if (resultado.HasUpdates)
            {
                System.Diagnostics.Debug.WriteLine($"[Polling] {resultado.TotalAtualizacoes} nova(s) atualização(ões) detectada(s)!");
                
                // Dispara evento para notificar listeners
                NovasAtualizacoesDetectadas?.Invoke(this, resultado.Atualizacoes);
            }
            else
            {
                System.Diagnostics.Debug.WriteLine("[Polling] Nenhuma atualização encontrada");
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[Polling] Erro na verificação automática: {ex.Message}");
        }
    }

    /// <summary>
    /// Altera o intervalo de polling (em minutos)
    /// </summary>
    public void ConfigurarIntervalo(int minutos)
    {
        var novoIntervalo = TimeSpan.FromMinutes(minutos);
        
        // Reinicia timer com novo intervalo
        if (_isPollingAtivo)
        {
            PararPolling();
            _pollingTimer = new Timer(
                async _ => await ExecutarVerificacaoAsync(),
                null,
                novoIntervalo,
                novoIntervalo
            );
            _isPollingAtivo = true;
        }
        
        System.Diagnostics.Debug.WriteLine($"[Polling] Intervalo alterado para {minutos} minutos");
    }

    // ===== MÉTODOS MOCK PARA TESTES =====

    /// <summary>
    /// Simula uma nova atualização (MOCK para demonstração)
    /// </summary>
    public static void SimularAtualizacao(int chamadoId, string tipo, string titulo, string? tecnico = null, string? status = null, string? corPrioridade = null)
    {
        var atualizacao = new AtualizacaoDto
        {
            ChamadoId = chamadoId,
            TituloResumido = titulo,
            TipoAtualizacao = tipo,
            DataHora = DateTime.Now,
            NomeTecnico = tecnico,
            NovoStatus = status,
            CorPrioridade = corPrioridade ?? "#2A5FDF"
        };
        
        _atualizacoesMock.Add(atualizacao);
        System.Diagnostics.Debug.WriteLine($"[Polling Mock] Atualização simulada: {tipo} - {titulo}");
    }

    /// <summary>
    /// Simula atualizações de teste sem parâmetros (atalho para testes)
    /// </summary>
    public static void SimularAtualizacao()
    {
        var random = new Random();
        var chamadoId = random.Next(1, 100);
        
        SimularAtualizacao(chamadoId, "NovoComentario", $"Problema #{chamadoId}", "João Silva", null, "#F59E0B");
        SimularAtualizacao(chamadoId + 1, "MudancaStatus", $"Urgente #{chamadoId + 1}", "Maria Santos", "Em Andamento", "#DC2626");
        SimularAtualizacao(chamadoId + 2, "Fechamento", $"Resolvido #{chamadoId + 2}", "Pedro Costa", "Fechado", "#10B981");
    }

    /// <summary>
    /// Limpa atualizações mock
    /// </summary>
    public static void LimparAtualizacoesMock()
    {
        _atualizacoesMock.Clear();
        System.Diagnostics.Debug.WriteLine("[Polling Mock] Atualizações limpas");
    }
}

using SistemaChamados.Mobile.Helpers;
using SistemaChamados.Mobile.Models.DTOs;
using SistemaChamados.Mobile.Services.Api;

namespace SistemaChamados.Mobile.Services.Chamados;

public class ChamadoService : IChamadoService
{
    private readonly IApiService _api;

    public ChamadoService(IApiService api)
    {
        _api = api;
    }

    public Task<ChamadoDto?> Create(CriarChamadoRequestDto dto)
    {
        return _api.PostAsync<CriarChamadoRequestDto, ChamadoDto>("chamados", dto);
    }

    public Task<ChamadoDto?> CreateComAnaliseAutomatica(string descricaoProblema)
    {
        var request = new AnalisarChamadoRequestDto
        {
            DescricaoProblema = descricaoProblema
        };

        return _api.PostAsync<AnalisarChamadoRequestDto, ChamadoDto>("chamados/analisar", request);
    }

    public Task<IEnumerable<ChamadoDto>?> GetMeusChamados(ChamadoQueryParameters? parameters = null)
    {
        var effectiveParams = parameters?.Clone() ?? new ChamadoQueryParameters();

        var userId = Settings.UserId;
        var tipoUsuario = Settings.TipoUsuario;

        if (tipoUsuario == 1 && userId > 0 && !effectiveParams.SolicitanteId.HasValue)
        {
            effectiveParams.SolicitanteId = userId;
        }
        else if (tipoUsuario == 3 && !effectiveParams.IncluirTodos.HasValue)
        {
            effectiveParams.IncluirTodos = true;
        }

        return GetChamados(effectiveParams);
    }

    public Task<IEnumerable<ChamadoDto>?> GetChamados(ChamadoQueryParameters? parameters = null)
    {
        var endpoint = "chamados";
        var query = parameters?.ToQueryString();

        if (!string.IsNullOrWhiteSpace(query))
        {
            endpoint = $"{endpoint}?{query}";
        }

        return _api.GetAsync<IEnumerable<ChamadoDto>>(endpoint);
    }

    public Task<ChamadoDto?> GetById(int id)
    {
        return _api.GetAsync<ChamadoDto>($"chamados/{id}");
    }

    public Task<ChamadoDto?> Update(int id, AtualizarChamadoDto dto)
    {
        return _api.PutAsync<AtualizarChamadoDto, ChamadoDto>($"chamados/{id}", dto);
    }

    public Task<ChamadoDto?> Close(int id)
    {
        // ⚠️ FIX: Backend não tem endpoint /fechar
        // Usa PUT /chamados/{id} com StatusId = 5 (Fechado)
        var atualizacao = new AtualizarChamadoDto
        {
            StatusId = 5 // ID do status "Fechado" no banco
        };
        return _api.PutAsync<AtualizarChamadoDto, ChamadoDto>($"chamados/{id}", atualizacao);
    }

    public Task<ChamadoDto?> AnalisarChamadoAsync(AnalisarChamadoRequestDto request)
    {
        // ⚠️ ATENÇÃO: Backend JÁ CRIA o chamado no endpoint /analisar
        // Retorna o chamado criado (ChamadoDto), não apenas a análise
        return _api.PostAsync<AnalisarChamadoRequestDto, ChamadoDto>("chamados/analisar", request);
    }
}

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

    public Task<ChamadoDto?> Close(int id)
    {
        return _api.PostAsync<object, ChamadoDto>($"chamados/{id}/fechar", new { });
    }
}

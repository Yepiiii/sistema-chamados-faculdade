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

    public Task<IEnumerable<ChamadoDto>?> GetMeusChamados()
    {
        return _api.GetAsync<IEnumerable<ChamadoDto>>("chamados");
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

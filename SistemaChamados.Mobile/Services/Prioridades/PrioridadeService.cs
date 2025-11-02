using SistemaChamados.Mobile.Models.DTOs;
using SistemaChamados.Mobile.Services.Api;

namespace SistemaChamados.Mobile.Services.Prioridades;

public class PrioridadeService : IPrioridadeService
{
    private readonly IApiService _api;

    public PrioridadeService(IApiService api)
    {
        _api = api;
    }

    public Task<IEnumerable<PrioridadeDto>?> GetAll()
    {
        return _api.GetAsync<IEnumerable<PrioridadeDto>>("prioridades");
    }
}

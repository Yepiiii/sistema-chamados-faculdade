using SistemaChamados.Mobile.Models.DTOs;
using SistemaChamados.Mobile.Services.Api;

namespace SistemaChamados.Mobile.Services.Status;

public class StatusService : IStatusService
{
    private readonly IApiService _api;

    public StatusService(IApiService api)
    {
        _api = api;
    }

    public Task<IEnumerable<StatusDto>?> GetAll()
    {
        return _api.GetAsync<IEnumerable<StatusDto>>("status");
    }
}

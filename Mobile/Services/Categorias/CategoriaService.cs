using SistemaChamados.Mobile.Models.DTOs;
using SistemaChamados.Mobile.Services.Api;

namespace SistemaChamados.Mobile.Services.Categorias;

public class CategoriaService : ICategoriaService
{
    private readonly IApiService _api;

    public CategoriaService(IApiService api)
    {
        _api = api;
    }

    public Task<IEnumerable<CategoriaDto>?> GetAll()
    {
        return _api.GetAsync<IEnumerable<CategoriaDto>>("categorias");
    }
}

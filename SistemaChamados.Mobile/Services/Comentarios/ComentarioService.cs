using SistemaChamados.Mobile.Models.DTOs;
using SistemaChamados.Mobile.Services.Api;

namespace SistemaChamados.Mobile.Services.Comentarios;

public class ComentarioService : IComentarioService
{
    private readonly IApiService _api;

    public ComentarioService(IApiService api)
    {
        _api = api;
    }

    public Task<IEnumerable<ComentarioDto>?> GetComentarios(int chamadoId)
    {
        return _api.GetAsync<IEnumerable<ComentarioDto>>($"chamados/{chamadoId}/comentarios");
    }

    public Task<ComentarioDto?> AdicionarComentarioAsync(int chamadoId, CriarComentarioRequestDto dto)
    {
        return _api.PostAsync<CriarComentarioRequestDto, ComentarioDto>($"chamados/{chamadoId}/comentarios", dto);
    }
}

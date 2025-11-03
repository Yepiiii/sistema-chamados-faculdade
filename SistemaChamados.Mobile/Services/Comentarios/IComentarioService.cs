using SistemaChamados.Mobile.Models.DTOs;

namespace SistemaChamados.Mobile.Services.Comentarios;

public interface IComentarioService
{
    Task<IEnumerable<ComentarioDto>?> GetComentarios(int chamadoId);
    Task<ComentarioDto?> AdicionarComentarioAsync(int chamadoId, CriarComentarioRequestDto dto);
}

using SistemaChamados.Mobile.Models.DTOs;

namespace SistemaChamados.Mobile.Services.Chamados;

public interface IChamadoService
{
    Task<IEnumerable<ChamadoDto>?> GetMeusChamados();
    Task<ChamadoDto?> GetById(int id);
    Task<ChamadoDto?> Create(CriarChamadoRequestDto dto);
    Task<ChamadoDto?> Close(int id);
}

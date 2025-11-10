using SistemaChamados.Mobile.Models.DTOs;

namespace SistemaChamados.Mobile.Services.Chamados;

public interface IChamadoService
{
    Task<IEnumerable<ChamadoDto>?> GetMeusChamados(ChamadoQueryParameters? parameters = null);
    Task<IEnumerable<ChamadoDto>?> GetChamados(ChamadoQueryParameters? parameters = null);
    Task<ChamadoDto?> GetById(int id);
    Task<ChamadoDto?> Create(CriarChamadoRequestDto dto);
    Task<ChamadoDto?> CreateComAnaliseAutomatica(string descricaoProblema);
    Task<ChamadoDto?> Close(int id);
}

using SistemaChamados.Mobile.Models.DTOs;

namespace SistemaChamados.Mobile.Services.Chamados;

public interface IChamadoService
{
    Task<IEnumerable<ChamadoDto>?> GetMeusChamados(ChamadoQueryParameters? parameters = null);
    Task<IEnumerable<ChamadoDto>?> GetChamados(ChamadoQueryParameters? parameters = null);
    Task<IEnumerable<ChamadoListDto>?> GetChamadosList(ChamadoQueryParameters? parameters = null);
    Task<ChamadoDto?> GetById(int id);
    Task<ChamadoDto?> Create(CriarChamadoRequestDto dto);
    Task<ChamadoDto?> CreateComAnaliseAutomatica(string descricaoProblema);
    Task<ChamadoDto?> Update(int id, AtualizarChamadoDto dto);
    Task<ChamadoDto?> Close(int id);
    Task<ChamadoDto?> Assumir(int id);
    Task<ChamadoDto?> AnalisarChamadoAsync(AnalisarChamadoRequestDto request);
}

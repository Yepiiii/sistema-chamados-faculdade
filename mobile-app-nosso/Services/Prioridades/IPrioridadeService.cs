using SistemaChamados.Mobile.Models.DTOs;

namespace SistemaChamados.Mobile.Services.Prioridades;

public interface IPrioridadeService
{
    Task<IEnumerable<PrioridadeDto>?> GetAll();
}

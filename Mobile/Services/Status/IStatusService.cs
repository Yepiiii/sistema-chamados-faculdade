using SistemaChamados.Mobile.Models.DTOs;

namespace SistemaChamados.Mobile.Services.Status;

public interface IStatusService
{
    Task<IEnumerable<StatusDto>?> GetAll();
}

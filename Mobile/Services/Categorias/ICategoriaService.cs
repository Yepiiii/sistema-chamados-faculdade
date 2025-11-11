using SistemaChamados.Mobile.Models.DTOs;

namespace SistemaChamados.Mobile.Services.Categorias;

public interface ICategoriaService
{
    Task<IEnumerable<CategoriaDto>?> GetAll();
}

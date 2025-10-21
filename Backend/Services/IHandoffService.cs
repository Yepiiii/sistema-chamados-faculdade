namespace SistemaChamados.Services;

public interface IHandoffService
{
    Task<int?> AtribuirTecnicoAsync(int categoriaId);
}

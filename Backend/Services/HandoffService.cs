using System.Linq;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SistemaChamados.Data;

namespace SistemaChamados.Services;

public class HandoffService : IHandoffService
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<HandoffService> _logger;

    public HandoffService(ApplicationDbContext context, ILogger<HandoffService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<int?> AtribuirTecnicoAsync(int categoriaId)
    {
        var tecnicos = await _context.Usuarios
            .Where(u => u.Ativo && (u.TipoUsuario == 2 || u.TipoUsuario == 4) && u.CategoriaEspecialidadeId == categoriaId)
            .ToListAsync();

        if (tecnicos.Count == 0)
        {
            _logger.LogWarning("Nenhum tecnico encontrado para a categoria {CategoriaId}", categoriaId);
            return null;
        }

        var statusIgnorados = await _context.Status
            .Where(s => s.Nome == "Fechado" || s.Nome == "Cancelado")
            .Select(s => s.Id)
            .ToListAsync();

        var menorCarga = int.MaxValue;
        int? tecnicoSelecionado = null;

        foreach (var tecnico in tecnicos)
        {
            var carga = await _context.Chamados.CountAsync(c =>
                (c.TecnicoAtribuidoId == tecnico.Id || c.TecnicoId == tecnico.Id) &&
                !statusIgnorados.Contains(c.StatusId));

            if (carga < menorCarga)
            {
                menorCarga = carga;
                tecnicoSelecionado = tecnico.Id;
            }
        }

    _logger.LogInformation("Tecnico {TecnicoId} selecionado com carga {Carga}", tecnicoSelecionado, menorCarga);
        return tecnicoSelecionado;
    }
}

namespace SistemaChamados.Mobile.Models.DTOs;

/// <summary>
/// DTO simplificado para listagem de chamados.
/// Corresponde ao ChamadoListDto do Backend (GET /api/chamados).
/// Para detalhes completos, use ChamadoDto (GET /api/chamados/{id}).
/// </summary>
public class ChamadoListDto
{
    public int Id { get; set; }
    public string Titulo { get; set; } = string.Empty;
    public string CategoriaNome { get; set; } = string.Empty;
    public string StatusNome { get; set; } = string.Empty;
    public string PrioridadeNome { get; set; } = string.Empty;
    
    // UI Helpers
    public string StatusBadgeColor => StatusNome.ToLowerInvariant() switch
    {
        "aberto" => "#3498db",          // Azul
        "em andamento" => "#f39c12",    // Laranja
        "fechado" => "#2ecc71",         // Verde
        "resolvido" => "#2ecc71",       // Verde (alias)
        "violado" => "#e74c3c",         // Vermelho
        "aguardando resposta" => "#9b59b6", // Roxo
        _ => "#95a5a6"                  // Cinza padrão
    };
    
    public string PrioridadeBadgeColor => PrioridadeNome.ToLowerInvariant() switch
    {
        "urgente" => "#e74c3c",   // Vermelho
        "alta" => "#f39c12",      // Laranja
        "média" => "#3498db",     // Azul
        "baixa" => "#95a5a6",     // Cinza
        _ => "#95a5a6"            // Cinza padrão
    };
}

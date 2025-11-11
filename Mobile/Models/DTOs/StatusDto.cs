namespace SistemaChamados.Mobile.Models.DTOs;

public class StatusDto
{
    public int Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public string? Descricao { get; set; }
    
    // Helper para cor baseado no nome
    public string CorHexadecimal => (Nome ?? string.Empty).Trim().ToLowerInvariant() switch
    {
        "aberto" => "#2A5FDF",        // Azul
        "em andamento" => "#F59E0B",  // Laranja
        "fechado" => "#10B981",       // Verde
        "violado" => "#B91C1C",       // Vermelho escuro
        "cancelado" => "#EF4444",     // Vermelho
        _ => "#8C9AB6"                // Cinza
    };
}

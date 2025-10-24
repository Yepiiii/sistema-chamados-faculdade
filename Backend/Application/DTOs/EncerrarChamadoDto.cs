namespace SistemaChamados.Application.DTOs;

/// <summary>
/// DTO para encerrar um chamado
/// </summary>
public class EncerrarChamadoDto
{
    /// <summary>
    /// Descrição da solução aplicada (opcional)
    /// </summary>
    public string? Solucao { get; set; }
}

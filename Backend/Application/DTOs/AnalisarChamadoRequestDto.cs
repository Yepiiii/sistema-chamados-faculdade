namespace SistemaChamados.Application.DTOs;

/// <summary>
/// DTO for ticket analysis request using AI.
/// </summary>
public class AnalisarChamadoRequestDto
{
    public string DescricaoProblema { get; set; } = string.Empty;
}

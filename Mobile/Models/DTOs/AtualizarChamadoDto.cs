namespace SistemaChamados.Mobile.Models.DTOs;

/// <summary>
/// DTO para atualizar um chamado existente (status, técnico)
/// Corresponde ao backend: Application/DTOs/AtualizarChamadoDto.cs
/// </summary>
public class AtualizarChamadoDto
{
    public int StatusId { get; set; }
    public int? TecnicoId { get; set; } // Opcional
}

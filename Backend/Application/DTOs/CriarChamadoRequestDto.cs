using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace SistemaChamados.Application.DTOs;

public class CriarChamadoRequestDto : IValidatableObject
{
    [StringLength(200, ErrorMessage = "Título deve ter no máximo 200 caracteres")]
    public string? Titulo { get; set; }

    [Required(ErrorMessage = "Descrição é obrigatória")]
    [StringLength(2000, ErrorMessage = "Descrição deve ter no máximo 2000 caracteres")]
    public string Descricao { get; set; } = string.Empty;

    // Categoria e Prioridade são opcionais quando IA está habilitada
    public int? CategoriaId { get; set; }

    public int? PrioridadeId { get; set; }

    public bool? UsarAnaliseAutomatica { get; set; }

    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        var usarAnaliseAutomatica = UsarAnaliseAutomatica ?? true;

        if (!usarAnaliseAutomatica)
        {
            if (!CategoriaId.HasValue || CategoriaId.Value <= 0)
            {
                yield return new ValidationResult(
                    "CategoriaId é obrigatório quando UsarAnaliseAutomatica é false.",
                    new[] { nameof(CategoriaId) }
                );
            }

            if (!PrioridadeId.HasValue || PrioridadeId.Value <= 0)
            {
                yield return new ValidationResult(
                    "PrioridadeId é obrigatório quando UsarAnaliseAutomatica é false.",
                    new[] { nameof(PrioridadeId) }
                );
            }
        }
    }
}
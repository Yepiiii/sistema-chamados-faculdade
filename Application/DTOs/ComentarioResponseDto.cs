using System;

namespace SistemaChamados.Application.DTOs;

public class ComentarioResponseDto
{
    public int Id { get; set; }
    public int ChamadoId { get; set; }
    public string Texto { get; set; } = string.Empty;
    public DateTime DataCriacao { get; set; }
    public DateTime DataHora { get; set; }
    public int UsuarioId { get; set; }
    public string UsuarioNome { get; set; } = string.Empty;
    public UsuarioResumoDto? Usuario { get; set; }
    public bool IsInterno { get; set; }
}
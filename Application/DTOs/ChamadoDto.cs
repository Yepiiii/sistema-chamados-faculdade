using System;
using System.Collections.Generic;

namespace SistemaChamados.Application.DTOs;

public class ChamadoDto
{
    public int Id { get; set; }
    public string Titulo { get; set; } = string.Empty;
    public string Descricao { get; set; } = string.Empty;
    public DateTime DataAbertura { get; set; }
    public DateTime? DataUltimaAtualizacao { get; set; }
    public DateTime? DataFechamento { get; set; }
    public CategoriaDto? Categoria { get; set; }
    public PrioridadeDto? Prioridade { get; set; }
    public StatusDto? Status { get; set; }
    public UsuarioResumoDto? Solicitante { get; set; }
    public UsuarioResumoDto? Tecnico { get; set; }
    public int? TecnicoAtribuidoId { get; set; }
    public string? TecnicoAtribuidoNome { get; set; }
    public int? TecnicoAtribuidoNivel { get; set; }
    public string? TecnicoAtribuidoNivelDescricao { get; set; }
    public List<HistoricoItemDto>? Historico { get; set; }
    public AnaliseChamadoResponseDto? Analise { get; set; }
}

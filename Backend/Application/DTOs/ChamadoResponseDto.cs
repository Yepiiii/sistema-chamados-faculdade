using System;

namespace SistemaChamados.Application.DTOs;

public class ChamadoResponseDto
{
    public int Id { get; set; }
    public string Titulo { get; set; } = string.Empty;
    public string Descricao { get; set; } = string.Empty;
    public DateTime DataAbertura { get; set; }
    public DateTime? DataUltimaAtualizacao { get; set; }
    public DateTime? DataFechamento { get; set; }
    public CategoriaResumoDto? Categoria { get; set; }
    public PrioridadeResumoDto? Prioridade { get; set; }
    public StatusResumoDto? Status { get; set; }
    public UsuarioResumoDto? Solicitante { get; set; }
    public UsuarioResumoDto? Tecnico { get; set; }
    
    // Campos adicionais para atribuição inteligente
    public int? TecnicoAtribuidoId { get; set; }
    public string? TecnicoAtribuidoNome { get; set; }
    public int? TecnicoAtribuidoNivel { get; set; }
    public string? TecnicoAtribuidoNivelDescricao => TecnicoAtribuidoNivel switch
    {
        2 => "Nível 2 - Suporte Intermediário",
        3 => "Nível 3 - Especialista Sênior",
        _ => null
    };
    public string? CategoriaNome { get; set; }
    public string? PrioridadeNome { get; set; }
}

public class UsuarioResumoDto
{
    public int Id { get; set; }
    public string NomeCompleto { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
}

public class CategoriaResumoDto
{
    public int Id { get; set; }
    public string Nome { get; set; } = string.Empty;
}

public class PrioridadeResumoDto
{
    public int Id { get; set; }
    public string Nome { get; set; } = string.Empty;
}

public class StatusResumoDto
{
    public int Id { get; set; }
    public string Nome { get; set; } = string.Empty;
}

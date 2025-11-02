using System;

namespace SistemaChamados.Mobile.Models.Entities;

public class Chamado
{
    public int Id { get; set; }
    public string Titulo { get; set; } = string.Empty;
    public string Descricao { get; set; } = string.Empty;
    public DateTime DataCriacao { get; set; }
}

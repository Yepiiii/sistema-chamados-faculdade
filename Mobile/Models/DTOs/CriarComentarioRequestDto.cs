namespace SistemaChamados.Mobile.Models.DTOs;

public class CriarComentarioRequestDto
{
    public string Texto { get; set; } = string.Empty;
    public bool IsInterno { get; set; }
}

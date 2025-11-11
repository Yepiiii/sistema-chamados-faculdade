namespace SistemaChamados.Mobile.Models.DTOs;

public class ResetarSenhaRequestDto
{
    public string Token { get; set; } = string.Empty;
    public string NovaSenha { get; set; } = string.Empty;
}

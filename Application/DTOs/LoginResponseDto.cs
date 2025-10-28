namespace SistemaChamados.Application.DTOs;

public class LoginResponseDto
{
    public int Id { get; set; }
    public string NomeCompleto { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public int TipoUsuario { get; set; }
    public string Token { get; set; } = string.Empty;
}
using SistemaChamados.Mobile.Models.DTOs;

namespace SistemaChamados.Mobile.Services.Auth;

public interface IAuthService
{
    Task<bool> Login(string email, string senha);
    Task Logout();
    bool IsAuthenticated { get; }
    UsuarioResponseDto? CurrentUser { get; }
    void AddAuthHeaderToClient();
}

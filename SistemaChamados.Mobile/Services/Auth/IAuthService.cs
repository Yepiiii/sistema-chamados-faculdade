using SistemaChamados.Mobile.Models.DTOs;

namespace SistemaChamados.Mobile.Services.Auth;

public interface IAuthService
{
    Task<bool> Login(string email, string senha);
    Task Logout();
    bool IsAuthenticated { get; }
    void AddAuthHeaderToClient();
    Task<(bool Sucesso, string Mensagem)> SolicitarResetSenhaAsync(string email);
    Task<(bool Sucesso, string Mensagem)> ResetarSenhaAsync(string token, string novaSenha);
}

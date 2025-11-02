using SistemaChamados.Mobile.Helpers;
using SistemaChamados.Mobile.Models.DTOs;
using SistemaChamados.Mobile.Services.Api;
using System.Diagnostics;

namespace SistemaChamados.Mobile.Services.Auth;

public class AuthService : IAuthService
{
    private readonly IApiService _api;
    private LoginResponseDto? _loginResponse;

    public AuthService(IApiService api)
    {
        _api = api;
        var storedToken = Settings.Token;
        if (!string.IsNullOrEmpty(storedToken))
        {
            _api.AddAuthorizationHeader(storedToken);
            _loginResponse = new LoginResponseDto
            {
                Token = storedToken,
                Usuario = Settings.GetUser<UsuarioResponseDto>()
            };
        }
    }

    public bool IsAuthenticated => !string.IsNullOrEmpty(_loginResponse?.Token);

    public UsuarioResponseDto? CurrentUser => _loginResponse?.Usuario;

    public async Task<bool> Login(string email, string senha)
    {
        var dto = new LoginRequestDto { Email = email, Senha = senha };
        try
        {
            Debug.WriteLine($"[AuthService] Tentando login para {email}");
            var resp = await _api.PostAsync<LoginRequestDto, LoginResponseDto>("usuarios/login", dto);
            
            Debug.WriteLine($"[AuthService] Resposta recebida: {resp != null}");
            
            if (resp == null)
            {
                Debug.WriteLine("[AuthService] Resposta nula");
                return false;
            }
            
            if (string.IsNullOrEmpty(resp.Token))
            {
                Debug.WriteLine("[AuthService] Token vazio");
                return false;
            }
            
            Debug.WriteLine($"[AuthService] Token recebido: {resp.Token.Substring(0, Math.Min(20, resp.Token.Length))}...");
            Debug.WriteLine($"[AuthService] Usuario recebido: {resp.Usuario?.Email ?? "NULL"}");
            Debug.WriteLine($"[AuthService] TipoUsuario recebido: {resp.Usuario?.TipoUsuario ?? 0}");
            
            Settings.Token = resp.Token;
            Settings.SaveUser(resp.Usuario ?? new UsuarioResponseDto());
            
            // Salvar propriedades específicas do usuário para acesso rápido
            if (resp.Usuario != null)
            {
                Settings.UserId = resp.Usuario.Id;
                Settings.NomeUsuario = resp.Usuario.NomeCompleto;
                Settings.Email = resp.Usuario.Email;
                Settings.TipoUsuario = resp.Usuario.TipoUsuario;
                
                App.Log($"AuthService settings saved - UserId: {Settings.UserId}, TipoUsuario: {Settings.TipoUsuario}");
            }
            
            _loginResponse = resp;
            AddAuthHeaderToClient();
            
            Debug.WriteLine("[AuthService] Login bem-sucedido");
            return true;
        }
        catch (Exception ex)
        {
            Debug.WriteLine($"[AuthService] ERRO no login: {ex.GetType().Name} - {ex.Message}");
            Debug.WriteLine($"[AuthService] StackTrace: {ex.StackTrace}");
            throw;
        }
    }

    public async Task Logout()
    {
        Settings.Clear();
        _loginResponse = null;
        _api.ClearAuthorizationHeader();
        await Task.CompletedTask;
    }

    public void AddAuthHeaderToClient()
    {
        var token = _loginResponse?.Token;
        if (!string.IsNullOrEmpty(token))
        {
            _api.AddAuthorizationHeader(token);
        }
    }
}
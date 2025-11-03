using System;
using System.Diagnostics;
using System.Linq;
using System.Net.Http;
using Newtonsoft.Json.Linq;
using SistemaChamados.Mobile.Helpers;
using SistemaChamados.Mobile.Models.DTOs;
using SistemaChamados.Mobile.Services.Api;

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
                TipoUsuario = Settings.TipoUsuario
            };
        }
    }

    public bool IsAuthenticated => !string.IsNullOrEmpty(_loginResponse?.Token);

    public async Task<bool> Login(string email, string senha)
    {
        var dto = new LoginRequestDto { Email = email, Senha = senha };
        try
        {
            Debug.WriteLine($"[AuthService] Tentando login para {email}");
            var resp = await _api.PostAsync<LoginRequestDto, LoginResponseDto>("usuarios/login", dto);

            Debug.WriteLine($"[AuthService] Resposta recebida: {resp != null}");

            if (resp == null || string.IsNullOrEmpty(resp.Token))
            {
                Debug.WriteLine("[AuthService] Resposta inválida da API de login");
                return false;
            }

            Debug.WriteLine($"[AuthService] Token recebido: {resp.Token[..Math.Min(20, resp.Token.Length)]}...");
            Debug.WriteLine($"[AuthService] TipoUsuario recebido: {resp.TipoUsuario}");

            Settings.Token = resp.Token;
            Settings.TipoUsuario = resp.TipoUsuario;
            Settings.Email = email.Trim();
            Settings.NomeUsuario = DeriveDisplayName(email);
            Settings.UserId = TryExtractUserId(resp.Token);

            App.Log($"AuthService login - UserId: {Settings.UserId}, TipoUsuario: {Settings.TipoUsuario}");

            _loginResponse = resp;
            AddAuthHeaderToClient();

            return true;
        }
        catch (HttpRequestException ex)
        {
            Debug.WriteLine($"[AuthService] HTTP erro no login: {ex.Message}");
            throw;
        }
        catch (Exception ex)
        {
            Debug.WriteLine($"[AuthService] ERRO no login: {ex.GetType().Name} - {ex.Message}");
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

    public async Task<(bool Sucesso, string Mensagem)> SolicitarResetSenhaAsync(string email)
    {
        var request = new EsqueciSenhaRequestDto { Email = email.Trim() };
        try
        {
            var response = await _api.PostAsync<EsqueciSenhaRequestDto, ApiMessageResponse>("usuarios/esqueci-senha", request);
            var message = response?.Message ?? "Se um usuário com este e-mail existir, um link de redefinição de senha foi enviado.";
            return (true, message);
        }
        catch (HttpRequestException ex)
        {
            Debug.WriteLine($"[AuthService] Falha ao solicitar redefinição: {ex.Message}");
            return (false, ExtractHttpMessage(ex));
        }
    }

    public async Task<(bool Sucesso, string Mensagem)> ResetarSenhaAsync(string token, string novaSenha)
    {
        var request = new ResetarSenhaRequestDto { Token = token.Trim(), NovaSenha = novaSenha };
        try
        {
            var response = await _api.PostAsync<ResetarSenhaRequestDto, ApiMessageResponse>("usuarios/resetar-senha", request);
            var message = response?.Message ?? "Senha redefinida com sucesso.";
            return (true, message);
        }
        catch (HttpRequestException ex)
        {
            Debug.WriteLine($"[AuthService] Falha ao redefinir senha: {ex.Message}");
            return (false, ExtractHttpMessage(ex));
        }
    }

    private static string DeriveDisplayName(string email)
    {
        if (string.IsNullOrWhiteSpace(email))
        {
            return "Usuário";
        }

        var localPart = email.Split('@').FirstOrDefault()?.Trim();
        if (string.IsNullOrWhiteSpace(localPart))
        {
            return email;
        }

        var segments = localPart
            .Split(new[] { '.', '-', '_' }, StringSplitOptions.RemoveEmptyEntries)
            .Select(segment => char.ToUpper(segment[0]) + segment.Substring(1));

        var candidate = string.Join(" ", segments);
        return string.IsNullOrWhiteSpace(candidate) ? email : candidate;
    }

    private static int TryExtractUserId(string token)
    {
        try
        {
            var parts = token.Split('.');
            if (parts.Length < 2) return 0;

            var payload = PadBase64(parts[1]);
            var bytes = Convert.FromBase64String(payload);
            var json = System.Text.Encoding.UTF8.GetString(bytes);
            var obj = JObject.Parse(json);

            var nameId =
                obj["nameid"] ??
                obj["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"];

            return nameId != null && int.TryParse(nameId.ToString(), out var id) ? id : 0;
        }
        catch (Exception ex)
        {
            Debug.WriteLine($"[AuthService] Falha ao extrair UserId do token: {ex.Message}");
            return 0;
        }
    }

    private static string PadBase64(string payload)
    {
        var padded = payload.Replace('-', '+').Replace('_', '/');
        return padded.PadRight(padded.Length + ((4 - padded.Length % 4) % 4), '=');
    }

    private static string ExtractHttpMessage(HttpRequestException ex) =>
        string.IsNullOrWhiteSpace(ex.Message) ? "Falha na comunicação com o servidor." : ex.Message;
}
using Newtonsoft.Json;
using Microsoft.Maui.Storage;

namespace SistemaChamados.Mobile.Helpers;

public static class Settings
{
    private const string TokenKey = "auth_token";
    private const string UserKey = "auth_user";
    private const string AccessTokenKey = "access_token";
    private const string RefreshTokenKey = "refresh_token";
    private const string NomeUsuarioKey = "nome_usuario";
    private const string EmailUsuarioKey = "email_usuario";
    private const string UserIdKey = "user_id";
    private const string TipoUsuarioKey = "tipo_usuario";

    public static string? Token
    {
        get => Preferences.Get(TokenKey, null);
        set
        {
            if (value == null) Preferences.Remove(TokenKey);
            else Preferences.Set(TokenKey, value);
        }
    }

    public static string AccessToken
    {
        get => Preferences.Get(AccessTokenKey, string.Empty);
        set => Preferences.Set(AccessTokenKey, value);
    }

    public static string RefreshToken
    {
        get => Preferences.Get(RefreshTokenKey, string.Empty);
        set => Preferences.Set(RefreshTokenKey, value);
    }

    public static string NomeUsuario
    {
        get => Preferences.Get(NomeUsuarioKey, string.Empty);
        set => Preferences.Set(NomeUsuarioKey, value);
    }

    public static string Email
    {
        get => Preferences.Get(EmailUsuarioKey, string.Empty);
        set => Preferences.Set(EmailUsuarioKey, value);
    }
    
    public static string EmailUsuario
    {
        get => Preferences.Get(EmailUsuarioKey, string.Empty);
        set => Preferences.Set(EmailUsuarioKey, value);
    }

    public static int UserId
    {
        get => Preferences.Get(UserIdKey, 0);
        set => Preferences.Set(UserIdKey, value);
    }

    public static int TipoUsuario
    {
        get => Preferences.Get(TipoUsuarioKey, 0);
        set => Preferences.Set(TipoUsuarioKey, value);
    }

    public static void SaveUser(object user)
    {
        var json = JsonConvert.SerializeObject(user);
        Preferences.Set(UserKey, json);
    }

    public static T? GetUser<T>() where T : class
    {
        var json = Preferences.Get(UserKey, null);
        if (string.IsNullOrEmpty(json)) return null;
        return JsonConvert.DeserializeObject<T>(json);
    }

    public static void Clear()
    {
        Preferences.Remove(TokenKey);
        Preferences.Remove(UserKey);
        Preferences.Remove(AccessTokenKey);
        Preferences.Remove(RefreshTokenKey);
        Preferences.Remove(NomeUsuarioKey);
        Preferences.Remove(EmailUsuarioKey);
        Preferences.Remove(UserIdKey);
        Preferences.Remove(TipoUsuarioKey);
    }
}

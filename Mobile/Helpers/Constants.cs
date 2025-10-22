namespace SistemaChamados.Mobile.Helpers;

public static class Constants
{
    // Para Windows Desktop/Emulador iOS
    public static string BaseUrlWindows => "http://localhost:5246/api/";
    
    // Para Emulador Android (10.0.2.2 = localhost do host)
    public static string BaseUrlAndroidEmulator => "http://10.0.2.2:5246/api/";
    
    // Para Dispositivo Físico - IP da máquina na rede local
    // IMPORTANTE: Execute .\Scripts\ConfigurarIP.ps1 antes de gerar o APK
    // O script detectará automaticamente seu IP local
    public static string BaseUrlPhysicalDevice => "http://SEU_IP_LOCAL:5246/api/";
    
    // BaseUrl dinâmica baseada na plataforma
    public static string BaseUrl
    {
        get
        {
#if ANDROID
            // Usando EMULADOR Android (10.0.2.2 aponta para localhost do host)
            return BaseUrlAndroidEmulator;
#elif WINDOWS
            return BaseUrlWindows;
#elif IOS || MACCATALYST
            return BaseUrlWindows;
#else
            return BaseUrlWindows;
#endif
        }
    }
}


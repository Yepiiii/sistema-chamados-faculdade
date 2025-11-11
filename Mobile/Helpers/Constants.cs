namespace SistemaChamados.Mobile.Helpers;

public static class Constants
{
    // Para Windows Desktop/Emulador iOS
    public static string BaseUrlWindows => "http://localhost:5246/api/";
    
    // Para Emulador Android (10.0.2.2 = localhost do host)
    public static string BaseUrlAndroidEmulator => "http://10.0.2.2:5246/api/";
    
    // Para Dispositivo Fisico - IP da maquina na rede local
    // IP Detectado: 192.168.1.6 (Atualizado para dispositivo físico)
    // Ultima atualizacao: 10/11/2025
    public static string BaseUrlPhysicalDevice => "http://192.168.1.6:5246/api/";
    
    // BaseUrl dinamica baseada na plataforma
    public static string BaseUrl
    {
        get
        {
#if ANDROID
            // DISPOSITIVO FÍSICO ANDROID - Usando IP da rede local
            return BaseUrlPhysicalDevice;
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

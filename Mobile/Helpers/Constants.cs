namespace SistemaChamados.Mobile.Helpers;

public static class Constants
{
    // Para Windows Desktop/Emulador iOS
    public static string BaseUrlWindows => "http://localhost:5246/api/";
    
    // Para Emulador Android (10.0.2.2 = localhost do host)
    public static string BaseUrlAndroidEmulator => "http://10.0.2.2:5246/api/";
    
    // Para Dispositivo Físico - IP da máquina na rede local
    // IP atual detectado: 192.168.0.18
    public static string BaseUrlPhysicalDevice => "http://192.168.0.18:5246/api/";
    
    // BaseUrl dinâmica baseada na plataforma
    public static string BaseUrl
    {
        get
        {
#if ANDROID
            // Usando dispositivo físico (celular real)
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

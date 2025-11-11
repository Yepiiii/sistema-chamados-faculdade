using System;
using Microsoft.Maui;

namespace SistemaChamados.Mobile.Helpers;

public static class ServiceHelper
{
    public static IServiceProvider Current
    {
        get
        {
            var provider = App.Services ?? IPlatformApplication.Current?.Services;
            if (provider == null)
            {
                App.Log("ServiceHelper.Current: provider null");
                throw new InvalidOperationException("Service provider not initialized.");
            }

            return provider;
        }
    }

    public static T GetService<T>() where T : notnull =>
        Current.GetService<T>()
        ?? throw new InvalidOperationException($"Service '{typeof(T)}' not registered.");
}

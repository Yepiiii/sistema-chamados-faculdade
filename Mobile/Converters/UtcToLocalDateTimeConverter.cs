using System;
using System.Globalization;
using Microsoft.Maui.Controls;

namespace SistemaChamados.Mobile.Converters;

/// <summary>
/// Converte DateTime UTC para horário local do dispositivo.
/// A API retorna datas em UTC, mas precisamos exibir no fuso horário do usuário.
/// </summary>
public class UtcToLocalDateTimeConverter : IValueConverter
{
    public object? Convert(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        if (value is DateTime dateTime)
        {
            // Se a data já tem Kind definido como UTC, converte direto
            if (dateTime.Kind == DateTimeKind.Utc)
            {
                return dateTime.ToLocalTime();
            }
            
            // Se a data não tem Kind definido (Unspecified), assume que é UTC
            // pois a API sempre retorna UTC
            if (dateTime.Kind == DateTimeKind.Unspecified)
            {
                return DateTime.SpecifyKind(dateTime, DateTimeKind.Utc).ToLocalTime();
            }
            
            // Se já é Local, retorna como está
            return dateTime;
        }
        
        return value;
    }

    public object? ConvertBack(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        if (value is DateTime dateTime && dateTime.Kind == DateTimeKind.Local)
        {
            // Converte de volta para UTC ao enviar para a API
            return dateTime.ToUniversalTime();
        }
        
        return value;
    }
}

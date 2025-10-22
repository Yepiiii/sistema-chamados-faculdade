using System;
using System.Globalization;
using Microsoft.Maui.Controls;

namespace SistemaChamados.Mobile.Converters;

/// <summary>
/// Converte DateTime UTC para horário local
/// </summary>
public class UtcToLocalConverter : IValueConverter
{
    public object? Convert(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        if (value is DateTime dateTime)
        {
            // Se a data já está em Local, retorna como está
            if (dateTime.Kind == DateTimeKind.Local)
                return dateTime;

            // Se está em UTC, converte para Local
            if (dateTime.Kind == DateTimeKind.Utc)
                return dateTime.ToLocalTime();

            // Se não tem Kind especificado, assume UTC e converte
            return DateTime.SpecifyKind(dateTime, DateTimeKind.Utc).ToLocalTime();
        }

        return value;
    }

    public object? ConvertBack(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        if (value is DateTime dateTime)
        {
            // Converte Local para UTC
            if (dateTime.Kind == DateTimeKind.Local)
                return dateTime.ToUniversalTime();

            if (dateTime.Kind == DateTimeKind.Utc)
                return dateTime;

            return DateTime.SpecifyKind(dateTime, DateTimeKind.Local).ToUniversalTime();
        }

        return value;
    }
}

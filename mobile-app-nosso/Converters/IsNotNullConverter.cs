using System;
using System.Globalization;
using Microsoft.Maui.Controls;

namespace SistemaChamados.Mobile.Converters;

/// <summary>
/// Verifica se um valor não é nulo
/// Útil para controlar visibilidade de elementos baseado em valores opcionais
/// </summary>
public class IsNotNullConverter : IValueConverter
{
    public object Convert(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        return value != null;
    }

    public object? ConvertBack(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        throw new NotImplementedException("IsNotNullConverter não suporta ConvertBack");
    }
}

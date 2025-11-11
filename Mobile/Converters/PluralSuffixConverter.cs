using System.Globalization;

namespace SistemaChamados.Mobile.Converters;

/// <summary>
/// Converte número para sufixo plural ("s" se maior que 1, string vazia caso contrário)
/// </summary>
public class PluralSuffixConverter : IValueConverter
{
    public object Convert(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        if (value is int number)
        {
            return number > 1 ? "s" : "";
        }
        return "";
    }

    public object ConvertBack(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        throw new NotImplementedException();
    }
}

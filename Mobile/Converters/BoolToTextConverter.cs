using System.Globalization;

namespace SistemaChamados.Mobile.Converters;

/// <summary>
/// Converte booleano para texto de botão de filtro
/// </summary>
public class BoolToTextConverter : IValueConverter
{
    public object Convert(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        if (value is bool isExpanded)
        {
            return isExpanded ? "🔼 Ocultar Filtros" : "🔽 Filtros Avançados";
        }
        return "🔽 Filtros Avançados";
    }

    public object ConvertBack(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        throw new NotImplementedException();
    }
}

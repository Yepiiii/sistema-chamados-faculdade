using FluentAssertions;
using SistemaChamados.Core.Domain.Services;
using SistemaChamados.Core.Entities;
using Xunit;

namespace Backend.Tests.Core.Domain.Services;

/// <summary>
/// Unit tests for SlaCalculationService.
/// These are PURE unit tests with NO database, HTTP, or external dependencies.
/// Tests validate business logic in isolation.
/// </summary>
public class SlaCalculationServiceTests
{
    private readonly SlaCalculationService _slaService;

    public SlaCalculationServiceTests()
    {
        _slaService = new SlaCalculationService();
    }

    #region CalculateSlaExpiration Tests

    [Fact]
    public void CalculateSlaExpiration_WithNullPriority_ShouldThrowArgumentNullException()
    {
        // Act
        Action act = () => _slaService.CalculateSlaExpiration(null!);

        // Assert
        act.Should().Throw<ArgumentNullException>()
            .WithMessage("*Prioridade não pode ser nula*");
    }

    [Fact]
    public void CalculateSlaExpiration_WithTempoRespostaHoras_ShouldAddHours()
    {
        // Arrange
        var openingDate = new DateTime(2025, 12, 11, 10, 0, 0, DateTimeKind.Utc);
        var prioridade = new Prioridade
        {
            Id = 4,
            Nome = "Crítica",
            Nivel = 4,
            TempoRespostaHoras = 4,
            Ativo = true
        };

        // Act
        var result = _slaService.CalculateSlaExpiration(prioridade, openingDate);

        // Assert
        result.Should().NotBeNull();
        result.Should().Be(new DateTime(2025, 12, 11, 14, 0, 0, DateTimeKind.Utc));
    }

    [Fact]
    public void CalculateSlaExpiration_HighPriority_ShouldAdd1BusinessDay()
    {
        // Arrange - Friday morning
        var openingDate = new DateTime(2025, 12, 12, 9, 0, 0, DateTimeKind.Utc); // Friday
        var prioridade = new Prioridade
        {
            Id = 3,
            Nome = "Alta",
            Nivel = 3,
            TempoRespostaHoras = 0,
            Ativo = true
        };

        // Act
        var result = _slaService.CalculateSlaExpiration(prioridade, openingDate);

        // Assert - Should be end of Monday (skip weekend)
        result.Should().NotBeNull();
        result.Value.Date.Should().Be(new DateTime(2025, 12, 15)); // Monday EOD
        result.Value.Hour.Should().Be(23);
        result.Value.Minute.Should().Be(59);
        result.Value.Second.Should().Be(59);
    }

    [Fact]
    public void CalculateSlaExpiration_MediumPriority_ShouldAdd3BusinessDays()
    {
        // Arrange - Monday
        var openingDate = new DateTime(2025, 12, 15, 10, 0, 0, DateTimeKind.Utc); // Monday
        var prioridade = new Prioridade
        {
            Id = 2,
            Nome = "Média",
            Nivel = 2,
            TempoRespostaHoras = 0,
            Ativo = true
        };

        // Act
        var result = _slaService.CalculateSlaExpiration(prioridade, openingDate);

        // Assert - Monday + 3 business days = Thursday EOD
        result.Should().NotBeNull();
        result.Value.Date.Should().Be(new DateTime(2025, 12, 18)); // Thursday EOD
    }

    [Fact]
    public void CalculateSlaExpiration_LowPriority_ShouldAdd5BusinessDays()
    {
        // Arrange - Monday
        var openingDate = new DateTime(2025, 12, 15, 10, 0, 0, DateTimeKind.Utc); // Monday
        var prioridade = new Prioridade
        {
            Id = 1,
            Nome = "Baixa",
            Nivel = 1,
            TempoRespostaHoras = 0,
            Ativo = true
        };

        // Act
        var result = _slaService.CalculateSlaExpiration(prioridade, openingDate);

        // Assert - Monday + 5 business days = Next Monday EOD
        result.Should().NotBeNull();
        result.Value.Date.Should().Be(new DateTime(2025, 12, 22)); // Monday EOD (next week)
    }

    [Fact]
    public void CalculateSlaExpiration_UnknownPriorityLevel_ShouldReturnNull()
    {
        // Arrange
        var openingDate = new DateTime(2025, 12, 11, 10, 0, 0, DateTimeKind.Utc);
        var prioridade = new Prioridade
        {
            Id = 99,
            Nome = "Desconhecida",
            Nivel = 99, // Invalid level
            TempoRespostaHoras = 0,
            Ativo = true
        };

        // Act
        var result = _slaService.CalculateSlaExpiration(prioridade, openingDate);

        // Assert
        result.Should().BeNull();
    }

    #endregion

    #region AddBusinessDays Tests

    [Fact]
    public void AddBusinessDays_WithZeroDays_ShouldReturnSameDate()
    {
        // Arrange
        var startDate = new DateTime(2025, 12, 11);

        // Act
        var result = _slaService.AddBusinessDays(startDate, 0);

        // Assert
        result.Should().Be(startDate);
    }

    [Fact]
    public void AddBusinessDays_WithNegativeDays_ShouldThrowArgumentException()
    {
        // Arrange
        var startDate = new DateTime(2025, 12, 11);

        // Act
        Action act = () => _slaService.AddBusinessDays(startDate, -5);

        // Assert
        act.Should().Throw<ArgumentException>()
            .WithMessage("*Business days cannot be negative*");
    }

    [Fact]
    public void AddBusinessDays_FromFriday_ShouldSkipWeekend()
    {
        // Arrange - Friday
        var startDate = new DateTime(2025, 12, 12); // Friday

        // Act - Add 1 business day
        var result = _slaService.AddBusinessDays(startDate, 1);

        // Assert - Should be Monday
        result.Should().Be(new DateTime(2025, 12, 15)); // Monday
        result.DayOfWeek.Should().Be(DayOfWeek.Monday);
    }

    [Fact]
    public void AddBusinessDays_FromFriday_Add3Days_ShouldSkipWeekend()
    {
        // Arrange - Friday
        var startDate = new DateTime(2025, 12, 12); // Friday

        // Act - Add 3 business days
        var result = _slaService.AddBusinessDays(startDate, 3);

        // Assert - Should be Wednesday (Mon, Tue, Wed)
        result.Should().Be(new DateTime(2025, 12, 17)); // Wednesday
        result.DayOfWeek.Should().Be(DayOfWeek.Wednesday);
    }

    [Fact]
    public void AddBusinessDays_FromSaturday_ShouldNotCountWeekend()
    {
        // Arrange - Saturday
        var startDate = new DateTime(2025, 12, 13); // Saturday

        // Act - Add 1 business day
        var result = _slaService.AddBusinessDays(startDate, 1);

        // Assert - Should be Monday (skip Sat, Sun)
        result.Should().Be(new DateTime(2025, 12, 15)); // Monday
    }

    #endregion

    #region IsBusinessDay Tests

    [Theory]
    [InlineData("2025-12-15", true)]  // Monday
    [InlineData("2025-12-16", true)]  // Tuesday
    [InlineData("2025-12-17", true)]  // Wednesday
    [InlineData("2025-12-18", true)]  // Thursday
    [InlineData("2025-12-19", true)]  // Friday
    [InlineData("2025-12-13", false)] // Saturday
    [InlineData("2025-12-14", false)] // Sunday
    public void IsBusinessDay_ShouldReturnCorrectResult(string dateStr, bool expected)
    {
        // Arrange
        var date = DateTime.Parse(dateStr);

        // Act
        var result = _slaService.IsBusinessDay(date);

        // Assert
        result.Should().Be(expected);
    }

    #endregion

    #region IsSlaExpired Tests

    [Fact]
    public void IsSlaExpired_WithNullSla_ShouldReturnFalse()
    {
        // Act
        var result = _slaService.IsSlaExpired(null);

        // Assert
        result.Should().BeFalse();
    }

    [Fact]
    public void IsSlaExpired_WhenCurrentDateBeforeSla_ShouldReturnFalse()
    {
        // Arrange
        var slaExpiration = new DateTime(2025, 12, 15, 23, 59, 59);
        var currentDate = new DateTime(2025, 12, 14, 10, 0, 0);

        // Act
        var result = _slaService.IsSlaExpired(slaExpiration, currentDate);

        // Assert
        result.Should().BeFalse();
    }

    [Fact]
    public void IsSlaExpired_WhenCurrentDateAfterSla_ShouldReturnTrue()
    {
        // Arrange
        var slaExpiration = new DateTime(2025, 12, 15, 23, 59, 59);
        var currentDate = new DateTime(2025, 12, 16, 0, 0, 1);

        // Act
        var result = _slaService.IsSlaExpired(slaExpiration, currentDate);

        // Assert
        result.Should().BeTrue();
    }

    #endregion

    #region CalculateRemainingTime Tests

    [Fact]
    public void CalculateRemainingTime_WithNullSla_ShouldReturnNull()
    {
        // Act
        var result = _slaService.CalculateRemainingTime(null);

        // Assert
        result.Should().BeNull();
    }

    [Fact]
    public void CalculateRemainingTime_WhenTimeRemaining_ShouldReturnCorrectTimeSpan()
    {
        // Arrange
        var slaExpiration = new DateTime(2025, 12, 15, 23, 59, 59);
        var currentDate = new DateTime(2025, 12, 15, 20, 0, 0);

        // Act
        var result = _slaService.CalculateRemainingTime(slaExpiration, currentDate);

        // Assert
        result.Should().NotBeNull();
        result.Value.Hours.Should().Be(3);
        result.Value.Minutes.Should().Be(59);
    }

    [Fact]
    public void CalculateRemainingTime_WhenExpired_ShouldReturnZero()
    {
        // Arrange
        var slaExpiration = new DateTime(2025, 12, 15, 23, 59, 59);
        var currentDate = new DateTime(2025, 12, 16, 10, 0, 0);

        // Act
        var result = _slaService.CalculateRemainingTime(slaExpiration, currentDate);

        // Assert
        result.Should().Be(TimeSpan.Zero);
    }

    #endregion

    #region CalculateBusinessDaysBetween Tests

    [Fact]
    public void CalculateBusinessDaysBetween_SameDay_ShouldReturn1IfBusinessDay()
    {
        // Arrange - Monday
        var startDate = new DateTime(2025, 12, 15); // Monday
        var endDate = new DateTime(2025, 12, 15);   // Same day

        // Act
        var result = _slaService.CalculateBusinessDaysBetween(startDate, endDate);

        // Assert
        result.Should().Be(1);
    }

    [Fact]
    public void CalculateBusinessDaysBetween_MondayToFriday_ShouldReturn5()
    {
        // Arrange
        var startDate = new DateTime(2025, 12, 15); // Monday
        var endDate = new DateTime(2025, 12, 19);   // Friday

        // Act
        var result = _slaService.CalculateBusinessDaysBetween(startDate, endDate);

        // Assert
        result.Should().Be(5);
    }

    [Fact]
    public void CalculateBusinessDaysBetween_FridayToMonday_ShouldReturn3()
    {
        // Arrange
        var startDate = new DateTime(2025, 12, 12); // Friday
        var endDate = new DateTime(2025, 12, 15);   // Monday

        // Act
        var result = _slaService.CalculateBusinessDaysBetween(startDate, endDate);

        // Assert
        result.Should().Be(2); // Friday, Monday (skip Sat, Sun)
    }

    [Fact]
    public void CalculateBusinessDaysBetween_EndDateBeforeStart_ShouldThrowArgumentException()
    {
        // Arrange
        var startDate = new DateTime(2025, 12, 15);
        var endDate = new DateTime(2025, 12, 10);

        // Act
        Action act = () => _slaService.CalculateBusinessDaysBetween(startDate, endDate);

        // Assert
        act.Should().Throw<ArgumentException>()
            .WithMessage("*End date must be greater than start date*");
    }

    #endregion
}

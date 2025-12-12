using SistemaChamados.Core.Shared.Extensions;
using Xunit;

namespace Backend.Tests.Core.Shared.Extensions;

/// <summary>
/// Testes unitários para StringValidationExtensions (Guard Clauses).
/// </summary>
public class StringValidationExtensionsTests
{
    #region RequiredString Tests

    [Fact]
    public void RequiredString_WithValidString_ReturnsString()
    {
        // Arrange
        var value = "Valid String";

        // Act
        var result = value.RequiredString("testParam");

        // Assert
        Assert.Equal(value, result);
    }

    [Fact]
    public void RequiredString_WithNull_ThrowsArgumentException()
    {
        // Arrange
        string? value = null;

        // Act & Assert
        var exception = Assert.Throws<ArgumentException>(() => value.RequiredString("testParam"));
        Assert.Contains("testParam", exception.Message);
        Assert.Contains("não pode ser nulo", exception.Message);
    }

    [Fact]
    public void RequiredString_WithEmptyString_ThrowsArgumentException()
    {
        // Arrange
        var value = string.Empty;

        // Act & Assert
        var exception = Assert.Throws<ArgumentException>(() => value.RequiredString("testParam"));
        Assert.Contains("testParam", exception.Message);
    }

    [Fact]
    public void RequiredString_WithWhitespace_ThrowsArgumentException()
    {
        // Arrange
        var value = "   ";

        // Act & Assert
        var exception = Assert.Throws<ArgumentException>(() => value.RequiredString("testParam"));
        Assert.Contains("testParam", exception.Message);
    }

    #endregion

    #region ValidEmail Tests

    [Theory]
    [InlineData("user@example.com")]
    [InlineData("test.user@domain.co.uk")]
    [InlineData("admin@localhost.localdomain")]
    public void ValidEmail_WithValidEmails_ReturnsEmail(string email)
    {
        // Act
        var result = email.ValidEmail("email");

        // Assert
        Assert.Equal(email, result);
    }

    [Theory]
    [InlineData("invalid")]
    [InlineData("@example.com")]
    [InlineData("user@")]
    [InlineData("user @example.com")]
    [InlineData("user@.com")]
    public void ValidEmail_WithInvalidEmails_ThrowsArgumentException(string invalidEmail)
    {
        // Act & Assert
        var exception = Assert.Throws<ArgumentException>(() => invalidEmail.ValidEmail("email"));
        Assert.Contains("email", exception.Message);
        Assert.Contains("email válido", exception.Message);
    }

    [Fact]
    public void ValidEmail_WithNull_ThrowsArgumentException()
    {
        // Arrange
        string? email = null;

        // Act & Assert
        Assert.Throws<ArgumentException>(() => email.ValidEmail("email"));
    }

    #endregion

    #region MaxLength Tests

    [Fact]
    public void MaxLength_WithinLimit_ReturnsString()
    {
        // Arrange
        var value = "Test";

        // Act
        var result = value.MaxLength(10, "testParam");

        // Assert
        Assert.Equal(value, result);
    }

    [Fact]
    public void MaxLength_AtLimit_ReturnsString()
    {
        // Arrange
        var value = "1234567890";

        // Act
        var result = value.MaxLength(10, "testParam");

        // Assert
        Assert.Equal(value, result);
    }

    [Fact]
    public void MaxLength_ExceedsLimit_ThrowsArgumentException()
    {
        // Arrange
        var value = "12345678901";

        // Act & Assert
        var exception = Assert.Throws<ArgumentException>(() => value.MaxLength(10, "testParam"));
        Assert.Contains("testParam", exception.Message);
        Assert.Contains("10 caracteres", exception.Message);
    }

    #endregion

    #region MinLength Tests

    [Fact]
    public void MinLength_AboveMinimum_ReturnsString()
    {
        // Arrange
        var value = "LongEnough";

        // Act
        var result = value.MinLength(5, "testParam");

        // Assert
        Assert.Equal(value, result);
    }

    [Fact]
    public void MinLength_AtMinimum_ReturnsString()
    {
        // Arrange
        var value = "12345";

        // Act
        var result = value.MinLength(5, "testParam");

        // Assert
        Assert.Equal(value, result);
    }

    [Fact]
    public void MinLength_BelowMinimum_ThrowsArgumentException()
    {
        // Arrange
        var value = "1234";

        // Act & Assert
        var exception = Assert.Throws<ArgumentException>(() => value.MinLength(5, "testParam"));
        Assert.Contains("testParam", exception.Message);
        Assert.Contains("pelo menos 5 caracteres", exception.Message);
    }

    #endregion

    #region LengthBetween Tests

    [Fact]
    public void LengthBetween_WithinRange_ReturnsString()
    {
        // Arrange
        var value = "Valid";

        // Act
        var result = value.LengthBetween(3, 10, "testParam");

        // Assert
        Assert.Equal(value, result);
    }

    [Fact]
    public void LengthBetween_AtMinimum_ReturnsString()
    {
        // Arrange
        var value = "123";

        // Act
        var result = value.LengthBetween(3, 10, "testParam");

        // Assert
        Assert.Equal(value, result);
    }

    [Fact]
    public void LengthBetween_AtMaximum_ReturnsString()
    {
        // Arrange
        var value = "1234567890";

        // Act
        var result = value.LengthBetween(3, 10, "testParam");

        // Assert
        Assert.Equal(value, result);
    }

    [Fact]
    public void LengthBetween_BelowMinimum_ThrowsArgumentException()
    {
        // Arrange
        var value = "12";

        // Act & Assert
        var exception = Assert.Throws<ArgumentException>(() => value.LengthBetween(3, 10, "testParam"));
        Assert.Contains("testParam", exception.Message);
        Assert.Contains("entre 3 e 10 caracteres", exception.Message);
    }

    [Fact]
    public void LengthBetween_AboveMaximum_ThrowsArgumentException()
    {
        // Arrange
        var value = "12345678901";

        // Act & Assert
        var exception = Assert.Throws<ArgumentException>(() => value.LengthBetween(3, 10, "testParam"));
        Assert.Contains("testParam", exception.Message);
        Assert.Contains("entre 3 e 10 caracteres", exception.Message);
    }

    #endregion

    #region Composite Methods Tests

    [Fact]
    public void RequiredWithMaxLength_ValidString_ReturnsString()
    {
        // Arrange
        var value = "Valid";

        // Act
        var result = value.RequiredWithMaxLength(10, "testParam");

        // Assert
        Assert.Equal(value, result);
    }

    [Fact]
    public void RequiredWithMaxLength_NullString_ThrowsArgumentException()
    {
        // Arrange
        string? value = null;

        // Act & Assert
        Assert.Throws<ArgumentException>(() => value.RequiredWithMaxLength(10, "testParam"));
    }

    [Fact]
    public void RequiredWithMaxLength_TooLongString_ThrowsArgumentException()
    {
        // Arrange
        var value = "12345678901";

        // Act & Assert
        var exception = Assert.Throws<ArgumentException>(() => value.RequiredWithMaxLength(10, "testParam"));
        Assert.Contains("10 caracteres", exception.Message);
    }

    [Fact]
    public void RequiredWithLengthBetween_ValidString_ReturnsString()
    {
        // Arrange
        var value = "Valid";

        // Act
        var result = value.RequiredWithLengthBetween(3, 10, "testParam");

        // Assert
        Assert.Equal(value, result);
    }

    [Fact]
    public void RequiredWithLengthBetween_NullString_ThrowsArgumentException()
    {
        // Arrange
        string? value = null;

        // Act & Assert
        Assert.Throws<ArgumentException>(() => value.RequiredWithLengthBetween(3, 10, "testParam"));
    }

    #endregion

    #region Chaining Tests

    [Fact]
    public void CanChainMultipleValidations()
    {
        // Arrange
        var value = "Valid";

        // Act
        var result = value
            .RequiredString("testParam")
            .MinLength(3, "testParam")
            .MaxLength(10, "testParam");

        // Assert
        Assert.Equal(value, result);
    }

    #endregion
}

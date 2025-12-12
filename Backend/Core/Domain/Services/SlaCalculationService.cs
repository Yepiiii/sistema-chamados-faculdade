using SistemaChamados.Core.Entities;

namespace SistemaChamados.Core.Domain.Services;

/// <summary>
/// Domain Service for calculating SLA (Service Level Agreement) expiration dates.
/// This is a PURE domain service with NO dependencies on infrastructure (DB, HTTP, etc).
/// It contains only business logic related to SLA calculations.
/// </summary>
public class SlaCalculationService
{
    /// <summary>
    /// Calculates SLA expiration date based on priority level.
    /// Business rules:
    /// - Level 4 (Critical): 4 hours
    /// - Level 3 (High): 1 business day
    /// - Level 2 (Medium): 3 business days
    /// - Level 1 (Low): 5 business days
    /// - Unknown/Invalid: No SLA (returns null)
    /// </summary>
    /// <param name="prioridade">The priority entity containing level and response time</param>
    /// <param name="openingDate">The date when the ticket was opened (defaults to UTC now)</param>
    /// <returns>SLA expiration DateTime or null if no SLA applies</returns>
    public DateTime? CalculateSlaExpiration(Prioridade prioridade, DateTime? openingDate = null)
    {
        if (prioridade == null)
        {
            throw new ArgumentNullException(nameof(prioridade), "Prioridade não pode ser nula");
        }

        var startDate = openingDate ?? DateTime.UtcNow;

        // Strategy 1: Use TempoRespostaHoras if available (hour-based SLA)
        if (prioridade.TempoRespostaHoras > 0)
        {
            return startDate.AddHours(prioridade.TempoRespostaHoras);
        }

        // Strategy 2: Use Nivel for business-day-based SLA
        int businessDaysToAdd = prioridade.Nivel switch
        {
            4 => 0,  // Critical: 4 hours (handled above via TempoRespostaHoras)
            3 => 1,  // High priority: 1 business day
            2 => 3,  // Medium priority: 3 business days
            1 => 5,  // Low priority: 5 business days
            _ => 0   // Unknown priority, no SLA
        };

        if (businessDaysToAdd == 0)
        {
            return null;
        }

        var expirationDate = AddBusinessDays(startDate, businessDaysToAdd);
        
        // Return end of business day (23:59:59)
        return expirationDate.Date.AddDays(1).AddTicks(-1);
    }

    /// <summary>
    /// Calculates if a ticket's SLA is expired.
    /// </summary>
    /// <param name="slaExpiration">The SLA expiration date</param>
    /// <param name="currentDate">Current date to compare (defaults to UTC now)</param>
    /// <returns>True if SLA is expired, false otherwise</returns>
    public bool IsSlaExpired(DateTime? slaExpiration, DateTime? currentDate = null)
    {
        if (slaExpiration == null)
        {
            return false; // No SLA defined, so it cannot be expired
        }

        var now = currentDate ?? DateTime.UtcNow;
        return now > slaExpiration.Value;
    }

    /// <summary>
    /// Calculates remaining time until SLA expiration.
    /// </summary>
    /// <param name="slaExpiration">The SLA expiration date</param>
    /// <param name="currentDate">Current date to compare (defaults to UTC now)</param>
    /// <returns>TimeSpan representing remaining time, or null if no SLA</returns>
    public TimeSpan? CalculateRemainingTime(DateTime? slaExpiration, DateTime? currentDate = null)
    {
        if (slaExpiration == null)
        {
            return null;
        }

        var now = currentDate ?? DateTime.UtcNow;
        var remaining = slaExpiration.Value - now;
        
        return remaining.TotalSeconds > 0 ? remaining : TimeSpan.Zero;
    }

    /// <summary>
    /// Adds business days (Monday-Friday) to a date, skipping weekends.
    /// This is a pure function with no side effects.
    /// </summary>
    /// <param name="startDate">The starting date</param>
    /// <param name="businessDays">Number of business days to add</param>
    /// <returns>The calculated date after adding business days</returns>
    /// <example>
    /// AddBusinessDays(new DateTime(2025, 12, 13), 3) // Friday + 3 days = Wednesday
    /// </example>
    public DateTime AddBusinessDays(DateTime startDate, int businessDays)
    {
        if (businessDays < 0)
        {
            throw new ArgumentException("Business days cannot be negative", nameof(businessDays));
        }

        if (businessDays == 0)
        {
            return startDate;
        }

        DateTime result = startDate;
        int daysAdded = 0;

        while (daysAdded < businessDays)
        {
            result = result.AddDays(1);
            
            // Only count weekdays (skip Saturday and Sunday)
            if (result.DayOfWeek != DayOfWeek.Saturday && 
                result.DayOfWeek != DayOfWeek.Sunday)
            {
                daysAdded++;
            }
        }

        return result;
    }

    /// <summary>
    /// Checks if a given date is a business day (Monday-Friday).
    /// </summary>
    /// <param name="date">The date to check</param>
    /// <returns>True if it's a business day, false if weekend</returns>
    public bool IsBusinessDay(DateTime date)
    {
        return date.DayOfWeek != DayOfWeek.Saturday && 
               date.DayOfWeek != DayOfWeek.Sunday;
    }

    /// <summary>
    /// Calculates the number of business days between two dates.
    /// </summary>
    /// <param name="startDate">Start date</param>
    /// <param name="endDate">End date</param>
    /// <returns>Number of business days between the dates</returns>
    public int CalculateBusinessDaysBetween(DateTime startDate, DateTime endDate)
    {
        if (endDate < startDate)
        {
            throw new ArgumentException("End date must be greater than start date");
        }

        int businessDays = 0;
        DateTime current = startDate.Date;

        while (current <= endDate.Date)
        {
            if (IsBusinessDay(current))
            {
                businessDays++;
            }
            current = current.AddDays(1);
        }

        return businessDays;
    }
}

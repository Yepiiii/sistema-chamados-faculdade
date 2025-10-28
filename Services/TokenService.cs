using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace SistemaChamados.Services;

public interface ITokenService
{
    string GenerateToken(int userId, string email, string nomeCompleto, int tipoUsuario);
}

public class TokenService : ITokenService
{
    private readonly IConfiguration _configuration;

    public TokenService(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public string GenerateToken(int userId, string email, string nomeCompleto, int tipoUsuario)
    {
        var jwtKey = _configuration["Jwt:Key"] 
            ?? throw new InvalidOperationException("Jwt:Key não configurado");
        var jwtIssuer = _configuration["Jwt:Issuer"] 
            ?? throw new InvalidOperationException("Jwt:Issuer não configurado");
        var jwtAudience = _configuration["Jwt:Audience"] 
            ?? throw new InvalidOperationException("Jwt:Audience não configurado");

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, userId.ToString()),
            new Claim(ClaimTypes.Email, email),
            new Claim(ClaimTypes.Name, nomeCompleto),
            new Claim("TipoUsuario", tipoUsuario.ToString())
        };

        var token = new JwtSecurityToken(
            issuer: jwtIssuer,
            audience: jwtAudience,
            claims: claims,
            expires: DateTime.UtcNow.AddDays(7), // Token válido por 7 dias
            signingCredentials: credentials
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}

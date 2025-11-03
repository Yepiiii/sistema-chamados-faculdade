using Newtonsoft.Json;

namespace SistemaChamados.Mobile.Models.DTOs;

public class ApiMessageResponse
{
    [JsonProperty("message")]
    public string? Message { get; set; }
}

// Configuração do ambiente
// Altere esta URL para a URL do seu backend em produção
const config = {
  // Para desenvolvimento local
  development: {
    apiUrl: 'http://localhost:5246'
  },
  
  // Para produção (Vercel + IP público HTTP)
  // ⚠️ IMPORTANTE: Navegadores bloqueiam HTTP em sites HTTPS (Mixed Content)
  // SOLUÇÃO: Usuários devem permitir "conteúdo inseguro" no navegador
  // Ou use ngrok (HTTPS) como fallback
  production: {
    apiUrl: 'http://172.177.19.255:5000',
    fallbackUrl: 'https://unrepudiated-unsolemnised-natalee.ngrok-free.dev'
  }
};

// Detecta automaticamente o ambiente
// Se estiver rodando no localhost, usa desenvolvimento
// Caso contrário, usa produção
const isLocalhost = window.location.hostname === 'localhost' || 
                    window.location.hostname === '127.0.0.1' ||
                    window.location.hostname === '';

const environment = isLocalhost ? 'development' : 'production';

// Exporta a configuração atual
const API_CONFIG = config[environment];

// Também exporta apenas a URL da API (compatibilidade com código existente)
const API_BASE = API_CONFIG.apiUrl;

console.log(`🔧 Ambiente: ${environment}`);
console.log(`🌐 API URL: ${API_BASE}`);

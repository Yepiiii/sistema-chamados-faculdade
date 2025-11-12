// Proxy HTTPS → HTTP para contornar Mixed Content
// Este serverless function roda no Vercel e encaminha requisições para o backend HTTP

export default async function handler(req, res) {
  // Configurar CORS ANTES de tudo
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS, PATCH');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  
  // Responder OPTIONS (preflight)
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }
  
  // URL do backend HTTP
  const BACKEND_URL = 'http://172.177.19.255:5000';
  
  // Pega o caminho da requisição (ex: /api/proxy/api/usuarios/login)
  // Remove /api/proxy do início
  const path = req.url.replace('/api/proxy', '');
  
  // Monta a URL completa do backend
  const targetUrl = `${BACKEND_URL}${path}`;
  
  console.log(`[PROXY] ${req.method} ${targetUrl}`);
  
  try {
    // Prepara os headers (remove headers que podem causar problemas)
    const headers = { ...req.headers };
    delete headers.host;
    delete headers.connection;
    delete headers['content-length'];
    
    // Configuração da requisição
    const fetchOptions = {
      method: req.method,
      headers: headers,
    };
    
    // Adiciona body se não for GET/HEAD
    if (req.method !== 'GET' && req.method !== 'HEAD' && req.body) {
      fetchOptions.body = JSON.stringify(req.body);
    }
    
    // Faz a requisição para o backend HTTP
    const response = await fetch(targetUrl, fetchOptions);
    
    // Pega o corpo da resposta
    const data = await response.text();
    
    // Define content-type baseado na resposta do backend
    const contentType = response.headers.get('content-type') || 'application/json';
    res.setHeader('Content-Type', contentType);
    
    // Retorna a resposta do backend
    return res.status(response.status).send(data);
    
  } catch (error) {
    console.error('[PROXY ERROR]', error);
    return res.status(500).json({ 
      error: 'Proxy error', 
      message: error.message,
      backend: BACKEND_URL,
      path: req.url
    });
  }
}

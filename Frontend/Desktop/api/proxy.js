// Proxy HTTPS → HTTP para contornar Mixed Content
// Este serverless function roda no Vercel e encaminha requisições para o backend HTTP

export default async function handler(req, res) {
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
    
    // Faz a requisição para o backend HTTP
    const response = await fetch(targetUrl, {
      method: req.method,
      headers: headers,
      body: req.method !== 'GET' && req.method !== 'HEAD' ? req.body : undefined,
    });
    
    // Pega o corpo da resposta
    const data = await response.text();
    
    // Define os headers CORS
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS, PATCH');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    res.setHeader('Content-Type', response.headers.get('content-type') || 'application/json');
    
    // Retorna a resposta do backend
    res.status(response.status).send(data);
    
  } catch (error) {
    console.error('[PROXY ERROR]', error);
    res.status(500).json({ 
      error: 'Proxy error', 
      message: error.message,
      backend: BACKEND_URL
    });
  }
}

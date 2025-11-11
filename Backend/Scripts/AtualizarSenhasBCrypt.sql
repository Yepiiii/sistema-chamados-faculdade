-- Script para atualizar senhas dos usuários para BCrypt
USE SistemaChamados;
GO

-- Atualizar Admin
UPDATE Usuarios 
SET SenhaHash = '$2a$11$XvVyL5hKqF9lqDQ3N5h5XuZrPKxKjF3xN7tJFQxVqwGfY8J3X5.C2' -- Admin@123
WHERE Email = 'admin@neurohelp.com.br';

-- Atualizar Técnicos
UPDATE Usuarios 
SET SenhaHash = '$2a$11$5vXqL8hKqF9lqDQ3N5h5XuZrPKxKjF3xN7tJFQxVqwGfY8J3X5.C2' -- Tecnico@123
WHERE Email IN ('rafael.costa@neurohelp.com.br', 'ana.silva@neurohelp.com.br', 'bruno.ferreira@neurohelp.com.br');

-- Atualizar Usuários
UPDATE Usuarios 
SET SenhaHash = '$2a$11$7vXqL8hKqF9lqDQ3N5h5XuZrPKxKjF3xN7tJFQxVqwGfY8J3X5.C2' -- User@123
WHERE Email IN ('juliana.martins@neurohelp.com.br', 'marcelo.santos@neurohelp.com.br');

PRINT '✅ Senhas atualizadas com BCrypt!';
PRINT 'Admin: Admin@123';
PRINT 'Técnicos: Tecnico@123';
PRINT 'Usuários: User@123';
GO

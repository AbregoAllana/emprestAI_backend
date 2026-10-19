---
description: Onde cada variável de ambiente vive e qual chave usar
globs: ["**/.env*", "<CAMINHO-DO-CLIENT>", "<CAMINHO-DE-CONFIG>"]
alwaysApply: false
---

# Variáveis de ambiente e chaves
> leitor: agente

## Quando
Ao criar ou usar qualquer variável de ambiente, ao instanciar o client
do banco, ou ao escrever código que lê configuração.

## Procedimento
1. Chave pública (anon): só ela pode aparecer em código que roda no
   navegador. A proteção dela são as políticas de acesso do banco.
2. Chave de serviço: ignora todas as políticas. Só em código que roda
   no servidor, nunca em componente de cliente, nunca em variável com
   prefixo público.
3. Variável nova existe em TRÊS lugares ou em nenhum:
   `.env.local` (sua máquina) · `.env.example` (versionado, sem valor)
   · painel da Vercel (preview e production).
4. Ao criar uma variável, diga na resposta em quais dos três lugares
   você já a colocou e o que falta eu fazer à mão.

## Verificação
Uma busca por "service" no código que vai para o navegador não
retorna nada. `.env.example` tem todas as chaves que o projeto usa,
sem nenhum valor real.

## Não faça
- Não escreva valor de chave em resposta, commit, log ou comentário.
- Não crie variável só no `.env.local`. Ela quebra o deploy e o erro
  só aparece no build da Vercel.
- Não contorne uma política de acesso trocando de chave. Se a política
  atrapalha, a política está errada — pare e me avise.

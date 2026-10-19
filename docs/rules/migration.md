---
description: Procedimento para qualquer mudança de schema
globs: ["supabase/migrations/**", "<CAMINHO-DO-ACESSO-A-DADOS>"]
alwaysApply: false
---

# Mudança de schema
> leitor: agente

## Quando
Qualquer tarefa que precise criar, alterar ou remover tabela, coluna,
índice, constraint ou política de acesso — inclusive quando a mudança
parecer trivial.

## Procedimento
1. Antes de gerar qualquer coisa: escreva o DDL pretendido na resposta
   e PARE. Eu aprovo ou corrijo.
2. Gere a migration pela CLI: `supabase migration new <nome>`.
   Uma migration por tarefa.
3. Toda tabela nova nasce com Row Level Security habilitada e pelo
   menos uma policy explícita na mesma migration. Tabela sem policy
   não entra no repositório.
4. Se a tabela já tem dado, diga o que acontece com as linhas
   existentes. Coluna obrigatória nova precisa de default ou de um
   passo de preenchimento.
5. Aplique com `supabase db reset` local e rode <COMANDO-TESTES>.

## Verificação
`supabase db reset` numa máquina limpa aplica todas as migrations do
zero, sem erro e sem nenhum passo manual.

## Não faça
- Não altere schema pelo Studio nem por SQL avulso. O que não está em
  migration não existe.
- Não edite migration que já foi para o repositório remoto. Escreva
  a próxima.
- Não toque no projeto Supabase remoto. Tudo acontece no local.

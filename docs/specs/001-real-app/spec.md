# Spec: aplicação real com autenticação e persistência

## Objetivo

Substituir a demonstração local por um fluxo real: login Supabase, catálogo
persistido no PostgreSQL e solicitação de empréstimo persistida na API.

## Escopo desta entrega

- API NestJS em `/v1`.
- Healthcheck público.
- Catálogo autenticado por membership e tenant do JWT.
- Solicitação e devolução de empréstimo.
- Seed idempotente do tenant e equipamentos.
- Tela de login sem scroll no frontend.
- Frontend consumindo a API, sem dados mockados em runtime.

## Critérios de aceite

- CA-01: usuário sem sessão vê login em viewport único.
- CA-02: usuário autenticado com membership vê equipamentos do próprio tenant.
- CA-03: catálogo não usa `mock-data.ts` em runtime.
- CA-04: solicitação grava um loan com prazo de 14 dias.
- CA-05: devolução grava `returnedAt` e libera o equipamento.
- CA-06: seed pode ser executado mais de uma vez sem duplicar equipamentos.
- CA-07: build e testes locais passam sem acessar o banco remoto.

# emprestAI — API

Backend (API) do **emprestAI**, sistema de empréstimo de equipamentos
internos (notebooks, monitores, cabos, câmeras).

Este repositório contém apenas a **API** (NestJS). O **frontend** (SPA
React/Vite) é um repositório separado: `emprestAI_frontend`.

## Execução

```bash
npm install
npm run prisma:generate
npm run prisma:migrate
npm run prisma:seed
npm run start:dev
```

A API expõe `GET /v1/health`, `GET /v1/equipment`, `POST /v1/loans/:equipmentId`
e `POST /v1/loans/:loanId/return`. O catálogo e empréstimos exigem um JWT
válido do Supabase e uma membership no tenant.

## Vercel

O arquivo [`vercel.json`](vercel.json) publica a função `api/index.ts` com
instância Nest cacheada. Configure `DATABASE_URL`, `DIRECT_URL`,
`SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` e `FRONTEND_ORIGIN` no projeto da
API. O banco deve ser migrado separadamente com `DIRECT_URL`; não execute
migrations pelo pooler de runtime.

## Stack

- Node.js LTS · NestJS · `@vendia/serverless-express` (instância cacheada)
- Supabase (Auth + PostgreSQL) · Prisma Migrate
- Zod via `nestjs-zod` · CASL · OpenAPI gerado
- Deploy: Vercel

## Documentação

- [PRD — visão do produto](docs/PRD.md)
- [ADR-001 — Stack (decisões de arquitetura)](docs/adr/001-stack.md)
- **Layout/UI** → movido para o repositório `emprestAI_frontend`
  (`docs/layout.md`)

## Repositório do frontend

- **`emprestAI_frontend`** — React + Vite, deploy na Vercel. Cliente de API
  gerado do `openapi.json` publicado por este repositório.

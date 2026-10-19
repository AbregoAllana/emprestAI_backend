# emprestAI — API

Backend (API) do **emprestAI**, sistema de empréstimo de equipamentos
internos (notebooks, monitores, cabos, câmeras).

Este repositório contém apenas a **API** (NestJS). O **frontend** (SPA
React/Vite) é um repositório separado: `emprestAI_frontend`.

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

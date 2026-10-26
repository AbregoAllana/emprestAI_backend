import type { Request, Response } from 'express'
import type { INestApplication } from '@nestjs/common'
import { createApp } from '../src/app'

let cachedApp: INestApplication | undefined

export default async function handler(req: Request, res: Response): Promise<void> {
  try {
    if (!cachedApp) {
      cachedApp = await createApp()
    }

    cachedApp.getHttpAdapter().getInstance()(req, res)
  } catch (error) {
    console.error('Failed to initialize API', error)
    if (!res.headersSent) {
      res.status(503).json({
        type: 'https://emprestai.dev/problems/service-unavailable',
        title: 'Serviço indisponível',
        status: 503,
      })
    }
  }
}

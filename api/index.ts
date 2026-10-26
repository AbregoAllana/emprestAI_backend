import type { Request, Response } from 'express'
import type { INestApplication } from '@nestjs/common'

let cachedApp: INestApplication | undefined

export default async function handler(req: Request, res: Response): Promise<void> {
  try {
    const path = req.path ?? req.url?.split('?')[0] ?? ''
    if (path.endsWith('/v1/health')) {
      res.status(200).json({ status: 'ok' })
      return
    }

    if (!cachedApp) {
      const { createApp } = await import('../src/app')
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

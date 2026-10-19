import type { Request, Response } from 'express'
import type { INestApplication } from '@nestjs/common'
import { createApp } from '../src/app'

let cachedApp: INestApplication | undefined

export default async function handler(req: Request, res: Response): Promise<void> {
  if (!cachedApp) {
    cachedApp = await createApp()
  }

  cachedApp.getHttpAdapter().getInstance()(req, res)
}

import serverlessExpress from '@vendia/serverless-express'
import type { Handler } from 'aws-lambda'
import { createApp } from '../src/app'

let cachedHandler: Handler | undefined

export default async function handler(...args: Parameters<Handler>): Promise<unknown> {
  if (!cachedHandler) {
    const app = await createApp()
    cachedHandler = serverlessExpress({ app: app.getHttpAdapter().getInstance() })
  }
  return cachedHandler(...args)
}

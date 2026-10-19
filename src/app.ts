import { ValidationPipe } from '@nestjs/common'
import { NestFactory } from '@nestjs/core'
import type { INestApplication } from '@nestjs/common'
import { AppModule } from './app.module'

export async function createApp(): Promise<INestApplication> {
  const app = await NestFactory.create(AppModule)
  app.setGlobalPrefix('v1')
  app.enableCors({
    origin: process.env.FRONTEND_ORIGIN ?? 'http://localhost:5173',
    allowedHeaders: ['Content-Type', 'Authorization'],
  })
  app.useGlobalPipes(new ValidationPipe({ transform: true, whitelist: true }))
  await app.init()
  return app
}

import { Module } from '@nestjs/common'
import { PrismaService } from './prisma.service'
import { AuthGuard } from './auth.guard'
import { HealthController } from './health.controller'
import { EquipmentController } from './equipment.controller'
import { LoanController } from './loan.controller'

@Module({
  controllers: [HealthController, EquipmentController, LoanController],
  providers: [PrismaService, AuthGuard],
})
export class AppModule {}

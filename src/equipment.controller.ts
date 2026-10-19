import { Controller, Get, Req, UseGuards } from '@nestjs/common'
import type { AuthenticatedRequest } from './auth.guard'
import { AuthGuard } from './auth.guard'
import { PrismaService } from './prisma.service'

@Controller('equipment')
export class EquipmentController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  @UseGuards(AuthGuard)
  async list(@Req() request: AuthenticatedRequest) {
    const equipment = await this.prisma.equipment.findMany({
      where: { tenantId: request.user.tenantId },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      include: { loans: { where: { returnedAt: null }, orderBy: { createdAt: 'desc' }, take: 1 } },
    })

    return equipment.map((item) => ({
      id: item.id,
      name: item.name,
      category: item.category,
      assetTag: item.assetTag,
      condition: item.condition,
      notes: item.notes,
      loan: item.loans[0] ?? null,
    }))
  }
}

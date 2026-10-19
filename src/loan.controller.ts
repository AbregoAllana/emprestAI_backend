import { BadRequestException, Controller, Param, Post, Req, UseGuards } from '@nestjs/common'
import type { AuthenticatedRequest } from './auth.guard'
import { AuthGuard } from './auth.guard'
import { PrismaService } from './prisma.service'

@Controller('loans')
@UseGuards(AuthGuard)
export class LoanController {
  constructor(private readonly prisma: PrismaService) {}

  @Post(':equipmentId')
  async borrow(@Param('equipmentId') equipmentId: string, @Req() request: AuthenticatedRequest) {
    const now = new Date()
    const dueAt = new Date(now)
    dueAt.setDate(dueAt.getDate() + 14)

    return this.prisma.$transaction(async (transaction) => {
      const equipment = await transaction.equipment.findFirst({
        where: { id: equipmentId, tenantId: request.user.tenantId, condition: 'AVAILABLE' },
      })
      if (!equipment) throw new BadRequestException('Equipamento indisponível')

      const activeLoans = await transaction.loan.count({
        where: { tenantId: request.user.tenantId, borrowerUserId: request.user.id, returnedAt: null },
      })
      if (activeLoans >= 3) throw new BadRequestException('Limite de 3 itens atingido')

      const overdue = await transaction.loan.count({
        where: { tenantId: request.user.tenantId, borrowerUserId: request.user.id, returnedAt: null, dueAt: { lt: now } },
      })
      if (overdue > 0) throw new BadRequestException('Há empréstimo em atraso')

      return transaction.loan.create({
        data: { tenantId: request.user.tenantId, equipmentId, borrowerUserId: request.user.id, dueAt },
      })
    })
  }

  @Post(':loanId/return')
  async returnLoan(@Param('loanId') loanId: string, @Req() request: AuthenticatedRequest) {
    const loan = await this.prisma.loan.findFirst({
      where: { id: loanId, tenantId: request.user.tenantId, borrowerUserId: request.user.id, returnedAt: null },
    })
    if (!loan) throw new BadRequestException('Empréstimo não encontrado')
    return this.prisma.loan.update({
      where: { id: loan.id },
      data: { returnedAt: new Date(), returnedByUserId: request.user.id },
    })
  }
}

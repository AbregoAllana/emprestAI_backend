import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main(): Promise<void> {
  await prisma.tenant.upsert({
    where: { slug: 'suporte_ti' },
    create: {
      slug: 'suporte_ti',
      name: 'Suporte de TI',
    },
    update: {
      name: 'Suporte de TI',
    },
  });
}

main()
  .catch(async (error: unknown) => {
    console.error(error);
    await prisma.$disconnect();
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

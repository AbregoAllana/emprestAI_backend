import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main(): Promise<void> {
  const tenant = await prisma.tenant.upsert({
    where: { slug: 'suporte_ti' },
    create: {
      slug: 'suporte_ti',
      name: 'Suporte de TI',
    },
    update: {
      name: 'Suporte de TI',
    },
  });

  const equipment = [
    ['Notebook Dell Latitude 5450', 'NOTEBOOK', 'TI-0142', 'AVAILABLE'],
    ['MacBook Pro 14 M3', 'NOTEBOOK', 'TI-0088', 'AVAILABLE'],
    ['Monitor LG 27" 4K', 'MONITOR', 'TI-0231', 'AVAILABLE'],
    ['Monitor Dell 24" FHD', 'MONITOR', 'TI-0233', 'MAINTENANCE'],
    ['Câmera Sony ZV-1', 'CAMERA', 'TI-0301', 'AVAILABLE'],
    ['Cabo HDMI 2.1 3m', 'CABLE', 'TI-0455', 'AVAILABLE'],
    ['Dock Thunderbolt 4', 'ACCESSORY', 'TI-0512', 'AVAILABLE'],
    ['Tripé Manfrotto Befree', 'ACCESSORY', 'TI-0318', 'MAINTENANCE'],
    ['Headset Jabra Evolve2', 'ACCESSORY', 'TI-0402', 'AVAILABLE'],
  ] as const;

  for (const [name, category, assetTag, condition] of equipment) {
    const existing = await prisma.equipment.findFirst({ where: { tenantId: tenant.id, assetTag } });
    if (existing) {
      await prisma.equipment.update({
        where: { id: existing.id },
        data: { name, category, condition },
      });
    } else {
      await prisma.equipment.create({
        data: { tenantId: tenant.id, name, category, assetTag, condition },
      });
    }
  }
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

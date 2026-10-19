CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TYPE "membership_role" AS ENUM ('COLLABORATOR', 'OPERATIONS');
CREATE TYPE "equipment_category" AS ENUM ('NOTEBOOK', 'MONITOR', 'CABLE', 'CAMERA', 'ACCESSORY');
CREATE TYPE "equipment_condition" AS ENUM ('AVAILABLE', 'MAINTENANCE');

CREATE TABLE "tenants" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "slug" VARCHAR(80) NOT NULL,
    "name" VARCHAR(160) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "tenants_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "memberships" (
    "tenant_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "role" "membership_role" NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "memberships_pkey" PRIMARY KEY ("tenant_id", "user_id"),
    CONSTRAINT "memberships_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "memberships_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES auth.users("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "equipment" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "name" VARCHAR(160) NOT NULL,
    "category" "equipment_category" NOT NULL,
    "asset_tag" VARCHAR(80),
    "notes" TEXT,
    "condition" "equipment_condition" NOT NULL DEFAULT 'AVAILABLE',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "equipment_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "equipment_name_not_blank" CHECK (length(btrim("name")) > 0),
    CONSTRAINT "equipment_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "equipment_tenant_id_id_key" UNIQUE ("tenant_id", "id")
);

CREATE TABLE "loans" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "equipment_id" UUID NOT NULL,
    "borrower_user_id" UUID NOT NULL,
    "borrowed_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "due_at" TIMESTAMPTZ(6) NOT NULL,
    "returned_at" TIMESTAMPTZ(6),
    "returned_by_user_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "loans_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "loans_due_after_borrowed" CHECK ("due_at" >= "borrowed_at"),
    CONSTRAINT "loans_returned_after_borrowed" CHECK ("returned_at" IS NULL OR "returned_at" >= "borrowed_at"),
    CONSTRAINT "loans_return_actor_pair" CHECK (("returned_at" IS NULL AND "returned_by_user_id" IS NULL) OR ("returned_at" IS NOT NULL AND "returned_by_user_id" IS NOT NULL)),
    CONSTRAINT "loans_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "loans_equipment_tenant_id_equipment_id_fkey" FOREIGN KEY ("tenant_id", "equipment_id") REFERENCES "equipment"("tenant_id", "id") ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE "audit_logs" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "actor_user_id" UUID NOT NULL,
    "action" VARCHAR(80) NOT NULL,
    "resource_type" VARCHAR(80) NOT NULL,
    "resource_id" UUID NOT NULL,
    "metadata" JSONB NOT NULL DEFAULT '{}'::jsonb,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "audit_logs_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "audit_logs_metadata_object" CHECK (jsonb_typeof("metadata") = 'object')
);

CREATE TABLE "rate_limit_buckets" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "subject_type" VARCHAR(10) NOT NULL,
    "subject_key" VARCHAR(255) NOT NULL,
    "route_key" VARCHAR(120) NOT NULL,
    "window_started_at" TIMESTAMPTZ(6) NOT NULL,
    "request_count" INTEGER NOT NULL DEFAULT 0,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    CONSTRAINT "rate_limit_buckets_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "rate_limit_buckets_subject_type" CHECK ("subject_type" IN ('IP', 'USER')),
    CONSTRAINT "rate_limit_buckets_request_count" CHECK ("request_count" >= 0)
);

CREATE UNIQUE INDEX "tenants_slug_key" ON "tenants"("slug");
CREATE INDEX "memberships_user_id_idx" ON "memberships"("user_id");
CREATE UNIQUE INDEX "equipment_tenant_asset_tag_key" ON "equipment"("tenant_id", "asset_tag") WHERE "asset_tag" IS NOT NULL;
CREATE INDEX "equipment_tenant_condition_idx" ON "equipment"("tenant_id", "condition");
CREATE INDEX "equipment_tenant_created_id_idx" ON "equipment"("tenant_id", "created_at" DESC, "id" DESC);
CREATE UNIQUE INDEX "loans_one_open_per_equipment_key" ON "loans"("tenant_id", "equipment_id") WHERE "returned_at" IS NULL;
CREATE INDEX "loans_tenant_borrower_created_id_idx" ON "loans"("tenant_id", "borrower_user_id", "created_at" DESC, "id" DESC);
CREATE INDEX "loans_open_due_at_idx" ON "loans"("tenant_id", "due_at") WHERE "returned_at" IS NULL;
CREATE INDEX "audit_logs_tenant_created_id_idx" ON "audit_logs"("tenant_id", "created_at" DESC, "id" DESC);
CREATE UNIQUE INDEX "rate_limit_bucket_window_key" ON "rate_limit_buckets"("subject_type", "subject_key", "route_key", "window_started_at");
CREATE INDEX "rate_limit_buckets_expires_at_idx" ON "rate_limit_buckets"("expires_at");

CREATE OR REPLACE FUNCTION app_current_tenant_id()
RETURNS UUID
LANGUAGE SQL
STABLE
AS $$
    SELECT NULLIF(current_setting('request.jwt.claims', true)::jsonb ->> 'tenant_id', '')::uuid;
$$;

ALTER TABLE "tenants" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "memberships" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "equipment" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "loans" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "audit_logs" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "rate_limit_buckets" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "tenants_read_current_tenant" ON "tenants"
    FOR SELECT TO authenticated
    USING ("id" = app_current_tenant_id());

CREATE POLICY "memberships_read_own_membership" ON "memberships"
    FOR SELECT TO authenticated
    USING ("tenant_id" = app_current_tenant_id() AND "user_id" = auth.uid());

CREATE POLICY "equipment_read_current_tenant" ON "equipment"
    FOR SELECT TO authenticated
    USING ("tenant_id" = app_current_tenant_id());

CREATE POLICY "loans_read_own_loans" ON "loans"
    FOR SELECT TO authenticated
    USING ("tenant_id" = app_current_tenant_id() AND "borrower_user_id" = auth.uid());

CREATE POLICY "audit_logs_no_direct_access" ON "audit_logs"
    FOR ALL TO authenticated
    USING (false)
    WITH CHECK (false);

CREATE POLICY "rate_limit_buckets_no_direct_access" ON "rate_limit_buckets"
    FOR ALL TO authenticated
    USING (false)
    WITH CHECK (false);

REVOKE UPDATE, DELETE ON "audit_logs" FROM PUBLIC;
REVOKE UPDATE, DELETE ON "audit_logs" FROM authenticated;

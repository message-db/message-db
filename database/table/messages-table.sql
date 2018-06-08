-- ----------------------------
--  Table structure for messages
-- ----------------------------
CREATE TABLE "public"."messages" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "stream_name" varchar(255) NOT NULL COLLATE "default",
  "type" varchar(255) NOT NULL COLLATE "default",
  "position" bigint NOT NULL,
  "global_position" bigserial NOT NULL ,
  "data" jsonb,
  "metadata" jsonb,
  "time" TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'utc') NOT NULL
)
WITH (OIDS=FALSE);

-- ----------------------------
--  Primary key structure for table messages
-- ----------------------------
ALTER TABLE "public"."messages" ADD PRIMARY KEY ("global_position") NOT DEFERRABLE INITIALLY IMMEDIATE;

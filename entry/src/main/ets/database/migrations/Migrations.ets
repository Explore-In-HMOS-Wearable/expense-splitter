import { RDBMigration } from './RDBMigration'

const MIGRATION_1_2 = new RDBMigration(1, 2, async (store) => {
  await store.executeSql('ALTER TABLE trips ADD COLUMN end_date INTEGER NOT NULL DEFAULT 0;');
});

const MIGRATION_2_3 = new RDBMigration(2, 3, async (store) => {
  await store.executeSql(`ALTER TABLE trips DROP COLUMN end_date;`);
});

export const MIGRATIONS: RDBMigration[] = [
  MIGRATION_1_2,
  MIGRATION_2_3,
];
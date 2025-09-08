import { relationalStore } from '@kit.ArkData';

export class RDBMigration {
  readonly fromVersion: number;
  readonly toVersion: number;
  private readonly migrateAction: (store: relationalStore.RdbStore) => Promise<void>;

  constructor(
    fromVersion: number,
    toVersion: number,
    migrateAction: (store: relationalStore.RdbStore) => Promise<void>
  ) {
    if (!Number.isInteger(fromVersion) || !Number.isInteger(toVersion)) {
      throw new Error('Migration versions must be integers.');
    }
    if (toVersion !== fromVersion + 1) {
      throw new Error('Each migration must be single step: n -> n+1.');
    }
    this.fromVersion = fromVersion;
    this.toVersion = toVersion;
    this.migrateAction = migrateAction;
  }

  public async run(store: relationalStore.RdbStore): Promise<void> {
    // skip if not current version.
    if (store.version !== this.fromVersion) {
      return;
    }

    store.beginTransaction();
    try {
      await this.migrateAction(store);
      store.version = this.toVersion; // bump only on success
      store.commit();
    } catch (e) {
      store.rollBack();
      throw new Error(`Migration ${this.fromVersion}→${this.toVersion} failed: ${e}`);
    }
  }
}
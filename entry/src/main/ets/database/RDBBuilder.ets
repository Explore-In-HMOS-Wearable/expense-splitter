import { relationalStore } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';
import { TRIP_TABLE } from './tables/TripTable';
import { EXPENSES_TABLE } from './tables/ExpensesTable';
import { RDBMigration } from './migrations/RDBMigration';

export interface RDBBuilderParams {
  dbName: string;
  dbVersion?: number;
}

export class RDBBuilder {
  private rdbName: string;
  private version: number;
  private migrations: RDBMigration[] = [];

  constructor(options: RDBBuilderParams) {
    if (options.dbVersion && !Number.isInteger(options.dbVersion)) {
      throw new Error('RDB version must be integer.');
    }
    this.version = options.dbVersion ?? 1;
    this.rdbName = options.dbName;
  }

  /**
   * Runs creation queries when the RDB version is 0 (initial version).
   * @param { relationalStore.RdbStore } store
   */
  private async runCreationQueries(store: relationalStore.RdbStore) {
    if (store.version === 0) {
      await store.executeSql(TRIP_TABLE.createQuery);
      await store.executeSql(EXPENSES_TABLE.createQuery);
      store.version = 1;
    }
  }

  /**
   * Validates passed migrations.
   */
  private validateMigrations() {
    const targetVersion = this.version; // e.g., 4
    // No need for any migration, skip any migrations
    if (targetVersion === 0 || targetVersion === 1) {
      return;
    }

    if (!this.migrations || this.migrations.length === 0) {
      throw new Error('No migrations provided.');
    }

    // Check first migration starts at 1 (or 0 if including initial)
    if (this.migrations[0].fromVersion !== 1) {
      throw new Error(`First migration must start at version 1, got ${this.migrations[0].fromVersion}`);
    }

    // Check chain continuity
    for (let i = 0; i < this.migrations.length; i++) {
      const m = this.migrations[i];
      if (m.toVersion !== m.fromVersion + 1) {
        throw new Error(`Migration ${m.fromVersion}→${m.toVersion} is invalid. Must be +1 step.`);
      }
      if (i > 0 && m.fromVersion !== this.migrations[i - 1].toVersion) {
        throw new Error(`Missing migration ${this.migrations[i - 1].toVersion}→${m.fromVersion}`);
      }
    }

    // Check last migration ends at targetVersion
    const lastMigration = this.migrations[this.migrations.length - 1];
    if (lastMigration.toVersion !== targetVersion) {
      throw new Error(
        `Last migration ends at ${lastMigration.toVersion}, expected ${targetVersion}`
      );
    }
  }

  /**
   * Set App RDB migrations list
   * @param { RDBMigration[] } migrations
   * @returns { RDBBuilder }
   */
  public setMigrations(migrations: RDBMigration[]): RDBBuilder {
    const sorted = [...migrations].sort((a, b) => a.fromVersion - b.fromVersion);
    this.migrations = sorted;
    this.validateMigrations();
    return this;
  }

  /**
   * Initialize RDB with migration handling (versions).
   * @param { Context } the application context.
   * @returns { Promise<relationalStore.RdbStore> } The RDB store {@link relationalStore.RdbStore}.
   */
  public async build(context: Context): Promise<relationalStore.RdbStore> {
    const store = await relationalStore.getRdbStore(context, {
      name: this.rdbName,
      securityLevel: relationalStore.SecurityLevel.S1,
    });
    // Fresh DB? Run creation queries once (version 0)
    if (store.version === 0) {
      await this.runCreationQueries(store);
    }

    const targetVersion = this.version;
    // Loop until we reach targetVersion, or detect no progress (missing step).
    while (store.version < targetVersion) {
      for (const m of this.migrations) {
        await m.run(store);
        if (store.version >= targetVersion) {
          break;
        }
      }
    }
    return store;
  }
}

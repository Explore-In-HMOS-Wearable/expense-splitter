import { Register, ServiceRegistry } from '../registry/ServiceRegistry';
import UIRegistry from '../registry/UIRegistry';
import AppDatabase from '../database/AppDatabase';
import { AppDatabaseImpl } from '../database/AppDatabaseImpl';

export class MainRegistry extends ServiceRegistry implements UIRegistry {
  context: Context

  private constructor(context: Context) {
    super();
    this.context = context;
  }

  public static build(context: Context): MainRegistry {
    const instance = new MainRegistry(context);
    instance.initialize();
    return instance;
  }

  @Register(AppDatabase)
  registerAppDatabase(): AppDatabase {
    return new AppDatabaseImpl(this.context);
  }
}


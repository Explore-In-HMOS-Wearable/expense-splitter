import { AbilityStage } from '@kit.AbilityKit';
import { MainRegistry } from '../di/MainRegistry';
import { ServiceRegistry } from '../registry/ServiceRegistry';

export default class MyAbilityStage extends AbilityStage {
  private registry: ServiceRegistry | null = null;

  onCreate(): void {
    this.registry = MainRegistry.build(this.context.getApplicationContext())
  }

  onDestroy(): void {
    this.registry?.destroy()
  }
}
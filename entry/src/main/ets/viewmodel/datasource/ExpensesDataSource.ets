import { TripExpenses } from '../../model/TripExpenses';

export class ExpensesDataSource implements IDataSource {
  private dataArray: TripExpenses[] = [];
  private listeners: DataChangeListener[] = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): TripExpenses {
    return this.dataArray[index];
  }

  public addData(data: TripExpenses): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  public addDataList(data: TripExpenses[]): void {
    this.dataArray.push(...data);
    this.notifyDataReload();
  }

  public clearDataList() {
    this.dataArray = [];
    this.notifyDataReload();
  }

  public deleteData(item: TripExpenses): void {
    const index = this.dataArray.indexOf(item);
    this.dataArray.splice(index, 1);
    this.notifyDataDelete(index);
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    });
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    });
  }
}
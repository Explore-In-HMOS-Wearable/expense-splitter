import { Expense } from '../../model/Expense';

export default class PayerExpensesDataSource implements IDataSource {
  private dataArray: Expense[] = [];
  private listeners: DataChangeListener[] = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): Expense {
    return this.dataArray[index];
  }

  public addData(data: Expense): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  public addDataList(data: Expense[]): void {
    this.dataArray.push(...data);
    this.notifyDataReload();
  }

  public clearDataList() {
    this.dataArray = [];
    this.notifyDataReload();
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
}
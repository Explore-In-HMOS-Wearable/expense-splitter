import AppDatabase from '../database/AppDatabase';
import { Resolve } from '../registry/ServiceRegistry';
import PayerExpensesDataSource from './datasource/PayerExpensesDataSource';

@Observed
export default class PayerExpensesViewModel {
  @Resolve(AppDatabase)
  private appDatabase?: AppDatabase;
  @Track
  isEmptyData: boolean = true;
  @Track
  payerExpensesAmount: number = 0;
  @Track
  datasource: PayerExpensesDataSource = new PayerExpensesDataSource();

  async loadPayerExpenses(tripId: number, payerName: string) {
    if (!this.appDatabase) {
      return;
    }

    const expenses = await this.appDatabase.getPayerExpenses(tripId, payerName);
    this.isEmptyData = expenses.length <= 0
    if (!this.isEmptyData) {
      this.payerExpensesAmount = expenses.reduce((sum, e) => sum + e.amount, 0);
    }
    this.datasource.clearDataList();
    this.datasource.addDataList(expenses);
  }
}
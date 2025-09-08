import AppDatabase from '../database/AppDatabase'
import { TripExpenses } from '../model/TripExpenses';
import { Resolve } from '../registry/ServiceRegistry'
import { ExpensesDataSource } from './datasource/ExpensesDataSource';

@Observed
export default class ExpensesViewModel {
  @Resolve(AppDatabase)
  private appDatabase?: AppDatabase;
  @Track
  isEmptyData: boolean = true;
  @Track
  totalExpensesAmount: number = 0;
  @Track
  datasource: ExpensesDataSource = new ExpensesDataSource();

  async deleteTripExpenses(tripExpense: TripExpenses) {
    this.datasource.deleteData(tripExpense);

    this.isEmptyData = this.datasource.totalCount() <= 0;
    if (!this.isEmptyData) {
      const newTotalExpenses = this.totalExpensesAmount - tripExpense.totalAmount;
      this.totalExpensesAmount = newTotalExpenses > 0 ? newTotalExpenses : 0;
    } else {
      this.totalExpensesAmount = 0;
    }

    await this.appDatabase?.deleteTripExpenses(tripExpense);
  }

  async loadExpenses(tripId: number) {
    if (!this.appDatabase) {
      return;
    }
    const expenses = await this.appDatabase.getTripExpenses(tripId);
    this.isEmptyData = expenses.length <= 0
    if (!this.isEmptyData) {
      this.totalExpensesAmount = expenses.reduce((sum, e) => sum + e.totalAmount, 0);
    } else {
      this.totalExpensesAmount = 0;
    }
    this.datasource.clearDataList();
    this.datasource.addDataList(expenses);
  }
}
import Logger from '../utils/Logger';
import AppDatabase from './AppDatabase';
import { BusinessError } from '@kit.BasicServicesKit';
import { RDBBuilder } from './RDBBuilder';
import { MIGRATIONS } from './migrations/Migrations';
import { relationalStore } from '@kit.ArkData';
import { TRIP_TABLE } from './tables/TripTable';
import { toTripType } from '../constants/TripType';
import { Trip } from '../model/Trip';
import { EXPENSES_TABLE } from './tables/ExpensesTable';
import { Expense } from '../model/Expense';
import { TripExpenses } from '../model/TripExpenses';

export class AppDatabaseImpl extends AppDatabase {
  private readonly readyDatabase: Promise<relationalStore.RdbStore>;

  constructor(context: Context) {
    super();
    this.readyDatabase = new RDBBuilder({
      dbName: 'expense_splitter.db',
      dbVersion: 3
    }).setMigrations(MIGRATIONS)
      .build(context)
      .then((store) => {
        Logger.info(`Succeeded in getting RdbStore, version: ${store.version}`);
        return store
      })
      .catch((err: BusinessError) => {
        const message = `Failed to get RdbStore. Code:${err.code}, message:${err.message}`;
        Logger.error(message);
        throw new Error(message);
      });
  }

  async onDispose(): Promise<void> {
    const database = await this.readyDatabase;
    database.close();
  }

  private addDays(date: Date, days: number): Date {
    const result = new Date(date);
    result.setDate(result.getDate() + days);
    return result;
  }

  async insertTrip(template: string, startDateMs: number, days: number): Promise<number | undefined> {
    const database = await this.readyDatabase;
    const valueBucket: relationalStore.ValuesBucket = {
      'template': template,
      'start_date': startDateMs,
      'days': days
    };
    const tripId = await database.insert(TRIP_TABLE.tableName, valueBucket);
    if (tripId === -1) {
      throw new Error(`Failed to insert Trip record, tripId: ${tripId}`);
    }
    Logger.info(`Succeeded insertTrip in RdbStore with id: ${tripId}`);
    return tripId;
  }

  async getTrips(): Promise<Trip[]> {
    const database = await this.readyDatabase;
    const predicates = new relationalStore.RdbPredicates(TRIP_TABLE.tableName);
    predicates.orderByDesc('id');
    try {
      const resultSet = await database.query(predicates, TRIP_TABLE.columns);
      if (!resultSet || resultSet.rowCount === 0) {
        return [];
      }

      const results: Trip[] = [];
      while (resultSet.goToNextRow()) {
        const startDate = new Date(resultSet.getLong(resultSet.getColumnIndex('start_date')));
        const days = resultSet.getLong(resultSet.getColumnIndex('days'));
        const trip: Trip = {
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          template: toTripType(resultSet.getString(resultSet.getColumnIndex('template'))),
          startDate: startDate.toLocaleDateString(),
          endDate: days > 1 ? this.addDays(startDate, days - 1).toLocaleDateString() : undefined,
          days: days,
        };
        results.push(trip);
      }
      return results;
    } catch (err) {
      return [];
    }
  }

  private async payerExpenseInDay(tripId: number, payerName: string, atDay: number): Promise<Expense | undefined> {
    const database = await this.readyDatabase;
    const predicates = new relationalStore.RdbPredicates(EXPENSES_TABLE.tableName)
      .equalTo('trip_id', tripId)
      .and()
      .equalTo('payer_name', payerName)
      .and()
      .equalTo('day', atDay)
      .limitAs(1);

    try {
      const resultSet = await database?.query(predicates, EXPENSES_TABLE.columns);
      if (!resultSet || resultSet.rowCount === 0) {
        return;
      }

      let expense: Expense | undefined;
      while (resultSet.goToNextRow()) {
        expense = {
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          tripId: resultSet.getLong(resultSet.getColumnIndex('trip_id')),
          payerName: resultSet.getString(resultSet.getColumnIndex('payer_name')),
          amount: resultSet.getDouble(resultSet.getColumnIndex('amount')),
          day: resultSet.getLong(resultSet.getColumnIndex('day')),
        };
      }
      return expense;
    } catch (e) {
      return;
    }
  }

  async insertExpense(
    tripId: number,
    payerName: string,
    days: number[],
    amount: number
  ): Promise<number[] | undefined> {
    const database = await this.readyDatabase;

    let paymentInADay = amount;
    // check when more than 1 day, then split amount equally on each day.
    if (days.length > 1) {
      paymentInADay = amount / days.length;
    }

    const expensesIds: number[] = [];
    for (let i = 0; i < days.length; i++) {
      const payerExpense = await this.payerExpenseInDay(tripId, payerName, days[i]);
      if (payerExpense) {
        const valueBucket: relationalStore.ValuesBucket = {
          'amount': payerExpense.amount + paymentInADay,
        };
        const predicates = new relationalStore.RdbPredicates(EXPENSES_TABLE.tableName)
          .equalTo('id', payerExpense.id)
          .limitAs(1);

        const expenseId = await database.update(valueBucket, predicates);
        expensesIds.push(expenseId);
      } else {
        const valueBucket: relationalStore.ValuesBucket = {
          'trip_id': tripId,
          'payer_name': payerName,
          'amount': paymentInADay,
          'day': days[i],
        };
        const expenseId = await database.insert(EXPENSES_TABLE.tableName, valueBucket);
        expensesIds.push(expenseId);
      }
    }

    return expensesIds;
  }

  async getTripExpenses(tripId: number): Promise<TripExpenses[]> {
    const detailedExpenses: Expense[] = await this.getPayerExpenses(tripId);
    const tripExpenses: TripExpenses[] = [];

    for (const exp of detailedExpenses) {
      let tripExp = tripExpenses.find(te => te.payerName === exp.payerName);

      if (!tripExp) {
        tripExp = {
          tripId: exp.tripId,
          payerName: exp.payerName,
          totalAmount: 0,
          days: []
        };
        tripExpenses.push(tripExp);
      }

      tripExp.totalAmount += exp.amount;
      if (!tripExp.days.includes(exp.day)) {
        tripExp.days.push(exp.day);
      }
    }

    // Keep days sorted for each payer
    tripExpenses.forEach(te => te.days.sort((a, b) => a - b));
    return tripExpenses;
  }

  async getPayerExpenses(tripId: number, payerName?: string): Promise<Expense[]> {
    const database = await this.readyDatabase;

    const predicates = new relationalStore.RdbPredicates(EXPENSES_TABLE.tableName)
      .equalTo('trip_id', tripId);

    if (payerName) {
      predicates
        .and()
        .equalTo('payer_name', payerName)
        .orderByAsc('day');
    } else {
      predicates.orderByDesc('id');
    }

    try {
      const resultSet = await database.query(predicates, EXPENSES_TABLE.columns);
      if (!resultSet || resultSet.rowCount === 0) {
        return [];
      }

      const results: Expense[] = [];
      while (resultSet.goToNextRow()) {
        const trip: Expense = {
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          tripId: resultSet.getLong(resultSet.getColumnIndex('trip_id')),
          payerName: resultSet.getString(resultSet.getColumnIndex('payer_name')),
          amount: resultSet.getDouble(resultSet.getColumnIndex('amount')),
          day: resultSet.getLong(resultSet.getColumnIndex('day')),
        };
        results.push(trip);
      }
      return results;
    } catch (err) {
      return [];
    }
  }

  async deleteTrip(trip: Trip): Promise<void> {
    const database = await this.readyDatabase;

    const expPredicates = new relationalStore.RdbPredicates(EXPENSES_TABLE.tableName)
      .equalTo('trip_id', trip.id);
    const tripsPredicates = new relationalStore.RdbPredicates(TRIP_TABLE.tableName)
      .equalTo('id', trip.id);
    try {
      await database.delete(expPredicates);
      await database.delete(tripsPredicates);
      Logger.info(`Success delete operations`);
    } catch (err) {
      Logger.error(`Failed to delete rows. Code:${err.code}, message:${err.message}`);
    }
  }

  async deleteTripExpenses(tripExpenses: TripExpenses): Promise<void> {
    const database = await this.readyDatabase;
    const predicates = new relationalStore.RdbPredicates(EXPENSES_TABLE.tableName)
      .equalTo('trip_id', tripExpenses.tripId)
      .and()
      .equalTo('payer_name', tripExpenses.payerName);
    try {
      await database.delete(predicates);
      Logger.info(`Success delete operations`);
    } catch (err) {
      Logger.error(`Failed to delete rows. Code:${err.code}, message:${err.message}`);
    }
  }
}
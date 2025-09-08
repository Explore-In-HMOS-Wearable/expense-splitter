import { Expense } from '../model/Expense';
import { Trip } from '../model/Trip';
import Injectable from '../registry/Injectable';
import { TripExpenses } from '../model/TripExpenses';

export default abstract class AppDatabase implements Injectable {
  abstract onDispose(): void

  abstract insertTrip(template: string, startDateMs: number, days: number): Promise<number | undefined>

  abstract getTrips(): Promise<Trip[]>

  abstract insertExpense(tripId: number, payerName: string, days: number[],
    amount: number): Promise<number[] | undefined>

  abstract getTripExpenses(tripId: number): Promise<TripExpenses[]>;

  abstract getPayerExpenses(tripId: number, payerName?: string): Promise<Expense[]>;

  abstract deleteTrip(trip: Trip): Promise<void>;

  abstract deleteTripExpenses(tripExpenses: TripExpenses): Promise<void>;
}
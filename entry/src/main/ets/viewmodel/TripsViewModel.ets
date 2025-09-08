import AppDatabase from '../database/AppDatabase'
import { Trip } from '../model/Trip';
import { Resolve } from '../registry/ServiceRegistry'
import { TripsDataSource } from './datasource/TripsDataSource';

@Observed
export default class TripsViewModel {
  @Resolve(AppDatabase)
  private appDatabase?: AppDatabase;
  @Track
  isEmptyData: boolean = true;
  @Track
  datasource: TripsDataSource = new TripsDataSource();

  async deleteTrip(trip: Trip) {
    this.datasource.deleteData(trip);
    this.isEmptyData = this.datasource.totalCount() <= 0;
    await this.appDatabase?.deleteTrip(trip);
  }

  async loadExpenses() {
    if (!this.appDatabase) {
      return;
    }

    const trips = await this.appDatabase.getTrips();
    this.isEmptyData = trips.length <= 0
    this.datasource.clearDataList();
    this.datasource.addDataList(trips);
  }
}
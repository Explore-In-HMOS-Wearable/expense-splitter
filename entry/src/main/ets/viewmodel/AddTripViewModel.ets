import { LabelOption } from '../components/OptionBuilder';
import { TripType } from '../constants/TripType';
import AppDatabase from '../database/AppDatabase';
import { Resolve } from '../registry/ServiceRegistry';
import Logger from '../utils/Logger';


const TRIP_OPTIONS: LabelOption[] = [
  {
    label: TripType.WeekendTrip,
    selected: false
  },
  {
    label: TripType.DinnerOut,
    selected: false
  },
  {
    label: TripType.TaxiRide,
    selected: false
  },
  {
    label: TripType.Groceries,
    selected: false
  },
  {
    label: TripType.RoadTrip,
    selected: false
  },
  {
    label: TripType.CoffeeBreak,
    selected: false
  },
  {
    label: TripType.MovieNight,
    selected: false
  },
  {
    label: TripType.PartyNight,
    selected: false
  },
  {
    label: TripType.BusinessLunch,
    selected: false
  },
  {
    label: TripType.ShoppingDay,
    selected: false
  },
]

const DAYS_OPTIONS: LabelOption[] = [
  {
    label: '1',
    selected: false
  },
  {
    label: '2',
    selected: false
  },
  {
    label: '3',
    selected: false
  },
  {
    label: '4',
    selected: false
  },
  {
    label: '5',
    selected: false
  },
  {
    label: '6',
    selected: false
  },
]


export default class AddTripViewModel {
  @Resolve(AppDatabase)
  private appDatabase?: AppDatabase;

  get getTripOptions(): LabelOption[] {
    return TRIP_OPTIONS;
  }

  get getDaysOptions(): LabelOption[] {
    return DAYS_OPTIONS;
  }

  async addTrip(tripOpt: LabelOption, daysOpt: LabelOption) {
    try {
      const days: number = Number(daysOpt.label);
      if (days) {
        await this.appDatabase?.insertTrip(tripOpt.label, Date.now(), days);
      }
    } catch (err) {
      Logger.error(`Failed to get insert-trip record. Code:${err.code}, message:${err.message}`);
    }
  }
}
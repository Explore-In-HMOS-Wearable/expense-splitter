export enum TripType {
  Unknown = 'Unknown',
  WeekendTrip = 'Weekend Trip',
  DinnerOut = 'Dinner Out',
  TaxiRide = 'Taxi Ride',
  Groceries = 'Groceries',
  RoadTrip = 'Road Trip',
  CoffeeBreak = 'Coffee Break',
  MovieNight = 'Movie Night',
  PartyNight = 'Party Night',
  BusinessLunch = 'Business Lunch',
  ShoppingDay = 'Shopping Day',
}

const TRIP_TYPE_VALUES: readonly TripType[] = [
  TripType.WeekendTrip,
  TripType.DinnerOut,
  TripType.TaxiRide,
  TripType.Groceries,
  TripType.RoadTrip,
  TripType.CoffeeBreak,
  TripType.MovieNight,
  TripType.PartyNight,
  TripType.BusinessLunch,
  TripType.ShoppingDay,
];

// Convert string → enum (safe)
export function toTripType(value: string): TripType {
  return (TRIP_TYPE_VALUES as readonly string[]).includes(value) ? (value as TripType) : TripType.Unknown;
}
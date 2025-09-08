import { TripType } from '../constants/TripType';

export interface Trip {
  id: number,
  template: TripType;
  startDate: string;
  endDate?: string;
  days: number;
}
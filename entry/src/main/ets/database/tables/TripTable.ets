import { RDBTable } from './RDBTable';

export const TRIP_TABLE: RDBTable = {
  tableName: 'Trips',
  createQuery: `CREATE TABLE IF NOT EXISTS Trips (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      template TEXT,
      start_date INTEGER,
      days INTEGER
    );`,
  columns: ['id', 'template', 'start_date', 'days']
};
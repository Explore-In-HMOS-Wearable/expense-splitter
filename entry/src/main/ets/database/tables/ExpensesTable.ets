import { RDBTable } from './RDBTable';

export const EXPENSES_TABLE: RDBTable = {
  tableName: 'Expenses',
  createQuery: `CREATE TABLE IF NOT EXISTS Expenses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      trip_id INTEGER,
      payer_name TEXT,
      amount REAL,
      day INTEGER,
      FOREIGN KEY (trip_id) REFERENCES Trips(id) ON DELETE CASCADE
    );`,
  columns: ['id', 'trip_id', 'payer_name', 'amount', 'day']
};
export interface RDBTable {
  tableName: string;
  createQuery: string;
  columns: string[];
};
import { LabelOption } from '../components/OptionBuilder';
import AppDatabase from '../database/AppDatabase';
import { Resolve } from '../registry/ServiceRegistry';

const PAYERS_OPTIONS: LabelOption[] = [
  {
    label: 'Orion',
    selected: false,
    color: '#3949AB', // indigo (light text)
    selectedColor: '#9FA8DA' // light indigo (dark text)
  },
  {
    label: 'Nova',
    selected: false,
    color: '#00897B', // teal (light text)
    selectedColor: '#80CBC4' // light teal (dark text)
  },
  {
    label: 'Vega',
    selected: false,
    color: '#6D4C41', // brown (light text)
    selectedColor: '#BCAAA4' // light brown (dark text)
  },
  {
    label: 'Luna',
    selected: false,
    color: '#AFB42B', // olive green (light text)
    selectedColor: '#E6EE9C' // lime pastel (dark text)
  },
  {
    label: 'Sol',
    selected: false,
    color: '#F57C00', // deep orange (light text)
    selectedColor: '#FFCC80' // light orange (dark text)
  },
  {
    label: 'Zen',
    selected: false,
    color: '#7B1FA2', // purple (light text)
    selectedColor: '#CE93D8' // light purple (dark text)
  },
  {
    label: 'Echo',
    selected: false,
    color: '#C2185B', // deep pink (light text)
    selectedColor: '#F48FB1' // light pink (dark text)
  },
  {
    label: 'Pixel',
    selected: false,
    color: '#1976D2', // blue (light text)
    selectedColor: '#90CAF9' // light blue (dark text)
  },
  {
    label: 'Nexus',
    selected: false,
    color: '#2E7D32', // green (light text)
    selectedColor: '#A5D6A7' // light green (dark text)
  },
  {
    label: 'Core',
    selected: false,
    color: '#455A64', // blue grey (light text)
    selectedColor: '#B0BEC5' // light blue grey (dark text)
  }
];


export default class AddExpenseViewModel {
  @Resolve(AppDatabase)
  private appDatabase?: AppDatabase;

  get getPayersLabels(): LabelOption[] {
    return PAYERS_OPTIONS;
  }

  getDaysOptions(daysCount: number): LabelOption[] {
    const daysOptions: LabelOption[] = [];
    for (let i = 0; i < daysCount; i++) {
      daysOptions.push({
        label: (i + 1).toString(),
        selected: false,
      })
    }
    return daysOptions;
  }


  async addExpense(tripId: number, payer: LabelOption, days: LabelOption[], amount: number): Promise<void> {
    await this.appDatabase?.insertExpense(tripId, payer.label, days.map((e) => Number(e.label)), amount);
  }
}
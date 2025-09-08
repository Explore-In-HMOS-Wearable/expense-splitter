import { AddTripPageBuilder, ADD_TRIP_PAGE } from './AddTripPage';
import { TripsPageBuilder, TRIPS_PAGE } from './TripsPage';
import { ExpensesPageBuilder, EXPENSES_PAGE } from './ExpensesPage';
import { AddExpensePageBuilder, ADD_EXPENSE_PAGE } from './AddExpensePage';
import { PayerExpensesPageBuilder, PAYER_EXPENSES_PAGE } from './PayerExpensesPage';

@Entry
@Component
struct Index {
  @Provide('NavPathStack') pageStack: NavPathStack = new NavPathStack()

  @Builder
  PageMap(name: string) {
    if (name === TRIPS_PAGE) {
      TripsPageBuilder();
    } else if (name === ADD_TRIP_PAGE) {
      AddTripPageBuilder();
    } else if (name === EXPENSES_PAGE) {
      ExpensesPageBuilder();
    } else if (name === ADD_EXPENSE_PAGE) {
      AddExpensePageBuilder();
    } else if (name === PAYER_EXPENSES_PAGE) {
      PayerExpensesPageBuilder();
    }
  }

  build() {
    Navigation(this.pageStack) {
      TripsPageBuilder()
    }
    .width($r('app.float.px_watch_size'))
    .height($r('app.float.px_watch_size'))
    .borderRadius($r('app.float.px_watch_radius'))
    .backgroundColor($r('app.color.background_color'))
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .hideBackButton(true)
    .ignoreLayoutSafeArea()
    .navDestination(this.PageMap)
  }
}
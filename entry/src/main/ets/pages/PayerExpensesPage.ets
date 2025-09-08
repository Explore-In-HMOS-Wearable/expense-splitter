import PayerExpensesViewModel from '../viewmodel/PayerExpensesViewModel';
import {
  UIContext,
  LengthMetrics,
  ArcList,
  ArcListItem,
  ArcListAttribute,
  ArcListItemAttribute,
  ComponentContent,
} from '@kit.ArkUI';
import { Expense } from '../model/Expense';
import { SizeConstants } from '../constants/SizeConstants';
import { TripExpenseCard } from '../components/TripExpenseCard';
import { formatAmount } from './ExpensesPage';

export const PAYER_EXPENSES_PAGE = 'PayerExpensesPage';

export class PayerExpensesPageParam {
  tripId: number;
  payerName: string;

  constructor(tripId: number, payerName: string) {
    this.tripId = tripId;
    this.payerName = payerName;
  }
}


@Builder
export function PayerExpensesPageBuilder() {
  PayerExpensesPage();
}


interface HeaderParamsInterface {
  payerName: string,
  totalAmount: number;
}

@Builder
function buildHeader(params: HeaderParamsInterface) {
  Column() {
    Text(params.payerName)
      .fontSize($r('app.float.list_header_font_size'))
      .fontWeight(FontWeight.Bold)
      .fontColor($r('app.color.on_primary_color'))
      .textAlign(TextAlign.Center)

    Row() {
      Text($r('app.string.total_amount_label'))
        .fontSize($r('app.float.char_chip_item_font_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.on_primary_color'))
        .textAlign(TextAlign.Center)

      Text(` ${formatAmount(params.totalAmount)}`)
        .fontSize($r('app.float.char_chip_item_font_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.on_primary_color'))
        .textAlign(TextAlign.Center)
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }
  .width(SizeConstants.PERCENT_80)
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
  .margin({ top: $r('app.float.margin_6') })

}


@Component
struct PayerExpensesPage {
  @Consume('NavPathStack') pageStack: NavPathStack;
  private context: UIContext = this.getUIContext();
  @State
  private params: PayerExpensesPageParam = new PayerExpensesPageParam(0, '');
  @State
  private viewModel: PayerExpensesViewModel = new PayerExpensesViewModel();
  private headerComponent: ComponentContent<HeaderParamsInterface> =
    new ComponentContent<HeaderParamsInterface>(this.context, wrapBuilder(buildHeader), {
      payerName: 'Payer',
      totalAmount: this.viewModel.payerExpensesAmount
    });

  private async loadPageData() {
    await this.viewModel.loadPayerExpenses(this.params.tripId, this.params.payerName);
    this.headerComponent.update({ payerName: this.params.payerName, totalAmount: this.viewModel.payerExpensesAmount });
  }

  build() {
    NavDestination() {
      ArcList({ header: this.headerComponent }) {
        if (this.viewModel.isEmptyData) {
          ArcListItem() {
            Text($r('app.string.empty_expenses_message'))
              .fontSize($r('app.float.empty_list_font_size'))
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.on_primary_color'))
              .textAlign(TextAlign.Center)
              .width(SizeConstants.PERCENT_80)
          }

        } else {
          LazyForEach(this.viewModel.datasource, (expense: Expense) => {
            ArcListItem() {
              TripExpenseCard({
                payerName: expense.payerName,
                totalAmount: expense.amount,
                payedInDays: [expense.day],
                onCardClicked: () => {
                }
              })
            }
            .width(SizeConstants.PERCENT_86)
          }, (expense: Expense, index: number) => `${expense.payerName}-${index}`)
        }
      }
      .width(SizeConstants.FULL_PERCENT)
      .height(SizeConstants.FULL_PERCENT)
      .space(LengthMetrics.resource($r('app.float.margin_8')))
      .focusable(true)
      .focusOnTouch(true)
      .defaultFocus(true)
    }
    .borderRadius($r('app.float.px_watch_radius'))
    .backgroundColor($r('app.color.background_color'))
    .hideTitleBar(true)
    .hideBackButton(true)
    .onReady((context: NavDestinationContext) => {
      this.params = context.pathInfo.param as PayerExpensesPageParam;
      this.loadPageData();
    })
  }
}
import {
  UIContext,
  LengthMetrics,
  ArcList,
  ArcListItem,
  ArcListAttribute,
  ArcListItemAttribute,
  ComponentContent,
  ArcButton,
  ArcButtonOptions,
  ArcButtonStyleMode,
  ColorMetrics,
} from '@kit.ArkUI';
import { SizeConstants } from '../constants/SizeConstants';
import ExpensesViewModel from '../viewmodel/ExpensesViewModel';
import { ADD_EXPENSE_PAGE } from './AddExpensePage';
import { TripExpenses } from '../model/TripExpenses';
import { TripExpenseCard } from '../components/TripExpenseCard';
import { PAYER_EXPENSES_PAGE, PayerExpensesPageParam } from './PayerExpensesPage';

export const EXPENSES_PAGE = 'ExpensesPage';

export class ExpensesPageParam {
  tripId: number;
  tripName: string;
  days: number;

  constructor(tripId: number, tripName: string, days: number) {
    this.tripId = tripId;
    this.tripName = tripName;
    this.days = days;
  }
}

@Builder
export function ExpensesPageBuilder() {
  ExpensesPage();
}

interface HeaderParamsInterface {
  tripName: string,
  totalAmount: number;
}

export function formatAmount(value: number): string {
  return value.toFixed(2);
}

@Builder
function buildHeader(params: HeaderParamsInterface) {
  Column() {
    Text(params.tripName)
      .fontSize($r('app.float.list_header_font_size'))
      .fontWeight(FontWeight.Bold)
      .fontColor($r('app.color.on_primary_color'))
      .textAlign(TextAlign.Center)

    if (params.totalAmount > 0) {
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
  }
  .width(SizeConstants.PERCENT_80)
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
  .padding({ top: $r('app.float.margin_6') })
}

@Component
struct ExpensesPage {
  @Consume('NavPathStack') pageStack: NavPathStack;
  @State
  private params: ExpensesPageParam = new ExpensesPageParam(0, '', 0);
  @State
  private viewModel: ExpensesViewModel = new ExpensesViewModel();
  private context: UIContext = this.getUIContext();
  private headerComponent: ComponentContent<HeaderParamsInterface> =
    new ComponentContent<HeaderParamsInterface>(this.context, wrapBuilder(buildHeader), {
      tripName: 'Payers',
      totalAmount: this.viewModel.totalExpensesAmount
    });
  private bottomOptions = new ArcButtonOptions({
    label: $r('app.string.new_expense'),
    styleMode: ArcButtonStyleMode.CUSTOM,
    fontSize: LengthMetrics.resource($r('app.float.list_header_font_size')),
    shadowEnabled: true,
    backgroundColor: ColorMetrics.resourceColor($r('app.color.brand_color')),
    fontColor: ColorMetrics.resourceColor($r('app.color.on_brand_color')),
    pressedFontColor: ColorMetrics.resourceColor($r('app.color.on_brand_color')),
    shadowColor: ColorMetrics.resourceColor($r('app.color.background_color')),
    onClick: () => {
      this.pageStack.pushPathByName(ADD_EXPENSE_PAGE, this.params, () => {
        this.loadPageData();
      });
    }
  });

  private async loadPageData() {
    await this.viewModel.loadExpenses(this.params.tripId);
    this.updateHeader();
  }

  private updateHeader() {
    this.headerComponent.update({ tripName: this.params.tripName, totalAmount: this.viewModel.totalExpensesAmount });
  }

  @Builder
  private itemEnd(expense: TripExpenses) {
    Row() {
      Button($r('app.string.delete_label'))
        .backgroundColor($r('app.color.brand_color'))
        .fontColor($r('app.color.on_brand_color'))
        .margin($r('app.float.margin_4'))
        .onClick(async () => {
          await this.viewModel.deleteTripExpenses(expense);
          this.updateHeader();
        })
    }
    .padding($r('app.float.margin_4'))
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  build() {
    NavDestination() {
      Stack() {
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
            LazyForEach(this.viewModel.datasource, (expense: TripExpenses) => {
              ArcListItem() {
                TripExpenseCard({
                  payerName: expense.payerName,
                  totalAmount: expense.totalAmount,
                  payedInDays: expense.days,
                  onCardClicked: () => {
                    this.pageStack.pushPathByName(
                      PAYER_EXPENSES_PAGE,
                      new PayerExpensesPageParam(expense.tripId, expense.payerName)
                    );
                  }
                })
              }
              .width(SizeConstants.PERCENT_86)
              .swipeAction({
                end: {
                  builder: () => {
                    this.itemEnd(expense)
                  },
                  onAction: () => {
                    this.context.animateTo({ duration: 1000 }, async () => {
                      await this.viewModel.deleteTripExpenses(expense);
                      this.updateHeader();
                    })
                  },
                  actionAreaDistance: 56,
                }
              })
            }, (expense: TripExpenses, index: number) => `${expense.payerName}-${index}-${expense.totalAmount}}`)
          }
        }
        .space(LengthMetrics.resource($r('app.float.margin_8')))
        .focusable(true)
        .focusOnTouch(true)
        .defaultFocus(true)
        .width(SizeConstants.FULL_PERCENT)
        .height(SizeConstants.FULL_PERCENT)

        ArcButton({
          options: this.bottomOptions
        }).align(Alignment.Bottom)
      }
      .width(SizeConstants.FULL_PERCENT)
      .height(SizeConstants.FULL_PERCENT)
      .alignContent(Alignment.Bottom)
    }
    .borderRadius($r('app.float.px_watch_radius'))
    .backgroundColor($r('app.color.background_color'))
    .hideTitleBar(true)
    .hideBackButton(true)
    .onReady((context: NavDestinationContext) => {
      this.params = context.pathInfo.param as ExpensesPageParam;
      this.loadPageData();
    })
  }
}
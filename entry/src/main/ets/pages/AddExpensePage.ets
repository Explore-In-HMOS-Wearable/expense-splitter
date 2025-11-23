import { LengthMetrics, ArcButton, ArcButtonOptions, ArcButtonStyleMode, ColorMetrics } from '@kit.ArkUI';
import { copyLabelOption, LabelOption, OptionBuilder } from '../components/OptionBuilder';
import { PayAmountCounter } from '../components/PayAmountCounter';
import { SizeConstants } from '../constants/SizeConstants';
import AddExpenseViewModel from '../viewmodel/AddExpenseViewModel';
import { ExpensesPageParam } from './ExpensesPage';

export const ADD_EXPENSE_PAGE = 'AddExpensePage';

@Builder
export function AddExpensePageBuilder() {
  AddExpensePage();
}

@Component
struct AddExpensePage {
  @Consume('NavPathStack') pageStack: NavPathStack;
  @State private params: ExpensesPageParam = new ExpensesPageParam(0, '', 0);
  private viewModel: AddExpenseViewModel = new AddExpenseViewModel();
  @State private payers: LabelOption[] = this.viewModel.getPayersLabels;
  @State private daysOptions: LabelOption[] = [];
  @State private payedAmount: number = 0;
  private bottomOptions = new ArcButtonOptions({
    label: $r('app.string.add_expense'),
    styleMode: ArcButtonStyleMode.CUSTOM,
    fontSize: LengthMetrics.resource($r('app.float.list_header_font_size')),
    shadowEnabled: true,
    backgroundColor: ColorMetrics.resourceColor($r('app.color.brand_color')),
    fontColor: ColorMetrics.resourceColor($r('app.color.on_brand_color')),
    pressedFontColor: ColorMetrics.resourceColor($r('app.color.on_brand_color')),
    shadowColor: ColorMetrics.resourceColor($r('app.color.background_color')),
    onClick: async () => {
      const selectedPayer: LabelOption | undefined = this.payers.find((opt) => opt.selected);
      const selectedDays: LabelOption[] = this.daysOptions.filter((opt) => opt.selected);

      if (selectedPayer && selectedDays.length > 0 && this.payedAmount > 0) {
        await this.viewModel.addExpense(this.params.tripId, selectedPayer, selectedDays, this.payedAmount);
        this.pageStack.pop({ result: true });
      }
    }
  });

  // Keep exactly 1 decimal in state
  private round1(v: number): number {
    return Math.round(v * 10) / 10;
  }

  // Parent decides how state changes; component just tells us the delta
  onIncreased = (delta: number = 0.1) => {
    this.payedAmount = this.round1(this.payedAmount + delta);
  };
  onDecreased = (delta: number = 0.1) => {
    const next = this.round1(this.payedAmount - delta);
    this.payedAmount = next < 0 ? 0 : next;
  };

  @Builder
  labeledOptionsBuilder() {
    Column({ space: LengthMetrics.resource($r('app.float.margin_4')).value }) {
      Text($r('app.string.payer_label'))
        .fontSize($r('app.float.list_item_title_font_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.on_primary_color'))
        .textAlign(TextAlign.Start)
        .width(SizeConstants.FULL_PERCENT)
        .margin({ left: $r('app.float.margin_4') })

      Flex({
        wrap: FlexWrap.Wrap, space: {
          main: LengthMetrics.resource($r('app.float.margin_4')),
          cross: LengthMetrics.resource($r('app.float.margin_2'))
        }
      }) {
        ForEach(this.payers, (option: LabelOption) => {
          OptionBuilder({
            labelOption: option,
            onClick: () => {
              this.payers = this.payers.map((opt) => {
                return copyLabelOption(opt, {
                  selected: opt.label === option.label ? !opt.selected : false,
                });
              });
            }
          })
        }, (option: LabelOption) => `${option.label}-${option.selected}`)
      }

      Text($r('app.string.payed_days'))
        .fontSize($r('app.float.list_item_title_font_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.on_primary_color'))
        .textAlign(TextAlign.Start)
        .width(SizeConstants.FULL_PERCENT)
        .margin({ top: $r('app.float.margin_4'), left: $r('app.float.margin_4') })

      Flex({
        wrap: FlexWrap.Wrap, space: {
          main: LengthMetrics.resource($r('app.float.margin_4')),
          cross: LengthMetrics.resource($r('app.float.margin_2'))
        }
      }) {
        ForEach(this.daysOptions, (option: LabelOption) => {
          OptionBuilder({
            labelOption: option,
            fontSize: $r('app.float.char_chip_item_font_size'),
            onClick: () => {
              this.daysOptions = this.daysOptions.map((opt) => {
                return copyLabelOption(opt, {
                  selected: opt.label === option.label ? !opt.selected : opt.selected,
                });
              });
            }
          })
        }, (option: LabelOption) => `${option.label}-${option.selected}`)
      }

      Text($r('app.string.expense_amount'))
        .fontSize($r('app.float.list_item_title_font_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.on_primary_color'))
        .textAlign(TextAlign.Start)
        .width(SizeConstants.FULL_PERCENT)
        .margin({ top: $r('app.float.margin_4'), left: $r('app.float.margin_4') })

      PayAmountCounter({
        amount: this.payedAmount,
        onIncreased: this.onIncreased,
        onDecreased: this.onDecreased
      }).align(Alignment.Center)
    }
    .width(SizeConstants.FULL_PERCENT)
    .padding($r('app.float.margin_16'))
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    NavDestination() {
      Stack() {
        Scroll() {
          Column() {
            Text($r('app.string.new_expense_title'))
              .fontSize($r('app.float.list_header_font_size'))
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.on_primary_color'))
              .textAlign(TextAlign.Center)
              .width(SizeConstants.FULL_PERCENT)
            this.labeledOptionsBuilder()
          }
          .margin({ bottom: $r('app.float.margin_24'), top: $r('app.float.margin_16') })
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Start)
        }
        .width(SizeConstants.FULL_PERCENT)
        .height(SizeConstants.FULL_PERCENT)
        .padding($r('app.float.margin_16'))

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
      this.daysOptions = this.viewModel.getDaysOptions(this.params.days);
    })
  }
}
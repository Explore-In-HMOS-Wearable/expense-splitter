import { LengthMetrics } from '@kit.ArkUI';
import { SizeConstants } from '../constants/SizeConstants';
import { formatAmount } from '../pages/ExpensesPage';

@Component
export struct TripExpenseCard {
  @Prop
  @Require
  payerName: string;
  @Prop
  @Require
  totalAmount: number;
  @Prop
  @Require
  payedInDays: number[];
  @Require
  onCardClicked: () => void;

  build() {
    Row() {
      Column({ space: LengthMetrics.resource($r('app.float.margin_4')).value }) {
        Row() {
          Text(`${this.payerName}: `)
            .fontSize($r('app.float.char_chip_item_font_size'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.on_primary_color'))
            .textAlign(TextAlign.Start)

          Text(formatAmount(this.totalAmount))
            .fontSize($r('app.float.char_chip_item_font_size'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.on_primary_color'))
            .textAlign(TextAlign.Start)
            .padding({ left: $r('app.float.margin_4'), right: $r('app.float.margin_4') })
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)

        Row({ space: LengthMetrics.resource($r('app.float.margin_2')).value }) {
          Text(this.payedInDays.length > 1 ? $r('app.string.days_label') : $r('app.string.day_label'))
            .fontSize($r('app.float.list_item_title_font_size'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.on_primary_color'))
            .textAlign(TextAlign.Start)
          // .padding({ right: $r('app.float.margin_4') })
          ForEach(this.payedInDays, (day: number) => {
            Text(day.toString())
              .constraintSize({ minWidth: $r('app.float.min_expense_day_label_width') })
              .padding($r('app.float.margin_2'))
              .fontSize($r('app.float.list_item_title_font_size'))
              .fontColor($r('app.color.on_brand_color'))
              .backgroundColor($r('app.color.brand_color'))
              .textAlign(TextAlign.Center)
              .borderRadius($r('app.float.margin_24'))
          }, (day: number, index) => `${day}-${index}`)
        }

        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)

      if (this.payedInDays.length > 1) {
        SymbolGlyph($r('sys.symbol.arrow_right'))
          .fontColor([$r('app.color.on_primary_color')])
      }
    }
    .backgroundColor($r('app.color.primary_color'))
    .borderRadius($r('app.float.margin_16'))
    .justifyContent(FlexAlign.Center)
    .padding({
      left: $r('app.float.margin_12'),
      top: $r('app.float.margin_8'),
      right: $r('app.float.margin_12'),
      bottom: $r('app.float.margin_8')
    })
    .align(Alignment.Start)
    .clickEffect(this.payedInDays.length > 1 ? {
      scale: SizeConstants.SCALE_9,
      level: ClickEffectLevel.MIDDLE
    } : null)
    .onClick(() => {
      if (this.payedInDays.length > 1) {
        this.onCardClicked();
      }
    })
  }
}
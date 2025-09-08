import { SizeConstants } from '../constants/SizeConstants';

@Component
export struct PayAmountCounter {
  @Link
  amount: number;
  @Require
  onIncreased: (delta?: number) => void;
  @Require
  onDecreased: (delta?: number) => void;
  // internal long-press state
  @State private plusRepeats: number = 0;
  @State private minusRepeats: number = 0;

  // 0.1 → 1.0 → 10.0 as you keep holding (tune thresholds as you like)
  private stepForRepeats(repeats: number): number {
    if (repeats <= 6) {
      return 0.1;
    } // ~0–0.6s (duration=100ms)
    if (repeats <= 20) {
      return 1.0;
    } // ~0.6–2.0s
    if (repeats <= 100) {
      return 10.0;
    } // ~2.0–10.0s
    return 100.0; // >10.0s
  }

  private formatAmount(v: number): string {
    const r = Math.round(v * 10) / 10;
    return Number.isInteger(r) ? String(r) : r.toFixed(1);
  }

  build() {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.minus'))
          .fontColor([$r('app.color.on_brand_color')])
      }
      .constraintSize({ minWidth: $r('app.float.min_chip_button_width') })
      .padding($r('app.float.margin_6'))
      .backgroundColor($r('app.color.brand_color'))
      .type(ButtonType.Capsule)
      .onClick(() => this.onDecreased?.(0.1))
      .gesture(
        LongPressGesture({ repeat: true, duration: 100 })
          .onAction((_e) => {
            // first tick → set to 1, then increment
            this.minusRepeats = (this.minusRepeats === 0) ? 1 : this.minusRepeats + 1;
            const step = this.stepForRepeats(this.minusRepeats);
            this.onDecreased?.(step);
          })
          .onActionEnd(() => {
            this.minusRepeats = 0;
          })
      )

      Stack() {
        Text('88.8')
          .fontSize($r('app.float.payment_amount_font_size'))
          .textAlign(TextAlign.Center)
          .visibility(Visibility.Hidden)
        Text(this.formatAmount(this.amount))
          .fontColor($r('app.color.on_primary_color'))
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .maxFontSize($r('app.float.payment_amount_font_size'))
          .minFontSize($r('app.float.list_item_title_font_size'))
      }
      .layoutWeight(1)
      .alignContent(Alignment.Center)

      Button() {
        SymbolGlyph($r('sys.symbol.plus'))
          .fontColor([$r('app.color.on_brand_color')])
      }
      .constraintSize({ minWidth: $r('app.float.min_chip_button_width') })
      .padding($r('app.float.margin_6'))
      .backgroundColor($r('app.color.brand_color'))
      .type(ButtonType.Capsule)
      .onClick(() => this.onIncreased?.(0.1))
      .gesture(
        LongPressGesture({ repeat: true, duration: 100 })
          .onAction((_e: GestureEvent) => {
            this.plusRepeats = (this.plusRepeats === 0) ? 1 : this.plusRepeats + 1;
            const step = this.stepForRepeats(this.plusRepeats);
            this.onIncreased?.(step);
          })
          .onActionEnd(() => {
            this.plusRepeats = 0;
          })
      )
    }
    .width(SizeConstants.FULL_PERCENT)
    .backgroundColor($r('app.color.primary_color'))
    .borderRadius($r('app.float.margin_24'))
    .padding($r('app.float.margin_4'))
  }
}
import { SizeConstants } from '../constants/SizeConstants';

@Component
export struct TripDetailsCard {
  @Prop
  @Require
  type: string;
  @Prop
  @Require
  startDate: string;
  @Prop
  @Require
  endDate: string;
  @Require
  onCardClicked: () => void;

  build() {
    Row() {
      Column() {
        Text(this.type)
          .fontSize($r('app.float.char_chip_item_font_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.on_primary_color'))
          .textAlign(TextAlign.Start)

        Text(`${this.startDate}${this.endDate ? `-${this.endDate}` : ''}`)
          .fontSize($r('app.float.list_item_subtitle_font_size'))
          .fontColor($r('app.color.on_primary_color'))
          .textAlign(TextAlign.Start)
          .margin({ top: $r('app.float.margin_4') })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)

      SymbolGlyph($r('sys.symbol.arrow_right'))
        .fontColor([$r('app.color.on_primary_color')])
    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.primary_color'))
    .borderRadius($r('app.float.margin_16'))
    .padding({
      left: $r('app.float.margin_12'),
      top: $r('app.float.margin_8'),
      right: $r('app.float.margin_12'),
      bottom: $r('app.float.margin_8')
    })
    .align(Alignment.Start)
    .clickEffect({
      scale: SizeConstants.SCALE_9,
      level: ClickEffectLevel.MIDDLE
    })
    .onClick(() => this.onCardClicked())
  }
}
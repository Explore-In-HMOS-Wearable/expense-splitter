import { LengthMetrics, ArcButton, ArcButtonOptions, ArcButtonStyleMode, ColorMetrics, } from '@kit.ArkUI';
import { copyLabelOption, LabelOption, OptionBuilder } from '../components/OptionBuilder';
import { SizeConstants } from '../constants/SizeConstants';
import AddTripViewModel from '../viewmodel/AddTripViewModel';

export const ADD_TRIP_PAGE = 'AddTripPage';

@Builder
export function AddTripPageBuilder() {
  AddTripPage();
}

@Component
struct AddTripPage {
  @Consume('NavPathStack') pageStack: NavPathStack;
  private viewModel = new AddTripViewModel();
  @State private tripOptions: LabelOption[] = this.viewModel.getTripOptions;
  @State private daysOptions: LabelOption[] = this.viewModel.getDaysOptions;
  private bottomOptions = new ArcButtonOptions({
    label: $r('app.string.add_trip'),
    styleMode: ArcButtonStyleMode.CUSTOM,
    fontSize: LengthMetrics.resource($r('app.float.list_header_font_size')),
    shadowEnabled: true,
    backgroundColor: ColorMetrics.resourceColor($r('app.color.brand_color')),
    fontColor: ColorMetrics.resourceColor($r('app.color.on_brand_color')),
    pressedFontColor: ColorMetrics.resourceColor($r('app.color.on_brand_color')),
    shadowColor: ColorMetrics.resourceColor($r('app.color.background_color')),
    onClick: async () => {
      const selectedTrip = this.tripOptions.find((opt) => opt.selected);
      const selectedDays = this.daysOptions.find((opt) => opt.selected);

      if (selectedTrip && selectedDays) {
        await this.viewModel.addTrip(selectedTrip, selectedDays);
        this.pageStack.pop({ result: true });
      }
    }
  });

  @Builder
  labeledOptionsBuilder() {
    Column({ space: LengthMetrics.resource($r('app.float.margin_4')).value }) {
      Text($r('app.string.trip_type'))
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
        ForEach(this.tripOptions, (option: LabelOption) => {
          OptionBuilder({
            labelOption: option,
            onClick: () => {
              this.tripOptions = this.tripOptions.map((opt) => {
                return copyLabelOption(opt, {
                  selected: opt.label === option.label ? !opt.selected : false,
                });
              });
            }
          })
        }, (option: LabelOption) => `${option.label}-${option.selected}`)
      }

      Text($r('app.string.days_label'))
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
                  selected: opt.label === option.label ? !opt.selected : false,
                });
              });
            }
          })
        }, (option: LabelOption) => `${option.label}-${option.selected}`)
      }
    }
    .width(SizeConstants.FULL_PERCENT)
    .margin($r('app.float.margin_16'))
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }

  build() {
    NavDestination() {
      Stack() {
        Scroll() {
          Column() {
            Text($r('app.string.new_trip_title'))
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
  }
}
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
import { TripDetailsCard } from '../components/TripDetailsCard';
import { SizeConstants } from '../constants/SizeConstants';
import { Trip } from '../model/Trip';
import TripsViewModel from '../viewmodel/TripsViewModel';
import { ADD_TRIP_PAGE } from './AddTripPage';
import { EXPENSES_PAGE, ExpensesPageParam } from './ExpensesPage';


export const TRIPS_PAGE = 'TripsPage';

@Builder
export function TripsPageBuilder() {
  TripsPage();
}

@Builder
function buildHeader() {
  Text($r('app.string.trip_expenses'))
    .fontSize($r('app.float.list_header_font_size'))
    .fontWeight(FontWeight.Bold)
    .fontColor($r('app.color.on_primary_color'))
    .textAlign(TextAlign.Center)
    .width(SizeConstants.FULL_PERCENT)
    .margin({ top: $r('app.float.margin_6') })
}

@Component
struct TripsPage {
  @Consume('NavPathStack') private pageStack: NavPathStack;
  @State
  private viewModel: TripsViewModel = new TripsViewModel();
  private context: UIContext = this.getUIContext();
  private headerComponent: ComponentContent<Object> = new ComponentContent(this.context, wrapBuilder(buildHeader));
  private bottomOptions = new ArcButtonOptions({
    label: $r('app.string.new_trip'),
    styleMode: ArcButtonStyleMode.CUSTOM,
    fontSize: LengthMetrics.resource($r('app.float.list_header_font_size')),
    shadowEnabled: true,
    backgroundColor: ColorMetrics.resourceColor($r('app.color.brand_color')),
    fontColor: ColorMetrics.resourceColor($r('app.color.on_brand_color')),
    pressedFontColor: ColorMetrics.resourceColor($r('app.color.on_brand_color')),
    shadowColor: ColorMetrics.resourceColor($r('app.color.background_color')),
    onClick: () => {
      this.pageStack.pushPathByName(ADD_TRIP_PAGE, null, () => {
        this.viewModel.loadExpenses();
      });
    }
  });

  aboutToAppear(): void {
    this.viewModel.loadExpenses();
  }

  @Builder
  itemEnd(trip: Trip) {
    Row() {
      Button($r('app.string.delete_label'))
        .backgroundColor($r('app.color.brand_color'))
        .fontColor($r('app.color.on_brand_color'))
        .margin($r('app.float.margin_4'))
        .onClick(() => {
          this.viewModel.deleteTrip(trip);
        })
    }
    .padding($r('app.float.margin_4'))
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  build() {
    Stack() {
      ArcList({ header: this.headerComponent }) {
        if (this.viewModel.isEmptyData) {
          ArcListItem() {
            Text($r('app.string.empty_trips_message'))
              .fontSize($r('app.float.empty_list_font_size'))
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.on_primary_color'))
              .textAlign(TextAlign.Center)
              .width(SizeConstants.PERCENT_80)
          }
        }

        LazyForEach(this.viewModel.datasource, (trip: Trip) => {
          ArcListItem() {
            TripDetailsCard({
              type: trip.template,
              startDate: trip.startDate,
              endDate: trip.endDate,
              onCardClicked: () => {
                this.pageStack.pushPathByName(
                  EXPENSES_PAGE,
                  new ExpensesPageParam(trip.id, trip.template, trip.days)
                );
              }
            })
          }
          .width(SizeConstants.PERCENT_86)
          .swipeAction({
            end: {
              builder: () => {
                this.itemEnd(trip)
              },
              onAction: () => {
                this.context.animateTo({ duration: 1000 }, () => {
                  this.viewModel.deleteTrip(trip);
                })
              },
              actionAreaDistance: 56,
            }
          })
        }, (expense: Trip, index: number) => `${expense.id}-${index}`)

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
    .borderRadius($r('app.float.px_watch_radius'))
    .backgroundColor($r('app.color.background_color'))
    .alignContent(Alignment.Bottom)
  }
}
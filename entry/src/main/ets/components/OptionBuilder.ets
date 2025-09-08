export interface LabelOption {
  readonly label: string,
  readonly selected: boolean,
  readonly color?: ResourceColor,
  readonly selectedColor?: ResourceColor
}

export interface CopyLabelOption {
  label?: string,
  selected?: boolean,
  color?: ResourceColor,
  selectedColor?: ResourceColor,
}

export function copyLabelOption(
  labelOption: LabelOption,
  copyOptions: CopyLabelOption
): LabelOption {
  return {
    label: copyOptions.label ?? labelOption.label,
    selected: copyOptions.selected ?? labelOption.selected,
    color: copyOptions.color ?? labelOption.color,
    selectedColor: copyOptions.selectedColor ?? labelOption.selectedColor,
  }
}

interface OptionBuilderParam {
  readonly labelOption: LabelOption,
  readonly fontSize?: number | string | Resource | undefined,
  readonly onClick: Callback<void>
}

@Builder
export function OptionBuilder(options: OptionBuilderParam) {
  Button() {
    Text(`${options.labelOption.label}`)
      .fontSize(options.fontSize ?? $r('app.float.list_item_title_font_size'))
      .fontColor(options.labelOption.selected ? $r('app.color.on_brand_color') : $r('app.color.on_primary_color'))
      .textAlign(TextAlign.Center)
  }
  .constraintSize({ minWidth: $r('app.float.min_chip_button_width') })
  .padding($r('app.float.margin_10'))
  .backgroundColor(options.labelOption.selected ?
    (options.labelOption.selectedColor ?? $r('app.color.brand_color')) :
    (options.labelOption.color ?? $r('app.color.primary_color')))
  .type(ButtonType.Capsule)
  .onClick(() => {
    options.onClick();
  })
}
// 心情选择器组件
@Component
export struct MoodPicker {
  @Link selectedMood: string;
  @State private showPicker: boolean = false;

  aboutToAppear() {
    // 初始化默认心情
    if (!this.selectedMood) {
      this.selectedMood = '😊';
    }
  }

  build() {
    Column() {
      // 当前选择的心情
      Button(this.selectedMood)
        .fontSize(32)
        .fontColor($r('app.color.text_primary'))
        .backgroundColor($r('app.color.background'))
        .borderRadius($r('app.float.border_radius_medium'))
        .padding($r('app.float.padding_medium'))
        .onClick(() => {
          this.showPicker = !this.showPicker;
        })

      // 心情选择器弹出层
      if (this.showPicker) {
        Column() {
          Text('选择心情')
            .fontSize($r('app.float.font_size_medium'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .margin({ bottom: $r('app.float.padding_medium') })

          Grid() {
            ForEach(['😊', '😄', '😍', '🥳', '😎', '😌', '😐', '😔', '😢', '😠', '😴', '🤔'], (mood: string) => {
              GridItem() {
                Button(mood)
                  .fontSize(28)
                  .fontColor(this.selectedMood === mood ? Color.White : $r('app.color.text_primary'))
                  .backgroundColor(this.selectedMood === mood ? $r('app.color.primary_color') : $r('app.color.surface'))
                  .borderRadius($r('app.float.border_radius_medium'))
                  .padding($r('app.float.padding_medium'))
                  .onClick(() => {
                    this.selectedMood = mood;
                    this.showPicker = false;
                  })
              }
            })
          }
          .columnsTemplate('1fr 1fr 1fr 1fr')
          .rowsTemplate('1fr 1fr 1fr')
          .columnsGap($r('app.float.padding_small'))
          .rowsGap($r('app.float.padding_small'))
          .margin({ bottom: $r('app.float.padding_medium') })

          Button('关闭')
            .fontSize($r('app.float.font_size_medium'))
            .fontColor($r('app.color.text_secondary'))
            .backgroundColor($r('app.color.surface'))
            .borderRadius($r('app.float.border_radius_medium'))
            .width('100%')
            .onClick(() => {
              this.showPicker = false;
            })
        }
        .padding($r('app.float.padding_large'))
        .backgroundColor($r('app.color.surface'))
        .borderRadius($r('app.float.border_radius_large'))
        .shadow({ radius: 8, color: $r('app.color.shadow') })
        .margin({ top: $r('app.float.padding_small') })
      }
    }
  }
}
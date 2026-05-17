/**
 * 时间胶囊解锁弹窗
 */
import { Colors } from '../constants/Colors';
import { TimeCapsule } from '../model/TimeCapsule';

@CustomDialog
export struct TimeCapsuleUnlockDialog {
  controller: CustomDialogController;
  @Prop capsule: TimeCapsule | null = null;
  @State private isPlaying: boolean = true;
  private onView?: () => void;
  
  build() {
    Column() {
      // 标题
      Text('⏰ 时间胶囊已解锁！')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(Colors.TEXT_PRIMARY)
        .margin({ bottom: 20 })
      
      if (this.capsule) {
        // 动画效果
        Column() {
          // 解锁动画 - 星星闪烁效果
          Stack() {
            // 背景光晕
            Circle()
              .width(100)
              .height(100)
              .fill('rgba(255, 215, 0, 0.3)')
              .animation({
                duration: 1000,
                curve: Curve.EaseInOut,
                iterations: -1,
                playMode: PlayMode.Alternate
              })
            
            // 胶囊图标
            Text('📦')
              .fontSize(48)
              .animation({
                duration: 500,
                curve: Curve.EaseInOut,
                iterations: -1,
                playMode: PlayMode.AlternateReverse
              })
          }
          .width(120)
          .height(120)
          .margin({ bottom: 16 })
          
          // 笔记标题
          Text(this.capsule.memoTitle)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.TEXT_PRIMARY)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 8 })
          
          // 封存时间
          Text(`封存于 ${this.formatDate(this.capsule.createdAt)}`)
            .fontSize(14)
            .fontColor(Colors.TEXT_SECONDARY)
            .margin({ bottom: 4 })
          
          // 解锁时间
          Text(`今日解锁！`)
            .fontSize(14)
            .fontColor(Colors.PRIMARY)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 16 })
          
          // 心情
          Text(`心情：${this.capsule.mood}`)
            .fontSize(16)
            .margin({ bottom: 16 })
        }
        .width('100%')
        .padding(20)
        .backgroundColor(Colors.SURFACE)
        .borderRadius(16)
        .margin({ bottom: 20 })
      }
      
      // 查看按钮
      Button('查看笔记')
        .width('100%')
        .height(44)
        .backgroundColor(Colors.PRIMARY)
        .borderRadius(22)
        .fontColor(Color.White)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          if (this.onView) {
            this.onView();
          }
          this.controller.close();
        })
    }
    .width('85%')
    .padding(24)
    .backgroundColor(Color.White)
    .borderRadius(20)
    .shadow({ radius: 20, color: 'rgba(0,0,0,0.15)' })
  }
  
  private formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getMonth() + 1}月${date.getDate()}日`;
  }
}

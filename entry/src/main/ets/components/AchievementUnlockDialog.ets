/**
 * 成就解锁弹窗
 */
import { Colors } from '../constants/Colors';
import { Achievement, AchievementCategory } from '../model/Achievement';

@CustomDialog
export struct AchievementUnlockDialog {
  controller: CustomDialogController;
  @Prop achievement: Achievement | null = null;
  private onConfirm?: () => void;
  
  // 获取类别颜色
  getCategoryColor(category: AchievementCategory): string {
    switch (category) {
      case AchievementCategory.TIME:
        return '#6366F1';
      case AchievementCategory.MOOD:
        return '#EC4899';
      case AchievementCategory.CONTENT:
        return '#10B981';
      case AchievementCategory.SPECIAL:
        return '#F59E0B';
      default:
        return Colors.PRIMARY;
    }
  }
  
  // 获取类别名称
  getCategoryName(category: AchievementCategory): string {
    switch (category) {
      case AchievementCategory.TIME:
        return '⏰ 时间成就';
      case AchievementCategory.MOOD:
        return '😊 心情成就';
      case AchievementCategory.CONTENT:
        return '📝 内容成就';
      case AchievementCategory.SPECIAL:
        return '🌟 特殊成就';
      default:
        return '🏆 成就';
    }
  }
  
  build() {
    Column() {
      // 庆祝标题
      Text('🎉 成就解锁！')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(Colors.TEXT_PRIMARY)
        .margin({ bottom: 20 })
      
      if (this.achievement) {
        // 成就卡片
        Column() {
          // 图标
          Text(this.achievement.icon)
            .fontSize(56)
            .margin({ bottom: 12 })
          
          // 类别标签
          Text(this.getCategoryName(this.achievement.category))
            .fontSize(12)
            .fontColor(Color.White)
            .backgroundColor(this.getCategoryColor(this.achievement.category))
            .borderRadius(10)
            .padding({ left: 12, right: 12, top: 4, bottom: 4 })
            .margin({ bottom: 12 })
          
          // 成就名称
          Text(this.achievement.name)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.TEXT_PRIMARY)
            .margin({ bottom: 8 })
          
          // 描述
          Text(this.achievement.description)
            .fontSize(14)
            .fontColor(Colors.TEXT_SECONDARY)
            .textAlign(TextAlign.Center)
            .margin({ bottom: 16 })
          
          // 解锁时间
          Text(`解锁于 ${this.formatDate(this.achievement.unlockedAt || Date.now())}`)
            .fontSize(12)
            .fontColor('#999999')
        }
        .width('100%')
        .padding(24)
        .backgroundColor(Colors.SURFACE)
        .borderRadius(16)
        .border({ width: 2, color: this.getCategoryColor(this.achievement.category) })
        .margin({ bottom: 20 })
      }
      
      // 确认按钮
      Button('太棒了！')
        .width('100%')
        .height(44)
        .backgroundColor(Colors.PRIMARY)
        .borderRadius(22)
        .fontColor(Color.White)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          if (this.onConfirm) {
            this.onConfirm();
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
    return `${date.getMonth() + 1}月${date.getDate()}日 ${date.getHours()}:${date.getMinutes().toString().padStart(2, '0')}`;
  }
}

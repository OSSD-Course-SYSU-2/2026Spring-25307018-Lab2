// 成就徽章组件
@Component
export struct AchievementBadge {
  @Prop title: string = '';
  @Prop description: string = '';
  @Prop icon: string = '🏆';
  @Prop isUnlocked: boolean = false;
  @Prop progress: number = 0;
  @Prop requirement: number = 0;
  @Prop rarity: string = 'common';

  build() {
    Column({ space: $r('app.float.padding_small') }) {
      // 徽章图标
      Column() {
        Text(this.icon)
          .fontSize(32)
          .fontColor(this.isUnlocked ? Color.White : this.getRarityColor())
        
        if (this.isUnlocked) {
          Text('✓')
            .width(16)
            .height(16)
            .position({ x: '80%', y: '80%' })
        }
      }
      .width(60)
      .height(60)
      .backgroundColor(this.isUnlocked ? this.getRarityColor() : $r('app.color.surface'))
      .borderRadius(30)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .border({ width: 2, color: this.getRarityColor() })
      .margin({ bottom: $r('app.float.padding_small') })

      // 成就标题
      Text(this.title)
        .fontSize($r('app.float.font_size_medium'))
        .fontWeight(FontWeight.Medium)
        .fontColor(this.isUnlocked ? $r('app.color.text_primary') : $r('app.color.text_secondary'))
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      // 成就描述
      Text(this.description)
        .fontSize($r('app.float.font_size_small'))
        .fontColor($r('app.color.text_hint'))
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 2 })

      // 进度条（如果未解锁且有进度）
      if (!this.isUnlocked && this.requirement > 0) {
        Column({ space: 4 }) {
          Row() {
            Text(`${this.progress}/${this.requirement}`)
              .fontSize(12)
              .fontColor(Color.Gray)
              .layoutWeight(1)
            
            Text(`${Math.round((this.progress / this.requirement) * 100)}%`)
              .fontSize(12)
              .fontColor(this.getRarityColor())
          }
          
          // 进度条
          Stack() {
            // 背景
            Row()
              .width('100%')
              .height(4)
              .backgroundColor($r('app.color.divider'))
              .borderRadius(2)
            
            // 进度
            Row()
              .width(`${Math.min(100, (this.progress / this.requirement) * 100)}%`)
              .height(4)
              .backgroundColor(this.getRarityColor())
              .borderRadius(2)
          }
          .width('100%')
        }
        .margin({ top: $r('app.float.padding_small') })
      }

      // 稀有度标签
      if (!this.isUnlocked) {
        Text(this.getRarityText())
          .fontSize($r('app.float.font_size_small'))
          .fontColor(this.getRarityColor())
          .backgroundColor(this.getRarityColor())
          .opacity(0.1)
          .borderRadius(10)
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .margin({ top: $r('app.float.padding_small') })
      }
    }
    .padding($r('app.float.padding_medium'))
    .backgroundColor($r('app.color.surface'))
    .borderRadius($r('app.float.border_radius_medium'))
    .width(140)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .opacity(this.isUnlocked ? 1 : 0.7)
  }

  private getRarityColor(): ResourceColor {
    switch (this.rarity) {
      case 'common':
        return $r('app.color.text_secondary');
      case 'rare':
        return $r('app.color.secondary_color');
      case 'epic':
        return '#9C27B0';
      case 'legendary':
        return $r('app.color.warning');
      default:
        return $r('app.color.text_secondary');
    }
  }

  private getRarityText(): string {
    switch (this.rarity) {
      case 'common':
        return '普通';
      case 'rare':
        return '稀有';
      case 'epic':
        return '史诗';
      case 'legendary':
        return '传说';
      default:
        return '普通';
    }
  }
}
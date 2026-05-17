// 鼓励语卡片组件
@Component
export struct EncouragementCard {
  @Prop text: string = '';
  @Prop mood: string = '😊';
  @Prop category: string = 'daily';

  build() {
    Column({ space: $r('app.float.padding_small') }) {
      // 心情图标
      Row() {
        Text(this.mood)
          .fontSize(32)
          .margin({ right: $r('app.float.padding_small') })
        
        Column({ space: 4 }) {
          Text(this.getCategoryText())
            .fontSize($r('app.float.font_size_small'))
            .fontColor(this.getCategoryColor())
            .backgroundColor(this.getCategoryColor())
            .opacity(0.1)
            .borderRadius(10)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          
          Text('每日鼓励')
            .fontSize($r('app.float.font_size_small'))
            .fontColor($r('app.color.text_secondary'))
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      // 鼓励语文本
      Text(this.text)
        .fontSize($r('app.float.font_size_medium'))
        .fontColor($r('app.color.text_primary'))
        .textAlign(TextAlign.Center)
        .lineHeight(24)
        .margin({ top: $r('app.float.padding_medium') })

      // 装饰线
      Row()
        .width('80%')
        .height(1)
        .backgroundColor($r('app.color.divider'))
        .margin({ top: $r('app.float.padding_medium') })

      // 提示文字
      Text('每天一句，给你力量 💪')
        .fontSize($r('app.float.font_size_small'))
        .fontColor($r('app.color.text_hint'))
        .margin({ top: $r('app.float.padding_small') })
    }
    .padding($r('app.float.padding_large'))
    .backgroundColor(this.getCardColor())
    .borderRadius($r('app.float.border_radius_large'))
    .width('100%')
  }

  private getCategoryText(): string {
    switch (this.category) {
      case 'daily':
        return '每日';
      case 'achievement':
        return '成就';
      case 'motivation':
        return '激励';
      case 'funny':
        return '趣味';
      case 'mood':
        return '心情';
      default:
        return '每日';
    }
  }

  private getCategoryColor(): ResourceColor {
    switch (this.category) {
      case 'daily':
        return $r('app.color.primary_color');
      case 'achievement':
        return $r('app.color.success');
      case 'motivation':
        return $r('app.color.warning');
      case 'funny':
        return $r('app.color.secondary_color');
      case 'mood':
        return '#E91E63';
      default:
        return $r('app.color.primary_color');
    }
  }

  private getCardColor(): ResourceColor {
    switch (this.mood) {
      case '😊': // 开心
        return '#FFF9C4';
      case '😄': // 大笑
        return '#C8E6C9';
      case '😍': // 喜爱
        return '#F8BBD0';
      case '🥳': // 庆祝
        return '#E1BEE7';
      case '😎': // 酷
        return '#BBDEFB';
      case '😌': // 平静
        return '#B2EBF2';
      case '😐': // 一般
        return '#F5F5F5';
      case '😔': // 沮丧
        return '#CFD8DC';
      case '😢': // 哭泣
        return '#C5CAE9';
      case '😠': // 生气
        return '#FFCDD2';
      case '😴': // 困倦
        return '#D7CCC8';
      case '🤔': // 思考
        return '#FFECB3';
      default:
        return '#F5F5F5';
    }
  }
}
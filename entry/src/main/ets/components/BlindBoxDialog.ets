/**
 * 盲盒弹窗组件
 */
import { Colors } from '../constants/Colors';
import { BlindBoxReward, Rarity, RewardType } from '../model/BlindBox';

@CustomDialog
export struct BlindBoxDialog {
  controller: CustomDialogController;
  @Prop reward: BlindBoxReward | null = null;
  private onClaim?: () => void;
  
  // 获取稀有度颜色
  getRarityColor(rarity: Rarity): string {
    switch (rarity) {
      case Rarity.COMMON:
        return '#9E9E9E';
      case Rarity.RARE:
        return '#2196F3';
      case Rarity.EPIC:
        return '#9C27B0';
      case Rarity.LEGENDARY:
        return '#FFD700';
      default:
        return '#9E9E9E';
    }
  }
  
  // 获取稀有度名称
  getRarityName(rarity: Rarity): string {
    switch (rarity) {
      case Rarity.COMMON:
        return '普通';
      case Rarity.RARE:
        return '稀有';
      case Rarity.EPIC:
        return '史诗';
      case Rarity.LEGENDARY:
        return '传说';
      default:
        return '普通';
    }
  }
  
  // 获取类型名称
  getTypeName(type: RewardType): string {
    switch (type) {
      case RewardType.STORY_FRAGMENT:
        return '📜 剧情碎片';
      case RewardType.EMOTICON:
        return '😊 限定表情';
      case RewardType.BORDER:
        return '🖼️ 笔记边框';
      case RewardType.SPRITE_SKIN:
        return '🎭 精灵皮肤';
      case RewardType.AI_REPLY:
        return '🤖 AI回复';
      case RewardType.HIDDEN_TASK:
        return '📋 隐藏任务';
      default:
        return '🎁 神秘奖励';
    }
  }
  
  build() {
    Column() {
      // 标题
      Text('🎁 恭喜获得盲盒奖励！')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(Colors.TEXT_PRIMARY)
        .margin({ bottom: 20 })
      
      if (this.reward) {
        // 奖励卡片
        Column() {
          // 图标
          Text(this.reward.icon)
            .fontSize(48)
            .margin({ bottom: 12 })
          
          // 稀有度标签
          Text(this.getRarityName(this.reward.rarity))
            .fontSize(12)
            .fontColor(Color.White)
            .backgroundColor(this.getRarityColor(this.reward.rarity))
            .borderRadius(10)
            .padding({ left: 12, right: 12, top: 4, bottom: 4 })
            .margin({ bottom: 8 })
          
          // 奖励名称
          Text(this.reward.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.TEXT_PRIMARY)
            .margin({ bottom: 8 })
          
          // 类型
          Text(this.getTypeName(this.reward.type))
            .fontSize(14)
            .fontColor(Colors.TEXT_SECONDARY)
            .margin({ bottom: 12 })
          
          // 描述
          Text(this.reward.description)
            .fontSize(14)
            .fontColor(Colors.TEXT_SECONDARY)
            .textAlign(TextAlign.Center)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
        .padding(20)
        .backgroundColor(Colors.SURFACE)
        .borderRadius(16)
        .border({ width: 2, color: this.getRarityColor(this.reward.rarity) })
        .margin({ bottom: 20 })
        
        // 传说级特效提示
        if (this.reward.rarity === Rarity.LEGENDARY) {
          Text('✨ 传说级奖励！太幸运了！✨')
            .fontSize(14)
            .fontColor('#FFD700')
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 16 })
        }
      }
      
      // 领取按钮
      Button('太棒了！')
        .width('100%')
        .height(44)
        .backgroundColor(Colors.PRIMARY)
        .borderRadius(22)
        .fontColor(Color.White)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          if (this.onClaim) {
            this.onClaim();
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
}

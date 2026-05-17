import { Constants } from '../constants/Constants';
import { StorageManager } from '../utils/StorageManager';
import { Statistics } from '../model/Statistics';
import { Memo } from '../model/Memo';
import router from '@ohos.router';

@Entry
@Component
struct StatsPage {
  @State private totalMemos: number = 0;
  @State private completedMemos: number = 0;
  @State private pendingMemos: number = 0;
  @State private highPriorityMemos: number = 0;
  @State private moodRecordsCount: number = 0;
  @State private unlockedAchievements: number = 0;
  @State private totalAchievements: number = 0;
  @State private streakCount: number = 0;
  @State private isLoading: boolean = true;

  private storageManager: StorageManager = StorageManager.getInstance();

  aboutToAppear() {
    this.loadStats();
  }

  async loadStats(): Promise<void> {
    this.isLoading = true;
    try {
      const memos: Memo[] = await this.storageManager.getMemos();
      const stats: Statistics = Statistics.fromMemos(memos);
      
      this.totalMemos = stats.totalMemos;
      this.completedMemos = stats.completedMemos;
      this.pendingMemos = this.totalMemos - this.completedMemos;
      this.highPriorityMemos = memos.filter((m: Memo) => m.priority === 3).length;
      this.moodRecordsCount = stats.moodDistribution.size;
      this.streakCount = stats.streakDays;
      this.unlockedAchievements = 0;
      this.totalAchievements = 10;
    } catch (error) {
      console.error('加载统计数据失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column({ space: 0 }) {
      // 应用栏
      Row() {
        Button('返回')
          .fontSize($r('app.float.font_size_medium'))
          .fontColor($r('app.color.primary_color'))
          .backgroundColor(Color.Transparent)
          .onClick(() => router.back())
          .margin({ left: $r('app.float.padding_small') })
        
        Text($r('app.string.stats_title'))
          .fontSize($r('app.float.font_size_xlarge'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Button('刷新')
          .fontSize($r('app.float.font_size_medium'))
          .fontColor($r('app.color.primary_color'))
          .backgroundColor(Color.Transparent)
          .onClick(() => this.loadStats())
          .margin({ right: $r('app.float.padding_small') })
      }
      .width('100%')
      .height(56)
      .backgroundColor($r('app.color.surface'))
      .shadow({ radius: $r('app.float.appbar_elevation'), color: $r('app.color.shadow') })

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .color($r('app.color.primary_color'))
          Text('加载中...')
            .fontSize($r('app.float.font_size_medium'))
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: $r('app.float.padding_medium') })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Scroll() {
          Column({ space: $r('app.float.padding_large') }) {
            // 统计概览
            Column() {
              Text('📊 统计概览')
                .fontSize($r('app.float.font_size_large'))
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.text_primary'))
                .margin({ bottom: $r('app.float.padding_medium') })
              
              Grid() {
                GridItem() {
                  this.buildStatCard('📝', '总备忘录', this.totalMemos.toString(), Color.Blue)
                }
                
                GridItem() {
                  this.buildStatCard('✅', '已完成', this.completedMemos.toString(), Color.Green)
                }
                
                GridItem() {
                  this.buildStatCard('⏳', '待完成', this.pendingMemos.toString(), Color.Orange)
                }
                
                GridItem() {
                  this.buildStatCard('⚠️', '高优先级', this.highPriorityMemos.toString(), Color.Red)
                }
                
                GridItem() {
                  this.buildStatCard('😊', '心情记录', this.moodRecordsCount.toString(), Color.Orange)
                }
                
                GridItem() {
                  this.buildStatCard('🔥', '连续天数', this.streakCount.toString(), Color.Pink)
                }
                
                GridItem() {
                  this.buildStatCard('🏆', '成就解锁', `${this.unlockedAchievements}/${this.totalAchievements}`, '#9C27B0')
                }
                
                GridItem() {
                  this.buildStatCard('📈', '完成率', `${this.getCompletionRate()}%`, Color.Blue)
                }
              }
              .columnsTemplate('1fr 1fr')
              .rowsTemplate('1fr 1fr 1fr 1fr')
              .columnsGap($r('app.float.padding_medium'))
              .rowsGap($r('app.float.padding_medium'))
            }
            .padding($r('app.float.padding_large'))
            .backgroundColor($r('app.color.surface'))
            .borderRadius($r('app.float.border_radius_large'))
            .margin({ top: $r('app.float.padding_large'), left: $r('app.float.padding_large'), right: $r('app.float.padding_large') })

            // 成就展示
            Column() {
              Row() {
                Text('🏆 成就勋章')
                  .fontSize($r('app.float.font_size_large'))
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.text_primary'))
                  .layoutWeight(1)
                
                Text(`${this.unlockedAchievements}/${this.totalAchievements}`)
                  .fontSize($r('app.float.font_size_medium'))
                  .fontColor($r('app.color.text_secondary'))
              }
              .margin({ bottom: $r('app.float.padding_medium') })
              
              if (this.unlockedAchievements === 0) {
                Column() {
                  Text('📊')
                    .fontSize(48)
                    .margin({ bottom: $r('app.float.padding_medium') })
                  Text('暂无成就')
                    .fontSize($r('app.float.font_size_medium'))
                    .fontColor($r('app.color.text_secondary'))
                }
                .width('100%')
                .padding($r('app.float.padding_large'))
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
              } else {
                Text(`已解锁 ${this.unlockedAchievements} 个成就`)
                  .fontSize($r('app.float.font_size_medium'))
                  .fontColor($r('app.color.text_secondary'))
                  .textAlign(TextAlign.Center)
                  .width('100%')
                  .padding($r('app.float.padding_medium'))
              }
            }
            .padding($r('app.float.padding_large'))
            .backgroundColor($r('app.color.surface'))
            .borderRadius($r('app.float.border_radius_large'))
            .margin({ left: $r('app.float.padding_large'), right: $r('app.float.padding_large') })

            // 使用提示
            Column() {
              Text('💡 使用提示')
                .fontSize($r('app.float.font_size_large'))
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.text_primary'))
                .margin({ bottom: $r('app.float.padding_medium') })
              
              Column({ space: $r('app.float.padding_small') }) {
                Text('• 每天记录心情可以解锁心情相关成就')
                  .fontSize($r('app.float.font_size_medium'))
                  .fontColor($r('app.color.text_secondary'))
                
                Text('• 连续记录备忘录可以增加连续天数')
                  .fontSize($r('app.float.font_size_medium'))
                  .fontColor($r('app.color.text_secondary'))
                
                Text('• 完成高优先级任务可以获得特殊成就')
                  .fontSize($r('app.float.font_size_medium'))
                  .fontColor($r('app.color.text_secondary'))
                
                Text('• 使用不同标签可以解锁标签大师成就')
                  .fontSize($r('app.float.font_size_medium'))
                  .fontColor($r('app.color.text_secondary')
                )
              }
            }
            .padding($r('app.float.padding_large'))
            .backgroundColor($r('app.color.primary_light'))
            .borderRadius($r('app.float.border_radius_large'))
            .margin({ left: $r('app.float.padding_large'), right: $r('app.float.padding_large'), bottom: $r('app.float.padding_large') })
          }
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }

  @Builder
  buildStatCard(icon: string, title: string, value: string, color: ResourceColor): void {
    Column({ space: $r('app.float.padding_small') }) {
      Text(icon)
        .fontSize(24)
      
      Text(value)
        .fontSize($r('app.float.font_size_xlarge'))
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      
      Text(title)
        .fontSize($r('app.float.font_size_small'))
        .fontColor($r('app.color.text_secondary'))
    }
    .padding($r('app.float.padding_medium'))
    .backgroundColor($r('app.color.surface'))
    .borderRadius($r('app.float.border_radius_medium'))
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .height(100)
  }

  @Builder
  buildAchievementItem() {
    Column({ space: $r('app.float.padding_small') }) {
      Row() {
        // 成就图标
        Column() {
          Text('🏆')
            .fontSize(24)
            .margin({ right: $r('app.float.padding_medium') })
        }
        
        // 成就信息
        Column({ space: 4 }) {
          Row() {
            Text('成就解锁')
              .fontSize($r('app.float.font_size_medium'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
              .layoutWeight(1)
            
            Text('已解锁')
              .fontSize($r('app.float.font_size_small'))
              .fontColor($r('app.color.success'))
              .backgroundColor($r('app.color.success'))
              .opacity(0.1)
              .borderRadius(10)
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          }
          
          Text('完成备忘录记录即可解锁成就')
            .fontSize($r('app.float.font_size_small'))
            .fontColor($r('app.color.text_secondary'))
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
      }
    }
    .padding($r('app.float.padding_medium'))
    .backgroundColor($r('app.color.surface'))
    .borderRadius($r('app.float.border_radius_medium'))
    .margin({ bottom: $r('app.float.padding_small') })
  }

  getCompletionRate(): number {
    return this.totalMemos > 0 ? Math.round((this.completedMemos / this.totalMemos) * 100) : 0;
  }

  formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    
    return `${year}-${month}-${day} ${hours}:${minutes}`;
  }
}
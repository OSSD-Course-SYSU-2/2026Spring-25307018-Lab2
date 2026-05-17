import { Colors } from '../constants/Colors';
import { StorageManager } from '../utils/StorageManager';
import { Memo } from '../model/Memo';
import { Statistics } from '../model/Statistics';
import { EggManager } from '../utils/EggManager';
import { EmotionWeather, WeatherConfig } from '../model/EmotionWeather';
import { TimeCapsule } from '../model/TimeCapsule';
import { TimeCapsuleUnlockDialog } from '../components/TimeCapsuleUnlockDialog';
import { AnimationUtils } from '../utils/AnimationUtils';
import router from '@ohos.router';
import prompt from '@ohos.promptAction';

@Entry
@Component
struct Index {
  @State private memoList: Memo[] = [];
  @State private stats: Statistics = new Statistics();
  @State private isLoading: boolean = true;
  @State private selectedMood: string = '😊';
  
  // 【新增】动画状态
  @State private pageOpacity: number = 0;
  @State private fabScale: number = 1;
  @State private aiBtnScale: number = 1;
  // 【新增】卡片点击动效状态
  @State private moodScale: number = 1;
  @State private statCardScale: number = 1;
  @State private memoItemScale: number = 1;
  
  // 【新增】情绪天气相关
  @State private currentWeather: EmotionWeather = WeatherConfig.getDefaultWeather();
  @State private expiredCapsules: TimeCapsule[] = [];
  @State private currentCapsule: TimeCapsule | null = null;
  
  // 心情选项
  private moods: string[] = ['😊', '😄', '😍', '🥳', '😎', '😌', '😐', '😔', '😢', '😠', '😴', '🤔'];
  
  private storageManager: StorageManager = StorageManager.getInstance();
  private eggManager: EggManager = EggManager.getInstance();
  
  // 时间胶囊解锁弹窗
  private capsuleDialogController: CustomDialogController = new CustomDialogController({
    builder: TimeCapsuleUnlockDialog({
      capsule: this.currentCapsule,
      onView: async () => {
        if (this.currentCapsule) {
          await this.eggManager.unlockTimeCapsule(this.currentCapsule.id);
          this.currentCapsule = null;
        }
      }
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center
  });

  aboutToAppear() {
    this.loadData();
    // 页面淡入动画
    animateTo(AnimationUtils.getFadeInOptions(), () => {
      this.pageOpacity = 1;
    });
  }

  // 页面每次显示时刷新数据（解决从其他页面返回不刷新的问题）
  onPageShow() {
    console.info('[Index] onPageShow 触发');
    this.loadData();
  }

  async loadData(): Promise<void> {
    this.isLoading = true;
    try {
      // 加载备忘录列表
      const allMemos: Memo[] = await this.storageManager.getMemos();
      console.info('[Index] 加载笔记数量:', allMemos.length);
      if (allMemos.length > 0) {
        console.info('[Index] 第一条笔记:', allMemos[0].title);
      }
      
      // 按时间倒序排序，取最近5条
      this.memoList = allMemos.sort((a: Memo, b: Memo): number => b.createdAt - a.createdAt).slice(0, 5);
      
      // 生成统计数据
      this.stats = Statistics.fromMemos(allMemos);
      console.info('[Index] 统计数据 - 总笔记:', this.stats.totalMemos, '今日:', this.stats.todayMemos);
      
      // 【新增】计算今日情绪天气
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const todayMemos = allMemos.filter(m => m.createdAt >= today.getTime());
      this.currentWeather = this.eggManager.calculateTodayWeather(todayMemos);
      
      // 【新增】检查到期的时间胶囊
      this.expiredCapsules = await this.eggManager.getExpiredCapsules();
      if (this.expiredCapsules.length > 0) {
        this.currentCapsule = this.expiredCapsules[0];
        this.capsuleDialogController.open();
      }
      
    } catch (error) {
      console.error('加载数据失败:', error);
      prompt.showToast({ message: '加载数据失败', duration: 2000 });
    } finally {
      this.isLoading = false;
      console.info('[Index] 加载完成, isLoading:', this.isLoading);
    }
  }

  // 导航到统计页
  navigateToStats(): void {
    router.pushUrl({ url: 'pages/Statistics' });
  }

  // 导航到新建笔记页
  navigateToCreateMemo(): void {
    router.pushUrl({ url: 'pages/CreateMemo' });
  }

  // 导航到AI功能页
  navigateToAIPage(): void {
    router.pushUrl({ url: 'pages/AIPage' });
  }

  // 导航到笔记详情
  navigateToMemoDetail(memo: Memo): void {
    router.pushUrl({ 
      url: 'pages/MemoDetail',
      params: { memoId: memo.id }
    });
  }

  // 刷新数据
  async refreshData(): Promise<void> {
    await this.loadData();
    prompt.showToast({ message: '数据已刷新', duration: 1500 });
  }

  // 快速记录心情
  async recordQuickMood(mood: string): Promise<void> {
    this.selectedMood = mood;
    const today = new Date();
    
    // 创建简单的心情记录
    const memo = new Memo(
      `mood_${Date.now()}`,
      `心情记录 - ${this.getMoodDescription(mood)}`,
      `今天的心情是：${mood}\n记录时间：${this.formatTime(today)}`,
      false,
      2, // 中等优先级
      mood,
      ['心情', '日常'],
      Date.now(),
      Date.now()
    );
    
    await this.storageManager.saveMemo(memo);
    prompt.showToast({ message: `心情已记录：${mood}`, duration: 1500 });
    await this.loadData();
  }

  // 获取心情描述
  getMoodDescription(mood: string): string {
    const descriptions: Record<string, string> = {
      '😊': '开心', '😄': '大笑', '😍': '喜爱', '🥳': '庆祝',
      '😎': '酷', '😌': '平静', '😐': '一般', '😔': '沮丧',
      '😢': '哭泣', '😠': '生气', '😴': '困倦', '🤔': '思考'
    };
    return descriptions[mood] || '未知心情';
  }

  // 格式化时间
  formatTime(date: Date): string {
    return `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
  }

  // 格式化日期
  formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const memoDate = new Date(date.getFullYear(), date.getMonth(), date.getDate());
    
    if (memoDate.getTime() === today.getTime()) {
      return '今天';
    } else if (memoDate.getTime() === today.getTime() - 86400000) {
      return '昨天';
    } else {
      return `${date.getMonth() + 1}/${date.getDate()}`;
    }
  }

  // 获取今日日期
  getTodayDate(): string {
    const now = new Date();
    const year = now.getFullYear();
    const month = now.getMonth() + 1;
    const day = now.getDate();
    const weekDays = ['日', '一', '二', '三', '四', '五', '六'];
    const weekDay = weekDays[now.getDay()];
    
    return `${year}年${month}月${day}日 星期${weekDay}`;
  }
  
  // 【新增】获取天气渐变颜色
  private getWeatherGradientColors(): Array<[string, number]> {
    const colors = this.currentWeather.backgroundGradient;
    const result: Array<[string, number]> = [];
    const step = 1 / (colors.length - 1);
    
    for (let i = 0; i < colors.length; i++) {
      result.push([colors[i], i * step]);
    }
    
    return result;
  }
  
  // 【新增】天气粒子效果
  @Builder
  WeatherParticles() {
    Stack() {
      // 根据天气类型显示不同粒子
      if (this.currentWeather.weatherType === 'rainbow') {
        ForEach([1, 2, 3, 4, 5, 6], (item: number) => {
          Text('✨')
            .fontSize(14 + item * 2)
            .opacity(0.5)
            .position({ x: `${item * 15}%`, y: `${10 + item * 5}%` })
        })
      } else if (this.currentWeather.weatherType === 'sunny') {
        ForEach([1, 2, 3], (item: number) => {
          Text('☀️')
            .fontSize(20)
            .opacity(0.3)
            .position({ x: `${item * 30}%`, y: `${5 + item * 3}%` })
        })
      } else if (this.currentWeather.weatherType === 'starry') {
        ForEach([1, 2, 3, 4, 5, 6, 7, 8], (item: number) => {
          Text('⭐')
            .fontSize(8 + item)
            .opacity(0.4)
            .position({ x: `${item * 12}%`, y: `${item * 5}%` })
        })
      } else if (this.currentWeather.weatherType === 'rainy') {
        ForEach([1, 2, 3, 4, 5, 6, 7, 8], (item: number) => {
          Text('|')
            .fontSize(12)
            .fontColor('rgba(150, 200, 255, 0.3)')
            .position({ x: `${item * 12}%`, y: `${item * 10}%` })
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      // 【新增】情绪天气背景
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 135,
          colors: this.getWeatherGradientColors()
        })
      
      // 天气粒子效果层
      this.WeatherParticles()
      
      Column({ space: 0 }) {
        // 应用栏
        Row() {
          Text('趣味备忘录')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .textShadow({ radius: 2, color: 'rgba(0,0,0,0.5)', offsetX: 1, offsetY: 1 })
            .margin({ left: 20 })
          
          Blank()
          
          // 【新增】天气状态显示
          Row({ space: 4 }) {
            Text(this.currentWeather.weatherIcon)
              .fontSize(16)
            Text(this.currentWeather.weatherName)
              .fontSize(12)
              .fontColor(Color.White)
              .textShadow({ radius: 1, color: 'rgba(0,0,0,0.5)', offsetX: 1, offsetY: 1 })
          }
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('rgba(0,0,0,0.3)')
          .borderRadius(12)
          .margin({ right: 8 })
          
          Button('统计')
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor('rgba(0,0,0,0.3)')
            .borderRadius(20)
            .padding({ left: 12, right: 12 })
            .onClick(() => this.navigateToStats())
            .margin({ right: 16 })
        }
        .width('100%')
        .height(56)
        .backgroundColor('rgba(0,0,0,0.25)')

        if (this.isLoading) {
          // 加载中
          Column() {
            LoadingProgress()
              .color(Colors.PRIMARY)
            Text('加载中...')
              .fontSize(14)
              .fontColor(Colors.TEXT_SECONDARY)
              .margin({ top: 12 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        } else {
          Scroll() {
            Column({ space: 16 }) {
              // 欢迎卡片（渐变背景）
              Column() {
                Row() {
                  Column({ space: 6 }) {
                    Text('欢迎回来！')
                      .fontSize(22)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#FFFFFF')
                    
                    Text(`今天是${this.getTodayDate()}`)
                      .fontSize(13)
                      .fontColor('rgba(255,255,255,0.85)')
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  
                  // 心情标签
                  Column() {
                    Text(this.selectedMood)
                      .fontSize(36)
                  }
                  .width(60)
                  .height(60)
                  .backgroundColor('rgba(255,255,255,0.25)')
                  .borderRadius(18)
                  .justifyContent(FlexAlign.Center)
                }
                .width('100%')
                
                Divider()
                  .strokeWidth(1)
                  .color('rgba(255,255,255,0.3)')
                  .margin({ top: 16, bottom: 16 })
                
                Text('记录生活中的点点滴滴，让每一天都有意义 ✨')
                  .fontSize(14)
                  .fontColor('rgba(255,255,255,0.9)')
                  .textAlign(TextAlign.Start)
                  .lineHeight(22)
              }
              .width('100%')
              .padding(24)
              .linearGradient({
                angle: 135,
                colors: [[Colors.PRIMARY, 0], [Colors.SECONDARY, 1]]
              })
              .borderRadius(18)
              .shadow({ radius: 16, color: Colors.PRIMARY_DARK + '40' })
              .margin({ top: 16, left: 16, right: 16 })

              // 快速统计卡片
              Column() {
                Row() {
                  Text('📊 快速统计')
                    .fontSize(17)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Colors.TEXT_PRIMARY)
                  
                  Blank()
                  
                  Row({ space: 4 }) {
                    Text('更多')
                      .fontSize(13)
                      .fontColor(Colors.PRIMARY)
                    Text('→')
                      .fontSize(13)
                      .fontColor(Colors.PRIMARY)
                  }
                  .onClick(() => this.navigateToStats())
                }
                .width('100%')
                .margin({ bottom: 16 })
                
                Grid() {
                  GridItem() {
                    this.buildStatCard('📝', '总笔记', this.stats.totalMemos.toString(), Colors.PRIMARY)
                  }
                  
                  GridItem() {
                    this.buildStatCard('✅', '已完成', this.stats.completedMemos.toString(), Colors.SUCCESS)
                  }
                  
                  GridItem() {
                    this.buildStatCard('📅', '今日', this.stats.todayMemos.toString(), Colors.ACCENT)
                  }
                  
                  GridItem() {
                    this.buildStatCard('😊', '心情', this.stats.moodDistribution.size.toString(), Colors.SECONDARY)
                  }
                  
                  GridItem() {
                    this.buildStatCard('🔥', '连续打卡', `${this.stats.streakDays}天`, Colors.WARNING)
                  }
                  
                  GridItem() {
                    // 盲盒收藏入口
                    Column({ space: 6 }) {
                      Text('🎁')
                        .fontSize(22)
                      Text('盲盒收藏')
                        .fontSize(11)
                        .fontColor(Colors.TEXT_SECONDARY)
                    }
                    .width('100%')
                    .height(100)
                    .justifyContent(FlexAlign.Center)
                    .linearGradient({
                      angle: 135,
                      colors: [[Colors.ACCENT_LIGHT, 0], ['#FFFFFF', 1]]
                    })
                    .borderRadius(18)
                    .shadow({ radius: 12, color: Colors.SHADOW })
                    .border({ width: 1, color: Colors.ACCENT })
                    .onClick(() => router.pushUrl({ url: 'pages/BlindBoxCollection' }))
                  }
                }
                .columnsTemplate('1fr 1fr 1fr')
                .rowsTemplate('1fr 1fr')
                .columnsGap(12)
                .rowsGap(12)
                .height(224)
              }
              .width('100%')
              .padding(20)
              .linearGradient({
                angle: 135,
                colors: [['#FFFFFF', 0], ['#F8F9FF', 1]]
              })
              .borderRadius(18)
              .shadow({ radius: 12, color: Colors.SHADOW })
              .margin({ left: 16, right: 16 })

              // 最近备忘录卡片
              Column() {
                Row() {
                  Text('📋 最近笔记')
                    .fontSize(17)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Colors.TEXT_PRIMARY)
                  
                  Blank()
                  
                  Row({ space: 4 }) {
                    Text('查看全部')
                      .fontSize(13)
                      .fontColor(Colors.PRIMARY)
                    Text('→')
                      .fontSize(13)
                      .fontColor(Colors.PRIMARY)
                  }
                  .onClick(() => router.pushUrl({ url: 'pages/MemoList' }))
                }
                .width('100%')
                .margin({ bottom: 16 })
                
                if (this.memoList.length === 0) {
                  Column() {
                    Text('📝')
                      .fontSize(48)
                      .margin({ bottom: 12 })
                    
                    Text('暂无笔记')
                      .fontSize(15)
                      .fontColor(Colors.TEXT_SECONDARY)
                    
                    Text('点击下方按钮创建你的第一条笔记')
                      .fontSize(13)
                      .fontColor(Colors.TEXT_HINT)
                      .margin({ top: 6 })
                  }
                  .width('100%')
                  .padding(32)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                } else {
                  Column({ space: 12 }) {
                    ForEach(this.memoList, (memo: Memo) => {
                      this.buildMemoItem(memo)
                    })
                  }
                }
              }
              .width('100%')
              .padding(20)
              .linearGradient({
                angle: 135,
                colors: [['#FFFFFF', 0], ['#F8F9FF', 1]]
              })
              .borderRadius(18)
              .shadow({ radius: 12, color: Colors.SHADOW })
              .margin({ left: 16, right: 16 })

              // 心情标签卡片
              Column() {
                Text('😊 快速记录心情')
                  .fontSize(17)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Colors.TEXT_PRIMARY)
                  .margin({ bottom: 16 })

                Scroll() {
                  Row({ space: 10 }) {
                    ForEach(this.moods, (mood: string) => {
                      Column() {
                        Text(mood)
                          .fontSize(26)
                        Text(this.getMoodDescription(mood))
                          .fontSize(10)
                          .fontColor(Colors.TEXT_SECONDARY)
                          .margin({ top: 4 })
                      }
                      .padding(14)
                      .linearGradient({
                        angle: 135,
                        colors: [[Colors.MOOD_BACKGROUNDS[mood] || '#F5F5FA', 0], ['#FFFFFF', 1]]
                      })
                      .borderRadius(16)
                      .shadow({ radius: 8, color: Colors.SHADOW })
                      .scale({ x: this.moodScale, y: this.moodScale })
                      .onClick(() => {
                        // 点击缩放动画
                        animateTo(AnimationUtils.getScaleOptions(), () => {
                          this.moodScale = AnimationUtils.SCALE_PRESSED;
                        });
                        setTimeout(() => {
                          animateTo(AnimationUtils.getScaleOptions(), () => {
                            this.moodScale = AnimationUtils.SCALE_NORMAL;
                          });
                        }, 100);
                        this.recordQuickMood(mood);
                      })
                    })
                  }
                  .padding({ left: 4, right: 4 })
                }
                .scrollBar(BarState.Off)
                .scrollable(ScrollDirection.Horizontal)
              }
              .width('100%')
              .padding(20)
              .linearGradient({
                angle: 135,
                colors: [['#FFFFFF', 0], ['#F8F9FF', 1]]
              })
              .borderRadius(18)
              .shadow({ radius: 12, color: Colors.SHADOW })
              .margin({ left: 16, right: 16, bottom: 100 })
            }
          }
          .scrollable(ScrollDirection.Vertical)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Colors.BACKGROUND)
      .opacity(this.pageOpacity)  // 页面淡入动画

      // 悬浮操作按钮
      Column() {
        // AI功能按钮
        Column() {
          Text('🤖')
            .fontSize(22)
        }
        .width(52)
        .height(52)
        .linearGradient({
          angle: 135,
          colors: [[Colors.SECONDARY, 0], ['#5BB8FF', 1]]
        })
        .borderRadius(18)
        .shadow({ radius: 12, color: Colors.SECONDARY + '60' })
        .justifyContent(FlexAlign.Center)
        .scale({ x: this.aiBtnScale, y: this.aiBtnScale })
        .onClick(() => {
          // 点击缩放动画
          animateTo(AnimationUtils.getScaleOptions(), () => {
            this.aiBtnScale = AnimationUtils.SCALE_PRESSED;
          });
          setTimeout(() => {
            animateTo(AnimationUtils.getScaleOptions(), () => {
              this.aiBtnScale = AnimationUtils.SCALE_NORMAL;
            });
          }, 100);
          this.navigateToAIPage();
        })
        .margin({ bottom: 14 })

        // 新建笔记按钮
        Column() {
          Text('+')
            .fontSize(30)
            .fontColor(Colors.TEXT_ON_PRIMARY)
        }
        .width(56)
        .height(56)
        .linearGradient({
          angle: 135,
          colors: [[Colors.PRIMARY, 0], [Colors.PRIMARY_DARK, 1]]
        })
        .borderRadius(20)
        .shadow({ radius: 16, color: Colors.PRIMARY + '60' })
        .justifyContent(FlexAlign.Center)
        .scale({ x: this.fabScale, y: this.fabScale })
        .onClick(() => {
          // 点击缩放动画
          animateTo(AnimationUtils.getScaleOptions(), () => {
            this.fabScale = AnimationUtils.SCALE_PRESSED;
          });
          setTimeout(() => {
            animateTo(AnimationUtils.getScaleOptions(), () => {
              this.fabScale = AnimationUtils.SCALE_NORMAL;
            });
          }, 100);
          this.navigateToCreateMemo();
        })
      }
      .margin({ right: 20, bottom: 20 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildStatCard(icon: string, title: string, value: string, color: string): void {
    Column({ space: 6 }) {
      Text(icon)
        .fontSize(22)
      
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      
      Text(title)
        .fontSize(11)
        .fontColor(Colors.TEXT_SECONDARY)
    }
    .width('100%')
    .height(100)
    .padding(12)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .linearGradient({
      angle: 135,
      colors: [['#FFFFFF', 0], ['#F8F9FF', 1]]
    })
    .borderRadius(18)
    .shadow({ radius: 12, color: Colors.SHADOW })
    .border({ width: 1, color: Colors.BORDER })
    .scale({ x: this.statCardScale, y: this.statCardScale })
    .onClick(() => {
      // 点击缩放动画
      animateTo(AnimationUtils.getScaleOptions(), () => {
        this.statCardScale = AnimationUtils.SCALE_PRESSED;
      });
      setTimeout(() => {
        animateTo(AnimationUtils.getScaleOptions(), () => {
          this.statCardScale = AnimationUtils.SCALE_NORMAL;
        });
      }, 100);
    })
  }

  @Builder
  buildMemoItem(memo: Memo): void {
    Row() {
      // 心情图标（左侧）
      Column() {
        Text(memo.mood)
          .fontSize(22)
      }
      .width(44)
      .height(44)
      .linearGradient({
        angle: 135,
        colors: [[Colors.MOOD_BACKGROUNDS[memo.mood] || '#F5F5FA', 0], ['#FFFFFF', 1]]
      })
      .borderRadius(14)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .margin({ right: 14 })

      // 内容区域
      Column({ space: 6 }) {
        Row() {
          Text(memo.title || '无标题')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(Colors.TEXT_PRIMARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
          
          if (memo.isCompleted) {
            Text('✓')
              .fontSize(14)
              .fontColor(Colors.SUCCESS)
              .fontWeight(FontWeight.Bold)
          }
        }

        Text(memo.content || '无内容')
          .fontSize(13)
          .fontColor(Colors.TEXT_SECONDARY)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .lineHeight(18)

        Row() {
          // 标签
          if (memo.tags.length > 0) {
            Text(`#${memo.tags[0]}`)
              .fontSize(11)
              .fontColor(Colors.PRIMARY)
              .backgroundColor(Colors.PRIMARY_LIGHT)
              .borderRadius(6)
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          }
          
          Blank()
          
          // 时间（右侧）
          Text(this.formatDate(memo.createdAt))
            .fontSize(11)
            .fontColor(Colors.TEXT_HINT)
        }
        .margin({ top: 2 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(14)
    .linearGradient({
      angle: 135,
      colors: [['#FFFFFF', 0], ['#F8F9FF', 1]]
    })
    .borderRadius(18)
    .shadow({ radius: 12, color: Colors.SHADOW })
    .scale({ x: this.memoItemScale, y: this.memoItemScale })
    .onClick(() => {
      // 点击缩放动画
      animateTo(AnimationUtils.getScaleOptions(), () => {
        this.memoItemScale = AnimationUtils.SCALE_PRESSED;
      });
      setTimeout(() => {
        animateTo(AnimationUtils.getScaleOptions(), () => {
          this.memoItemScale = AnimationUtils.SCALE_NORMAL;
        });
      }, 100);
      this.navigateToMemoDetail(memo);
    })
  }
}
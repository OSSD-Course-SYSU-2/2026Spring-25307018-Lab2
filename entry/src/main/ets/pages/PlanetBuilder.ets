/**
 * 【笔记星球建造系统】星球建造页面
 * 碎片自动拼接成专属星球，笔记越多星球越完整
 */
import { Colors } from '../constants/Colors';
import { StorageManager } from '../utils/StorageManager';
import { PlanetManager } from '../utils/PlanetManager';
import { PlanetFragment, PlanetProgress, FragmentColor, FragmentSize } from '../model/PlanetFragment';
import { Memo } from '../model/Memo';
import { AnimationUtils } from '../utils/AnimationUtils';
import router from '@ohos.router';
import prompt from '@ohos.promptAction';

// 碎片位置信息接口
interface FragmentPosition {
  x: number;
  y: number;
  visible: boolean;
  opacity: number;
  scale: number;
}

@Entry
@Component
struct PlanetBuilderPage {
  @State private fragments: PlanetFragment[] = [];
  @State private progress: PlanetProgress = new PlanetProgress();
  @State private isLoading: boolean = true;
  @State private planetScale: number = 1.0;
  @State private rotation: number = 0;
  @State private showFragmentDetail: boolean = false;
  @State private selectedFragment: PlanetFragment | null = null;
  
  // 动画相关
  @State private starOpacity: number = 0.3;
  @State private meteorX: number = -100;
  @State private meteorY: number = 0;
  
  // 【新增】页面淡入动画状态
  @State private pageOpacity: number = 0;
  
  private storageManager: StorageManager = StorageManager.getInstance();
  private planetManager: PlanetManager = PlanetManager.getInstance();
  
  // 手势相关
  private pinchScale: number = 1.0;
  private lastRotation: number = 0;
  
  aboutToAppear() {
    this.loadData();
    this.startAnimations();
    // 页面淡入动画
    animateTo(AnimationUtils.getFadeInOptions(), () => {
      this.pageOpacity = 1;
    });
  }
  
  async loadData(): Promise<void> {
    this.isLoading = true;
    try {
      // 先加载现有碎片
      this.fragments = await this.planetManager.getFragments();
      console.info('[PlanetBuilder] 加载碎片数:', this.fragments.length);
      
      // 打印前3个碎片的memoId
      this.fragments.slice(0, 3).forEach((f: PlanetFragment, i: number) => {
        console.info(`[PlanetBuilder] 碎片${i}: id=${f.id}, memoId=${f.memoId}`);
      });
      
      // 如果没有碎片，但有笔记，则为现有笔记初始化碎片
      if (this.fragments.length === 0) {
        const memos = await this.storageManager.getMemos();
        if (memos.length > 0) {
          console.info('[PlanetBuilder] 为现有笔记初始化碎片，笔记数:', memos.length);
          const newFragments = this.planetManager.createFragmentsForMemos(memos);
          await this.planetManager.saveFragments(newFragments);
          this.fragments = newFragments;
        }
      }
      
      this.progress = await this.planetManager.getProgress();
    } catch (error) {
      console.error('加载星球数据失败:', error);
    } finally {
      this.isLoading = false;
    }
  }
  
  // 启动动画
  startAnimations(): void {
    // 星光闪烁动画
    setInterval(() => {
      this.starOpacity = 0.3 + Math.random() * 0.7;
    }, 1500);
    
    // 流星动画
    setInterval(() => {
      this.meteorX = -100;
      this.meteorY = Math.random() * 200;
      
      // 流星移动
      let steps = 0;
      const moveMeteor = setInterval(() => {
        this.meteorX += 15;
        this.meteorY += 10;
        steps++;
        if (steps > 30) {
          clearInterval(moveMeteor);
        }
      }, 50);
    }, 5000);
  }
  
  // 获取心情对应的背景渐变
  getBackgroundGradient(): LinearGradient {
    // 根据碎片颜色分布决定背景
    const colorCounts = new Map<FragmentColor, number>();
    for (const fragment of this.fragments) {
      const count = colorCounts.get(fragment.color) || 0;
      colorCounts.set(fragment.color, count + 1);
    }
    
    // 找出最多的颜色
    let dominantColor = FragmentColor.SILVER_WHITE;
    let maxCount = 0;
    colorCounts.forEach((count, color) => {
      if (count > maxCount) {
        maxCount = count;
        dominantColor = color;
      }
    });
    
    // 返回对应的渐变
    const gradients: Record<FragmentColor, [string, string]> = {
      [FragmentColor.WARM_ORANGE]: ['#1a1a2e', '#16213e'],
      [FragmentColor.LIGHT_BLUE]: ['#0f0f23', '#1a1a3e'],
      [FragmentColor.PURPLE_GRAY]: ['#1a1025', '#2d1b3d'],
      [FragmentColor.SILVER_WHITE]: ['#0d0d1a', '#1a1a2e']
    };
    
    const colors = gradients[dominantColor];
    return {
      angle: 180,
      colors: [[colors[0], 0], [colors[1], 1]]
    };
  }
  
  // 点击碎片跳转到对应笔记
  async onFragmentClick(fragment: PlanetFragment): Promise<void> {
    console.info('[PlanetBuilder] 点击碎片:', fragment.id, 'memoId:', fragment.memoId);
    
    if (!fragment.memoId) {
      prompt.showToast({ message: '该碎片没有关联笔记', duration: 2000 });
      return;
    }
    
    try {
      await router.pushUrl({
        url: 'pages/MemoDetail',
        params: { memoId: fragment.memoId }
      });
    } catch (error) {
      console.error('[PlanetBuilder] 跳转失败:', error);
      prompt.showToast({ message: '跳转失败，请重试', duration: 2000 });
    }
  }
  
  build() {
    Column({ space: 0 }) {
      // 顶部导航栏
      Row() {
        Button('返回')
          .fontSize(14)
          .fontColor('#FFD700')
          .backgroundColor(Color.Transparent)
          .onClick(() => router.back())
          .margin({ left: 16 })
        
        Text('🌟 笔记星球')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFD700')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Button('刷新')
          .fontSize(14)
          .fontColor('#FFD700')
          .backgroundColor(Color.Transparent)
          .onClick(() => this.loadData())
          .margin({ right: 16 })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#1a1a2e')
      
      if (this.isLoading) {
        // 加载中
        Column() {
          LoadingProgress()
            .color('#FFD700')
            .width(48)
            .height(48)
          Text('星球加载中...')
            .fontSize(14)
            .fontColor('#AAAAAA')
            .margin({ top: 12 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .linearGradient({
          angle: 180,
          colors: [['#0d0d1a', 0], ['#1a1a2e', 1]]
        })
      } else {
        // 星球展示区域
        Stack() {
          // 深空背景
          Column()
            .width('100%')
            .height('100%')
            .linearGradient(this.getBackgroundGradient())
          
          // 星光背景
          ForEach(Array.from({ length: 50 }), (_: ESObject, index: number) => {
            Text('✦')
              .fontSize(8 + Math.random() * 8)
              .fontColor(`rgba(255, 255, 255, ${this.starOpacity * (0.3 + Math.random() * 0.7)})`)
              .position({
                x: `${Math.random() * 100}%`,
                y: `${Math.random() * 100}%`
              })
          })
          
          // 流星
          if (this.meteorX > -50) {
            Text('☄️')
              .fontSize(16)
              .position({ x: this.meteorX, y: this.meteorY })
          }
          
          // 星球主体
          Column() {
            // 星球核心
            Stack() {
              // 星球基底（带手势）
              Column()
                .width(200 * this.planetScale)
                .height(200 * this.planetScale)
                .borderRadius(100 * this.planetScale)
                .linearGradient({
                  angle: 135,
                  colors: [['#2a2a4a', 0], ['#1a1a3a', 0.5], ['#0a0a2a', 1]]
                })
                .shadow({
                  radius: 30 * this.planetScale,
                  color: 'rgba(100, 100, 200, 0.3)',
                  offsetX: 0,
                  offsetY: 0
                })
                .gesture(
                  GestureGroup(GestureMode.Parallel,
                    PinchGesture()
                      .onActionUpdate((event: PinchGestureEvent) => {
                        this.planetScale = Math.max(0.5, Math.min(2.0, this.pinchScale * event.scale));
                      })
                      .onActionEnd(() => {
                        this.pinchScale = this.planetScale;
                      }),
                    RotationGesture()
                      .onActionUpdate((event: RotationGestureEvent) => {
                        this.rotation = this.lastRotation + event.angle;
                      })
                      .onActionEnd(() => {
                        this.lastRotation = this.rotation;
                      })
                  )
                )
              
              // 碎片层（可点击）
              ForEach(this.fragments.slice(0, 50), (fragment: PlanetFragment, index: number) => {
                this.FragmentBuilder(fragment, index)
              })
              
              // 星球光环
              Column()
                .width(220 * this.planetScale)
                .height(220 * this.planetScale)
                .borderRadius(110 * this.planetScale)
                .border({ width: 2, color: 'rgba(255, 215, 0, 0.3)' })
                .hitTestBehavior(HitTestMode.Transparent)
            }
            .width(250 * this.planetScale)
            .height(250 * this.planetScale)
            
            // 进度信息
            Column({ space: 8 }) {
              Text(`🌍 星球完整度: ${this.progress.completionPercent}%`)
                .fontSize(16)
                .fontColor('#FFD700')
                .fontWeight(FontWeight.Bold)
              
              Text(`✨ 碎片总数: ${this.fragments.length} 块`)
                .fontSize(14)
                .fontColor('#AAAAAA')
              
              Text(`📅 今日新增: ${this.progress.todayFragments} 块`)
                .fontSize(14)
                .fontColor('#AAAAAA')
            }
            .margin({ top: 24 })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ top: 80 })
        }
        .width('100%')
        .layoutWeight(1)
        
        // 底部统计信息
        Column() {
          Row() {
            this.StatItemBuilder('🟠', '暖橙', this.getColorCount(FragmentColor.WARM_ORANGE))
            this.StatItemBuilder('🔵', '淡蓝', this.getColorCount(FragmentColor.LIGHT_BLUE))
            this.StatItemBuilder('🟣', '紫灰', this.getColorCount(FragmentColor.PURPLE_GRAY))
            this.StatItemBuilder('⚪', '银白', this.getColorCount(FragmentColor.SILVER_WHITE))
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)
          
          Text('💡 双指缩放/旋转星球，点击碎片查看笔记')
            .fontSize(12)
            .fontColor('#888888')
            .margin({ top: 8 })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('rgba(26, 26, 46, 0.9)')
      }
    }
    .width('100%')
    .height('100%')
  }
  
  // 统计颜色数量
  getColorCount(color: FragmentColor): number {
    return this.fragments.filter((f: PlanetFragment): boolean => f.color === color).length;
  }
  
  // 计算碎片在球面上的2D位置
  getFragmentPosition(fragment: PlanetFragment): FragmentPosition {
    const theta = fragment.positionX * 2 * Math.PI;
    const phi = fragment.positionY * Math.PI;
    const radius = 90 * this.planetScale;
    
    const x3d = radius * Math.sin(phi) * Math.cos(theta);
    const y3d = radius * Math.sin(phi) * Math.sin(theta);
    const z3d = radius * Math.cos(phi);
    
    const rotRad = this.rotation * Math.PI / 180;
    const xRotated = x3d * Math.cos(rotRad) - z3d * Math.sin(rotRad);
    const zRotated = x3d * Math.sin(rotRad) + z3d * Math.cos(rotRad);
    
    const x2d = xRotated + 125 * this.planetScale;
    const y2d = y3d + 125 * this.planetScale;
    
    const depthScale = 0.6 + 0.4 * (zRotated / radius + 1) / 2;
    const opacity = 0.4 + 0.6 * (zRotated / radius + 1) / 2;
    const visible = zRotated >= -radius * 0.3;
    
    const result: FragmentPosition = {
      x: x2d,
      y: y2d,
      visible: visible,
      opacity: opacity,
      scale: depthScale
    };
    return result;
  }
  
  // 获取碎片大小
  getFragmentSize(fragment: PlanetFragment, depthScale: number): number {
    const baseSize = fragment.size === FragmentSize.LARGE ? 28 :
                     fragment.size === FragmentSize.MEDIUM ? 22 : 18;
    return baseSize * this.planetScale * depthScale;
  }
  
  @Builder
  FragmentBuilder(fragment: PlanetFragment, index: number): void {
    if (this.getFragmentPosition(fragment).visible) {
      Column() {
        Column()
          .width(this.getFragmentSize(fragment, this.getFragmentPosition(fragment).scale))
          .height(this.getFragmentSize(fragment, this.getFragmentPosition(fragment).scale))
          .borderRadius(this.getFragmentSize(fragment, this.getFragmentPosition(fragment).scale) * 0.25)
          .linearGradient({
            angle: 135,
            colors: [[fragment.getColorGradient()[0], 0], [fragment.getColorGradient()[1], 1]]
          })
          .border({ width: 1.5, color: 'rgba(255, 255, 255, 0.6)' })
          .shadow({ radius: 8, color: fragment.getColorHex() })
      }
      .position({
        x: this.getFragmentPosition(fragment).x - this.getFragmentSize(fragment, this.getFragmentPosition(fragment).scale) / 2,
        y: this.getFragmentPosition(fragment).y - this.getFragmentSize(fragment, this.getFragmentPosition(fragment).scale) / 2
      })
      .opacity(this.getFragmentPosition(fragment).opacity)
      .onClick(() => this.onFragmentClick(fragment))
    }
  }
  
  @Builder
  StatItemBuilder(icon: string, label: string, count: number): void {
    Column({ space: 4 }) {
      Text(icon)
        .fontSize(20)
      Text(label)
        .fontSize(12)
        .fontColor('#AAAAAA')
      Text(count.toString())
        .fontSize(14)
        .fontColor('#FFD700')
        .fontWeight(FontWeight.Bold)
    }
  }
}

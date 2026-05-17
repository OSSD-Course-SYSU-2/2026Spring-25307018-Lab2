/**
 * 情绪天气背景组件
 */
import { Colors } from '../constants/Colors';
import { EmotionWeather, WeatherType } from '../model/EmotionWeather';

@Component
export struct WeatherBackground {
  @Prop weather: EmotionWeather | null = null;
  @State private particleOffset: number = 0;
  
  aboutToAppear() {
    // 启动粒子动画
    this.startParticleAnimation();
  }
  
  private startParticleAnimation() {
    setInterval(() => {
      this.particleOffset = (this.particleOffset + 1) % 100;
    }, 50);
  }
  
  build() {
    Stack() {
      // 渐变背景
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 135,
          colors: this.getGradientColors()
        })
      
      // 粒子效果层
      if (this.weather) {
        this.ParticleEffect()
      }
    }
    .width('100%')
    .height('100%')
  }
  
  // 获取渐变颜色
  private getGradientColors(): Array<[string, number]> {
    if (!this.weather || !this.weather.backgroundGradient) {
      return [['#667EEA', 0], ['#764BA2', 1]];
    }
    
    const colors = this.weather.backgroundGradient;
    const result: Array<[string, number]> = [];
    const step = 1 / (colors.length - 1);
    
    for (let i = 0; i < colors.length; i++) {
      result.push([colors[i], i * step]);
    }
    
    return result;
  }
  
  // 粒子效果
  @Builder
  ParticleEffect() {
    if (!this.weather) return;
    
    Stack() {
      // 根据天气类型显示不同粒子
      if (this.weather.weatherType === WeatherType.RAINBOW) {
        // 彩虹效果 - 彩色星星
        ForEach([1, 2, 3, 4, 5, 6, 7, 8], (item: number) => {
          Text('✨')
            .fontSize(16 + Math.random() * 8)
            .opacity(0.6)
            .position({
              x: `${(item * 12 + this.particleOffset) % 100}%`,
              y: `${(item * 10 + Math.sin(this.particleOffset / 10) * 20) % 80}%`
            })
        })
      } else if (this.weather.weatherType === WeatherType.SUNNY) {
        // 晴天效果 - 阳光
        ForEach([1, 2, 3, 4, 5], (item: number) => {
          Text('☀️')
            .fontSize(20 + Math.random() * 10)
            .opacity(0.3)
            .position({
              x: `${(item * 20 + this.particleOffset * 0.5) % 100}%`,
              y: `${10 + item * 5}%`
            })
        })
      } else if (this.weather.weatherType === WeatherType.STARRY) {
        // 星空效果 - 星星
        ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], (item: number) => {
          Text('⭐')
            .fontSize(8 + Math.random() * 12)
            .opacity(0.4 + Math.sin(this.particleOffset / 5 + item) * 0.3)
            .position({
              x: `${(item * 10) % 100}%`,
              y: `${(item * 8 + Math.sin(this.particleOffset / 10 + item) * 5) % 60}%`
            })
        })
      } else if (this.weather.weatherType === WeatherType.RAINY) {
        // 雨夜效果 - 雨滴
        ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], (item: number) => {
          Text('|')
            .fontSize(16)
            .fontColor('rgba(150, 200, 255, 0.4)')
            .position({
              x: `${(item * 10) % 100}%`,
              y: `${(this.particleOffset * 2 + item * 10) % 100}%`
            })
        })
      } else if (this.weather.weatherType === WeatherType.CLOUDY) {
        // 多云效果 - 云朵
        ForEach([1, 2, 3], (item: number) => {
          Text('☁️')
            .fontSize(30 + item * 10)
            .opacity(0.3)
            .position({
              x: `${(item * 30 + this.particleOffset * 0.3) % 100}%`,
              y: `${10 + item * 15}%`
            })
        })
      } else if (this.weather.weatherType === WeatherType.BREEZY) {
        // 微风效果 - 落叶
        ForEach([1, 2, 3, 4, 5], (item: number) => {
          Text('🍃')
            .fontSize(16 + Math.random() * 8)
            .opacity(0.5)
            .position({
              x: `${(item * 20 + this.particleOffset) % 100}%`,
              y: `${(30 + item * 10 + Math.sin(this.particleOffset / 10) * 20) % 80}%`
            })
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}

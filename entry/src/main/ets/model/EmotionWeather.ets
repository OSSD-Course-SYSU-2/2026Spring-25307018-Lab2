/**
 * 情绪天气系统
 */
export class EmotionWeather {
  weatherType: WeatherType;
  backgroundGradient: string[];
  particleEffect: string;
  weatherName: string;
  weatherIcon: string;
  description: string;
  
  constructor(
    weatherType: WeatherType,
    backgroundGradient: string[],
    particleEffect: string,
    weatherName: string,
    weatherIcon: string,
    description: string
  ) {
    this.weatherType = weatherType;
    this.backgroundGradient = backgroundGradient;
    this.particleEffect = particleEffect;
    this.weatherName = weatherName;
    this.weatherIcon = weatherIcon;
    this.description = description;
  }
}

/**
 * 天气类型
 */
export enum WeatherType {
  SUNNY = 'sunny',       // 晴天（开心）
  RAINBOW = 'rainbow',   // 彩虹（非常开心）
  CLOUDY = 'cloudy',     // 多云（焦虑）
  RAINY = 'rainy',       // 雨夜（难过）
  BREEZY = 'breezy',     // 微风（平淡）
  STARRY = 'starry'      // 星空（平静）
}

/**
 * 天气配置
 */
export class WeatherConfig {
  // 心情到情绪值的映射
  static readonly MOOD_VALUES: Record<string, number> = {
    '😊': 0.8,   // 开心
    '😄': 1.0,   // 超级开心
    '😍': 0.9,   // 爱心
    '🥳': 0.85,  // 庆祝
    '😎': 0.75,  // 酷
    '😌': 0.5,   // 平静
    '😐': 0.0,   // 平淡
    '😔': -0.5,  // 难过
    '😢': -0.7,  // 哭泣
    '😠': -0.3,  // 生气
    '😴': 0.3,   // 困
    '🤔': -0.2   // 思考
  };
  
  // 天气配置
  static readonly WEATHERS: Record<WeatherType, EmotionWeather> = {
    [WeatherType.RAINBOW]: new EmotionWeather(
      WeatherType.RAINBOW,
      ['#FF6B9D', '#C44CE0', '#7B68EE', '#4ECDC4'],  // 彩虹渐变
      'rainbow_sparkle',
      '彩虹天',
      '🌈',
      '今天心情超棒！彩虹出现啦~'
    ),
    [WeatherType.SUNNY]: new EmotionWeather(
      WeatherType.SUNNY,
      ['#FFD93D', '#FF6B6B', '#4ECDC4'],  // 晴天渐变
      'sunshine',
      '晴天',
      '☀️',
      '阳光明媚，心情好好~'
    ),
    [WeatherType.STARRY]: new EmotionWeather(
      WeatherType.STARRY,
      ['#2D1B69', '#11998E', '#38EF7D'],  // 星空渐变
      'stars',
      '星空',
      '✨',
      '平静的夜晚，星星闪烁~'
    ),
    [WeatherType.BREEZY]: new EmotionWeather(
      WeatherType.BREEZY,
      ['#667EEA', '#764BA2', '#F093FB'],  // 微风渐变
      'wind',
      '微风',
      '🍃',
      '微风轻拂，岁月静好~'
    ),
    [WeatherType.CLOUDY]: new EmotionWeather(
      WeatherType.CLOUDY,
      ['#606C88', '#3F4C6B', '#606C88'],  // 多云渐变
      'clouds',
      '多云',
      '☁️',
      '云层飘过，心情起伏中...'
    ),
    [WeatherType.RAINY]: new EmotionWeather(
      WeatherType.RAINY,
      ['#1A1A2E', '#16213E', '#0F3460'],  // 雨夜渐变
      'rain',
      '雨夜',
      '🌧️',
      '雨滴落下，让思绪随雨飘散...'
    )
  };
  
  // 根据平均心情值计算天气
  static calculateWeather(averageMood: number): EmotionWeather {
    if (averageMood >= 0.85) {
      return WeatherConfig.WEATHERS[WeatherType.RAINBOW];
    } else if (averageMood >= 0.6) {
      return WeatherConfig.WEATHERS[WeatherType.SUNNY];
    } else if (averageMood >= 0.4) {
      return WeatherConfig.WEATHERS[WeatherType.STARRY];
    } else if (averageMood >= 0.2) {
      return WeatherConfig.WEATHERS[WeatherType.BREEZY];
    } else if (averageMood >= -0.3) {
      return WeatherConfig.WEATHERS[WeatherType.CLOUDY];
    } else {
      return WeatherConfig.WEATHERS[WeatherType.RAINY];
    }
  }
  
  // 计算今日平均心情
  static calculateAverageMood(moods: string[]): number {
    if (moods.length === 0) return 0.5;  // 默认平淡
    
    let total = 0;
    for (let i = 0; i < moods.length; i++) {
      const value = WeatherConfig.MOOD_VALUES[moods[i]];
      total += (value !== undefined ? value : 0);
    }
    
    return total / moods.length;
  }
  
  // 获取默认天气
  static getDefaultWeather(): EmotionWeather {
    return WeatherConfig.WEATHERS[WeatherType.BREEZY];
  }
}

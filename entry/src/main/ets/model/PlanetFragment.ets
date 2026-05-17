/**
 * 【笔记星球建造系统】星球碎片模型
 * 每保存一条笔记自动产出1块星球碎片
 */

/**
 * 碎片颜色类型 - 由心情决定
 */
export enum FragmentColor {
  WARM_ORANGE = 'warm_orange',   // 开心 - 暖橙星光
  LIGHT_BLUE = 'light_blue',     // 难过 - 淡蓝星云
  PURPLE_GRAY = 'purple_gray',   // 焦虑 - 紫灰星尘
  SILVER_WHITE = 'silver_white'  // 平淡 - 银白微光
}

/**
 * 碎片大小 - 由优先级决定
 */
export enum FragmentSize {
  SMALL = 1,   // 低优先级
  MEDIUM = 2,  // 中优先级
  LARGE = 3    // 高优先级
}

/**
 * 星球碎片数据模型
 */
export class PlanetFragment {
  id: string;              // 碎片唯一ID
  memoId: string;          // 关联的笔记ID
  color: FragmentColor;    // 碎片颜色（心情决定）
  size: FragmentSize;      // 碎片大小（优先级决定）
  pattern: string;         // 纹路类型（标签决定）
  starIntensity: number;   // 星光特效强度 (1-10)
  createdAt: number;       // 创建时间戳
  
  // 碎片在星球上的位置（用于拼接）
  positionX: number;       // X坐标 (0-1)
  positionY: number;       // Y坐标 (0-1)
  rotation: number;        // 旋转角度 (0-360)
  
  constructor(
    id: string,
    memoId: string,
    color: FragmentColor,
    size: FragmentSize,
    pattern: string,
    starIntensity: number,
    createdAt: number,
    positionX: number = Math.random(),
    positionY: number = Math.random(),
    rotation: number = Math.random() * 360
  ) {
    this.id = id;
    this.memoId = memoId;
    this.color = color;
    this.size = size;
    this.pattern = pattern;
    this.starIntensity = starIntensity;
    this.createdAt = createdAt;
    this.positionX = positionX;
    this.positionY = positionY;
    this.rotation = rotation;
  }
  
  // 根据心情获取碎片颜色
  static getColorFromMood(mood: string): FragmentColor {
    const happyMoods = ['😊', '😄', '😍', '🥳', '😎'];
    const sadMoods = ['😢', '😔'];
    const anxiousMoods = ['😠', '🤔'];
    
    if (happyMoods.includes(mood)) {
      return FragmentColor.WARM_ORANGE;
    } else if (sadMoods.includes(mood)) {
      return FragmentColor.LIGHT_BLUE;
    } else if (anxiousMoods.includes(mood)) {
      return FragmentColor.PURPLE_GRAY;
    } else {
      return FragmentColor.SILVER_WHITE;
    }
  }
  
  // 根据优先级获取碎片大小
  static getSizeFromPriority(priority: number): FragmentSize {
    if (priority === 3) return FragmentSize.LARGE;
    if (priority === 2) return FragmentSize.MEDIUM;
    return FragmentSize.SMALL;
  }
  
  // 根据优先级计算星光强度
  static calculateStarIntensity(priority: number): number {
    // 优先级越高，星光越强
    return priority * 3 + 1; // 低=4, 中=7, 高=10
  }
  
  // 根据标签生成纹路类型
  static getPatternFromTags(tags: string[]): string {
    if (tags.length === 0) return 'default';
    // 取第一个标签作为纹路基础
    const tag = tags[0].toLowerCase();
    const patternMap: Record<string, string> = {
      '工作': 'grid',
      '学习': 'dots',
      '生活': 'waves',
      '购物': 'circles',
      '健康': 'hearts',
      '旅行': 'compass',
      '想法': 'spiral',
      '灵感': 'star',
      '任务': 'checkers',
      '计划': 'lines'
    };
    return patternMap[tag] || 'default';
  }
  
  // 获取颜色对应的十六进制值
  getColorHex(): string {
    const colorMap: Record<FragmentColor, string> = {
      [FragmentColor.WARM_ORANGE]: '#FFB347',   // 暖橙
      [FragmentColor.LIGHT_BLUE]: '#87CEEB',    // 淡蓝
      [FragmentColor.PURPLE_GRAY]: '#B8A9C9',   // 紫灰
      [FragmentColor.SILVER_WHITE]: '#E8E8E8'   // 银白
    };
    return colorMap[this.color];
  }
  
  // 获取颜色对应的渐变色
  getColorGradient(): string[] {
    switch (this.color) {
      case FragmentColor.WARM_ORANGE:
        return ['#FFD700', '#FFA500'];
      case FragmentColor.LIGHT_BLUE:
        return ['#ADD8E6', '#87CEEB'];
      case FragmentColor.PURPLE_GRAY:
        return ['#C4B5D0', '#9B8AA8'];
      case FragmentColor.SILVER_WHITE:
        return ['#F5F5F5', '#DCDCDC'];
      default:
        return ['#F5F5F5', '#DCDCDC'];
    }
  }
  
  // 获取大小对应的像素值
  getSizePixels(): number {
    switch (this.size) {
      case FragmentSize.SMALL:
        return 50;
      case FragmentSize.MEDIUM:
        return 70;
      case FragmentSize.LARGE:
        return 90;
      default:
        return 50;
    }
  }
  
  toJson(): ESObject {
    return {
      id: this.id,
      memoId: this.memoId,
      color: this.color,
      size: this.size,
      pattern: this.pattern,
      starIntensity: this.starIntensity,
      createdAt: this.createdAt,
      positionX: this.positionX,
      positionY: this.positionY,
      rotation: this.rotation
    };
  }
  
  static fromJson(json: ESObject): PlanetFragment {
    return new PlanetFragment(
      json['id'] as string,
      json['memoId'] as string,
      json['color'] as FragmentColor,
      json['size'] as FragmentSize,
      json['pattern'] as string,
      json['starIntensity'] as number,
      json['createdAt'] as number,
      json['positionX'] as number,
      json['positionY'] as number,
      json['rotation'] as number
    );
  }
  
  // 生成唯一ID
  static generateId(): string {
    return `fragment_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
}

/**
 * 星球成长进度模型
 */
export class PlanetProgress {
  totalFragments: number;      // 总碎片数
  todayFragments: number;      // 今日碎片数
  averageMood: string;         // 平均心情
  completionPercent: number;   // 完成度百分比
  lastUpdated: number;         // 最后更新时间
  
  constructor(
    totalFragments: number = 0,
    todayFragments: number = 0,
    averageMood: string = '😊',
    completionPercent: number = 0,
    lastUpdated: number = Date.now()
  ) {
    this.totalFragments = totalFragments;
    this.todayFragments = todayFragments;
    this.averageMood = averageMood;
    this.completionPercent = completionPercent;
    this.lastUpdated = lastUpdated;
  }
  
  toJson(): ESObject {
    return {
      totalFragments: this.totalFragments,
      todayFragments: this.todayFragments,
      averageMood: this.averageMood,
      completionPercent: this.completionPercent,
      lastUpdated: this.lastUpdated
    };
  }
  
  static fromJson(json: ESObject): PlanetProgress {
    return new PlanetProgress(
      json['totalFragments'] as number || 0,
      json['todayFragments'] as number || 0,
      json['averageMood'] as string || '😊',
      json['completionPercent'] as number || 0,
      json['lastUpdated'] as number || Date.now()
    );
  }
}

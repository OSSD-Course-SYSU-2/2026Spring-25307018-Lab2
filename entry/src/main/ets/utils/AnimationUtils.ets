/**
 * 动画工具类 - 统一管理动画参数和效果
 * 动画时长统一200-300ms，节奏柔和不突兀
 */
export class AnimationUtils {
  // 动画时长常量
  static readonly DURATION_FAST: number = 200;      // 快速动画
  static readonly DURATION_NORMAL: number = 250;    // 正常动画
  static readonly DURATION_SLOW: number = 300;      // 慢速动画（淡入）
  
  // 缩放参数
  static readonly SCALE_PRESSED: number = 0.95;     // 按下时缩放
  static readonly SCALE_NORMAL: number = 1.0;       // 正常缩放
  static readonly SCALE_HOVER: number = 1.02;       // 悬浮时轻微放大
  
  // 阴影参数
  static readonly SHADOW_NORMAL: number = 8;        // 正常阴影
  static readonly SHADOW_HOVER: number = 16;        // 悬浮时阴影
  static readonly SHADOW_PRESSED: number = 4;       // 按下时阴影
  
  // 透明度参数
  static readonly OPACITY_FADE_IN_START: number = 0;    // 淡入开始
  static readonly OPACITY_NORMAL: number = 1;           // 正常透明度
  static readonly OPACITY_DISABLED: number = 0.6;       // 禁用透明度
  
  // 位移参数
  static readonly TRANSLATE_HOVER: number = -4;     // 悬浮时上浮距离
  
  // 动画曲线
  static readonly CURVE_SMOOTH: Curve = Curve.EaseInOut;      // 平滑曲线
  static readonly CURVE_BOUNCE: Curve = Curve.EaseOut;        // 弹性曲线
  static readonly CURVE_LINEAR: Curve = Curve.Linear;         // 线性曲线
  
  /**
   * 获取淡入动画选项
   */
  static getFadeInOptions(): AnimateParam {
    return {
      duration: AnimationUtils.DURATION_SLOW,
      curve: AnimationUtils.CURVE_SMOOTH,
      delay: 0,
      iterations: 1,
      playMode: PlayMode.Normal
    };
  }
  
  /**
   * 获取缩放动画选项
   */
  static getScaleOptions(): AnimateParam {
    return {
      duration: AnimationUtils.DURATION_FAST,
      curve: AnimationUtils.CURVE_BOUNCE,
      delay: 0,
      iterations: 1,
      playMode: PlayMode.Normal
    };
  }
  
  /**
   * 获取悬浮动画选项
   */
  static getHoverOptions(): AnimateParam {
    return {
      duration: AnimationUtils.DURATION_NORMAL,
      curve: AnimationUtils.CURVE_SMOOTH,
      delay: 0,
      iterations: 1,
      playMode: PlayMode.Normal
    };
  }
}

/**
 * 可复用的动画状态管理类
 * 用于管理组件的动画状态
 */
export class AnimationState {
  // 页面淡入状态
  pageOpacity: number = AnimationUtils.OPACITY_FADE_IN_START;
  
  // 按钮按压状态
  buttonScale: number = AnimationUtils.SCALE_NORMAL;
  
  // 卡片悬浮状态
  cardScale: number = AnimationUtils.SCALE_NORMAL;
  cardShadow: number = AnimationUtils.SHADOW_NORMAL;
  cardTranslateY: number = 0;
  
  /**
   * 重置页面淡入状态
   */
  resetPageState(): void {
    this.pageOpacity = AnimationUtils.OPACITY_FADE_IN_START;
  }
  
  /**
   * 重置按钮状态
   */
  resetButtonState(): void {
    this.buttonScale = AnimationUtils.SCALE_NORMAL;
  }
  
  /**
   * 重置卡片状态
   */
  resetCardState(): void {
    this.cardScale = AnimationUtils.SCALE_NORMAL;
    this.cardShadow = AnimationUtils.SHADOW_NORMAL;
    this.cardTranslateY = 0;
  }
}

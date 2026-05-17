// 统一风格颜色常量 - 简约现代卡片风
export class Colors {
  // 主色调 - 柔和的蓝色
  static readonly PRIMARY = '#4A90E2';
  static readonly PRIMARY_LIGHT = '#E3F2FD';
  static readonly PRIMARY_DARK = '#1565C0';
  
  // 辅助色 - 柔和的绿色
  static readonly SECONDARY = '#66BB6A';
  static readonly SECONDARY_LIGHT = '#E8F5E9';
  static readonly SECONDARY_DARK = '#388E3C';
  
  // 强调色 - 柔和的橙色
  static readonly ACCENT = '#FFA726';
  static readonly ACCENT_LIGHT = '#FFF3E0';
  static readonly ACCENT_DARK = '#F57C00';
  
  // 背景色
  static readonly BACKGROUND = '#F8F9FA';
  static readonly SURFACE = '#FFFFFF';
  static readonly SURFACE_VARIANT = '#F5F5F5';
  
  // 文字色
  static readonly TEXT_PRIMARY = '#212121';
  static readonly TEXT_SECONDARY = '#757575';
  static readonly TEXT_HINT = '#BDBDBD';
  static readonly TEXT_ON_PRIMARY = '#FFFFFF';
  static readonly TEXT_ON_SECONDARY = '#FFFFFF';
  
  // 状态色
  static readonly SUCCESS = '#4CAF50';
  static readonly WARNING = '#FF9800';
  static readonly ERROR = '#F44336';
  static readonly INFO = '#2196F3';
  
  // 边框和分割线
  static readonly DIVIDER = '#E0E0E0';
  static readonly BORDER = '#E0E0E0';
  
  // 阴影
  static readonly SHADOW = 'rgba(0, 0, 0, 0.08)';
  static readonly SHADOW_DARK = 'rgba(0, 0, 0, 0.12)';
  
  // 心情颜色映射
  static readonly MOOD_COLORS: Record<string, string> = {
    '😊': '#FFEB3B', // 开心 - 柔和黄色
    '😄': '#4CAF50', // 大笑 - 柔和绿色
    '😍': '#E91E63', // 喜爱 - 柔和粉色
    '🥳': '#9C27B0', // 庆祝 - 柔和紫色
    '😎': '#2196F3', // 酷 - 柔和蓝色
    '😌': '#009688', // 平静 - 柔和青色
    '😐': '#9E9E9E', // 一般 - 柔和灰色
    '😔': '#607D8B', // 沮丧 - 柔和蓝灰色
    '😢': '#3F51B5', // 哭泣 - 柔和深蓝色
    '😠': '#F44336', // 生气 - 柔和红色
    '😴': '#795548', // 困倦 - 柔和棕色
    '🤔': '#FF9800'  // 思考 - 柔和橙色
  };
  
  // 心情背景色
  static readonly MOOD_BACKGROUNDS: Record<string, string> = {
    '😊': '#FFFDE7', // 开心背景
    '😄': '#E8F5E9', // 大笑背景
    '😍': '#FCE4EC', // 喜爱背景
    '🥳': '#F3E5F5', // 庆祝背景
    '😎': '#E3F2FD', // 酷背景
    '😌': '#E0F2F1', // 平静背景
    '😐': '#FAFAFA', // 一般背景
    '😔': '#ECEFF1', // 沮丧背景
    '😢': '#E8EAF6', // 哭泣背景
    '😠': '#FFEBEE', // 生气背景
    '😴': '#EFEBE9', // 困倦背景
    '🤔': '#FFF3E0'  // 思考背景
  };
  
  // 优先级颜色
  static readonly PRIORITY_COLORS: Record<number, string> = {
    1: '#4CAF50', // 低 - 绿色
    2: '#FF9800', // 中 - 橙色
    3: '#F44336'  // 高 - 红色
  };
  
  // 图表颜色
  static readonly CHART_COLORS = [
    '#4A90E2', '#66BB6A', '#FFA726', '#FF7043',
    '#AB47BC', '#26C6DA', '#FFCA28', '#78909C'
  ];
}
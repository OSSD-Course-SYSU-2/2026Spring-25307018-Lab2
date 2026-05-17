/**
 * AI服务
 * 提供AI生成、润色、分析等功能
 * 注意：这是一个模拟实现，实际使用时需要接入真实的AI API
 */
import { Memo } from '../model/Memo';

// AI生成结果接口
export interface AIGenerateResult {
  title: string;
  content: string;
}

export class AIService {
  // 生成备忘录内容
  static async generateMemo(prompt: string): Promise<AIGenerateResult> {
    // 模拟AI生成延迟
    await AIService.delay(1500);
    
    // 根据提示词生成内容（模拟）
    const templates = AIService.getTemplates();
    const template = templates[Math.floor(Math.random() * templates.length)];
    
    const title = `AI生成: ${prompt}`;
    const content = template.replace(/{topic}/g, prompt);
    
    const result: AIGenerateResult = {
      title: title,
      content: content
    };
    
    return result;
  }
  
  // 润色备忘录内容
  static async polishMemo(content: string): Promise<string> {
    // 模拟AI润色延迟
    await AIService.delay(1000);
    
    // 简单的润色逻辑（模拟）
    let polished = content.trim();
    
    // 添加段落结构
    if (polished.length > 50 && !polished.includes('\n')) {
      const sentences = polished.split('。');
      if (sentences.length > 2) {
        polished = sentences.slice(0, Math.ceil(sentences.length / 2)).join('。') + '。\n\n' +
                   sentences.slice(Math.ceil(sentences.length / 2)).join('。');
      }
    }
    
    // 添加总结
    if (polished.length > 100) {
      polished += '\n\n【总结】\n以上内容已通过AI润色，结构更加清晰，表达更加流畅。';
    }
    
    return polished;
  }
  
  // 分析心情趋势
  static async analyzeMoodTrend(memos: Memo[]): Promise<string> {
    // 模拟AI分析延迟
    await AIService.delay(2000);
    
    if (memos.length === 0) {
      return '暂无心情记录数据，开始记录您的第一条心情吧！';
    }
    
    // 统计心情分布
    const moodCount: Map<string, number> = new Map();
    memos.forEach((memo: Memo) => {
      const count = moodCount.get(memo.mood) || 0;
      moodCount.set(memo.mood, count + 1);
    });
    
    // 找出最常见的心情
    let maxCount = 0;
    let mostCommonMood = '😊';
    moodCount.forEach((count: number, mood: string) => {
      if (count > maxCount) {
        maxCount = count;
        mostCommonMood = mood;
      }
    });
    
    // 生成分析报告
    const analysis = `📊 心情分析报告

📈 总体情况：
- 记录总数：${memos.length} 条
- 最常见心情：${mostCommonMood}（${maxCount} 次）

💡 AI建议：
${AIService.getMoodSuggestion(mostCommonMood)}

🎯 改善建议：
- 保持积极心态，记录生活中的美好瞬间
- 定期回顾心情记录，了解情绪变化规律
- 尝试不同的心情标签，丰富情感表达

📅 继续加油！每天记录一点，让生活更有意义！`;
    
    return analysis;
  }
  
  // 智能推荐标签
  static async suggestTags(content: string): Promise<string[]> {
    // 模拟AI推荐延迟
    await AIService.delay(800);
    
    const suggestedTags: string[] = [];
    const lowerContent = content.toLowerCase();
    
    // 基于关键词的标签推荐
    const tagKeywords: Record<string, string[]> = {
      '工作': ['工作', '会议', '项目', '任务', '报告', '计划'],
      '学习': ['学习', '读书', '课程', '笔记', '复习', '考试'],
      '生活': ['生活', '日常', '家庭', '朋友', '聚会'],
      '购物': ['购物', '买', '订单', '快递', '商品'],
      '健康': ['健康', '运动', '锻炼', '健身', '饮食', '睡眠'],
      '旅行': ['旅行', '旅游', '出行', '景点', '酒店', '机票'],
      '想法': ['想法', '思考', '灵感', '创意', '点子'],
      '计划': ['计划', '安排', '目标', '待办', '日程']
    };
    
    // 检查关键词并推荐标签
    Object.keys(tagKeywords).forEach((tag: string) => {
      const keywords = tagKeywords[tag];
      if (keywords.some((keyword: string) => lowerContent.includes(keyword))) {
        suggestedTags.push(tag);
      }
    });
    
    // 如果没有匹配的标签，添加默认标签
    if (suggestedTags.length === 0) {
      suggestedTags.push('日常');
    }
    
    // 最多返回5个标签
    return suggestedTags.slice(0, 5);
  }
  
  // 获取心情建议
  private static getMoodSuggestion(mood: string): string {
    const suggestions: Record<string, string> = {
      '😊': '您的心情整体很好！继续保持积极乐观的态度。',
      '😄': '您经常很开心，生活充满阳光！',
      '😍': '您充满爱心，善于发现生活中的美好！',
      '🥳': '您喜欢庆祝，懂得享受生活的每个时刻！',
      '😎': '您很自信，保持这种酷酷的状态！',
      '😌': '您心态平和，这是很好的心理状态。',
      '😐': '心情一般时，可以尝试做一些喜欢的事情来调节。',
      '😔': '如果感到沮丧，建议与朋友聊天或做些运动。',
      '😢': '难过时不要压抑，适当宣泄情绪是健康的。',
      '😠': '生气时可以深呼吸，冷静思考问题的根源。',
      '😴': '注意休息和睡眠，保持良好的作息习惯。',
      '🤔': '善于思考是好事，但也要注意适时放松。'
    };
    
    return suggestions[mood] || '继续保持记录心情的好习惯！';
  }
  
  // 获取内容模板
  private static getTemplates(): string[] {
    return [
      `📋 {topic}

✨ 主要内容：
• 第一点：详细描述
• 第二点：注意事项
• 第三点：后续计划

💡 备注：
可以根据实际情况调整内容。

📅 创建时间：${new Date().toLocaleDateString()}`,
      
      `📝 {topic}

【背景】
简要说明背景信息。

【目标】
明确要达成的目标。

【步骤】
1. 第一步操作
2. 第二步操作
3. 第三步操作

【预期结果】
描述预期的完成状态。`,
      
      `✅ {topic}

📌 要点记录：
- 关键信息1
- 关键信息2
- 关键信息3

🎯 重点提示：
注意重要事项和细节。

⏰ 时间节点：
设定合理的时间安排。`
    ];
  }
  
  // 模拟延迟
  private static delay(ms: number): Promise<void> {
    return new Promise<void>((resolve: Function) => {
      setTimeout(() => {
        resolve();
      }, ms);
    });
  }
}

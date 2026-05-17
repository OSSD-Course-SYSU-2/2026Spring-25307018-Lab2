// AI服务类 - 提供AI生成和润色功能
export class AIService {
  // 模拟AI生成笔记（实际项目中应该调用真实的AI接口）
  static async generateMemo(prompt: string): Promise<{title: string, content: string}> {
    // 模拟网络延迟
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    // 根据提示生成不同的笔记
    if (prompt.includes('购物') || prompt.includes('买')) {
      return {
        title: '购物清单',
        content: `📝 购物清单\n\n✅ 需要购买：\n1. 牛奶 2盒\n2. 鸡蛋 12个\n3. 面包 1袋\n4. 水果（苹果、香蕉）\n5. 蔬菜（西红柿、黄瓜）\n\n💡 提示：记得带购物袋，查看优惠券`
      };
    } else if (prompt.includes('学习') || prompt.includes('读书')) {
      return {
        title: '学习计划',
        content: `📚 学习计划\n\n🎯 目标：\n• 完成《ArkTS编程》第5-7章\n• 练习HarmonyOS UI组件\n• 完成项目实践\n\n⏰ 时间安排：\n• 上午9:00-11:00：理论学习\n• 下午2:00-4:00：实践练习\n• 晚上8:00-9:00：复习总结`
      };
    } else if (prompt.includes('工作') || prompt.includes('任务')) {
      return {
        title: '工作任务',
        content: `💼 工作任务清单\n\n🔧 技术任务：\n1. 修复首页UI布局问题\n2. 优化数据加载性能\n3. 添加单元测试\n\n📋 管理任务：\n• 团队周会准备\n• 项目进度报告\n• 代码审查\n\n⏳ 优先级：高优先级任务优先处理`
      };
    } else if (prompt.includes('旅行') || prompt.includes('旅游')) {
      return {
        title: '旅行计划',
        content: `✈️ 旅行计划\n\n📍 目的地：杭州西湖\n📅 时间：本周末\n\n🎒 准备物品：\n• 身份证、钱包、手机\n• 充电宝、数据线\n• 雨伞、防晒霜\n• 舒适的运动鞋\n\n🗺️ 行程安排：\n• 上午：西湖十景游览\n• 中午：西湖醋鱼午餐\n• 下午：灵隐寺参观\n• 晚上：河坊街夜市`
      };
    } else {
      return {
        title: '智能笔记',
        content: `✨ AI生成的笔记\n\n📌 主题：${prompt}\n\n💭 思考要点：\n1. 明确目标和需求\n2. 分解具体步骤\n3. 设置时间节点\n4. 准备必要资源\n5. 定期检查进度\n\n🎯 建议：\n• 保持专注，一次只做一件事\n• 设置合理的截止日期\n• 及时记录进展和问题\n• 定期回顾和调整计划`
      };
    }
  }
  
  // 模拟AI润色笔记
  static async polishMemo(content: string): Promise<string> {
    // 模拟网络延迟
    await new Promise(resolve => setTimeout(resolve, 800));
    
    // 简单的润色逻辑
    let polished = content;
    
    // 添加emoji和格式
    if (content.includes('完成') || content.includes('完成')) {
      polished = polished.replace(/完成/g, '✅ 完成');
    }
    
    if (content.includes('重要') || content.includes('重要')) {
      polished = polished.replace(/重要/g, '⭐ 重要');
    }
    
    if (content.includes('注意') || content.includes('注意')) {
      polished = polished.replace(/注意/g, '⚠️ 注意');
    }
    
    // 添加开头和结尾
    if (!polished.startsWith('✨ ')) {
      polished = '✨ AI润色版：\n\n' + polished;
    }
    
    if (!polished.includes('\n\n💡 小贴士：')) {
      polished += '\n\n💡 小贴士：保持笔记简洁明了，定期整理归档';
    }
    
    return polished;
  }
  
  // 分析心情趋势
  static async analyzeMoodTrend(memos: Memo[]): Promise<string> {
    if (memos.length === 0) {
      return '暂无足够数据进行分析';
    }
    
    // 统计心情
    const moodCount = new Map<string, number>();
    memos.forEach(memo => {
      const count = moodCount.get(memo.mood) || 0;
      moodCount.set(memo.mood, count + 1);
    });
    
    // 找到最频繁的心情
    let maxMood = '😊';
    let maxCount = 0;
    moodCount.forEach((count, mood) => {
      if (count > maxCount) {
        maxCount = count;
        maxMood = mood;
      }
    });
    
    // 生成分析报告
    const total = memos.length;
    const percentage = Math.round((maxCount / total) * 100);
    
    let analysis = `📊 心情分析报告\n\n`;
    analysis += `• 总笔记数：${total} 条\n`;
    analysis += `• 最常出现的心情：${maxMood}（${percentage}%）\n\n`;
    
    // 添加建议
    if (maxMood === '😊' || maxMood === '😄') {
      analysis += `💡 您最近心情不错！继续保持积极心态，记录生活中的美好瞬间。`;
    } else if (maxMood === '😢' || maxMood === '😔') {
      analysis += `💡 检测到较多负面情绪。建议：\n• 尝试记录感恩日记\n• 与朋友家人交流\n• 进行放松活动（散步、冥想）`;
    } else if (maxMood === '😴' || maxMood === '😪') {
      analysis += `💡 您可能有些疲惫。建议：\n• 保证充足睡眠\n• 合理安排休息时间\n• 尝试轻度运动`;
    } else {
      analysis += `💡 保持情绪平衡很重要。建议每天花几分钟记录心情，有助于情绪管理。`;
    }
    
    return analysis;
  }
  
  // 生成智能标签建议
  static async suggestTags(content: string): Promise<string[]> {
    await new Promise(resolve => setTimeout(resolve, 500));
    
    const tags: string[] = [];
    
    // 基于内容的关键词提取
    if (content.includes('工作') || content.includes('任务') || content.includes('项目')) {
      tags.push('工作', '任务');
    }
    
    if (content.includes('学习') || content.includes('读书') || content.includes('课程')) {
      tags.push('学习', '成长');
    }
    
    if (content.includes('购物') || content.includes('买') || content.includes('清单')) {
      tags.push('购物', '生活');
    }
    
    if (content.includes('旅行') || content.includes('旅游') || content.includes('计划')) {
      tags.push('旅行', '休闲');
    }
    
    if (content.includes('健康') || content.includes('运动') || content.includes('饮食')) {
      tags.push('健康', '运动');
    }
    
    if (content.includes('重要') || content.includes('紧急') || content.includes('优先')) {
      tags.push('重要', '紧急');
    }
    
    if (content.includes('想法') || content.includes('灵感') || content.includes('创意')) {
      tags.push('灵感', '创意');
    }
    
    // 去重
    return [...new Set(tags)].slice(0, 5); // 最多返回5个标签
  }
}
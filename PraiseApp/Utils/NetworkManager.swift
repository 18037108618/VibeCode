//
//  NetworkManager.swift
//  PraiseApp
//
//  网络管理工具 - 检测网络状态、验证关键词、调用AI生成
//

import Foundation
import Network

class NetworkManager {
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    private var isConnected: Bool = false
    
    init() {
        startMonitoring()
    }
    
    deinit {
        monitor.cancel()
    }
    
    // MARK: - Network Monitoring
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        monitor.start(queue: monitorQueue)
    }
    
    /// 检查网络可用性
    func checkNetworkAvailability() async -> Bool {
        // 等待一小段时间确保网络状态已更新
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1秒
        return isConnected
    }
    
    // MARK: - Keyword Validation
    
    struct KeywordValidationResult {
        let canValidate: Bool
        let isPositive: Bool
        let negativeWord: String? // 找到的负面词
    }
    
    /// 验证关键词是否具有赞美含义
    func validatePositiveKeywords(_ keywords: String) async -> KeywordValidationResult {
        // 使用本地词库进行验证
        return validateLocalPositiveKeywords(keywords)
    }
    
    /// 使用本地词库验证关键词
    private func validateLocalPositiveKeywords(_ keywords: String) -> KeywordValidationResult {
        // 负面词词库（大幅扩充）
        let negativeWords = Set([
            // 性格缺陷
            "笨", "蠢", "傻", "呆", "痴", "愚", "愚蠢", "愚笨", "笨蛋", "傻瓜",
            "懒", "懒惰", "懒散", "懒鬼", "懒虫", "怠惰", "惰性",
            "坏", "恶", "邪", "邪恶", "恶毒", "恶劣", "卑鄙", "卑劣", "龌龊",
            "丑", "丑陋", "难看", "恶心",
            "脏", "肮脏", "污秽", "邋遢",
            "假", "虚伪", "虚假", "做作", "装", "装逼",
            "骗", "欺骗", "骗子", "骗人", "忽悠",
            "贪", "贪婪", "贪心", "贪财", "贪图",
            "自私", "自利", "利己", "小气", "吝啬", "抠门", "铁公鸡",
            
            // 工作态度
            "拖延", "拖拉", "磨蹭", "敷衍", "应付", "马虎", "粗心", "草率",
            "不负责", "不靠谱", "不可靠", "不专业", "业余",
            "无能", "废物", "没用", "无用", "废柴", "菜鸡", "菜",
            "摸鱼", "划水", "偷懒", "怠工",
            
            // 人际关系
            "讨厌", "厌恶", "反感", "嫌弃",
            "孤僻", "冷漠", "冷淡", "无情", "绝情",
            "刻薄", "尖酸", "挑剔", "苛刻",
            "傲慢", "自大", "狂妄", "嚣张", "目中无人",
            "虚荣", "攀比", "炫耀", "显摆",
            "嫉妒", "妒忌", "眼红",
            "八卦", "碎嘴", "长舌", "搬弄是非",
            
            // 能力问题
            "差", "差劲", "很差", "太差", "烂", "糟糕", "糟", "垃圾", "辣鸡",
            "弱", "弱智", "智障", "白痴", "脑残",
            "失败", "失败者", "loser", "输家",
            
            // 情绪相关
            "暴躁", "易怒", "火爆", "脾气差", "脾气臭",
            "悲观", "消极", "负面", "丧", "颓废", "颓丧",
            "抱怨", "牢骚", "唠叨", "啰嗦",
            "固执", "死板", "顽固", "倔强", "一根筋",
            
            // 品德问题
            "不诚实", "撒谎", "说谎", "欺诈",
            "不孝", "忘恩负义", "白眼狼",
            "背叛", "出卖", "叛徒",
            "偷", "窃", "小偷", "盗",
            
            // 英文负面词
            "stupid", "lazy", "bad", "ugly", "terrible", "awful", "horrible",
            "useless", "worthless", "incompetent", "unreliable", "dishonest",
            "selfish", "greedy", "mean", "rude", "arrogant", "boring",
            "weak", "slow", "dumb", "idiot", "fool", "loser", "liar"
        ])
        
        // 赞美词词库
        let positiveWords = Set([
            "聪明", "智慧", "勤奋", "努力", "优秀", "出色", "卓越", "杰出",
            "认真", "负责", "专业", "敬业", "细心", "耐心", "热情", "积极",
            "善良", "友善", "真诚", "诚实", "可靠", "靠谱", "稳重", "踏实",
            "创新", "创意", "有才", "才华", "天赋", "能干", "厉害", "牛",
            "帅气", "漂亮", "美丽", "温柔", "体贴", "大方", "慷慨", "宽容",
            "坚强", "勇敢", "果断", "坚定", "毅力", "执着", "上进", "进取",
            "领导力", "影响力", "感染力", "魅力", "风度", "气质", "品味", "格调",
            "乐观", "开朗", "幽默", "风趣", "有趣", "活泼", "阳光",
            "博学", "渊博", "机智", "睿智", "敏锐", "灵活", "高效",
            "正直", "正义", "公正", "仁慈", "善解人意", "通情达理",
            "smart", "intelligent", "hardworking", "excellent", "outstanding",
            "professional", "dedicated", "creative", "innovative", "talented",
            "kind", "friendly", "honest", "reliable", "responsible",
            "brilliant", "amazing", "wonderful", "fantastic", "great"
        ])
        
        // 分割关键词
        let keywordList = keywords
            .components(separatedBy: CharacterSet(charactersIn: "、，,；; "))
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        // 检查是否包含负面词
        for keyword in keywordList {
            let lowerKeyword = keyword.lowercased()
            
            // 直接匹配
            if negativeWords.contains(lowerKeyword) || negativeWords.contains(keyword) {
                return KeywordValidationResult(canValidate: true, isPositive: false, negativeWord: keyword)
            }
            
            // 部分匹配（检查关键词是否包含负面词）
            for negWord in negativeWords {
                if keyword.contains(negWord) || lowerKeyword.contains(negWord.lowercased()) {
                    return KeywordValidationResult(canValidate: true, isPositive: false, negativeWord: negWord)
                }
            }
        }
        
        // 检查是否至少有一个赞美词
        for keyword in keywordList {
            let lowerKeyword = keyword.lowercased()
            if positiveWords.contains(lowerKeyword) || positiveWords.contains(keyword) {
                return KeywordValidationResult(canValidate: true, isPositive: true, negativeWord: nil)
            }
            
            // 部分匹配
            for posWord in positiveWords {
                if keyword.contains(posWord) || lowerKeyword.contains(posWord.lowercased()) {
                    return KeywordValidationResult(canValidate: true, isPositive: true, negativeWord: nil)
                }
            }
        }
        
        // 无法通过本地词库验证，默认允许（用户可能输入了我们词库中没有的赞美词）
        return KeywordValidationResult(canValidate: false, isPositive: true, negativeWord: nil)
    }
    
    // MARK: - AI Generation
    
    /// 通过网络API生成赞美文案（预留接口）
    func generatePraiseFromAPI(personName: String, keywords: String) async -> String? {
        // 这里预留网络API调用接口
        // 实际项目中可以接入 OpenAI、Claude、通义千问等 AI 服务
        return nil
    }
}

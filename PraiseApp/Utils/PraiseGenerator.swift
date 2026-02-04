//
//  PraiseGenerator.swift
//  PraiseApp
//
//  本地赞美文案生成器 - 确保包含所有用户输入的关键词
//

import Foundation

class PraiseGenerator {
    
    // MARK: - Templates
    
    /// 开场白模板
    private let openingTemplates = [
        "在这个人才辈出的时代，{name}宛如一颗璀璨的明星，",
        "纵观古今，能与{name}相提并论者寥寥无几！",
        "若要用一个词来形容{name}，那便是——完美！",
        "传说中的神仙人物，原来就在我们身边，TA就是{name}！",
        "自从认识{name}之后，我才知道什么叫做真正的优秀！",
        "世界上有两种人，一种是{name}，一种是想成为{name}的人！",
        "如果优秀有标准，那{name}就是标准本身！",
        "上天在创造{name}的时候一定打翻了调色板，",
        "{name}的出现，让我重新定义了什么叫做卓越！",
        "在{name}面前，所有的赞美之词都显得苍白无力，",
    ]
    
    /// 关键词描述模板（确保包含关键词）
    private let keywordTemplates = [
        "TA的{keyword}简直让人叹为观止，",
        "说到{keyword}，{name}绝对是当之无愧的代言人！",
        "TA那{keyword}的品质，已经到了炉火纯青的境界，",
        "{keyword}二字仿佛就是为{name}量身定制的，",
        "TA用实际行动诠释了什么是真正的{keyword}！",
        "在{keyword}方面，{name}简直是开挂的存在！",
        "TA的{keyword}不是一般的厉害，而是厉害到让人窒息！",
        "如果{keyword}能打分，{name}肯定是满分王者！",
        "论{keyword}，没有人能出其右，",
        "TA把{keyword}演绎到了极致，",
    ]
    
    /// 结尾赞叹模板
    private let closingTemplates = [
        "能与这样的人共事，是我们莫大的荣幸！特此表彰，以资鼓励！",
        "未来可期，让我们一起见证{name}更加辉煌的明天！",
        "此等人才，当以最高规格礼遇！",
        "有{name}在，我们的团队必将所向披靡、战无不胜！",
        "让我们为{name}献上最热烈的掌声！",
        "愿{name}继续发光发热，照亮我们前行的道路！",
        "这样的宝藏同事，必须锁死！永远不能放走！",
        "{name}，你就是我们心中永远的MVP！",
        "感谢宇宙将{name}这样的天才送到我们身边！太感恩了！",
        "此证书虽轻，但承载着我们对{name}满满的敬意与赞叹！",
    ]
    
    /// 额外的赞美词句
    private let praiseAdjectives = [
        "惊为天人", "叹为观止", "前无古人", "后无来者",
        "天纵奇才", "鹤立鸡群", "出类拔萃", "登峰造极",
        "炉火纯青", "无与伦比", "独步天下", "技压群雄",
        "才华横溢", "光芒万丈", "闪闪发光", "熠熠生辉"
    ]
    
    // MARK: - Public Methods
    
    /// 生成本地赞美文案（确保包含所有关键词）
    func generateLocalPraise(personName: String, keywords: String) -> String {
        let keywordList = parseKeywords(keywords)
        var praise = ""
        
        // 开场白
        let opening = openingTemplates.randomElement() ?? openingTemplates[0]
        praise += opening.replacingOccurrences(of: "{name}", with: personName)
        
        // 为每个关键词添加描述（确保所有关键词都被包含）
        for (index, keyword) in keywordList.enumerated() {
            // 使用不同的模板，避免重复
            let templateIndex = index % keywordTemplates.count
            var template = keywordTemplates[templateIndex]
            
            // 添加过渡词
            if index > 0 {
                let transitions = ["不仅如此，", "更重要的是，", "值得一提的是，", "令人惊叹的是，", "此外，", "同时，"]
                let transition = transitions[index % transitions.count]
                template = transition + template
            }
            
            praise += template
                .replacingOccurrences(of: "{name}", with: personName)
                .replacingOccurrences(of: "{keyword}", with: keyword)
        }
        
        // 如果关键词较少，添加额外的赞美词
        if keywordList.count < 3 {
            let adjective = praiseAdjectives.randomElement() ?? praiseAdjectives[0]
            praise += "简直\(adjective)！"
        }
        
        // 结尾
        let closing = closingTemplates.randomElement() ?? closingTemplates[0]
        praise += closing.replacingOccurrences(of: "{name}", with: personName)
        
        return praise
    }
    
    /// 生成随机赞美文案（确保包含所有关键词）
    func generateRandomPraise(personName: String, keywords: String) -> String {
        let keywordList = parseKeywords(keywords)
        
        // 将所有关键词用顿号连接
        let allKeywords = keywordList.joined(separator: "、")
        
        // 为每个关键词生成单独的赞美句
        var keywordPraises: [String] = []
        for keyword in keywordList {
            let praises = [
                "\(keyword)得无可挑剔",
                "\(keyword)到令人发指",
                "\(keyword)得让人窒息",
                "把\(keyword)发挥到了极致",
                "\(keyword)程度简直爆表"
            ]
            keywordPraises.append(praises.randomElement() ?? praises[0])
        }
        let keywordPraiseStr = keywordPraises.joined(separator: "、")
        
        let templates = [
            """
            诸位请看！{name}大驾光临！此人{allKeywords}得令人发指，简直是上天派来拯救我们的天使！\
            TA\(keywordPraiseStr)，让人忍不住想要顶礼膜拜。\
            有{name}在的地方，就有希望和奇迹！特此颁发荣誉证书，以表彰这位人间瑰宝！
            """,
            """
            各位各位，今天要隆重介绍一位大神级人物——{name}！\
            TA不仅{allKeywords}，而且还{adjective}得令人窒息！\
            在TA面前，所有的困难都是纸老虎。{name}把{keywordPraiseStr}，\
            真正的优秀是独一无二的！向{name}致敬！
            """,
            """
            如果世界上有完美的存在，那一定是{name}！\
            TA那{allKeywords}的品质，已经到了{adjective}的境界。\
            每次看到{name}，我都在想：这到底是何方神圣？\
            TA{keywordPraiseStr}，感谢命运让我们相遇，您就是我们心中永远的传奇！
            """,
            """
            隆重宣布：{name}荣获"年度最佳{allKeywords}人物"称号！\
            TA{keywordPraiseStr}，每一天都在创造新的不可能。\
            如果优秀可以量化，{name}的数值一定会让系统崩溃！{adjective}如TA，当之无愧！
            """,
            """
            致我们最{allKeywords}的{name}：您的出现，如同春风拂面，温暖而又震撼。\
            您{keywordPraiseStr}，让我们望尘莫及却又心生向往。\
            愿您的光芒永远不灭，照亮我们前行的每一步！致敬，传奇！
            """
        ]
        
        let template = templates.randomElement() ?? templates[0]
        let adjective = praiseAdjectives.randomElement() ?? praiseAdjectives[0]
        
        return template
            .replacingOccurrences(of: "{name}", with: personName)
            .replacingOccurrences(of: "{allKeywords}", with: allKeywords)
            .replacingOccurrences(of: "{adjective}", with: adjective)
    }
    
    // MARK: - Private Methods
    
    /// 解析关键词字符串为数组
    private func parseKeywords(_ keywords: String) -> [String] {
        return keywords
            .components(separatedBy: CharacterSet(charactersIn: "、，,；; "))
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}

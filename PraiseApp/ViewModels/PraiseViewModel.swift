//
//  PraiseViewModel.swift
//  PraiseApp
//
//  处理赞美文案生成的业务逻辑
//

import SwiftUI
import Combine

@MainActor
class PraiseViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var personName: String = ""
    @Published var keywords: String = ""
    @Published var praiseText: String = ""
    @Published var isLoading: Bool = false
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    
    // MARK: - Private Properties
    private let networkManager = NetworkManager()
    private let praiseGenerator = PraiseGenerator()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Methods
    
    /// 生成赞美文案
    func generatePraise() {
        // 1. 验证被夸人姓名
        guard validatePersonName() else { return }
        
        // 2. 验证优点关键词格式
        guard validateKeywordsFormat() else { return }
        
        // 3. 验证关键词是否为赞美词并生成文案
        Task {
            await generatePraiseText()
        }
    }
    
    /// 显示Toast消息
    func showToastMessage(_ message: String) {
        toastMessage = message
        withAnimation(.easeInOut(duration: 0.3)) {
            showToast = true
        }
        
        // 2.5秒后自动隐藏
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            withAnimation(.easeInOut(duration: 0.3)) {
                self?.showToast = false
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// 验证被夸人姓名是否合法
    private func validatePersonName() -> Bool {
        let trimmedName = personName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 检查是否为空
        if trimmedName.isEmpty {
            showToastMessage("请输入被夸人的姓名")
            return false
        }
        
        // 检查长度
        if trimmedName.count > 20 {
            showToastMessage("被夸人姓名过长，请控制在20字以内")
            return false
        }
        
        // 检查是否包含非法字符（只允许中文、英文、数字和常见符号）
        let pattern = "^[\\u4e00-\\u9fa5a-zA-Z0-9·•\\-_\\s]+$"
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let range = NSRange(location: 0, length: trimmedName.utf16.count)
            if regex.firstMatch(in: trimmedName, options: [], range: range) == nil {
                showToastMessage("当前输入的「被夸人」不合法，请修改后重新生成")
                return false
            }
        }
        
        return true
    }
    
    /// 验证优点关键词格式是否合法
    private func validateKeywordsFormat() -> Bool {
        let trimmedKeywords = keywords.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 检查是否为空
        if trimmedKeywords.isEmpty {
            showToastMessage("请输入优点关键词")
            return false
        }
        
        // 检查长度
        if trimmedKeywords.count > 50 {
            showToastMessage("优点关键词过长，请控制在50字以内")
            return false
        }
        
        // 检查是否包含非法字符
        let pattern = "^[\\u4e00-\\u9fa5a-zA-Z0-9、，,\\-_\\s]+$"
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let range = NSRange(location: 0, length: trimmedKeywords.utf16.count)
            if regex.firstMatch(in: trimmedKeywords, options: [], range: range) == nil {
                showToastMessage("当前输入的「优点关键词」不合法，请修改后重新生成")
                return false
            }
        }
        
        return true
    }
    
    /// 生成赞美文案
    private func generatePraiseText() async {
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        // 先验证关键词是否为赞美词（无论网络是否可用都要验证）
        let keywordValidation = await networkManager.validatePositiveKeywords(keywords)
        
        if keywordValidation.canValidate && !keywordValidation.isPositive {
            if let negativeWord = keywordValidation.negativeWord {
                showToastMessage("「\(negativeWord)」不是赞美词，请修改后重新生成")
            } else {
                showToastMessage("「优点关键词」包含负面词汇，请修改后重新生成")
            }
            return
        }
        
        // 检查网络状态
        let isNetworkAvailable = await networkManager.checkNetworkAvailability()
        
        if isNetworkAvailable {
            // 尝试使用网络API生成文案
            if let networkPraise = await networkManager.generatePraiseFromAPI(
                personName: personName.trimmingCharacters(in: .whitespacesAndNewlines),
                keywords: keywords.trimmingCharacters(in: .whitespacesAndNewlines)
            ) {
                praiseText = networkPraise
                return
            }
        }
        
        // 使用本地生成
        let text = praiseGenerator.generateLocalPraise(
            personName: personName.trimmingCharacters(in: .whitespacesAndNewlines),
            keywords: keywords.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        praiseText = text
    }
}

//
//  TypewriterTextField.swift
//  PraiseApp
//
//  打字机效果的自定义输入框组件 - 使用UIKit实现真正的打字机效果
//  支持中文拼音输入法：等待用户选择候选词后再逐字渲染
//

import SwiftUI
import UIKit

struct TypewriterTextField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    let characterDelay: Double
    var maxLength: Int? = nil
    var onExceedLimit: (() -> Void)? = nil
    
    func makeUIView(context: Context) -> TypewriterUITextField {
        let textField = TypewriterUITextField()
        textField.placeholder = placeholder
        textField.characterDelay = characterDelay
        textField.maxLength = maxLength
        textField.onTextChange = { newText in
            DispatchQueue.main.async {
                // 检查是否超出限制
                if let maxLen = self.maxLength, newText.count > maxLen {
                    // 截取文本
                    let truncated = String(newText.prefix(maxLen))
                    self.text = truncated
                    textField.setTextWithoutAnimation(truncated)
                    self.onExceedLimit?()
                } else {
                    self.text = newText
                }
            }
        }
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        textField.tintColor = UIColor(red: 1.0, green: 0.5, blue: 0.3, alpha: 1.0)
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.gray.withAlphaComponent(0.5)]
        )
        
        // 添加内边距
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        textField.rightViewMode = .always
        
        // 防止文本框根据内容扩展宽度
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return textField
    }
    
    func updateUIView(_ uiView: TypewriterUITextField, context: Context) {
        // 只在外部text改变且与当前显示不同时更新
        if uiView.displayedText != text && !uiView.isTyping && uiView.markedTextRange == nil {
            uiView.setTextWithoutAnimation(text)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: TypewriterTextField
        
        init(_ parent: TypewriterTextField) {
            self.parent = parent
        }
    }
}

class TypewriterUITextField: UITextField, UITextFieldDelegate {
    var characterDelay: Double = 0.05
    var onTextChange: ((String) -> Void)?
    var isTyping = false
    var maxLength: Int? = nil
    
    // 已经显示的文本（打字机效果已完成的部分）
    var displayedText: String = ""
    
    // 用户确认输入的完整文本（不包含 marked text）
    private var confirmedText: String = ""
    
    private var typingQueue: [Character] = []
    private var typingWorkItem: DispatchWorkItem?
    
    // 防止循环调用的标志
    private var isUpdatingText = false
    
    // 用于中间插入的位置跟踪
    private var insertionIndex: String.Index?
    private var targetCursorOffset: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.delegate = self
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    // 防止根据内容扩展宽度
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: super.intrinsicContentSize.height)
    }
    
    @objc private func textDidChange() {
        // 如果是内部更新，跳过处理
        if isUpdatingText {
            return
        }
        
        // 如果有 marked text（正在输入拼音），不处理，让输入法正常工作
        if markedTextRange != nil {
            return
        }
        
        let currentText = text ?? ""
        
        // 如果正在打字机效果中，忽略新输入
        if isTyping {
            isUpdatingText = true
            text = displayedText
            // 将光标移到当前插入位置
            if let insertIdx = insertionIndex {
                let offset = displayedText.distance(from: displayedText.startIndex, to: insertIdx)
                if let pos = position(from: beginningOfDocument, offset: offset) {
                    selectedTextRange = textRange(from: pos, to: pos)
                }
            }
            isUpdatingText = false
            return
        }
        
        // 获取当前光标位置（相对于文本开头的偏移量）
        var cursorOffset = currentText.count
        if let selectedRange = selectedTextRange,
           let start = selectedRange.start as? UITextPosition {
            cursorOffset = offset(from: beginningOfDocument, to: start)
        }
        
        // 检查是否是末尾追加
        let isAppendingAtEnd = currentText.count > confirmedText.count && currentText.hasPrefix(confirmedText)
        
        if isAppendingAtEnd {
            // 在末尾追加文字
            let newChars = String(currentText.dropFirst(confirmedText.count))
            confirmedText = currentText
            
            // 设置插入位置为末尾
            insertionIndex = displayedText.endIndex
            targetCursorOffset = currentText.count
            
            // 将 text 恢复到之前显示的状态
            isUpdatingText = true
            text = displayedText
            moveCursorToEnd()
            isUpdatingText = false
            
            // 用打字机效果添加新字符
            typeTextAtPosition(newChars)
        } else if currentText.count < confirmedText.count {
            // 删除了文字
            confirmedText = currentText
            displayedText = currentText
            onTextChange?(currentText)
        } else if currentText != confirmedText && currentText.count > confirmedText.count {
            // 在中间插入文字
            let addedCount = currentText.count - confirmedText.count
            
            // 计算插入位置：光标位置减去新增字符数
            let insertOffset = max(0, cursorOffset - addedCount)
            
            // 提取新增的字符
            let insertStartIndex = currentText.index(currentText.startIndex, offsetBy: insertOffset)
            let insertEndIndex = currentText.index(insertStartIndex, offsetBy: addedCount)
            let newChars = String(currentText[insertStartIndex..<insertEndIndex])
            
            confirmedText = currentText
            
            // 设置插入位置
            if insertOffset <= displayedText.count {
                insertionIndex = displayedText.index(displayedText.startIndex, offsetBy: insertOffset)
            } else {
                insertionIndex = displayedText.endIndex
            }
            targetCursorOffset = cursorOffset
            
            // 将 text 恢复到之前显示的状态
            isUpdatingText = true
            text = displayedText
            // 将光标移到插入位置
            if let pos = position(from: beginningOfDocument, offset: insertOffset) {
                selectedTextRange = textRange(from: pos, to: pos)
            }
            isUpdatingText = false
            
            // 用打字机效果在指定位置插入新字符
            typeTextAtPosition(newChars)
        } else if currentText != confirmedText {
            // 其他变化（替换等）
            confirmedText = currentText
            displayedText = currentText
            onTextChange?(currentText)
        }
    }
    
    func typeText(_ newText: String) {
        // 将新文本的所有字符加入队列
        typingQueue.append(contentsOf: newText)
        insertionIndex = displayedText.endIndex
        targetCursorOffset = displayedText.count + newText.count
        
        if !isTyping {
            processQueue()
        }
    }
    
    func typeTextAtPosition(_ newText: String) {
        // 将新文本的所有字符加入队列
        typingQueue.append(contentsOf: newText)
        
        if !isTyping {
            processQueueAtPosition()
        }
    }
    
    func setTextWithoutAnimation(_ newText: String) {
        // 取消正在进行的打字效果
        typingWorkItem?.cancel()
        typingQueue.removeAll()
        isTyping = false
        
        confirmedText = newText
        displayedText = newText
        insertionIndex = nil
        
        isUpdatingText = true
        text = newText
        isUpdatingText = false
    }
    
    private func processQueue() {
        guard !typingQueue.isEmpty else {
            isTyping = false
            insertionIndex = nil
            onTextChange?(displayedText)
            return
        }
        
        isTyping = true
        let char = typingQueue.removeFirst()
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            self.displayedText.append(char)
            
            self.isUpdatingText = true
            self.text = self.displayedText
            self.moveCursorToEnd()
            self.isUpdatingText = false
            
            // 继续处理队列
            self.processQueue()
        }
        
        typingWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + characterDelay, execute: workItem)
    }
    
    private func processQueueAtPosition() {
        guard !typingQueue.isEmpty else {
            isTyping = false
            // 打字完成后，将光标移到目标位置
            isUpdatingText = true
            if let pos = position(from: beginningOfDocument, offset: targetCursorOffset) {
                selectedTextRange = textRange(from: pos, to: pos)
            }
            isUpdatingText = false
            insertionIndex = nil
            onTextChange?(displayedText)
            return
        }
        
        isTyping = true
        let char = typingQueue.removeFirst()
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            // 在指定位置插入字符
            if let insertIdx = self.insertionIndex, insertIdx <= self.displayedText.endIndex {
                self.displayedText.insert(char, at: insertIdx)
                // 更新插入位置到下一个位置
                self.insertionIndex = self.displayedText.index(after: insertIdx)
            } else {
                self.displayedText.append(char)
                self.insertionIndex = self.displayedText.endIndex
            }
            
            // 计算当前应该显示的光标位置
            let currentInsertOffset = self.insertionIndex.map { 
                self.displayedText.distance(from: self.displayedText.startIndex, to: $0) 
            } ?? self.displayedText.count
            
            self.isUpdatingText = true
            self.text = self.displayedText
            // 光标跟随插入位置
            if let pos = self.position(from: self.beginningOfDocument, offset: currentInsertOffset) {
                self.selectedTextRange = self.textRange(from: pos, to: pos)
            }
            self.isUpdatingText = false
            
            // 继续处理队列
            self.processQueueAtPosition()
        }
        
        typingWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + characterDelay, execute: workItem)
    }
    
    private func moveCursorToEnd() {
        if let newPosition = position(from: endOfDocument, offset: 0) {
            selectedTextRange = textRange(from: newPosition, to: newPosition)
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        return true
    }
}

#Preview {
    VStack(spacing: 20) {
        TypewriterTextField(
            text: .constant(""),
            placeholder: "请输入同事的名字",
            characterDelay: 0.05
        )
        .frame(height: 50)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding()
    }
}

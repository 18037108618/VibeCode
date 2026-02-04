//
//  Extensions.swift
//  PraiseApp
//
//  通用扩展
//

import SwiftUI

// MARK: - View Extensions

extension View {
    /// 条件修饰符
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// 隐藏键盘
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    /// 圆角（指定角）
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - Custom Shapes

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Color Extensions

extension Color {
    /// 从十六进制字符串创建颜色
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// 主题颜色
    static let primaryOrange = Color(red: 1.0, green: 0.5, blue: 0.3)
    static let primaryGold = Color(red: 0.85, green: 0.65, blue: 0.15)
    static let backgroundWarm = Color(red: 1.0, green: 0.95, blue: 0.85)
}

// MARK: - String Extensions

extension String {
    /// 是否为空或只包含空白字符
    var isBlank: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// 安全截取
    func safeSubstring(to index: Int) -> String {
        guard index >= 0 else { return "" }
        guard index < count else { return self }
        return String(prefix(index))
    }
}

// MARK: - UIImage Extensions

extension UIImage {
    /// 调整图片大小
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// 压缩图片质量
    func compressed(quality: CGFloat = 0.8) -> Data? {
        return jpegData(compressionQuality: quality)
    }
}

// MARK: - Haptic Feedback

struct HapticManager {
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// MARK: - Animation Extensions

extension Animation {
    static var bouncy: Animation {
        .spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)
    }
    
    static var smooth: Animation {
        .easeInOut(duration: 0.3)
    }
}

// MARK: - Date Extensions

extension Date {
    /// 格式化为中文日期
    var chineseFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: self)
    }
}

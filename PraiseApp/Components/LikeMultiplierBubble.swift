//
//  LikeMultiplierBubble.swift
//  PraiseApp
//
//  点赞气泡倍数动画组件 - 模拟气泡在水中上浮的效果
//

import SwiftUI

struct LikeMultiplierBubble: View {
    let multiplier: Int
    let startPosition: CGPoint
    let onComplete: () -> Void
    
    @State private var offsetY: CGFloat = 0
    @State private var offsetX: CGFloat = 0
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 1.0
    @State private var wobblePhase: Double = 0
    
    // 根据倍数计算颜色（初始带红色，越大越红）
    private var textColor: Color {
        let progress = min(Double(multiplier) / 99.0, 1.0)
        return Color(
            red: 1.0,
            green: 0.7 - progress * 0.5,  // 初始 0.7，最终 0.2
            blue: 0.6 - progress * 0.5    // 初始 0.6，最终 0.1
        )
    }
    
    // 根据倍数计算背景不透明度（越大越不透明）
    private var backgroundOpacity: Double {
        let progress = min(Double(multiplier) / 99.0, 1.0)
        return 0.3 + progress * 0.6
    }
    
    // 根据倍数计算字体大小
    private var fontSize: CGFloat {
        let baseSize: CGFloat = 18
        let maxSize: CGFloat = 32
        let progress = min(Double(multiplier) / 50.0, 1.0)
        return baseSize + CGFloat(progress) * (maxSize - baseSize)
    }
    
    // 气泡大小
    private var bubbleSize: CGFloat {
        return 60 + CGFloat(multiplier) / 4
    }
    
    var body: some View {
        ZStack {
            // 气泡背景
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(backgroundOpacity + 0.2),
                            Color(red: 1.0, green: 0.9, blue: 0.8).opacity(backgroundOpacity)
                        ]),
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: bubbleSize / 2
                    )
                )
                .overlay(
                    // 气泡高光
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.8),
                                    Color.white.opacity(0)
                                ]),
                                center: UnitPoint(x: 0.3, y: 0.3),
                                startRadius: 0,
                                endRadius: bubbleSize / 3
                            )
                        )
                )
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.9),
                                    textColor.opacity(0.4)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: textColor.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // 倍数文字
            Text("x\(multiplier)")
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundColor(textColor)
                .shadow(color: textColor.opacity(0.5), radius: 2, x: 0, y: 1)
        }
        .frame(width: bubbleSize, height: bubbleSize)
        .scaleEffect(scale)
        .offset(x: offsetX + sin(wobblePhase) * 8, y: offsetY)
        .position(startPosition)
        .opacity(opacity)
        .onAppear {
            startBubbleAnimation()
        }
    }
    
    private func startBubbleAnimation() {
        // 初始弹出效果
        withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
            scale = 1.1
        }
        
        // 回弹到正常大小
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6).delay(0.3)) {
            scale = 1.0
        }
        
        // 上浮动画 - 飘到屏幕外
        let screenHeight = UIScreen.main.bounds.height
        let totalDistance = startPosition.y + 100 // 确保飘出屏幕顶部
        let duration: Double = 3.0
        
        // 使用定时器创建摇曳效果
        let wobbleTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            wobblePhase += 0.15
            
            // 检查是否应该停止
            if opacity <= 0 {
                timer.invalidate()
            }
        }
        RunLoop.main.add(wobbleTimer, forMode: .common)
        
        // 主上浮动画 - 带加速效果
        withAnimation(.easeIn(duration: duration)) {
            offsetY = -totalDistance
            // 随机水平漂移
            offsetX = CGFloat.random(in: -30...30)
        }
        
        // 动画完成后移除
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            wobbleTimer.invalidate()
            onComplete()
        }
    }
}

// 气泡管理器 - 处理连续点击逻辑
class BubbleManager: ObservableObject {
    @Published var bubbles: [BubbleInfo] = []
    @Published var currentMultiplier: Int = 0
    @Published var isLongPressing: Bool = false
    
    private var lastClickTime: Date?
    private let clickInterval: TimeInterval = 1.0 // 1秒内算连续点击
    private var longPressTimer: Timer?
    private var longPressPosition: CGPoint = .zero
    
    /// 处理点击事件
    /// - Returns: true 表示连续点击，应显示气泡动画；false 表示单点，应显示单点动画
    func handleClick(at position: CGPoint) -> Bool {
        let now = Date()
        var isConsecutiveClick = false
        
        if let lastTime = lastClickTime {
            let interval = now.timeIntervalSince(lastTime)
            
            if interval <= clickInterval {
                // 连续点击
                currentMultiplier += 1
                isConsecutiveClick = true
                
                // 添加气泡
                let bubble = BubbleInfo(
                    id: UUID(),
                    multiplier: min(currentMultiplier, 99),
                    position: CGPoint(
                        x: position.x + CGFloat.random(in: -20...20),
                        y: position.y
                    )
                )
                bubbles.append(bubble)
            } else {
                // 超时，重置计数，这是单点
                currentMultiplier = 1
                isConsecutiveClick = false
            }
        } else {
            // 第一次点击，这是单点
            currentMultiplier = 1
            isConsecutiveClick = false
        }
        
        lastClickTime = now
        return isConsecutiveClick
    }
    
    func removeBubble(id: UUID) {
        bubbles.removeAll { $0.id == id }
    }
    
    func reset() {
        currentMultiplier = 0
        lastClickTime = nil
        stopLongPress()
    }
    
    /// 开始长按
    func startLongPress(at position: CGPoint) {
        longPressPosition = position
        isLongPressing = true
        
        // 长按开始时，如果当前不在连续点击状态，初始化倍数
        let now = Date()
        if let lastTime = lastClickTime {
            let interval = now.timeIntervalSince(lastTime)
            if interval > clickInterval {
                currentMultiplier = 1
            }
        } else {
            currentMultiplier = 1
        }
        
        // 立即触发第一次
        triggerLongPressBubble()
        
        // 启动定时器，每 0.15 秒触发一次
        longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { [weak self] _ in
            self?.triggerLongPressBubble()
        }
        RunLoop.main.add(longPressTimer!, forMode: .common)
    }
    
    /// 停止长按
    func stopLongPress() {
        isLongPressing = false
        longPressTimer?.invalidate()
        longPressTimer = nil
        // 更新最后点击时间，这样停止长按后如果快速点击还能继续连击
        lastClickTime = Date()
    }
    
    /// 长按时触发气泡
    private func triggerLongPressBubble() {
        currentMultiplier += 1
        lastClickTime = Date()
        
        let bubble = BubbleInfo(
            id: UUID(),
            multiplier: min(currentMultiplier, 99),
            position: CGPoint(
                x: longPressPosition.x + CGFloat.random(in: -20...20),
                y: longPressPosition.y
            )
        )
        bubbles.append(bubble)
    }
}

struct BubbleInfo: Identifiable {
    let id: UUID
    let multiplier: Int
    let position: CGPoint
}

#Preview {
    ZStack {
        Color(red: 1.0, green: 0.95, blue: 0.85)
            .ignoresSafeArea()
        
        VStack {
            LikeMultiplierBubble(multiplier: 5, startPosition: CGPoint(x: 150, y: 500)) {}
            LikeMultiplierBubble(multiplier: 25, startPosition: CGPoint(x: 200, y: 550)) {}
            LikeMultiplierBubble(multiplier: 50, startPosition: CGPoint(x: 250, y: 600)) {}
        }
    }
}

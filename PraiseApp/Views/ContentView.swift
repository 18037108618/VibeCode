//
//  ContentView.swift
//  PraiseApp
//
//  主页视图 - 包含输入框、生成按钮、点赞按钮、颁发证书按钮
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PraiseViewModel()
    @StateObject private var bubbleManager = BubbleManager()
    @State private var showCertificatePopup = false
    @State private var certificateImage: UIImage?
    @State private var showConfetti = false
    
    // 输入框字数限制
    private let personNameMaxLength = 15
    private let keywordsMaxLength = 20
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 1.0, green: 0.95, blue: 0.85),
                        Color(red: 1.0, green: 0.85, blue: 0.75)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 标题
                        Text("🎉 夸夸助手 🎉")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.2))
                            .padding(.top, 40)
                        
                        Text("让每一份赞美都闪闪发光")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                        
                        // 被夸人输入框
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("被夸人")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                                
                                Spacer()
                                
                                // 剩余字数显示
                                HStack(spacing: 2) {
                                    Text("剩余可输入字数：")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color.gray)
                                    Text("\(max(0, personNameMaxLength - viewModel.personName.count))")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(
                                            viewModel.personName.count >= personNameMaxLength
                                            ? Color.red
                                            : Color.red.opacity(0.7)
                                        )
                                }
                            }
                            
                            TypewriterTextField(
                                text: $viewModel.personName,
                                placeholder: "请输入同事的名字",
                                characterDelay: 0.05,
                                maxLength: personNameMaxLength,
                                onExceedLimit: {
                                    viewModel.showToastMessage("输入的被夸人名字过长")
                                }
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                        }
                        .padding(.horizontal, 24)
                        
                        // 优点关键词输入框
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("优点关键词")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                                
                                Spacer()
                                
                                // 剩余字数显示
                                HStack(spacing: 2) {
                                    Text("剩余可输入字数：")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color.gray)
                                    Text("\(max(0, keywordsMaxLength - viewModel.keywords.count))")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(
                                            viewModel.keywords.count >= keywordsMaxLength
                                            ? Color.red
                                            : Color.red.opacity(0.7)
                                        )
                                }
                            }
                            
                            TypewriterTextField(
                                text: $viewModel.keywords,
                                placeholder: "请输入优点关键词（如：勤奋、聪明）",
                                characterDelay: 0.05,
                                maxLength: keywordsMaxLength,
                                onExceedLimit: {
                                    viewModel.showToastMessage("输入的优点关键词过长")
                                }
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                        }
                        .padding(.horizontal, 24)
                        
                        // 浮夸赞美文案展示区 - 固定高度
                        VStack(alignment: .leading, spacing: 8) {
                            Text("浮夸赞美文案")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.3))
                            
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                                
                                if viewModel.praiseText.isEmpty {
                                    Text("点击「生成」按钮，生成浮夸赞美文案...")
                                        .foregroundColor(Color.gray.opacity(0.5))
                                        .padding(16)
                                } else {
                                    ScrollView {
                                        Text(viewModel.praiseText)
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                                            .padding(16)
                                            .lineSpacing(6)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .scrollDismissesKeyboard(.immediately)
                                }
                            }
                            .frame(height: 180) // 固定高度
                            .contentShape(Rectangle())
                            .onTapGesture {
                                hideKeyboard()
                            }
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 5)
                                    .onChanged { _ in
                                        hideKeyboard()
                                    }
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        // 按钮区域
                        HStack(spacing: 12) {
                            // 生成按钮
                            Button(action: {
                                hideKeyboard()
                                viewModel.generatePraise()
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "sparkles")
                                    Text("生成")
                                }
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 46)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 1.0, green: 0.6, blue: 0.4),
                                            Color(red: 1.0, green: 0.4, blue: 0.3)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(23)
                                .shadow(color: Color(red: 1.0, green: 0.4, blue: 0.3).opacity(0.4), radius: 6, x: 0, y: 3)
                            }
                            .disabled(viewModel.isLoading)
                            .buttonStyle(ScaleButtonStyle())
                            
                            // 点赞按钮 - 支持点击和长按
                            LikeButton(geometry: geometry, bubbleManager: bubbleManager) {
                                hideKeyboard()
                                triggerLike(in: geometry)
                            } onLongPressStart: {
                                hideKeyboard()
                                startLongPressLike(in: geometry)
                            } onLongPressEnd: {
                                stopLongPressLike()
                            }
                            
                            // 颁发证书按钮
                            Button(action: {
                                hideKeyboard()
                                generateCertificate()
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "rosette")
                                    Text("证书")
                                }
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 46)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.6, green: 0.4, blue: 0.8),
                                            Color(red: 0.5, green: 0.3, blue: 0.7)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(23)
                                .shadow(color: Color(red: 0.5, green: 0.3, blue: 0.7).opacity(0.4), radius: 6, x: 0, y: 3)
                            }
                            .disabled(viewModel.praiseText.isEmpty)
                            .opacity(viewModel.praiseText.isEmpty ? 0.6 : 1.0)
                            .buttonStyle(ScaleButtonStyle())
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                hideKeyboard()
                            }
                    )
                }
                .scrollDismissesKeyboard(.immediately)
                
                // 五彩纸屑效果
                if showConfetti {
                    ConfettiView()
                        .allowsHitTesting(false)
                }
                
                // 点赞气泡
                ForEach(bubbleManager.bubbles) { bubble in
                    LikeMultiplierBubble(
                        multiplier: bubble.multiplier,
                        startPosition: bubble.position
                    ) {
                        bubbleManager.removeBubble(id: bubble.id)
                    }
                }
                
                // 证书弹窗
                if showCertificatePopup, let image = certificateImage {
                    CertificatePopupView(
                        image: image,
                        isPresented: $showCertificatePopup
                    )
                    .transition(.opacity.combined(with: .scale))
                }
                
                // Toast提示
                if viewModel.showToast {
                    ToastView(message: viewModel.toastMessage)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // 加载指示器
                if viewModel.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture { } // 阻止点击穿透
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showCertificatePopup)
        .animation(.easeInOut(duration: 0.3), value: viewModel.showToast)
    }
    
    // 触发点赞效果（点击）
    private func triggerLike(in geometry: GeometryProxy) {
        // AppIconGenerator.saveIconToPhotos() // 生成appIcon
        // 计算按钮位置（大约在屏幕中下方）
        let buttonY = geometry.size.height - 120
        let buttonX = geometry.size.width / 2
        
        // 使用BubbleManager处理连续点击逻辑
        let isConsecutiveClick = bubbleManager.handleClick(at: CGPoint(x: buttonX, y: buttonY))
        
        if isConsecutiveClick {
            // 连续点击：只显示气泡动画，不显示纸屑效果
            // 气泡已经在 handleClick 中添加了
        } else {
            // 单点：触发纸屑效果
            showConfetti = true
            
            // 1.5秒后关闭纸屑效果
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showConfetti = false
            }
        }
    }
    
    // 开始长按点赞
    private func startLongPressLike(in geometry: GeometryProxy) {
        let buttonY = geometry.size.height - 120
        let buttonX = geometry.size.width / 2
        bubbleManager.startLongPress(at: CGPoint(x: buttonX, y: buttonY))
    }
    
    // 停止长按点赞
    private func stopLongPressLike() {
        bubbleManager.stopLongPress()
    }
    
    // 生成证书
    private func generateCertificate() {
        guard !viewModel.personName.isEmpty && !viewModel.praiseText.isEmpty else {
            viewModel.showToastMessage("请先输入被夸人姓名并生成赞美文案")
            return
        }
        
        let certificateView = CertificateView(
            personName: viewModel.personName,
            keywords: viewModel.keywords,
            praiseText: viewModel.praiseText
        )
        
        let renderer = ImageRenderer(content: certificateView)
        renderer.scale = UIScreen.main.scale
        
        if let image = renderer.uiImage {
            certificateImage = image
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showCertificatePopup = true
            }
        }
    }
    
    // 隐藏键盘
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// 按钮缩放样式 - 防止点击区域过大
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// 点赞按钮 - 支持点击和长按
struct LikeButton: View {
    let geometry: GeometryProxy
    @ObservedObject var bubbleManager: BubbleManager
    let onTap: () -> Void
    let onLongPressStart: () -> Void
    let onLongPressEnd: () -> Void
    
    @State private var isPressed = false
    @State private var longPressTriggered = false
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "hand.thumbsup.fill")
            Text("点赞")
        }
        .font(.system(size: 15, weight: .semibold))
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 46)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.75, blue: 0.3),
                    Color(red: 1.0, green: 0.6, blue: 0.2)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(23)
        .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.4), radius: 6, x: 0, y: 3)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                        longPressTriggered = false
                        
                        // 延迟 0.3 秒后触发长按
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            if isPressed && !longPressTriggered {
                                longPressTriggered = true
                                onLongPressStart()
                            }
                        }
                    }
                }
                .onEnded { _ in
                    if longPressTriggered {
                        // 长按结束
                        onLongPressEnd()
                    } else {
                        // 普通点击
                        onTap()
                    }
                    isPressed = false
                    longPressTriggered = false
                }
        )
    }
}

#Preview {
    ContentView()
}

//
//  CertificateView.swift
//  PraiseApp
//
//  荣誉证书生成视图 - 屏幕90%大小，包含艺术字效果
//

import SwiftUI

struct CertificateView: View {
    let personName: String
    let keywords: String
    let praiseText: String
    
    // 证书尺寸 - 屏幕宽度的90%，高度为屏幕的85%
    private var certificateWidth: CGFloat {
        UIScreen.main.bounds.width * 0.9
    }
    
    private var certificateHeight: CGFloat {
        UIScreen.main.bounds.height * 0.85
    }
    
    var body: some View {
        ZStack {
            // 证书背景
            certificateBackground
            
            VStack(spacing: 0) {
                // 顶部装饰
                topDecoration
                    .padding(.top, certificateHeight * 0.03)
                
                // 荣誉证书标题 - 艺术字效果
                Text("荣誉证书")
                    .font(.system(size: certificateWidth * 0.1, weight: .bold, design: .serif))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.75, green: 0.55, blue: 0.15),
                                Color(red: 0.95, green: 0.8, blue: 0.35),
                                Color(red: 0.85, green: 0.65, blue: 0.2),
                                Color(red: 0.95, green: 0.8, blue: 0.35),
                                Color(red: 0.75, green: 0.55, blue: 0.15)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color(red: 0.6, green: 0.4, blue: 0.1).opacity(0.8), radius: 1, x: 1, y: 1)
                    .shadow(color: Color(red: 0.95, green: 0.85, blue: 0.6).opacity(0.5), radius: 0, x: -1, y: -1)
                    .padding(.top, certificateHeight * 0.015)
                
                // 分隔线
                HStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.clear,
                                    Color(red: 0.8, green: 0.6, blue: 0.2)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 2)
                    
                    Image(systemName: "star.fill")
                        .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.2))
                        .font(.system(size: certificateWidth * 0.04))
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.8, green: 0.6, blue: 0.2),
                                    Color.clear
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 2)
                }
                .padding(.horizontal, certificateWidth * 0.12)
                .padding(.top, certificateHeight * 0.015)
                
                // 被夸人名字 - 艺术字效果
                HStack(spacing: 0) {
                    Text("兹授予 ")
                        .font(.system(size: certificateWidth * 0.045, design: .serif))
                        .foregroundColor(Color(red: 0.3, green: 0.25, blue: 0.2))
                    
                    Text(personName)
                        .font(.system(size: certificateWidth * 0.07, weight: .bold, design: .serif))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.75, green: 0.15, blue: 0.15),
                                    Color(red: 0.9, green: 0.25, blue: 0.2),
                                    Color(red: 0.75, green: 0.15, blue: 0.15)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color(red: 0.5, green: 0.1, blue: 0.1).opacity(0.4), radius: 1, x: 1, y: 1)
                    
                    Text(" 同志")
                        .font(.system(size: certificateWidth * 0.045, design: .serif))
                        .foregroundColor(Color(red: 0.3, green: 0.25, blue: 0.2))
                }
                .padding(.top, certificateHeight * 0.025)
                
                // 优点关键词
                if !keywords.isEmpty {
                    HStack {
                        Text("「\(keywords)」")
                            .font(.system(size: certificateWidth * 0.038, weight: .medium, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.5, green: 0.35, blue: 0.2),
                                        Color(red: 0.6, green: 0.45, blue: 0.3),
                                        Color(red: 0.5, green: 0.35, blue: 0.2)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.98, green: 0.95, blue: 0.88),
                                                Color(red: 0.95, green: 0.9, blue: 0.8)
                                            ]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .shadow(color: Color(red: 0.8, green: 0.6, blue: 0.3).opacity(0.3), radius: 2, x: 0, y: 1)
                            )
                    }
                    .padding(.top, certificateHeight * 0.015)
                }
                
                // 赞美文案 - 艺术字效果，精美边框
                if !praiseText.isEmpty {
                    ZStack {
                        // 装饰边框背景
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.98, blue: 0.95),
                                        Color(red: 0.98, green: 0.95, blue: 0.9)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        // 装饰边框
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.85, green: 0.7, blue: 0.45),
                                        Color(red: 0.9, green: 0.8, blue: 0.55),
                                        Color(red: 0.85, green: 0.7, blue: 0.45)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                        
                        // 四角装饰
                        VStack {
                            HStack {
                                cornerDecoration
                                Spacer()
                                cornerDecoration
                                    .rotationEffect(.degrees(90))
                            }
                            Spacer()
                            HStack {
                                cornerDecoration
                                    .rotationEffect(.degrees(-90))
                                Spacer()
                                cornerDecoration
                                    .rotationEffect(.degrees(180))
                            }
                        }
                        .padding(6)
                        
                        VStack(spacing: 0) {
                            // 上装饰
                            HStack(spacing: 8) {
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: certificateWidth * 0.025))
                                    .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.3))
                                    .rotationEffect(.degrees(-45))
                                
                                Text("✦ 荣誉评语 ✦")
                                    .font(.system(size: certificateWidth * 0.03, weight: .semibold, design: .serif))
                                    .foregroundColor(Color(red: 0.7, green: 0.5, blue: 0.25))
                                
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: certificateWidth * 0.025))
                                    .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.3))
                                    .rotationEffect(.degrees(45))
                            }
                            .padding(.top, 12)
                            
                            // 分隔装饰
                            HStack(spacing: 4) {
                                Rectangle()
                                    .fill(Color(red: 0.85, green: 0.7, blue: 0.45).opacity(0.6))
                                    .frame(width: 30, height: 1)
                                Circle()
                                    .fill(Color(red: 0.85, green: 0.7, blue: 0.45))
                                    .frame(width: 4, height: 4)
                                Rectangle()
                                    .fill(Color(red: 0.85, green: 0.7, blue: 0.45).opacity(0.6))
                                    .frame(width: 30, height: 1)
                            }
                            .padding(.top, 6)
                            
                            // 赞美文案内容
                            Text(praiseText)
                                .font(.system(size: certificateWidth * 0.038, weight: .medium, design: .serif))
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.4, green: 0.3, blue: 0.2),
                                            Color(red: 0.5, green: 0.4, blue: 0.3),
                                            Color(red: 0.4, green: 0.3, blue: 0.2)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .italic()
                                .multilineTextAlignment(.center)
                                .lineSpacing(10)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .shadow(color: Color.white.opacity(0.8), radius: 0, x: 0.5, y: 0.5)
                            
                            // 下装饰
                            HStack(spacing: 6) {
                                Image(systemName: "sparkle")
                                    .font(.system(size: certificateWidth * 0.02))
                                Image(systemName: "star.fill")
                                    .font(.system(size: certificateWidth * 0.025))
                                Image(systemName: "sparkle")
                                    .font(.system(size: certificateWidth * 0.02))
                            }
                            .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.3))
                            .padding(.bottom, 12)
                        }
                    }
                    .padding(.horizontal, certificateWidth * 0.06)
                    .padding(.top, certificateHeight * 0.025)
                }
                
                // 中间装饰带
                HStack(spacing: 12) {
                    Image(systemName: "leaf.fill")
                        .rotationEffect(.degrees(180))
                    ForEach(0..<5) { _ in
                        Circle()
                            .frame(width: 4, height: 4)
                    }
                    Image(systemName: "heart.fill")
                    ForEach(0..<5) { _ in
                        Circle()
                            .frame(width: 4, height: 4)
                    }
                    Image(systemName: "leaf.fill")
                }
                .font(.system(size: certificateWidth * 0.03))
                .foregroundColor(Color(red: 0.85, green: 0.7, blue: 0.4).opacity(0.6))
                .padding(.top, certificateHeight * 0.02)
                
                Spacer()
                
                // 底部印章和日期
                HStack(alignment: .bottom) {
                    // 左侧装饰
                    VStack(spacing: 4) {
                        Image(systemName: "laurel.leading")
                            .font(.system(size: certificateWidth * 0.06))
                            .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.2).opacity(0.5))
                    }
                    .padding(.leading, certificateWidth * 0.08)
                    
                    Spacer()
                    
                    VStack(spacing: 10) {
                        // 印章
                        ZStack {
                            // 印章外圈装饰
                            Circle()
                                .stroke(Color(red: 0.8, green: 0.2, blue: 0.2).opacity(0.3), lineWidth: 1)
                                .frame(width: certificateWidth * 0.22, height: certificateWidth * 0.22)
                            
                            Circle()
                                .stroke(Color(red: 0.8, green: 0.2, blue: 0.2), lineWidth: 3)
                                .frame(width: certificateWidth * 0.18, height: certificateWidth * 0.18)
                            
                            VStack(spacing: 2) {
                                Text("夸夸")
                                    .font(.system(size: certificateWidth * 0.04, weight: .bold, design: .serif))
                                Text("助手")
                                    .font(.system(size: certificateWidth * 0.04, weight: .bold, design: .serif))
                            }
                            .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.2))
                        }
                        .rotationEffect(.degrees(-15))
                        
                        // 日期带装饰
                        HStack(spacing: 6) {
                            Rectangle()
                                .fill(Color(red: 0.7, green: 0.6, blue: 0.5).opacity(0.4))
                                .frame(width: 20, height: 1)
                            Text(formattedDate)
                                .font(.system(size: certificateWidth * 0.034, design: .serif))
                                .foregroundColor(Color(red: 0.5, green: 0.45, blue: 0.4))
                            Rectangle()
                                .fill(Color(red: 0.7, green: 0.6, blue: 0.5).opacity(0.4))
                                .frame(width: 20, height: 1)
                        }
                    }
                    .padding(.trailing, certificateWidth * 0.08)
                }
                .padding(.bottom, certificateHeight * 0.035)
            }
        }
        .frame(width: certificateWidth, height: certificateHeight)
    }
    
    // 角落装饰
    private var cornerDecoration: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 15))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 15, y: 0))
        }
        .stroke(Color(red: 0.85, green: 0.7, blue: 0.45), lineWidth: 2)
        .frame(width: 15, height: 15)
    }
    
    // 证书背景
    private var certificateBackground: some View {
        ZStack {
            // 主背景
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.98, blue: 0.94),
                            Color(red: 0.98, green: 0.95, blue: 0.88)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // 外边框
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.85, green: 0.7, blue: 0.4),
                            Color(red: 0.9, green: 0.8, blue: 0.5),
                            Color(red: 0.85, green: 0.7, blue: 0.4)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 10
                )
            
            // 内边框
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(red: 0.8, green: 0.65, blue: 0.35), lineWidth: 1.5)
                .padding(16)
            
            // 背景纹理
            certificatePattern
                .opacity(0.03)
        }
    }
    
    // 顶部装饰
    private var topDecoration: some View {
        HStack(spacing: certificateWidth * 0.04) {
            Image(systemName: "laurel.leading")
                .font(.system(size: certificateWidth * 0.08))
                .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.2))
            
            Image(systemName: "crown.fill")
                .font(.system(size: certificateWidth * 0.09))
                .foregroundColor(Color(red: 0.85, green: 0.65, blue: 0.15))
                .shadow(color: Color(red: 0.85, green: 0.65, blue: 0.15).opacity(0.5), radius: 4, x: 0, y: 2)
            
            Image(systemName: "laurel.trailing")
                .font(.system(size: certificateWidth * 0.08))
                .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.2))
        }
    }
    
    // 背景纹理
    private var certificatePattern: some View {
        GeometryReader { geometry in
            Path { path in
                let size: CGFloat = 30
                for x in stride(from: 0, to: geometry.size.width, by: size) {
                    for y in stride(from: 0, to: geometry.size.height, by: size) {
                        path.addRect(CGRect(x: x, y: y, width: size / 2, height: size / 2))
                    }
                }
            }
            .fill(Color(red: 0.8, green: 0.6, blue: 0.2))
        }
    }
    
    // 格式化日期
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: Date())
    }
}

#Preview {
    CertificateView(
        personName: "张三",
        keywords: "聪明、勤奋、善良",
        praiseText: "此人天赋异禀，才华横溢，不仅在工作中表现出色，更是团队中的中流砥柱。其聪明才智令人叹为观止，勤奋刻苦的精神更是值得所有人学习。特此表彰！"
    )
}

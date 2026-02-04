//
//  ToastView.swift
//  PraiseApp
//
//  Toast提示组件
//

import SwiftUI

struct ToastView: View {
    let message: String
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                
                Text(message)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.3, green: 0.3, blue: 0.35),
                                Color(red: 0.25, green: 0.25, blue: 0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            )
            .padding(.top, 60)
            
            Spacer()
        }
    }
}

// Toast修饰器
struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let duration: Double
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                ToastView(message: message)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isPresented = false
                            }
                        }
                    }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isPresented)
    }
}

extension View {
    func toast(isPresented: Binding<Bool>, message: String, duration: Double = 2.5) -> some View {
        modifier(ToastModifier(isPresented: isPresented, message: message, duration: duration))
    }
}

// 成功Toast样式
struct SuccessToastView: View {
    let message: String
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                
                Text(message)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.2, green: 0.7, blue: 0.4),
                                Color(red: 0.15, green: 0.6, blue: 0.35)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.green.opacity(0.3), radius: 10, x: 0, y: 5)
            )
            .padding(.top, 60)
            
            Spacer()
        }
    }
}

// 错误Toast样式
struct ErrorToastView: View {
    let message: String
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                
                Text(message)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.9, green: 0.3, blue: 0.3),
                                Color(red: 0.8, green: 0.2, blue: 0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.red.opacity(0.3), radius: 10, x: 0, y: 5)
            )
            .padding(.top, 60)
            
            Spacer()
        }
    }
}

#Preview {
    ZStack {
        Color(red: 1.0, green: 0.95, blue: 0.85)
            .ignoresSafeArea()
        
        VStack(spacing: 100) {
            ToastView(message: "当前输入的「被夸人」不合法，请修改后重新生成")
            SuccessToastView(message: "保存成功！")
            ErrorToastView(message: "保存失败，请重试")
        }
    }
}

//
//  AppIconGenerator.swift
//  PraiseApp
//
//  App 图标生成器 - 用于生成夸夸助手的应用图标
//

import SwiftUI

struct AppIconView: View {
    let size: CGFloat
    
    init(size: CGFloat = 1024) {
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.5, blue: 0.4),   // 珊瑚粉
                    Color(red: 1.0, green: 0.65, blue: 0.3),  // 温暖橙
                    Color(red: 1.0, green: 0.75, blue: 0.35)  // 金黄色
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 装饰性光晕
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.4
                    )
                )
                .frame(width: size * 0.8, height: size * 0.8)
                .offset(x: -size * 0.1, y: -size * 0.1)
            
            // 主要图标内容
            VStack(spacing: size * 0.02) {
                // 大拇指点赞图标
                ZStack {
                    // 外圈光晕
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.yellow.opacity(0.4),
                                    Color.yellow.opacity(0)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: size * 0.25
                            )
                        )
                        .frame(width: size * 0.6, height: size * 0.6)
                    
                    // 点赞手势
                    Image(systemName: "hand.thumbsup.fill")
                        .font(.system(size: size * 0.35, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.95, blue: 0.7),
                                    Color(red: 1.0, green: 0.85, blue: 0.4),
                                    Color(red: 0.95, green: 0.7, blue: 0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color(red: 0.8, green: 0.5, blue: 0.2).opacity(0.5), radius: size * 0.02, x: 0, y: size * 0.01)
                }
            }
            
            // 装饰星星
            decorativeStars
        }
        .frame(width: size, height: size)
        .background(Color.clear) // 确保视图背景透明（全版本兼容）
        .clipShape(RoundedRectangle(cornerRadius: size * 0.2237)) // iOS 标准图标圆角比例
    }
    
    // 装饰性星星
    private var decorativeStars: some View {
        ZStack {
            // 左上星星
            Image(systemName: "sparkle")
                .font(.system(size: size * 0.06, weight: .bold))
                .foregroundColor(.white.opacity(0.9))
                .offset(x: -size * 0.28, y: -size * 0.25)
            
            // 右上星星
            Image(systemName: "star.fill")
                .font(.system(size: size * 0.05))
                .foregroundColor(.white.opacity(0.8))
                .offset(x: size * 0.3, y: -size * 0.2)
            
            // 左下星星
            Image(systemName: "star.fill")
                .font(.system(size: size * 0.04))
                .foregroundColor(.white.opacity(0.7))
                .offset(x: -size * 0.32, y: size * 0.15)
            
            // 右下星星
            Image(systemName: "sparkle")
                .font(.system(size: size * 0.05, weight: .bold))
                .foregroundColor(.white.opacity(0.85))
                .offset(x: size * 0.28, y: size * 0.22)
            
            // 额外的小星星
            Image(systemName: "star.fill")
                .font(.system(size: size * 0.03))
                .foregroundColor(.white.opacity(0.6))
                .offset(x: size * 0.15, y: -size * 0.32)
            
            Image(systemName: "star.fill")
                .font(.system(size: size * 0.025))
                .foregroundColor(.white.opacity(0.5))
                .offset(x: -size * 0.18, y: size * 0.3)
        }
    }
}

// 生成并保存图标
@MainActor
struct AppIconGenerator {
    static func generateIcon() -> UIImage? {
        let iconSize: CGFloat = 1024
        let iconView = AppIconView(size: iconSize)
        
        // 1. 配置渲染器（全版本兼容的透明设置）
        let renderer = ImageRenderer(content: iconView)
        renderer.scale = 1.0
        renderer.isOpaque = false // 核心：关闭不透明模式（全版本兼容）
        
        // 2. 生成基础透明图片
        guard let baseImage = renderer.uiImage else {
            print("图标渲染失败")
            return nil
        }
        
        // 3. 二次裁剪：确保圆角外完全透明（全版本兼容）
        UIGraphicsBeginImageContextWithOptions(baseImage.size, false, baseImage.scale)
        defer { UIGraphicsEndImageContext() } // 确保上下文必关闭，避免内存泄漏
        
        guard let context = UIGraphicsGetCurrentContext() else {
            print("获取图形上下文失败")
            return baseImage
        }
        
        // 设置裁剪路径（iOS 标准图标圆角比例）
        let rect = CGRect(origin: .zero, size: baseImage.size)
        let cornerRadius = iconSize * 0.2237 // 标准iOS图标圆角（无棱角）
        let iconPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        
        // 清空画布（确保背景完全透明）
        context.clear(rect)
        
        // 应用裁剪路径（圆角外区域透明）
        iconPath.addClip()
        
        // 绘制图片
        baseImage.draw(in: rect)
        
        // 获取裁剪后的图片
        guard let croppedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            print("裁剪图片失败")
            return baseImage
        }
        
        // 4. 强制转为PNG（唯一支持透明的格式，JPEG会丢失透明）
        guard let pngData = croppedImage.pngData(),
              let finalImage = UIImage(data: pngData) else {
            print("转换为PNG格式失败")
            return croppedImage
        }
        
        return finalImage
    }
    
    static func saveIconToPhotos() {
        guard let image = generateIcon() else {
            print("生成图标失败，无法保存")
            return
        }
        
        // 仅保存PNG格式（确保透明性，JPEG会把透明转成黑色）
        guard let pngData = image.pngData() else {
            print("转换为PNG数据失败")
            return
        }
        
        saveImageDataToSandbox(data: pngData, fileName: "app_icon.png")
        
        // 可选：保存到相册（如需开启，取消注释）
        // UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    /// 保存图片到沙盒并打印路径
    /// - Parameters:
    ///   - data: 图片二进制数据
    ///   - fileName: 保存的文件名（包含后缀）
    private static func saveImageDataToSandbox(data: Data, fileName: String) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("获取沙盒Documents目录失败")
            return
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL, options: .atomic)
            print("图片保存成功！沙盒路径：\(fileURL.path)")
        } catch {
            print("图片保存失败：\(error.localizedDescription)")
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        AppIconView(size: 200)
        
        Text("夸夸助手")
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.gray)
    }
    .padding()
    .background(Color.gray.opacity(0.1)) // 预览时直观查看透明效果
}

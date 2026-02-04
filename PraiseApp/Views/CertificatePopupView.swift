//
//  CertificatePopupView.swift
//  PraiseApp
//
//  证书弹窗视图 - 包含关闭、保存、分享功能
//

import SwiftUI
import Photos

struct CertificatePopupView: View {
    let image: UIImage
    @Binding var isPresented: Bool
    
    @State private var showingSaveSuccess = false
    @State private var showingSaveError = false
    @State private var showingShareSheet = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // 半透明背景
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    closePopup()
                }
            
            // 弹窗内容 - 高度为屏幕的90%
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // 顶部栏 - 关闭按钮
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            closePopup()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(Color(red: 0.95, green: 0.95, blue: 0.95))
                                )
                        }
                        .padding(.trailing, 12)
                        .padding(.top, 12)
                    }
                    
                    // 证书图片 - 适应更大的证书
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                        .padding(.horizontal, 12)
                        .padding(.top, 4)
                    
                    Spacer()
                    
                    // 底部按钮区域
                    HStack(spacing: 16) {
                        // 保存按钮
                        Button(action: {
                            saveToPhotoLibrary()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.down")
                                    .font(.system(size: 18, weight: .medium))
                                Text("保存到相册")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.3, green: 0.7, blue: 0.4),
                                        Color(red: 0.2, green: 0.6, blue: 0.35)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(24)
                            .shadow(color: Color(red: 0.2, green: 0.6, blue: 0.35).opacity(0.4), radius: 6, x: 0, y: 3)
                        }
                        
                        // 分享按钮
                        Button(action: {
                            shareImage()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 18, weight: .medium))
                                Text("分享")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.2, green: 0.5, blue: 0.9),
                                        Color(red: 0.15, green: 0.4, blue: 0.8)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(24)
                            .shadow(color: Color(red: 0.15, green: 0.4, blue: 0.8).opacity(0.4), radius: 6, x: 0, y: 3)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.15), radius: 30, x: 0, y: 15)
                )
                .frame(height: geometry.size.height * 0.9)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 10)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
            .scaleEffect(scale)
            .opacity(opacity)
            
            // 保存成功提示
            if showingSaveSuccess {
                SuccessToastView(message: "证书已保存到相册")
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // 保存失败提示
            if showingSaveError {
                ErrorToastView(message: "保存失败，请检查相册权限")
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                scale = 1.0
                opacity = 1.0
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [image])
        }
    }
    
    // 关闭弹窗
    private func closePopup() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            scale = 0.8
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
    
    // 保存到相册
    private func saveToPhotoLibrary() {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                if status == .authorized || status == .limited {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingSaveSuccess = true
                    }
                    
                    // 1.5秒后自动关闭弹窗
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        closePopup()
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingSaveError = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingSaveError = false
                        }
                    }
                }
            }
        }
    }
    
    // 分享图片
    private func shareImage() {
        showingShareSheet = true
    }
}

// 系统分享表单
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.completionWithItemsHandler = { _, completed, _, _ in
            // 分享完成后可以进行相应处理
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// 带完成回调的分享表单
struct ShareSheetWithCompletion: UIViewControllerRepresentable {
    let items: [Any]
    let onComplete: (Bool) -> Void
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.completionWithItemsHandler = { _, completed, _, _ in
            onComplete(completed)
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    // 创建一个示例图片用于预览
    let size = CGSize(width: 380, height: 540)
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    UIColor(red: 1.0, green: 0.98, blue: 0.94, alpha: 1.0).setFill()
    UIRectFill(CGRect(origin: .zero, size: size))
    let sampleImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    UIGraphicsEndImageContext()
    
    return CertificatePopupView(
        image: sampleImage,
        isPresented: .constant(true)
    )
}

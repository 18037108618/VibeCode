//
//  ConfettiView.swift
//  PraiseApp
//
//  五彩纸屑粒子特效组件
//

import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    
    private let colors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink,
        Color(red: 1.0, green: 0.4, blue: 0.4),
        Color(red: 0.4, green: 0.8, blue: 1.0),
        Color(red: 1.0, green: 0.8, blue: 0.2),
        Color(red: 0.6, green: 1.0, blue: 0.4),
        Color(red: 0.9, green: 0.5, blue: 0.9)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    ConfettiPiece(particle: particle)
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
            }
        }
        .ignoresSafeArea()
    }
    
    private func createParticles(in size: CGSize) {
        particles = (0..<100).map { _ in
            ConfettiParticle(
                id: UUID(),
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: -100...0),
                color: colors.randomElement() ?? .red,
                size: CGFloat.random(in: 6...14),
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: -10...10),
                fallSpeed: Double.random(in: 3...8),
                horizontalDrift: Double.random(in: -2...2),
                shape: ConfettiShape.allCases.randomElement() ?? .rectangle
            )
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    let color: Color
    let size: CGFloat
    var rotation: Double
    let rotationSpeed: Double
    let fallSpeed: Double
    let horizontalDrift: Double
    let shape: ConfettiShape
}

enum ConfettiShape: CaseIterable {
    case rectangle
    case circle
    case triangle
    case star
}

struct ConfettiPiece: View {
    let particle: ConfettiParticle
    
    @State private var offsetY: CGFloat = 0
    @State private var offsetX: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        confettiShapeView
            .frame(width: particle.size, height: particle.size * 1.5)
            .rotationEffect(.degrees(rotation))
            .rotation3DEffect(.degrees(rotation * 2), axis: (x: 1, y: 0, z: 0))
            .position(x: particle.x + offsetX, y: particle.y + offsetY)
            .opacity(opacity)
            .onAppear {
                startAnimation()
            }
    }
    
    @ViewBuilder
    private var confettiShapeView: some View {
        switch particle.shape {
        case .rectangle:
            RoundedRectangle(cornerRadius: 2)
                .fill(particle.color)
        case .circle:
            Circle()
                .fill(particle.color)
        case .triangle:
            Triangle()
                .fill(particle.color)
        case .star:
            Star(corners: 5, smoothness: 0.45)
                .fill(particle.color)
        }
    }
    
    private func startAnimation() {
        let duration = Double.random(in: 2.0...3.5)
        
        withAnimation(.linear(duration: duration)) {
            offsetY = UIScreen.main.bounds.height + 200
            offsetX = CGFloat(particle.horizontalDrift * 100)
            rotation = particle.rotation + particle.rotationSpeed * 50
        }
        
        withAnimation(.linear(duration: duration).delay(duration * 0.7)) {
            opacity = 0
        }
    }
}

// 三角形
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// 星形
struct Star: Shape {
    let corners: Int
    let smoothness: CGFloat
    
    func path(in rect: CGRect) -> Path {
        guard corners >= 2 else { return Path() }
        
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        var currentAngle = -CGFloat.pi / 2
        let angleAdjustment = .pi * 2 / CGFloat(corners * 2)
        let innerX = center.x * smoothness
        let innerY = center.y * smoothness
        
        var path = Path()
        
        path.move(to: CGPoint(
            x: center.x * cos(currentAngle) + center.x,
            y: center.y * sin(currentAngle) + center.y
        ))
        
        var bottomEdge: CGFloat = 0
        
        for corner in 0..<corners * 2 {
            let sinAngle = sin(currentAngle)
            let cosAngle = cos(currentAngle)
            let bottom: CGFloat
            
            if corner.isMultiple(of: 2) {
                bottom = center.y * sinAngle + center.y
                path.addLine(to: CGPoint(
                    x: center.x * cosAngle + center.x,
                    y: bottom
                ))
            } else {
                bottom = innerY * sinAngle + center.y
                path.addLine(to: CGPoint(
                    x: innerX * cosAngle + center.x,
                    y: bottom
                ))
            }
            
            if bottom > bottomEdge {
                bottomEdge = bottom
            }
            
            currentAngle += angleAdjustment
        }
        
        path.closeSubpath()
        
        let unusedSpace = (rect.height - bottomEdge) / 2
        let transform = CGAffineTransform(translationX: 0, y: unusedSpace)
        return path.applying(transform)
    }
}

// UIKit版本的粒子发射器（更流畅的效果）
struct ConfettiEmitterView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        let emitterLayer = CAEmitterLayer()
        emitterLayer.emitterPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: -50)
        emitterLayer.emitterSize = CGSize(width: UIScreen.main.bounds.width, height: 1)
        emitterLayer.emitterShape = .line
        emitterLayer.beginTime = CACurrentMediaTime()
        
        let colors: [UIColor] = [
            .systemRed, .systemOrange, .systemYellow, .systemGreen,
            .systemBlue, .systemPurple, .systemPink, .cyan
        ]
        
        var cells: [CAEmitterCell] = []
        
        for color in colors {
            let cell = CAEmitterCell()
            cell.birthRate = 20
            cell.lifetime = 3.0
            cell.velocity = 150
            cell.velocityRange = 50
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi / 4
            cell.spin = 2
            cell.spinRange = 3
            cell.scale = 0.08
            cell.scaleRange = 0.04
            cell.color = color.cgColor
            cell.alphaSpeed = -0.3
            
            // 使用系统提供的形状
            cell.contents = createConfettiImage(color: color)?.cgImage
            
            cells.append(cell)
        }
        
        emitterLayer.emitterCells = cells
        view.layer.addSublayer(emitterLayer)
        
        // 1.5秒后停止发射
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            emitterLayer.birthRate = 0
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    private func createConfettiImage(color: UIColor) -> UIImage? {
        let size = CGSize(width: 12, height: 18)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.setFillColor(color.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

#Preview {
    ZStack {
        Color.white
        ConfettiView()
    }
}

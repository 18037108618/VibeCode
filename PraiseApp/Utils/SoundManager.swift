//
//  SoundManager.swift
//  PraiseApp
//
//  声音效果管理器 - 处理点赞相关的声音播放
//

import AVFoundation
import UIKit
import AudioToolbox

/// 声音类型枚举
enum SoundType: String {
    case cheer = "cheer"           // 喝彩声（单击点赞时）
    case bubble = "bubble"         // 气泡声（连续点击/长按时）
}

/// 声音管理器单例
class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayers: [SoundType: AVAudioPlayer] = [:]
    private var audioEngine: AVAudioEngine?
    private var cheerPlayerNode: AVAudioPlayerNode?
    private var bubblePlayerNode: AVAudioPlayerNode?
    
    // 预生成的音频缓冲区
    private var cheerBuffer: AVAudioPCMBuffer?
    private var bubbleBuffer: AVAudioPCMBuffer?
    
    // 是否启用声音
    var isSoundEnabled: Bool = true
    
    // 标记是否有自定义声音文件
    private var hasCustomCheerSound = false
    private var hasCustomBubbleSound = false
    
    private init() {
        setupAudioSession()
        preloadSounds()
        setupSynthesizedSounds()
    }
    
    /// 设置音频会话
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    /// 预加载自定义声音文件
    private func preloadSounds() {
        for soundType in [SoundType.cheer, SoundType.bubble] {
            let extensions = ["mp3", "wav", "caf", "m4a"]
            
            for ext in extensions {
                if let url = Bundle.main.url(forResource: soundType.rawValue, withExtension: ext) {
                    do {
                        let player = try AVAudioPlayer(contentsOf: url)
                        player.prepareToPlay()
                        player.volume = soundType == .bubble ? 0.5 : 0.8
                        audioPlayers[soundType] = player
                        
                        if soundType == .cheer {
                            hasCustomCheerSound = true
                        } else {
                            hasCustomBubbleSound = true
                        }
                        break
                    } catch {
                        print("Failed to load sound \(soundType.rawValue): \(error)")
                    }
                }
            }
        }
    }
    
    /// 设置合成声音（当没有自定义声音文件时使用）
    private func setupSynthesizedSounds() {
        audioEngine = AVAudioEngine()
        guard let engine = audioEngine else { return }
        
        let mainMixer = engine.mainMixerNode
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        
        // 创建喝彩声音的播放器节点
        cheerPlayerNode = AVAudioPlayerNode()
        if let node = cheerPlayerNode {
            engine.attach(node)
            engine.connect(node, to: mainMixer, format: format)
        }
        
        // 创建气泡声音的播放器节点
        bubblePlayerNode = AVAudioPlayerNode()
        if let node = bubblePlayerNode {
            engine.attach(node)
            engine.connect(node, to: mainMixer, format: format)
        }
        
        // 预生成喝彩声音缓冲区（欢呼声效果 - 多个频率混合的升调音）
        cheerBuffer = generateCheerSound(format: format)
        
        // 预生成气泡声音缓冲区（气泡上浮效果 - 清脆的泡泡音）
        bubbleBuffer = generateBubbleSound(format: format)
        
        do {
            try engine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    /// 生成喝彩声音（多频率混合的欢呼声效果）
    private func generateCheerSound(format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let sampleRate = format.sampleRate
        let duration: Double = 0.6  // 0.6秒
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return nil
        }
        buffer.frameLength = frameCount
        
        guard let channelData = buffer.floatChannelData?[0] else {
            return nil
        }
        
        // 生成多频率混合的欢呼声效果
        for frame in 0..<Int(frameCount) {
            let time = Double(frame) / sampleRate
            let progress = time / duration
            
            // 频率从低到高变化（升调效果）
            let baseFreq1 = 400.0 + progress * 200.0
            let baseFreq2 = 600.0 + progress * 300.0
            let baseFreq3 = 800.0 + progress * 400.0
            
            // 混合多个正弦波
            let sample1 = sin(2.0 * Double.pi * baseFreq1 * time) * 0.3
            let sample2 = sin(2.0 * Double.pi * baseFreq2 * time) * 0.25
            let sample3 = sin(2.0 * Double.pi * baseFreq3 * time) * 0.2
            
            // 添加一些泛音
            let harmonic1 = sin(2.0 * Double.pi * baseFreq1 * 2.0 * time) * 0.1
            let harmonic2 = sin(2.0 * Double.pi * baseFreq2 * 1.5 * time) * 0.08
            
            // 包络（快速起音，缓慢衰减）
            let attack = min(1.0, time / 0.05)
            let decay = max(0.0, 1.0 - pow(progress, 0.5) * 0.8)
            let envelope = attack * decay
            
            let mixedSample = (sample1 + sample2 + sample3 + harmonic1 + harmonic2) * envelope * 0.6
            channelData[frame] = Float(mixedSample)
        }
        
        return buffer
    }
    
    /// 生成气泡声音（清脆的泡泡上浮音效）
    private func generateBubbleSound(format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let sampleRate = format.sampleRate
        let duration: Double = 0.15  // 0.15秒（短促的气泡音）
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return nil
        }
        buffer.frameLength = frameCount
        
        guard let channelData = buffer.floatChannelData?[0] else {
            return nil
        }
        
        // 生成气泡上浮的音效（频率上升的短促音）
        for frame in 0..<Int(frameCount) {
            let time = Double(frame) / sampleRate
            let progress = time / duration
            
            // 频率快速上升（模拟气泡上浮变小的效果）
            let frequency = 800.0 + progress * progress * 1200.0
            
            // 主音
            let sample = sin(2.0 * Double.pi * frequency * time)
            
            // 添加轻微的噪声使声音更自然
            let noise = (Double.random(in: -1...1)) * 0.05 * (1.0 - progress)
            
            // 包络（快速起音，快速衰减）
            let attack = min(1.0, time / 0.01)
            let decay = pow(1.0 - progress, 2.0)
            let envelope = attack * decay
            
            let mixedSample = (sample + noise) * envelope * 0.5
            channelData[frame] = Float(mixedSample)
        }
        
        return buffer
    }
    
    /// 播放喝彩声音（单击点赞时调用）
    func playCheerSound() {
        guard isSoundEnabled else { return }
        
        // 优先使用自定义声音文件
        if hasCustomCheerSound, let player = audioPlayers[.cheer] {
            if player.isPlaying {
                player.stop()
            }
            player.currentTime = 0
            player.play()
            return
        }
        
        // 使用合成声音
        if let node = cheerPlayerNode, let buffer = cheerBuffer {
            if node.isPlaying {
                node.stop()
            }
            node.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
            node.play()
        }
        
        // 同时添加触觉反馈增强体验
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// 播放气泡声音（连续点击/长按时调用）
    func playBubbleSound() {
        guard isSoundEnabled else { return }
        
        // 优先使用自定义声音文件
        if hasCustomBubbleSound {
            // 为气泡声音创建新的播放器实例，以支持重叠播放
            let extensions = ["mp3", "wav", "caf", "m4a"]
            for ext in extensions {
                if let url = Bundle.main.url(forResource: SoundType.bubble.rawValue, withExtension: ext) {
                    do {
                        let player = try AVAudioPlayer(contentsOf: url)
                        player.volume = 0.4
                        player.play()
                        return
                    } catch {
                        break
                    }
                }
            }
        }
        
        // 使用合成声音
        if let node = bubblePlayerNode, let buffer = bubbleBuffer {
            // 气泡声音允许重叠播放
            node.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
            if !node.isPlaying {
                node.play()
            }
        }
        
        // 同时添加轻柔的触觉反馈
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// 播放指定类型的声音
    func playSound(_ type: SoundType) {
        switch type {
        case .cheer:
            playCheerSound()
        case .bubble:
            playBubbleSound()
        }
    }
    
    /// 停止所有声音
    func stopAllSounds() {
        for player in audioPlayers.values {
            player.stop()
        }
        cheerPlayerNode?.stop()
        bubblePlayerNode?.stop()
    }
}

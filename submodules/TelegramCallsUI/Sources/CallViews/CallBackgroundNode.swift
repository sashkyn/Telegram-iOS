import Foundation
import AsyncDisplayKit
import GradientBackground
import AccountContext

final class CallBackgroundNode: ASDisplayNode {
    
    private var gradientState: GradientState
    private var spinningState: SpinningState
    
    private var validLayout: CGSize?
    private let gradientNode: GradientBackgroundNode
    
    init(gradientState: GradientState = .ringingOrCallEnded) {
        print("call gradient: init")
        self.gradientState = gradientState
        self.spinningState = .stopped
        self.gradientNode = createGradientBackgroundNode(
            colors: gradientState.colors,
            useSharedAnimationPhase: true
        )
        
        super.init()
        
        self.addSubnode(self.gradientNode)
    }
    
    func updateLayout(size: CGSize, completion: @escaping () -> Void) {
        self.validLayout = size
        print("call gradient: updateLayout")
        self.gradientNode.updateLayout(
            size: size,
            transition: .immediate,
            extendAnimation: false,
            backwards: false,
            completion: completion
        )
    }
    
    func startSpinning(fromAnimateNext: Bool = false) {
        print("call gradient: startSpinning - fromAnimateNext = \(fromAnimateNext)")
        guard fromAnimateNext || (validLayout != nil && spinningState == .stopped) else {
            gradientNode.layer.removeAllAnimations()
            return
        }
        
        self.spinningState = .spinning
        
        self.gradientNode.animateEvent(
            transition: .animated(duration: 0.5, curve: .linear),
            extendAnimation: false,
            backwards: false,
            completion: { [weak self] in
                if self?.spinningState == .spinning {
                    // INFO: исправить цикличные вызовы после ухода с экрана на back
                    self?.startSpinning(fromAnimateNext: true)
                }
            }
        )
    }
    
    func stopSpinning() {
        print("call gradient: stopSpinning")
        spinningState = .stopped
        gradientNode.layer.removeAllAnimations()
    }
    
    func update(presentationCallState: PresentationCallState.State) {
        switch presentationCallState {
        case .waiting,
             .ringing,
             .requesting,
             .connecting,
             .reconnecting,
             .terminating,
             .terminated:
            self.gradientState = .ringingOrCallEnded
        case .active(_, let statusReception, _) where (statusReception ?? 0) < 2:
            self.gradientState = .weakSignal
        case .active:
            self.gradientState = .active
        }
        
        self.gradientNode.updateColors(colors: self.gradientState.colors)
    }
    
    deinit {
        print("call gradient: deinit")
    }
}

extension CallBackgroundNode {
    
    enum GradientState {
        case ringingOrCallEnded
        case weakSignal
        case active
        
        var colors: [UIColor] {
            switch self {
            case .active:
                return Constants.activeColors
            case .ringingOrCallEnded:
                return Constants.ringingOrCallEndedColors
            case .weakSignal:
                return Constants.weakSignalColors
            }
        }
    }
}

extension CallBackgroundNode {
    
    enum SpinningState {
        case spinning
        case stopped
    }
}

private extension CallBackgroundNode {
    
    enum Constants {
        static let ringingOrCallEndedColors: [UIColor] = [
            UIColor(rgb: 0x5295D6),
            UIColor(rgb: 0x616AD5),
            UIColor(rgb: 0xAC65D4),
            UIColor(rgb: 0x7261DA)
        ]

        static let weakSignalColors: [UIColor] = [
            UIColor(rgb: 0xB84498),
            UIColor(rgb: 0xF4992E),
            UIColor(rgb: 0xFF7E46),
            UIColor(rgb: 0xFF7E46)
        ]

        static let activeColors: [UIColor] = [
            UIColor(rgb: 0x53A6DE),
            UIColor(rgb: 0x398D6F),
            UIColor(rgb: 0xBAC05D),
            UIColor(rgb: 0x3C9C8F)
        ]
    }
}

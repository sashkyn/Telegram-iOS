import Foundation
import AsyncDisplayKit
import AvatarNode
import AccountContext
import Postbox
import TelegramCore
import SwiftSignalKit
import AudioBlob
import Display
import AnimatedAvatarSetNode

private let avatarFont = avatarPlaceholderFont(size: 42.0)

final class CallUserAvatarNode: ASDisplayNode {
    
    private var audioBlobState: AudioBlobState
    
    private var avatarNode: ContentNode?
    private var peer: Peer?
    
    override init() {
        self.audioBlobState = .audio
        super.init()
    }
    
    func updateData(
        peer: Peer,
        account: Account,
        sharedAccountContext: SharedAccountContext
    ) {
        guard self.peer?.id != peer.id else {
            return
        }
        self.peer = peer
        
        let avatarNode = ContentNode(
            context: sharedAccountContext.makeTempAccountContext(account: account),
            peer: EnginePeer(peer),
            placeholderColor: UIColor.black,
            size: CGSize(width: 136.0, height: 136.0),
            spacing: .zero
        )
        self.addSubnode(avatarNode)
        self.avatarNode = avatarNode
    }
    
    func updateLayout() {
        self.avatarNode?.updateLayout(
            size: CGSize(width: 136.0, height: 136.0),
            isClipped: true,
            animated: true
        )
        self.avatarNode?.updateAudioLevel(
            color: UIColor.white,
            value: 0.15
        )
        avatarNode?.setNeedsLayout()
    }
    
    func update(audioLevel: Float) {
        guard audioBlobState == .audio else {
            return
        }
        
        self.avatarNode?.updateAudioLevel(
            color: UIColor.white,
            value: audioLevel
        )
    }
    
    func update(audioBlobState: AudioBlobState) {
        self.audioBlobState = audioBlobState
        
        switch audioBlobState {
        case .spinning,
             .audio:
            self.avatarNode?.updateAudioLevel(
                color: UIColor.white,
                value: 0.15
            )
        case .disabled:
            self.avatarNode?.updateAudioLevel(
                color: UIColor.white,
                value: -1.0
            )
        }
    }
}

extension CallUserAvatarNode {
    
    enum AudioBlobState {
        case audio
        case spinning
        case disabled
    }
}

private final class ContentNode: ASDisplayNode {
    private var audioLevelView: VoiceBlobView?
    private let unclippedNode: ASImageNode
    private let clippedNode: ASImageNode

    private var size: CGSize
    private var spacing: CGFloat
    
    private var disposable: Disposable?
    
    init(context: AccountContext, peer: EnginePeer?, placeholderColor: UIColor, size: CGSize, spacing: CGFloat) {
        self.size = size
        self.spacing = spacing

        self.unclippedNode = ASImageNode()
        self.clippedNode = ASImageNode()
        
        super.init()
        
        self.addSubnode(self.unclippedNode)
        self.addSubnode(self.clippedNode)

        if let peer = peer {
            if let representation = peer.largeProfileImage, let signal = peerAvatarImage(account: context.account, peerReference: PeerReference(peer._asPeer()), authorOfMessage: nil, representation: representation, displayDimensions: size, synchronousLoad: false) {
                let image = generateImage(size, rotatedContext: { size, context in
                    context.clear(CGRect(origin: CGPoint(), size: size))
                    context.setFillColor(UIColor.lightGray.cgColor)
                    context.fillEllipse(in: CGRect(origin: CGPoint(), size: size))
                })!
                self.updateImage(image: image, size: size, spacing: spacing)

                let disposable = (signal
                |> deliverOnMainQueue).start(next: { [weak self] imageVersions in
                    guard let strongSelf = self else {
                        return
                    }
                    let image = imageVersions?.0
                    if let image = image {
                        strongSelf.updateImage(image: image, size: size, spacing: spacing)
                    }
                })
                self.disposable = disposable
            } else {
                let image = generateImage(size, rotatedContext: { size, context in
                    context.clear(CGRect(origin: CGPoint(), size: size))
                    drawPeerAvatarLetters(context: context, size: size, font: avatarFont, letters: peer.displayLetters, peerId: peer.id)
                })!
                self.updateImage(image: image, size: size, spacing: spacing)
            }
        } else {
            let image = generateImage(size, rotatedContext: { size, context in
                context.clear(CGRect(origin: CGPoint(), size: size))
                context.setFillColor(placeholderColor.cgColor)
                context.fillEllipse(in: CGRect(origin: CGPoint(), size: size))
            })!
            self.updateImage(image: image, size: size, spacing: spacing)
        }
    }
    
    private func updateImage(image: UIImage, size: CGSize, spacing: CGFloat) {
        self.unclippedNode.image = image
        self.clippedNode.image = generateImage(size, rotatedContext: { size, context in
            context.clear(CGRect(origin: CGPoint(), size: size))
            context.translateBy(x: size.width / 2.0, y: size.height / 2.0)
            context.scaleBy(x: 1.0, y: -1.0)
            context.translateBy(x: -size.width / 2.0, y: -size.height / 2.0)
            context.draw(image.cgImage!, in: CGRect(origin: CGPoint(), size: size))
            context.translateBy(x: size.width / 2.0, y: size.height / 2.0)
            context.scaleBy(x: 1.0, y: -1.0)
            context.translateBy(x: -size.width / 2.0, y: -size.height / 2.0)
            
            context.setBlendMode(.copy)
            context.setFillColor(UIColor.clear.cgColor)
            context.fillEllipse(in: CGRect(origin: CGPoint(), size: size).insetBy(dx: 0.0, dy: 0.0).offsetBy(dx: spacing - size.width, dy: 0.0))
        })
    }
    
    deinit {
        self.disposable?.dispose()
    }
    
    func updateLayout(size: CGSize, isClipped: Bool, animated: Bool) {
        self.unclippedNode.frame = CGRect(origin: CGPoint(), size: size)
        self.clippedNode.frame = CGRect(origin: CGPoint(), size: size)
        
        if animated && self.unclippedNode.alpha.isZero != self.clippedNode.alpha.isZero {
            let transition: ContainedViewLayoutTransition = .animated(duration: 0.2, curve: .easeInOut)
            transition.updateAlpha(node: self.unclippedNode, alpha: isClipped ? 0.0 : 1.0)
            transition.updateAlpha(node: self.clippedNode, alpha: isClipped ? 1.0 : 0.0)
        } else {
            self.unclippedNode.alpha = isClipped ? 0.0 : 1.0
            self.clippedNode.alpha = isClipped ? 1.0 : 0.0
        }
    }
    
    func updateAudioLevel(color: UIColor, value: Float) {
        if self.audioLevelView == nil, value > 0.0 {
            let blobFrame = self.unclippedNode.bounds.insetBy(dx: -30.0, dy: -30.0)
            
            let audioLevelView = VoiceBlobView(
                frame: blobFrame,
                maxLevel: 1.0,
                smallBlobRange: (0, 0),
                mediumBlobRange: (0.8, 1.2),
                bigBlobRange: (0.9, 1.4)
            )
            
            audioLevelView.setColor(color)
            self.audioLevelView = audioLevelView
            self.view.insertSubview(audioLevelView, at: 0)
        }
        
        if let audioLevelView = self.audioLevelView {
            audioLevelView.updateLevel(CGFloat(value) * 2.0)
            
            let audioLevelScale: CGFloat
            if value > 0.0 {
                audioLevelView.startAnimating()
                audioLevelScale = 1.0
            } else {
                audioLevelView.stopAnimating(duration: 0.5)
                audioLevelScale = 0.01
            }
            
            let transition: ContainedViewLayoutTransition = .animated(duration: 0.2, curve: .easeInOut)
            
            transition.updateSublayerTransformScale(
                layer: audioLevelView.layer,
                scale: CGPoint(x: audioLevelScale, y: audioLevelScale),
                beginWithCurrentState: true
            )
        }
    }
}

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

private let avatarFont = avatarPlaceholderFont(size: 12.0)

final class CallUserAvatarNode: ASDisplayNode {
    
    private var avatarNode: ContentNode?
    private var peer: Peer?
    
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
            synchronousLoad: true,
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
            value: 3.0
        )
        avatarNode?.setNeedsLayout()
    }
}

private final class ContentNode: ASDisplayNode {
    private var audioLevelView: VoiceBlobView?
    private let unclippedNode: ASImageNode
    private let clippedNode: ASImageNode

    private var size: CGSize
    private var spacing: CGFloat
    
    private var disposable: Disposable?
    
    init(context: AccountContext, peer: EnginePeer?, placeholderColor: UIColor, synchronousLoad: Bool, size: CGSize, spacing: CGFloat) {
        self.size = size
        self.spacing = spacing

        self.unclippedNode = ASImageNode()
        self.clippedNode = ASImageNode()
        
        super.init()
        
        self.addSubnode(self.unclippedNode)
        self.addSubnode(self.clippedNode)

        if let peer = peer {
            if let representation = peer.largeProfileImage, let signal = peerAvatarImage(account: context.account, peerReference: PeerReference(peer._asPeer()), authorOfMessage: nil, representation: representation, displayDimensions: size, synchronousLoad: synchronousLoad) {
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
            context.fillEllipse(in: CGRect(origin: CGPoint(), size: size).insetBy(dx: -1.5, dy: -1.5).offsetBy(dx: spacing - size.width, dy: 0.0))
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
                maxLevel: 0.3,
                smallBlobRange: (0, 0),
                mediumBlobRange: (0.7, 0.8),
                bigBlobRange: (0.8, 0.9)
            )
            
            let maskRect = CGRect(origin: .zero, size: blobFrame.size)
            let playbackMaskLayer = CAShapeLayer()
            playbackMaskLayer.frame = maskRect
            playbackMaskLayer.fillRule = .evenOdd
            let maskPath = UIBezierPath()
            maskPath.append(UIBezierPath(roundedRect: self.unclippedNode.bounds.offsetBy(dx: 8, dy: 8), cornerRadius: maskRect.width / 2.0))
            maskPath.append(UIBezierPath(rect: maskRect))
            playbackMaskLayer.path = maskPath.cgPath
//            audioLevelView.layer.mask = playbackMaskLayer
            
            audioLevelView.setColor(color)
            self.audioLevelView = audioLevelView
            self.view.insertSubview(audioLevelView, at: 0)
        }
        
        let level = min(1.0, max(0.0, CGFloat(value)))
        if let audioLevelView = self.audioLevelView {
            audioLevelView.updateLevel(CGFloat(value) * 2.0)
            
            let avatarScale: CGFloat
            let audioLevelScale: CGFloat
            if value > 0.0 {
                audioLevelView.startAnimating()
                avatarScale = 1.03 + level * 0.07
                audioLevelScale = 1.0
            } else {
                audioLevelView.stopAnimating(duration: 0.5)
                avatarScale = 1.0
                audioLevelScale = 0.01
            }
            
            let transition: ContainedViewLayoutTransition = .animated(duration: 0.2, curve: .easeInOut)
            transition.updateSublayerTransformScale(node: self, scale: CGPoint(x: avatarScale, y: avatarScale), beginWithCurrentState: true)
            transition.updateSublayerTransformScale(layer: audioLevelView.layer, scale: CGPoint(x: audioLevelScale, y: audioLevelScale), beginWithCurrentState: true)
        }
    }
}

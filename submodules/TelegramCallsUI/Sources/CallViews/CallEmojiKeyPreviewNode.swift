import Foundation
import UIKit
import Display
import AsyncDisplayKit
import SwiftSignalKit
import LegacyComponents
import AccountContext
import AnimatedStickerNode
import TelegramCore
import TelegramAnimatedStickerNode
import ShimmerEffect
import StickerResources

// TODO: сделать динамический style black или light для effectView для видео и нет
// TODO: сделать анимацию появления и убирания
// TODO: сделать состояния кнопки ок

// INFO: вьюшка с эмодзями на полный экран
final class CallEmojiKeyPreviewNode: ASDisplayNode {
    private let keyTextNode: ASTextNode
    private let titleTextNode: ASTextNode
    private let infoTextNode: ASTextNode
    private let separatorButtonNode: ASDisplayNode
    private let okButtonNode: ASButtonNode
    private let effectView: UIVisualEffectView
    private let containerNode: ASDisplayNode
    
    private let accountContext: AccountContext
    private let animatedKeysStickerContainer: ASDisplayNode
    private let animatedStickerFiles: [TelegramMediaFile]
    private var disposable = DisposableSet()
    
    private var animatedEmoji: Bool {
        animatedStickerFiles.count == keyTextNode.attributedText?.string.count
    }
    
    private let dismiss: () -> Void
    
    init(
        accountContext: AccountContext,
        animatedStickerFiles: [TelegramMediaFile],
        keyText: String,
        titleText: String,
        infoText: String,
        dismiss: @escaping () -> Void
    ) {
        self.accountContext = accountContext
        self.animatedStickerFiles = animatedStickerFiles
        
        self.containerNode = ASDisplayNode()
        self.containerNode.displaysAsynchronously = false
        
        self.keyTextNode = ASTextNode()
        self.keyTextNode.displaysAsynchronously = false
        
        self.titleTextNode = ASTextNode()
        self.titleTextNode.displaysAsynchronously = false
        self.infoTextNode = ASTextNode()
        self.infoTextNode.displaysAsynchronously = false
        self.okButtonNode = ASButtonNode()
        self.okButtonNode.displaysAsynchronously = false
        self.separatorButtonNode = ASDisplayNode()
        self.separatorButtonNode.displaysAsynchronously = false
        self.dismiss = dismiss
        
        self.effectView = UIVisualEffectView()
        self.effectView.effect = UIBlurEffect(style: .light)
        
        self.animatedKeysStickerContainer = ASDisplayNode()
        self.animatedKeysStickerContainer.displaysAsynchronously = false
        
        super.init()

        // TODO: сделать ее с анимированными эмодзями
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        self.keyTextNode.attributedText = NSAttributedString(
            string: keyText,
            attributes: [
                NSAttributedString.Key.font: Font.regular(42.0),
                NSAttributedString.Key.kern: 6.0 as NSNumber,
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
        )
        
        self.titleTextNode.attributedText = NSAttributedString(
            string: titleText,
            font: Font.bold(16.0),
            textColor: UIColor.white,
            paragraphAlignment: .center
        )
        
        self.infoTextNode.attributedText = NSAttributedString(
            string: infoText,
            font: Font.regular(16.0),
            textColor: UIColor.white,
            paragraphAlignment: .center
        )
        
        self.separatorButtonNode.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        self.okButtonNode.setTitle(
            "OK", // TODO: Strings
            with: Font.regular(20.0),
            with: UIColor.white,
            for: .normal
        )
        
        self.containerNode.view.addSubview(self.effectView)
        self.effectView.layer.cornerRadius = 20.0
        self.effectView.clipsToBounds = true
        
        self.containerNode.addSubnode(self.titleTextNode)
        self.containerNode.addSubnode(self.infoTextNode)
        self.containerNode.addSubnode(self.separatorButtonNode)
        self.containerNode.addSubnode(self.okButtonNode)
        self.addSubnode(containerNode)
        
        self.addSubnode(self.keyTextNode)
        self.addSubnode(self.animatedKeysStickerContainer)

        animatedStickerFiles.forEach { file in
            let stickerNode = StickerNode(context: accountContext, file: file)
            self.animatedKeysStickerContainer.addSubnode(stickerNode)
        }
    }
    
    deinit {
        self.disposable.dispose()
    }
    
    override func didLoad() {
        super.didLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapGesture(_:))))
    }
    
    private var validLayout: CGSize? = nil
    
    func updateLayout(
        size: CGSize,
        topOffset: CGFloat,
        transition: ContainedViewLayoutTransition
    ) {
        guard validLayout == nil else {
            return
        }
        
        self.validLayout = size
        
        let alertWidth: CGFloat = size.width - 45.0 * 2
        let alertX = floor((size.width - alertWidth) / 2)
        let alertY = topOffset
        
        // Key
        let keyTextSize = self.keyTextNode.measure(.init(width: size.width, height: .greatestFiniteMagnitude))
        let keyTextFrame = CGRect(
            origin: CGPoint(
                x: floor((size.width - keyTextSize.width) / 2),
                y: topOffset + 20.0
            ),
            size: keyTextSize
        )
        
        // Animated Key
        transition.updateFrame(
            node: self.animatedKeysStickerContainer,
            frame: keyTextFrame
        )
        
        animatedKeysStickerContainer.subnodes?
            .compactMap { $0 as? StickerNode }
            .enumerated()
            .forEach { index, node in
                let frame = CGRect(
                    x: index == 0 ? 0.0 : (48.0 + 6) * CGFloat(index),
                    y: 0.0,
                    width: 48.0,
                    height: 48.0
                )
                
                transition.updateFrame(
                    node: node,
                    frame: frame
                )
                
                node.updateLayout(
                    size: frame.size,
                    transition: .immediate
                )
            }
        
        // Static Key
        transition.updateFrame(
            node: self.keyTextNode,
            frame: keyTextFrame
        )
        
        // Title
        let titleSize = self.titleTextNode.measure(
            CGSize(
                width: alertWidth - 16 - 16,
                height: .greatestFiniteMagnitude
            )
        )
        
        transition.updateFrame(
            node: self.titleTextNode,
            frame: CGRect(
                origin: CGPoint(
                    x: floor((alertWidth - titleSize.width) / 2),
                    y: 20 + keyTextSize.height + 10.0
                ),
                size: titleSize
            )
        )
        
        // Info
        let infoTextSize = self.infoTextNode.measure(
            CGSize(
                width: alertWidth - 16 - 16,
                height: .greatestFiniteMagnitude
            )
        )
        let infoTextFrame = CGRect(
            origin: CGPoint(
                x: floor((alertWidth - infoTextSize.width) / 2),
                y: self.titleTextNode.frame.maxY + 10.0
            ),
            size: infoTextSize
        )
        transition.updateFrame(
            node: self.infoTextNode,
            frame: infoTextFrame
        )
        
        // Separator
        transition.updateFrame(
            node: self.separatorButtonNode,
            frame: CGRect(
                origin: CGPoint(
                    x: 0.0,
                    y: infoTextFrame.maxY + 10
                ),
                size: CGSize(
                    width: alertWidth,
                    height: 0.3
                )
            )
        )
        
        // Ok Button
        let buttonHeight = 56.0
        transition.updateFrame(
            node: self.okButtonNode,
            frame: CGRect(
                origin: CGPoint(
                    x: 0.0,
                    y: self.separatorButtonNode.frame.maxY + 1.0
                ),
                size: CGSize(
                    width: alertWidth,
                    height: buttonHeight
                )
            )
        )
        
        // Container
        let alertHeight: CGFloat = 20.0 + keyTextSize.height + 10 + titleSize.height + 10.0 + infoTextSize.height + 10.0 + 1.0 + buttonHeight
        let alertSize = CGSize(
            width: alertWidth,
            height: alertHeight
        )
        
        let alertFrame = CGRect(
            origin: CGPoint(
                x: alertX,
                y: alertY
            ),
            size: alertSize
        )
        
        transition.updateFrame(
            node: self.containerNode,
            frame: alertFrame
        )

        self.effectView.frame = self.containerNode.bounds
    }
    
    func animateIn(from rect: CGRect, fromNode: ASDisplayNode) {
        // INFO: Начальные значения
        let immediateTransition = ContainedViewLayoutTransition.immediate
        
        let targetContainerPosition = self.containerNode.frame.origin
        immediateTransition.updatePosition(node: self.containerNode, position: .init(x: rect.maxX, y: rect.minY))
        immediateTransition.updateTransformScale(node: self.containerNode, scale: 0.0)
        self.containerNode.alpha = 0.0
        
        let targetKeyFrame = self.animatedKeysStickerContainer.frame
        //let keySize = self.animatedKeysStickerContainer.frame.size
        let initialKeyScale = 0.75 //rect.size.height / keySize.height
        
        // INFO: Анимация эмодзи
        self.animatedKeysStickerContainer.isHidden = !animatedEmoji
        self.keyTextNode.isHidden = animatedEmoji
        
        let keyTransition = ContainedViewLayoutTransition.animated(duration: 0.4, curve: .easeInOut)
        
        if animatedEmoji {
            immediateTransition.updateTransformScale(
                node: self.animatedKeysStickerContainer,
                scale: initialKeyScale
            )
            
            immediateTransition.updateFrame(
                node: self.animatedKeysStickerContainer,
                frame: .init(origin: .init(x: rect.minX - 16, y: rect.minY - 6), size: rect.size)
            )
            
            keyTransition.updateTransformScale(node: self.animatedKeysStickerContainer, scale: 1.0)
            keyTransition.updateFrame(
                node: self.animatedKeysStickerContainer,
                frame: targetKeyFrame
            )
            
            animatedKeysStickerContainer.subnodes?
                .compactMap { $0 as? StickerNode }
                .enumerated()
                .forEach { index, node in
                    immediateTransition.updateTransformScale(node: node, scale: initialKeyScale)
                    immediateTransition.updateFrame(
                        node: node,
                        frame: .init(
                            x: (index == 0 ? 0.0 : 48.0 * CGFloat(index)) * initialKeyScale,
                            y: 0.0,
                            width: 48.0 * initialKeyScale,
                            height: 48.0 * initialKeyScale
                        )
                    )
                    node.setVisible(true)
                    
                    keyTransition.updateTransformScale(node: node, scale: 1.0)
                    keyTransition.updateFrame(
                        node: node,
                        frame: .init(
                            x: (index == 0 ? 0.0 : (48.0 + 6) * CGFloat(index)),
                            y: 0.0,
                            width: node.frame.width * initialKeyScale,
                            height: node.frame.height * initialKeyScale
                        )
                    )
                }
            
        } else {
            immediateTransition.updateTransformScale(
                node: self.keyTextNode,
                scale: initialKeyScale
            )
            immediateTransition.updateFrame(
                node: self.keyTextNode,
                frame: rect
            )
            keyTransition.updateTransformScale(node: self.keyTextNode, scale: 1.0)
            keyTransition.updateFrame(
                node: self.keyTextNode,
                frame: targetKeyFrame
            )
        }
        
        // INFO: Анимация контейнера
        let transition = ContainedViewLayoutTransition.animated(duration: 0.3, curve: .easeInOut)
        transition.updateAlpha(node: self.containerNode, alpha: 1.0)
        transition.updateTransformScale(node: self.containerNode, scale: 1.0)
        
        transition.updateFrame(
            node: self.containerNode,
            frame: .init(
                origin: targetContainerPosition,
                size: self.containerNode.frame.size
            )
        )
    }
    
    func animateOut(to rect: CGRect, toNode: ASDisplayNode, completion: (() -> Void)?) {
        let transition = ContainedViewLayoutTransition.animated(duration: 0.3, curve: .spring)
        transition.updateAlpha(node: self.containerNode, alpha: 0.0, completion: { _ in
            completion?()
        })
        
        if animatedEmoji {
            transition.updateAlpha(node: self.animatedKeysStickerContainer, alpha: 0.0)
        } else {
            transition.updateAlpha(node: self.keyTextNode, alpha: 0.0)
        }
        
//        transition.updateFrame(
//            node: self.containerNode,
//            frame: .init(
//                origin: rect.origin,
//                size: rect.size
//            )
//        )
        
//        let scale = 0.75
//        let targetFrame = CGRect(origin: .init(x: rect.minX - 16, y: rect.minY - 6), size: rect.size)
//        let keyTransition = ContainedViewLayoutTransition.animated(duration: 0.4, curve: .easeInOut)
//        if animatedEmoji {
//            keyTransition.updateTransformScale(node: self.animatedKeysStickerContainer, scale: 0.75)
//            keyTransition.updateFrame(
//                node: self.animatedKeysStickerContainer,
//                frame: targetFrame
//            )
//
//            animatedKeysStickerContainer.subnodes?
//                .compactMap { $0 as? StickerNode }
//                .enumerated()
//                .forEach { index, node in
//                    keyTransition.updateTransformScale(node: node, scale: 1.0)
//                    keyTransition.updateFrame(
//                        node: node,
//                        frame: .init(
//                            x: (index == 0 ? 0.0 : (48.0 + 6) * CGFloat(index) * scale),
//                            y: 0.0,
//                            width: node.frame.width * scale,
//                            height: node.frame.height * scale
//                        ),
//                        completion: { _ in
//                            completion?()
//                        }
//                    )
//                }
//
//        } else {
//            keyTransition.updateTransformScale(node: self.keyTextNode, scale: scale)
//            keyTransition.updateFrame(
//                node: self.keyTextNode,
//                frame: rect,
//                completion: { _ in
//                    completion?()
//                }
//            )
//        }
    }
    
    @objc func tapGesture(_ recognizer: UITapGestureRecognizer) {
        if case .ended = recognizer.state {
            self.dismiss()
        }
    }
}

private let itemSize = CGSize(width: 48.0, height: 48.0)

private class StickerNode: ASDisplayNode {
    private let context: AccountContext
    private let file: TelegramMediaFile
    
    public var imageNode: TransformImageNode
    public var animationNode: AnimatedStickerNode
    
    private var placeholderNode: StickerShimmerEffectNode
    
    private let disposable = MetaDisposable()
    private let effectDisposable = MetaDisposable()
    
    private var setupTimestamp: Double?
    
    init(context: AccountContext, file: TelegramMediaFile) {
        self.context = context
        self.file = file
        
        self.imageNode = TransformImageNode()
    
        let animationNode = DefaultAnimatedStickerNodeImpl()
        //let animationNode = DirectAnimatedStickerNode()
        animationNode.automaticallyLoadFirstFrame = true
        self.animationNode = animationNode
        
        let dimensions = file.dimensions ?? PixelDimensions(width: 512, height: 512)
        let fittedDimensions = dimensions.cgSize.aspectFitted(CGSize(width: 240.0, height: 240.0))
        
        let pathPrefix = context.account.postbox.mediaBox.shortLivedResourceCachePathPrefix(file.resource.id)
        animationNode.setup(source: AnimatedStickerResourceSource(account: self.context.account, resource: file.resource, isVideo: file.isVideoSticker), width: Int(fittedDimensions.width * 1.6), height: Int(fittedDimensions.height * 1.6), playbackMode: .once, mode: .direct(cachePathPrefix: pathPrefix))
        
        self.imageNode.setSignal(chatMessageAnimatedSticker(postbox: context.account.postbox, userLocation: .other, file: file, small: false, size: fittedDimensions))
        
        self.disposable.set(
            freeMediaFileResourceInteractiveFetched(
                account: self.context.account,
                userLocation: .other,
                fileReference: stickerPackFileReference(file),
                resource: file.resource
            )
            .start()
        )
        
        self.placeholderNode = StickerShimmerEffectNode()
        
        super.init()
        
        self.isUserInteractionEnabled = false
        
        self.addSubnode(self.imageNode)
        self.addSubnode(self.animationNode)
        
        self.addSubnode(self.placeholderNode)
        
        var firstTime = true
        self.imageNode.imageUpdated = { [weak self] image in
            guard let strongSelf = self else {
                return
            }
            if image != nil {
                strongSelf.removePlaceholder(animated: !firstTime)
            }
            firstTime = false
        }
            
        animationNode.started = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.imageNode.alpha = 0.0
            
            let current = CACurrentMediaTime()
            if let setupTimestamp = strongSelf.setupTimestamp, current - setupTimestamp > 0.3 {
                if !strongSelf.placeholderNode.alpha.isZero {
                    strongSelf.removePlaceholder(animated: true)
                }
            } else {
                strongSelf.removePlaceholder(animated: false)
            }
        }
    }
    
    deinit {
        self.disposable.dispose()
        self.effectDisposable.dispose()
    }
    
    private func removePlaceholder(animated: Bool) {
        if !animated {
            self.placeholderNode.removeFromSupernode()
        } else {
            self.placeholderNode.alpha = 0.0
            self.placeholderNode.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.2, completion: { [weak self] _ in
                self?.placeholderNode.removeFromSupernode()
            })
        }
    }
    
    private var visibility: Bool = false
    private var centrality: Bool = false
    
    public func setCentral(_ central: Bool) {
        self.centrality = central
        self.updatePlayback()
    }
    
    public func setVisible(_ visible: Bool) {
        self.visibility = visible
        self.updatePlayback()
        
        self.setupTimestamp = CACurrentMediaTime()
    }
    
    func updateAbsoluteRect(_ rect: CGRect, within containerSize: CGSize) {
        if self.placeholderNode.supernode != nil {
            self.placeholderNode.updateAbsoluteRect(rect, within: containerSize)
        }
    }
    
    private func updatePlayback() {
        self.animationNode.visibility = self.visibility
    }
    
    public func updateLayout(size: CGSize, transition: ContainedViewLayoutTransition) {
        let boundingSize = itemSize
            
        if let dimensitons = self.file.dimensions {
            let imageSize = dimensitons.cgSize.aspectFitted(boundingSize)
            self.imageNode.asyncLayout()(TransformImageArguments(corners: ImageCorners(), imageSize: imageSize, boundingSize: imageSize, intrinsicInsets: UIEdgeInsets()))()
            let imageFrame = CGRect(origin: CGPoint(x: floor((size.width - imageSize.width) / 2.0), y: 0.0), size: imageSize)
            
            self.imageNode.frame = imageFrame
            self.animationNode.frame = imageFrame
            self.animationNode.updateLayout(size: imageSize)
            
            if self.placeholderNode.supernode != nil {
                let placeholderFrame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: imageSize)
                let thumbnailDimensions = PixelDimensions(width: 512, height: 512)
                self.placeholderNode.update(backgroundColor: nil, foregroundColor: UIColor(rgb: 0xffffff, alpha: 0.2), shimmeringColor: UIColor(rgb: 0xffffff, alpha: 0.3), data: self.file.immediateThumbnailData, size: placeholderFrame.size, imageSize: thumbnailDimensions.cgSize)
                self.placeholderNode.frame = placeholderFrame
            }
        }
    }
}

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
        
        self.view.addSubview(self.effectView)
        self.effectView.layer.cornerRadius = 20.0
        self.effectView.clipsToBounds = true
        
        self.separatorButtonNode.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        self.okButtonNode.setTitle(
            "OK", // TODO: Strings
            with: Font.regular(20.0),
            with: UIColor.white,
            for: .normal
        )
        
        self.addSubnode(self.keyTextNode)
        self.addSubnode(self.titleTextNode)
        self.addSubnode(self.infoTextNode)
        self.addSubnode(self.separatorButtonNode)
        self.addSubnode(self.okButtonNode)
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
        let keyTextSize = self.keyTextNode.measure(.init(width: alertWidth, height: .greatestFiniteMagnitude))
        let keyTextFrame = CGRect(
            origin: CGPoint(
                x: floor((size.width - keyTextSize.width) / 2),
                y: alertY + 20.0
            ),
            size: keyTextSize
        )
        
        if animatedEmoji {
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
                    node.setVisible(true)
                }
        } else {
            // Static Key
            transition.updateFrame(
                node: self.keyTextNode,
                frame: keyTextFrame
            )
        }
        
        // Title
        let titleSize = self.titleTextNode.measure(
            CGSize(
                width: alertWidth - 16,
                height: .greatestFiniteMagnitude
            )
        )
        transition.updateFrame(
            node: self.titleTextNode,
            frame: CGRect(
                origin: CGPoint(
                    x: floor((size.width - titleSize.width) / 2),
                    y: keyTextFrame.maxY + 10.0
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
                x: floor((size.width - infoTextSize.width) / 2),
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
                    x: alertX,
                    y: infoTextFrame.maxY + 10
                ),
                size: CGSize(
                    width: alertWidth,
                    height: 0.3
                )
            )
        )
        
        // Ok Button
        transition.updateFrame(
            node: self.okButtonNode,
            frame: CGRect(
                origin: CGPoint(
                    x: alertX,
                    y: self.separatorButtonNode.frame.maxY + 1.0
                ),
                size: CGSize(
                    width: alertWidth,
                    height: 56.0
                )
            )
        )
        
        // INFO: размещение бекграунда
        let alertHeight: CGFloat = self.okButtonNode.frame.maxY - alertY
        let alertSize = CGSize(
            width: alertWidth,
            height: alertHeight
        )
        
        let alertFrame = CGRect(
            origin: CGPoint(
                x: floor((size.width - alertWidth) / 2),
                y: alertY
            ),
            size: alertSize
        )
        self.effectView.frame = alertFrame
    }
    
    func animateIn(from rect: CGRect, fromNode: ASDisplayNode) {
    }
    
    func animateOut(to rect: CGRect, toNode: ASDisplayNode, completion: @escaping () -> Void) {
        completion()
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

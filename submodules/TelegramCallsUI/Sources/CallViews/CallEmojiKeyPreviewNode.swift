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

// TODO: сделать анимированные эмодзи

// TODO: сделать динамический style black или light для effectView для видео и нет
// TODO: сделать анимацию появления и убирания
// TODO: сделать состояния кнопки ок
// TODO: пофиксить баг с появлением имени когда показывается алерт

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
        return true
//        let count = animatedStickerFiles.count == keyTextNode.attributedText?.string.count
//        print("call emoji preview: animated count = \(animatedStickerFiles.count)")
//        return count
    }
    
    private let dismiss: () -> Void
    
    init(
        accountContext: AccountContext,
        keyText: String,
        titleText: String,
        infoText: String,
        dismiss: @escaping () -> Void
    ) {
        self.accountContext = accountContext
        
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
        
        var files: [TelegramMediaFile] = []
//        keyText.forEach { emojiKey in
//            if let file = accountContext.animatedEmojiStickers["\(emojiKey)"]?.first?.file {
//                files.append(file)
//            }
//        }
        
        accountContext.animatedEmojiStickers.keys.shuffled().prefix(4).forEach { emojiKey in
            if let file = accountContext.animatedEmojiStickers["\(emojiKey)"]?.first?.file {
                files.append(file)
            }
        }
        self.animatedStickerFiles = files
        
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
        
        // INFO: работа с анимированными эмоджи
        
//        self.disposable.set((source.directDataPath(attemptSynchronously: false)
//        |> filter { $0 != nil }
//        |> deliverOnMainQueue).start(next: { path in
//            print("sticker - path = \(path ?? "nil")")
//            return f(path!)
//        }))

        animatedStickerFiles.forEach { file in
            let animatedEmojiNode = DefaultAnimatedStickerNodeImpl()
            let dimensions = file.dimensions ?? PixelDimensions(width: 512, height: 512)
            let fittedSize = dimensions.cgSize.aspectFilled(CGSize(width: 48.0, height: 48.0))
            let pathPrefix = accountContext.account.postbox.mediaBox.shortLivedResourceCachePathPrefix(file.resource.id)
            
            animatedEmojiNode.setup(
                source: AnimatedStickerResourceSource(
                    account: accountContext.account,
                    resource: file.resource,
                    fitzModifier: nil,
                    isVideo: false
                ),
                width: Int(fittedSize.width),
                height: Int(fittedSize.height),
                playbackMode: .once,
                mode: .direct(cachePathPrefix: pathPrefix)
            )
            
            self.disposable.add(
                freeMediaFileResourceInteractiveFetched(
                    account: accountContext.account,
                    userLocation: .other,
                    fileReference: stickerPackFileReference(file),
                    resource: file.resource
                )
                .start(next: { element in
                    print("call emoji preview: \(element)")
                })
            )
            self.animatedKeysStickerContainer.addSubnode(animatedEmojiNode)
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
        
        // INFO: размещение бекграунда
        let alertWidth: CGFloat = size.width - 45.0 * 2
        let alertHeight: CGFloat = 225.0
        let alertSize = CGSize(
            width: alertWidth,
            height: alertHeight
        )
        
        let alertFrame = CGRect(
            origin: CGPoint(
                x: floor((size.width - alertWidth) / 2),
                y: topOffset
            ),
            size: alertSize
        )
        self.effectView.frame = alertFrame
        
        // Key
        let keyTextSize = self.keyTextNode.measure(alertSize)
        let keyTextFrame = CGRect(
            origin: CGPoint(
                x: floor((size.width - keyTextSize.width) / 2),
                y: alertFrame.minY + 20.0
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
                .compactMap { $0 as? AnimatedStickerNode }
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
                    
                    node.updateLayout(size: frame.size)
                    node.playOnce()
                }
        } else {
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
                width: alertWidth - 16,
                height: .greatestFiniteMagnitude
            )
        )
        transition.updateFrame(
            node: self.infoTextNode,
            frame: CGRect(
                origin: CGPoint(
                    x: floor((size.width - infoTextSize.width) / 2),
                    y: self.titleTextNode.frame.maxY + 10.0
                ),
                size: infoTextSize
            )
        )
        
        // Separator
        transition.updateFrame(
            node: self.separatorButtonNode,
            frame: CGRect(
                origin: CGPoint(
                    x: alertFrame.minX,
                    y: alertFrame.maxY - 57.0
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
                    x: alertFrame.minX,
                    y: self.separatorButtonNode.frame.maxY + 1.0
                ),
                size: CGSize(
                    width: alertWidth,
                    height: 56.0
                )
            )
        )
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

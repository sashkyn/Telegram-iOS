import Foundation
import UIKit
import Display
import AsyncDisplayKit
import SwiftSignalKit
import AnimatedStickerNode
import TelegramAnimatedStickerNode

final class CallRatingNode: ASDisplayNode {
    
    private let rateEffectView: UIVisualEffectView
    
    private let titleNode: ASTextNode
    private let subtitleNode: ASTextNode
    private let starContainerNode: ASDisplayNode
    private let starNodes: [ASButtonNode]
    private let closeButtonNode: RatingCloseButtonNode
    
    private let animationStarNode: AnimatedStickerNode
    
    private var rating: Int? = nil
    private var didTapOnStarOnce: Bool = false
    
    private let onClose: () -> Void
    private let onRating: (Int) -> Void
    
    private var validLayout: CGRect? = nil
    
    init(
        onClose: @escaping () -> Void,
        onRating: @escaping (Int) -> Void
    ) {
        self.onClose = onClose
        self.onRating = onRating
        
        self.titleNode = ASTextNode()
        self.titleNode.displaysAsynchronously = false
        
        self.subtitleNode = ASTextNode()
        self.subtitleNode.displaysAsynchronously = false
        
        // INFO: генерация звездочек
        var starNodes: [ASButtonNode] = []
        for _ in 0 ..< 5 {
            let button = ASButtonNode()
            button.displaysAsynchronously = false
            starNodes.append(button)
        }
        self.starNodes = starNodes
        
        self.starContainerNode = ASDisplayNode()
        self.starContainerNode.displaysAsynchronously = false
        
        self.closeButtonNode = RatingCloseButtonNode()
        self.closeButtonNode.displaysAsynchronously = false
        
        // INFO: блюр для рейтинга
        self.rateEffectView = UIVisualEffectView()
        self.rateEffectView.effect = UIBlurEffect(style: .light)
        
        // INFO: анимация звездочек
        self.animationStarNode = DefaultAnimatedStickerNodeImpl()
        self.animationStarNode.displaysAsynchronously = false

        super.init()
        
        self.view.addSubview(self.rateEffectView)
        self.rateEffectView.layer.cornerRadius = 20.0
        self.rateEffectView.clipsToBounds = true
        
        // Rate This Call
        self.addSubnode(titleNode)
        self.titleNode.attributedText = NSAttributedString(
            string: "Rate This Call", // TODO: Strings
            font: Font.bold(16.0),
            textColor: UIColor.white,
            paragraphAlignment: .center
        )
        
        // Please rate the quality of this call.
        self.addSubnode(subtitleNode)
        self.subtitleNode.attributedText = NSAttributedString(
            string: "Please rate the quality of this call.", // TODO: Strings
            font: Font.regular(16.0),
            textColor: UIColor.white,
            paragraphAlignment: .center
        )
        
        // Stars
        self.addSubnode(starContainerNode)
        for node in self.starNodes {
            starContainerNode.addSubnode(node)
            
            // Targets
            node.addTarget(self, action: #selector(self.starPressed(_:)), forControlEvents: .touchDown)
            node.addTarget(self, action: #selector(self.starReleased(_:)), forControlEvents: .touchUpInside)
            
            // Images
            node.setImage(generateTintedImage(image: UIImage(bundleImageName: "Call/RateStar"), color: UIColor.white), for: [])
            let highlighted = generateTintedImage(image: UIImage(bundleImageName: "Call/RateStarHighlighted"), color: UIColor.white)
            node.setImage(highlighted, for: [.selected])
            node.setImage(highlighted, for: [.selected, .highlighted])
        }
        
        // Stars well animation effect
        self.addSubnode(animationStarNode)
        self.animationStarNode.setup(
            source: AnimatedStickerNodeLocalFileSource(name: "RateStars"),
            width: 64,
            height: 64,
            playbackMode: .loop,
            mode: .direct(cachePathPrefix: nil)
        )
        
        // Close
        self.addSubnode(closeButtonNode)
        self.closeButtonNode.animationCompletion = { [weak self] in
            self?.onClose()
        }
        self.closeButtonNode.view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(close)
            )
        )
    }
    
    deinit {
        print("call rating - deinit")
    }
    
    func updateLayout(
        constaintedRect: CGRect,
        transition: ContainedViewLayoutTransition
    ) {
        guard validLayout == nil else {
            return
        }
        
        self.validLayout = constaintedRect
        
        // Rate background
        let size = constaintedRect.size
        
        let rateContainerWidth: CGFloat = size.width - 45.0 * 2
        let rateContainerHeight: CGFloat = 142.0
        let rateContainerSize = CGSize(
            width: rateContainerWidth,
            height: rateContainerHeight
        )
        
        let rateContainerFrame = CGRect(
            origin: CGPoint(
                x: floor((size.width - rateContainerWidth) / 2),
                y: constaintedRect.minY
            ),
            size: rateContainerSize
        )
        self.rateEffectView.frame = rateContainerFrame
        
        // Title
        let titleSize = self.titleNode.measure(
            CGSize(
                width: rateContainerWidth - 16,
                height: .greatestFiniteMagnitude
            )
        )
        transition.updateFrame(
            node: self.titleNode,
            frame: CGRect(
                origin: CGPoint(
                    x: floor((size.width - titleSize.width) / 2),
                    y: constaintedRect.minY + 20.0
                ),
                size: titleSize
            )
        )
        
        // Subtitle
        let subtitleSize = self.subtitleNode.measure(
            CGSize(
                width: rateContainerWidth - 16,
                height: .greatestFiniteMagnitude
            )
        )
        transition.updateFrame(
            node: self.subtitleNode,
            frame: CGRect(
                origin: CGPoint(
                    x: floor((size.width - subtitleSize.width) / 2),
                    y: self.titleNode.frame.maxY + 10.0
                ),
                size: subtitleSize
            )
        )
        
        // Star container
        let starContainerSize = CGSize(
            width: 226.0,
            height: 42.0
        )
        transition.updateFrame(
            node: self.starContainerNode,
            frame: CGRect(
                origin: CGPoint(
                    x: floor((size.width - starContainerSize.width) / 2),
                    y: self.subtitleNode.frame.maxY + 16.0
                ),
                size: CGSize(
                    width: 226.0,
                    height: 42.0
                )
            )
        )
        
        // Stars
        let starSize = CGSize(width: 34.0, height: 34.0)
        let starHorizontalOffset = 13.0
        self.starContainerNode.frame = CGRect(
            origin: CGPoint(
                x: self.starContainerNode.frame.minX,
                y: self.starContainerNode.frame.minY
            ),
            size: CGSize(
                width: starSize.width * (CGFloat(self.starNodes.count) + starHorizontalOffset) - starHorizontalOffset,
                height: starSize.height
            )
        )
        for i in 0 ..< self.starNodes.count {
            let node = self.starNodes[i]
            transition.updateFrame(
                node: node,
                frame: CGRect(
                    x: i == 0 ? 0.0 : (starSize.width + starHorizontalOffset) * CGFloat(i),
                    y: 0.0,
                    width: starSize.width,
                    height: starSize.height
                )
            )
        }
        
        // Close button
        let closeButtonFrame = CGRect(
            origin: CGPoint(
                x: rateContainerFrame.minX,
                y: constaintedRect.maxY - 50.0
            ),
            size: CGSize(
                width: rateContainerWidth,
                height: 50.0
            )
        )
        
        transition.updateFrame(
            node: self.closeButtonNode,
            frame: closeButtonFrame
        )
        
        self.closeButtonNode.layout(transition: transition)
        
        // Animation of stars
        self.animationStarNode.updateLayout(
            size: .init(width: 64.0, height: 64.0)
        )
    }
}

// MARK: Actions

private extension CallRatingNode {
    
    @objc func starPressed(_ sender: ASButtonNode) {
        guard !didTapOnStarOnce else {
            return
        }
        if let index = self.starNodes.firstIndex(of: sender) {
            self.rating = index + 1
            for i in 0 ..< self.starNodes.count {
                let node = self.starNodes[i]
                node.isSelected = i <= index
            }
        }
    }
    
    @objc func starReleased(_ sender: ASButtonNode) {
        guard let rating, !didTapOnStarOnce else {
            return
        }
        self.didTapOnStarOnce = true
        
        onRating(rating)
        if rating > 3 {
            let starRect = sender.convert(sender.bounds, to: self)
            let point = CGPoint(
                x: starRect.midX - 32,
                y: starRect.midY - 32
            )
            self.animationStarNode.frame = CGRect(
                origin: point,
                size: .init(width: 64.0, height: 64.0)
            )
            self.animationStarNode.playOnce()
            self.animationStarNode.completed = { [weak self] bool in
                guard let self else { return }
                
                self.onClose()
            }
        } else {
            onClose()
        }
    }
    
    @objc func close() {
        onClose()
    }
}

private final class RatingCloseButtonNode: ASDisplayNode {
    
    private let closeButtonBluredBackgroundView: UIVisualEffectView
    private let closeButtonFilledBackgoundView: UIView
    private let closeWhiteTextNode: ASTextNode
    private let closePurpleTextNode: ASTextNode
    
    var animationCompletion: (() -> Void)?
    
    override init() {
        // INFO: блюр для кнопки
        self.closeButtonBluredBackgroundView = UIVisualEffectView()
        self.closeButtonBluredBackgroundView.effect = UIBlurEffect(style: .light)
        
        // INFO: анимирующийся белый бекграунд для кнопки
        self.closeButtonFilledBackgoundView = UIView()
        self.closeButtonFilledBackgoundView.backgroundColor = .white
        
        self.closeWhiteTextNode = ASTextNode()
        self.closeWhiteTextNode.displaysAsynchronously = false
        
        self.closePurpleTextNode = ASTextNode()
        self.closePurpleTextNode.displaysAsynchronously = false
        
        super.init()
        
        self.view.addSubview(self.closeButtonBluredBackgroundView)
        self.closeButtonBluredBackgroundView.layer.cornerRadius = 14.0
        self.closeButtonBluredBackgroundView.clipsToBounds = true
        
        self.view.addSubview(self.closeButtonFilledBackgoundView)
        self.closeButtonFilledBackgoundView.layer.cornerRadius = 14.0
        self.closeButtonFilledBackgoundView.clipsToBounds = true
        
        self.addSubnode(closePurpleTextNode)
        self.closePurpleTextNode.attributedText = NSAttributedString(
            string: "Close", // TODO: Strings
            font: Font.regular(17.0),
            textColor: UIColor(rgb: 0xFF7261DA),
            paragraphAlignment: .center
        )
        
        self.addSubnode(closeWhiteTextNode)
        self.closeWhiteTextNode.attributedText = NSAttributedString(
            string: "Close", // TODO: Strings
            font: Font.regular(17.0),
            textColor: UIColor.white,
            paragraphAlignment: .center
        )
        self.closeWhiteTextNode.isHidden = true
    }
    
    override func calculateSizeThatFits(_ constrainedSize: CGSize) -> CGSize {
        .init(
            width: constrainedSize.width,
            height: 50.0
        )
    }
    
    private var didLayouted: Bool = false
    
    func layout(transition: ContainedViewLayoutTransition) {
        guard !didLayouted else {
            return
        }
        self.didLayouted = true
        
        let closeButtonFrame = CGRect(
            origin: .zero,
            size: frame.size
        )
        
        let closeSize = self.closePurpleTextNode.measure(
            .init(
                width: closeButtonFrame.width,
                height: closeButtonFrame.height
            )
        )
        
        // INFO: обновляем фрейм у лейбла фиолетового текста
        transition.updateFrame(
            node: self.closePurpleTextNode,
            frame: .init(
                x: 0.0,
                y: floor(closeButtonFrame.height - closeSize.height) / 2,
                width: closeButtonFrame.width,
                height: closeSize.height
            )
        )
        
        // INFO: обновляем фрейм у лейбла белого текста
        transition.updateFrame(
            node: self.closeWhiteTextNode,
            frame: .init(
                x: 0.0,
                y: floor(closeButtonFrame.height - closeSize.height) / 2,
                width: closeButtonFrame.width,
                height: closeSize.height
            )
        )
        
        // INFO: настраиваем анимацию у заблюренной части
        let showingBluredTransition = ContainedViewLayoutTransition.animated(
            duration: 0.4,
            curve: .slide
        )
        
        // INFO: анимируем заблюренную часть
        showingBluredTransition.animateFrame(
            layer: closeButtonBluredBackgroundView.layer,
            from: .init(
                x: closeButtonFrame.maxX,
                y: closeButtonFrame.origin.y,
                width: 0.0,
                height: closeButtonFrame.height
            ),
            to: closeButtonFrame,
            completion: { [weak self] _ in
                self?.closeButtonBluredBackgroundView.frame = closeButtonFrame
            }
        )
        
        // INFO: настраиваем анимацию у белой части
        let showingFilledTransition = ContainedViewLayoutTransition.animated(
            duration: 0.5,
            curve: .slide
        )
        
        // INFO: анимируем белую часть
        showingFilledTransition.animateFrame(
            layer: closeButtonFilledBackgoundView.layer,
            from: .init(
                x: closeButtonFrame.maxX,
                y: closeButtonFrame.origin.y,
                width: 0.0,
                height: closeButtonFrame.height
            ),
            to: closeButtonFrame,
            completion: { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.closeWhiteTextNode.isHidden = false
                
                let transition = ContainedViewLayoutTransition.immediate
                
                let closingTransition = ContainedViewLayoutTransition.animated(
                    duration: 8.0,
                    curve: .linear
                )
                closingTransition.animateFrame(
                    layer: strongSelf.closeButtonFilledBackgoundView.layer,
                    from: closeButtonFrame,
                    to: .init(
                        x: closeButtonFrame.maxX,
                        y: closeButtonFrame.origin.y,
                        width: 0.0,
                        height: closeButtonFrame.height
                    ),
                    completion: { [weak self] _ in
                        self?.closeButtonFilledBackgoundView.removeFromSuperview()
                        self?.animationCompletion?()
                    }
                )
                
                // Animation of change color
                let maskLayer = CAShapeLayer()
                maskLayer.frame = CGRect(
                    origin: .zero,
                    size: .init(
                        width: 1,
                        height: strongSelf.closeWhiteTextNode.frame.height
                    )
                )
                
                let path = CGMutablePath()
                path.addEllipse(
                    in: .init(
                        origin: .zero,
                        size: .init(
                            width: 1,
                            height: strongSelf.closeWhiteTextNode.frame.height
                        )
                    )
                )
                maskLayer.path = path
                
                strongSelf.closeWhiteTextNode.layer.mask = maskLayer
                
                let transition: ContainedViewLayoutTransition = .animated(duration: 8.1, curve: .linear)
                
                transition.updateTransformScale(
                    layer: maskLayer,
                    scale: strongSelf.closeWhiteTextNode.frame.width * 2
                )
            }
        )
    }
}

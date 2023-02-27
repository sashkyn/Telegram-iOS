import Foundation
import UIKit
import Display
import AsyncDisplayKit
import SwiftSignalKit
import LegacyComponents

// TODO: сделать динамический style black или light для effectView для видео и нет
// TODO: сделать анимированные эмодзи
// TODO: сделать анимацию появления и убирания
// TODO: сделать состояния кнопки ок
// TODO: пофиксить баг с появлением имени когда показывается алерт

// INFO: вьюшка с эмодзями на полный экран
final class CallAlertKeyPreviewNode: ASDisplayNode {
    private let keyTextNode: ASTextNode
    private let titleTextNode: ASTextNode
    private let infoTextNode: ASTextNode
    private let separatorButtonNode: ASDisplayNode
    private let okButtonNode: ASButtonNode
    
    private let effectView: UIVisualEffectView
    
    private let dismiss: () -> Void
    
    init(
        keyText: String,
        titleText: String,
        infoText: String,
        dismiss: @escaping () -> Void
    ) {
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
        
        super.init()
        
        // TODO: сделать ее с анимированными эмодзями
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        self.keyTextNode.attributedText = NSAttributedString(
            string: keyText,
            attributes: [
                NSAttributedString.Key.font: Font.regular(48.0),
                NSAttributedString.Key.kern: 11.0 as NSNumber,
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
    }
    
    override func didLoad() {
        super.didLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapGesture(_:))))
    }
    
    func updateLayout(
        size: CGSize,
        topOffset: CGFloat,
        transition: ContainedViewLayoutTransition
    ) {
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
        transition.updateFrame(
            node: self.keyTextNode,
            frame: CGRect(
                origin: CGPoint(
                    x: floor((size.width - keyTextSize.width) / 2),
                    y: alertFrame.minY + 20.0
                ),
                size: keyTextSize
            )
        )
        
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
                    y: self.keyTextNode.frame.maxY + 10.0
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
                    y: self.infoTextNode.frame.maxY + 10.0
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


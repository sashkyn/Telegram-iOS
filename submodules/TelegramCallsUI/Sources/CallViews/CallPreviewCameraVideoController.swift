import Foundation
import UIKit
import Display
import AsyncDisplayKit
import Postbox
import TelegramCore
import SwiftSignalKit
import AccountContext
import TelegramPresentationData
import SolidRoundedButtonNode
import PresentationDataUtils
import UIKitRuntimeUtils
import ReplayKit

final class CallPreviewCameraVideoController: ViewController {
    private var controllerNode: CallPreviewCameraVideoNode {
        return self.displayNode as! CallPreviewCameraVideoNode
    }
    
    private let sharedContext: SharedAccountContext
    let animateInFromRect: CGRect?
    
    private var animatedIn = false

    private let cameraNode: PreviewVideoNode
    private let shareCamera: (ASDisplayNode, Bool) -> Void
    private let switchCamera: () -> Void
    
    private var presentationDataDisposable: Disposable?
    
    init(
        sharedContext: SharedAccountContext,
        cameraNode: PreviewVideoNode,
        animateInFromRect: CGRect?,
        shareCamera: @escaping (ASDisplayNode, Bool) -> Void,
        switchCamera: @escaping () -> Void
    ) {
        self.sharedContext = sharedContext
        self.cameraNode = cameraNode
        self.shareCamera = shareCamera
        self.switchCamera = switchCamera
        self.animateInFromRect = animateInFromRect
        
        super.init(navigationBarPresentationData: nil)
        
        self.statusBar.statusBarStyle = .Ignore
        
        self.blocksBackgroundWhenInOverlay = true
        
        self.presentationDataDisposable = (sharedContext.presentationData
        |> deliverOnMainQueue).start(next: { [weak self] presentationData in
            if let strongSelf = self {
                strongSelf.controllerNode.updatePresentationData(presentationData)
            }
        })
        
        self.statusBar.statusBarStyle = .Ignore
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.presentationDataDisposable?.dispose()
    }
    
    override public func loadDisplayNode() {
        self.displayNode = CallPreviewCameraVideoNode(
            controller: self,
            sharedContext: self.sharedContext,
            cameraNode: self.cameraNode
        )
        
        self.controllerNode.shareCamera = { [weak self] unmuted in
            if let strongSelf = self {
                strongSelf.shareCamera(strongSelf.cameraNode, unmuted)
                strongSelf.dismiss()
            }
        }
        self.controllerNode.switchCamera = { [weak self] in
            self?.switchCamera()
            self?.cameraNode.flip(withBackground: false)
        }
        self.controllerNode.dismiss = { [weak self] in
            self?.presentingViewController?.dismiss(animated: false, completion: nil)
        }
        self.controllerNode.cancel = { [weak self] in
            self?.dismiss()
        }
    }
    
    override public func loadView() {
        super.loadView()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !self.animatedIn {
            self.animatedIn = true
            self.controllerNode.animateIn()
        }
    }
    
    override public func dismiss(completion: (() -> Void)? = nil) {
        self.controllerNode.animateOut(completion: completion)
    }
    
    override public func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)
        
        self.controllerNode.containerLayoutUpdated(layout, navigationBarHeight: self.navigationLayout(layout: layout).navigationFrame.maxY, transition: transition)
    }
}

private class CallPreviewCameraVideoNode: ViewControllerTracingNode, UIScrollViewDelegate {
    private weak var controller: CallPreviewCameraVideoController?
    private let sharedContext: SharedAccountContext
    private var presentationData: PresentationData
    
    private let cameraNode: PreviewVideoNode
    private let dimNode: ASDisplayNode
    private let wrappingScrollNode: ASScrollNode
    private let contentContainerNode: ASDisplayNode
    private let backgroundNode: ASDisplayNode
    private let contentBackgroundNode: ASDisplayNode
    private let titleNode: ASTextNode
    private let previewContainerNode: ASDisplayNode
    private let shimmerNode: ShimmerEffectForegroundNode
    private let doneButton: SolidRoundedButtonNode
    private var broadcastPickerView: UIView?
    private let cancelButton: HighlightableButtonNode
    
    private let placeholderTextNode: ImmediateTextNode
    private let placeholderIconNode: ASImageNode
    
    private var wheelNode: WheelControlNode
    private var selectedTabIndex: Int = 1
    private var containerLayout: (ContainerViewLayout, CGFloat)?

    private var applicationStateDisposable: Disposable?
    
    private let hapticFeedback = HapticFeedback()
    
    private let readyDisposable = MetaDisposable()
    
    var shareCamera: ((Bool) -> Void)?
    var switchCamera: (() -> Void)?
    var dismiss: (() -> Void)?
    var cancel: (() -> Void)?
    
    init(
        controller: CallPreviewCameraVideoController,
        sharedContext: SharedAccountContext,
        cameraNode: PreviewVideoNode
    ) {
        self.controller = controller
        self.sharedContext = sharedContext
        self.presentationData = sharedContext.currentPresentationData.with { $0 }
        
        self.cameraNode = cameraNode
        self.cameraNode.backgroundColor = UIColor(rgb: 0x000000)
        
        self.wrappingScrollNode = ASScrollNode()
        self.wrappingScrollNode.view.alwaysBounceVertical = true
        self.wrappingScrollNode.view.delaysContentTouches = false
        self.wrappingScrollNode.view.canCancelContentTouches = true
        
        self.dimNode = ASDisplayNode()
        self.dimNode.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        
        self.contentContainerNode = ASDisplayNode()
        self.contentContainerNode.isOpaque = false

        self.backgroundNode = ASDisplayNode()
    
        self.contentBackgroundNode = ASDisplayNode()
        
        let title =  self.presentationData.strings.VoiceChat_VideoPreviewTitle
        
        self.titleNode = ASTextNode()
        self.titleNode.attributedText = NSAttributedString(string: title, font: Font.bold(17.0), textColor: UIColor(rgb: 0xffffff))
                
        self.doneButton = SolidRoundedButtonNode(theme: SolidRoundedButtonTheme(backgroundColor: UIColor(rgb: 0xffffff), foregroundColor: UIColor(rgb: 0x4f5352)), font: .bold, height: 48.0, cornerRadius: 10.0, gloss: false)
        self.doneButton.title = "Start video"
        
        if #available(iOS 12.0, *) {
            let broadcastPickerView = RPSystemBroadcastPickerView(frame: CGRect(x: 0, y: 0, width: 50, height: 52.0))
            broadcastPickerView.alpha = 0.02
            broadcastPickerView.isHidden = true
            broadcastPickerView.preferredExtension = "\(self.sharedContext.applicationBindings.appBundleId).BroadcastUpload"
            broadcastPickerView.showsMicrophoneButton = false
            self.broadcastPickerView = broadcastPickerView
        }
        
        self.cancelButton = HighlightableButtonNode()
        self.cancelButton.setAttributedTitle(NSAttributedString(string: self.presentationData.strings.Common_Cancel, font: Font.regular(17.0), textColor: UIColor(rgb: 0xffffff)), for: [])
        
        self.previewContainerNode = ASDisplayNode()
        self.previewContainerNode.clipsToBounds = true
        
        self.shimmerNode = ShimmerEffectForegroundNode(size: 200.0)
        self.previewContainerNode.addSubnode(self.shimmerNode)
                
        self.placeholderTextNode = ImmediateTextNode()
        self.placeholderTextNode.alpha = 0.0
        self.placeholderTextNode.maximumNumberOfLines = 3
        self.placeholderTextNode.textAlignment = .center
        
        self.placeholderIconNode = ASImageNode()
        self.placeholderIconNode.alpha = 0.0
        self.placeholderIconNode.contentMode = .scaleAspectFit
        self.placeholderIconNode.displaysAsynchronously = false
        
        self.wheelNode = WheelControlNode(items: [WheelControlNode.Item(title: UIDevice.current.model == "iPad" ? self.presentationData.strings.VoiceChat_VideoPreviewTabletScreen : self.presentationData.strings.VoiceChat_VideoPreviewPhoneScreen), WheelControlNode.Item(title: self.presentationData.strings.VoiceChat_VideoPreviewFrontCamera), WheelControlNode.Item(title: self.presentationData.strings.VoiceChat_VideoPreviewBackCamera)], selectedIndex: self.selectedTabIndex)
        
        super.init()
        
        self.backgroundColor = nil
        self.isOpaque = false
        
        self.dimNode.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dimTapGesture(_:))))
        self.addSubnode(self.dimNode)
        
        self.wrappingScrollNode.view.delegate = self
        self.addSubnode(self.wrappingScrollNode)
                
        self.wrappingScrollNode.addSubnode(self.backgroundNode)
        self.wrappingScrollNode.addSubnode(self.contentContainerNode)
        
        self.backgroundNode.addSubnode(self.contentBackgroundNode)
        self.contentContainerNode.addSubnode(self.previewContainerNode)
        self.contentContainerNode.addSubnode(self.titleNode)
        self.contentContainerNode.addSubnode(self.doneButton)
        if let broadcastPickerView = self.broadcastPickerView {
            self.contentContainerNode.view.addSubview(broadcastPickerView)
        }
        self.contentContainerNode.addSubnode(self.cancelButton)
                
        self.previewContainerNode.addSubnode(self.cameraNode)
        
        self.previewContainerNode.addSubnode(self.placeholderIconNode)
        self.previewContainerNode.addSubnode(self.placeholderTextNode)
        
        self.previewContainerNode.addSubnode(self.wheelNode)

        self.wheelNode.selectedIndexChanged = { [weak self] index in
            if let strongSelf = self {
                if (index == 1 && strongSelf.selectedTabIndex == 2) || (index == 2 && strongSelf.selectedTabIndex == 1) {
                    strongSelf.switchCamera?()
                }
                if index == 0 && [1, 2].contains(strongSelf.selectedTabIndex) {
                    strongSelf.broadcastPickerView?.isHidden = false
                    strongSelf.cameraNode.updateIsBlurred(isBlurred: true, light: false, animated: true)
                    let transition = ContainedViewLayoutTransition.animated(duration: 0.3, curve: .easeInOut)
                    transition.updateAlpha(node: strongSelf.placeholderTextNode, alpha: 1.0)
                    transition.updateAlpha(node: strongSelf.placeholderIconNode, alpha: 1.0)
                } else if [1, 2].contains(index) && strongSelf.selectedTabIndex == 0 {
                    strongSelf.broadcastPickerView?.isHidden = true
                    strongSelf.cameraNode.updateIsBlurred(isBlurred: false, light: false, animated: true)
                    let transition = ContainedViewLayoutTransition.animated(duration: 0.3, curve: .easeInOut)
                    transition.updateAlpha(node: strongSelf.placeholderTextNode, alpha: 0.0)
                    transition.updateAlpha(node: strongSelf.placeholderIconNode, alpha: 0.0)
                }
                strongSelf.selectedTabIndex = index
            }
        }
        
        self.doneButton.pressed = { [weak self] in
            if let strongSelf = self {
                strongSelf.shareCamera?(true)
            }
        }
        self.cancelButton.addTarget(self, action: #selector(self.cancelPressed), forControlEvents: .touchUpInside)
        
        self.readyDisposable.set(self.cameraNode.ready.start(next: { [weak self] ready in
            if let strongSelf = self, ready {
                if let maskLayer = strongSelf.layer.mask {
                    Queue.mainQueue().async {
                        strongSelf.isHidden = false
                        let transition: ContainedViewLayoutTransition = .animated(duration: 0.5, curve: .easeInOut)
                        transition.updateTransformScale(
                            layer: maskLayer,
                            scale: 100,
                            completion: { _ in strongSelf.layer.mask = nil }
                        )
                    }
                }
                
                Queue.mainQueue().after(0.07) {
                    strongSelf.shimmerNode.alpha = 0.0
                    strongSelf.shimmerNode.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.3)
                }
            }
        }))
    }
    
    deinit {
        self.readyDisposable.dispose()
        self.applicationStateDisposable?.dispose()
    }
       
    func updatePresentationData(_ presentationData: PresentationData) {
        self.presentationData = presentationData
    }
    
    override func didLoad() {
        super.didLoad()
        
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.leftSwipeGesture))
        leftSwipeGestureRecognizer.direction = .left
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.rightSwipeGesture))
        rightSwipeGestureRecognizer.direction = .right
        
        self.view.addGestureRecognizer(leftSwipeGestureRecognizer)
        self.view.addGestureRecognizer(rightSwipeGestureRecognizer)
        
        if #available(iOSApplicationExtension 11.0, iOS 11.0, *) {
            self.wrappingScrollNode.view.contentInsetAdjustmentBehavior = .never
        }
    }
    
    @objc func leftSwipeGesture() {
        if self.selectedTabIndex < 2 {
            self.wheelNode.setSelectedIndex(self.selectedTabIndex + 1, animated: true)
            self.wheelNode.selectedIndexChanged(self.wheelNode.selectedIndex)
        }
    }
    
    @objc func rightSwipeGesture() {
        if self.selectedTabIndex > 0 {
            self.wheelNode.setSelectedIndex(self.selectedTabIndex - 1, animated: true)
            self.wheelNode.selectedIndexChanged(self.wheelNode.selectedIndex)
        }
    }
    
    @objc func cancelPressed() {
        self.cancel?()
    }
    
    @objc func dimTapGesture(_ recognizer: UITapGestureRecognizer) {
        if case .ended = recognizer.state {
            self.cancel?()
        }
    }
    
    func animateIn() {
        self.dimNode.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.4)
        
        let fromRect: CGRect = {
            if let animateInFromRect = self.controller?.animateInFromRect {
                return self.convert(animateInFromRect, to: previewContainerNode)
            } else {
                return CGRect(origin: previewContainerNode.frame.center, size: .init(width: 50, height: 50))
            }
        }()

        let maskLayer = CAShapeLayer()
        maskLayer.frame = fromRect
        
        let path = CGMutablePath()
        path.addEllipse(in: CGRect(origin: CGPoint(), size: fromRect.size))
        maskLayer.path = path

        self.layer.mask = maskLayer
        self.isHidden = true

        self.applicationStateDisposable = (self.sharedContext.applicationBindings.applicationIsActive
        |> filter { !$0 }
        |> take(1)
        |> deliverOnMainQueue).start(next: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.controller?.dismiss()
        })
    }
    
    func animateOut(completion: (() -> Void)? = nil) {
        var dimCompleted = false

        let internalCompletion: () -> Void = { [weak self] in
            if dimCompleted {
                self?.dismiss?()
            }
            completion?()
        }

        self.dimNode.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.1, removeOnCompletion: false, completion: { _ in
            dimCompleted = true
            internalCompletion()
        })
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.bounds.contains(point) {
            if !self.contentBackgroundNode.bounds.contains(self.convert(point, to: self.contentBackgroundNode)) {
                return self.dimNode.view
            }
        }
        return super.hitTest(point, with: event)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let contentOffset = scrollView.contentOffset
        let additionalTopHeight = max(0.0, -contentOffset.y)
        
        if additionalTopHeight >= 30.0 {
            self.cancel?()
        }
    }
    
    func containerLayoutUpdated(_ layout: ContainerViewLayout, navigationBarHeight: CGFloat, transition: ContainedViewLayoutTransition) {
        self.containerLayout = (layout, navigationBarHeight)
        
        let isLandscape: Bool
        if layout.size.width > layout.size.height {
            isLandscape = true
        } else {
            isLandscape = false
        }
        let isTablet: Bool
        if case .regular = layout.metrics.widthClass {
            isTablet = true
        } else {
            isTablet = false
        }
        
        var insets = layout.insets(options: [.statusBar])
        insets.top = max(10.0, insets.top)

        let contentFrame = CGRect(origin: .zero, size: layout.size)
        
        transition.updateFrame(node: self.backgroundNode, frame: CGRect(origin: CGPoint(), size: layout.size))
        transition.updateFrame(node: self.contentBackgroundNode, frame: CGRect(origin: CGPoint(), size: layout.size))
        transition.updateFrame(node: self.wrappingScrollNode, frame: CGRect(origin: CGPoint(), size: layout.size))
        transition.updateFrame(node: self.dimNode, frame: CGRect(origin: CGPoint(), size: layout.size))
        
        let navigationOffset: CGFloat = max(20.0, layout.safeInsets.top)
        
        let titleSize = self.titleNode.measure(CGSize(width: contentFrame.width, height: .greatestFiniteMagnitude))
        let titleFrame = CGRect(
            origin: CGPoint(
                x: floor((contentFrame.width - titleSize.width) / 2.0),
                y: navigationOffset + 20
            ),
            size: titleSize
        )
        transition.updateFrame(node: self.titleNode, frame: titleFrame)
                
        let previewSize: CGSize = layout.size
        let previewFrame: CGRect = CGRect(origin: .zero, size: layout.size)
        transition.updateFrame(node: self.previewContainerNode, frame: previewFrame)
        transition.updateFrame(node: self.shimmerNode, frame: CGRect(origin: CGPoint(), size: previewFrame.size))
        self.shimmerNode.update(foregroundColor: UIColor(rgb: 0xffffff, alpha: 0.07))
        self.shimmerNode.updateAbsoluteRect(CGRect(origin: CGPoint(), size: layout.size), within: layout.size)
        
        let cancelButtonSize = self.cancelButton.measure(CGSize(width: (previewFrame.width - titleSize.width) / 2.0, height: .greatestFiniteMagnitude))
        let cancelButtonFrame = CGRect(
            origin: CGPoint(
                x: previewFrame.minX + 17.0,
                y: navigationOffset + 20
            ),
            size: cancelButtonSize
        )
        transition.updateFrame(node: self.cancelButton, frame: cancelButtonFrame)
        
        self.cameraNode.frame =  CGRect(origin: CGPoint(), size: previewSize)
        self.cameraNode.updateLayout(size: previewSize, layoutMode: isLandscape ? .fillHorizontal : .fillVertical, transition: .immediate)
      
        self.placeholderTextNode.attributedText = NSAttributedString(string: presentationData.strings.VoiceChat_VideoPreviewShareScreenInfo, font: Font.semibold(16.0), textColor: .white)
        self.placeholderIconNode.image = generateTintedImage(image: UIImage(bundleImageName: isTablet ? "Call/ScreenShareTablet" : "Call/ScreenSharePhone"), color: .white)
        
        let placeholderTextSize = self.placeholderTextNode.updateLayout(CGSize(width: previewSize.width - 80.0, height: 100.0))
        transition.updateFrame(node: self.placeholderTextNode, frame: CGRect(origin: CGPoint(x: floor((previewSize.width - placeholderTextSize.width) / 2.0), y: floorToScreenPixels(previewSize.height / 2.0) + 10.0), size: placeholderTextSize))
        if let imageSize = self.placeholderIconNode.image?.size {
            transition.updateFrame(node: self.placeholderIconNode, frame: CGRect(origin: CGPoint(x: floor((previewSize.width - imageSize.width) / 2.0), y: floorToScreenPixels(previewSize.height / 2.0) - imageSize.height - 8.0), size: imageSize))
        }

        let buttonInset: CGFloat = 16.0
        let buttonMaxWidth: CGFloat = 360.0
        
        let buttonWidth = min(buttonMaxWidth, contentFrame.width - buttonInset * 2.0)
        let doneButtonHeight = self.doneButton.updateLayout(width: buttonWidth, transition: transition)
        transition.updateFrame(
            node: self.doneButton,
            frame: CGRect(
                x: floorToScreenPixels((contentFrame.width - buttonWidth) / 2.0),
                y: previewFrame.maxY - doneButtonHeight - buttonInset - layout.intrinsicInsets.bottom,
                width: buttonWidth,
                height: doneButtonHeight
            )
        )
        self.broadcastPickerView?.frame = self.doneButton.frame
        
        let wheelFrame = CGRect(origin: CGPoint(x: 16.0 + previewFrame.minX, y: previewFrame.maxY - doneButtonHeight - buttonInset - 36.0 - 20.0 - layout.intrinsicInsets.bottom), size: CGSize(width: previewFrame.width - 32.0, height: 36.0))
        self.wheelNode.updateLayout(size: wheelFrame.size, transition: transition)
        transition.updateFrame(node: self.wheelNode, frame: wheelFrame)
        
        transition.updateFrame(node: self.contentContainerNode, frame: contentFrame)
    }
}

private let textFont = Font.with(size: 14.0, design: .camera, weight: .regular)
private let selectedTextFont = Font.with(size: 14.0, design: .camera, weight: .semibold)

private class WheelControlNode: ASDisplayNode, UIGestureRecognizerDelegate {
    struct Item: Equatable {
        public let title: String
        
        public init(title: String) {
            self.title = title
        }
    }

    private let maskNode: ASDisplayNode
    private let containerNode: ASDisplayNode
    private var itemNodes: [HighlightTrackingButtonNode]
    
    private var validLayout: CGSize?

    private var _items: [Item]
    private var _selectedIndex: Int = 0
    
    public var selectedIndex: Int {
        get {
            return self._selectedIndex
        }
        set {
            guard newValue != self._selectedIndex else {
                return
            }
            self._selectedIndex = newValue
            if let size = self.validLayout {
                self.updateLayout(size: size, transition: .immediate)
            }
        }
    }
    
    public func setSelectedIndex(_ index: Int, animated: Bool) {
        guard index != self._selectedIndex else {
            return
        }
        self._selectedIndex = index
        if let size = self.validLayout {
            self.updateLayout(size: size, transition: .animated(duration: 0.2, curve: .easeInOut))
        }
    }
    
    public var selectedIndexChanged: (Int) -> Void = { _ in }
        
    public init(items: [Item], selectedIndex: Int) {
        self._items = items
        self._selectedIndex = selectedIndex
        
        self.maskNode = ASDisplayNode()
        self.maskNode.setLayerBlock({
            let maskLayer = CAGradientLayer()
            maskLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
            maskLayer.locations = [0.0, 0.15, 0.85, 1.0]
            maskLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
            maskLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
            return maskLayer
        })
        self.containerNode = ASDisplayNode()
        
        self.itemNodes = items.map { item in
            let itemNode = HighlightTrackingButtonNode()
            itemNode.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 8.0)
            itemNode.titleNode.maximumNumberOfLines = 1
            itemNode.titleNode.truncationMode = .byTruncatingTail
            itemNode.accessibilityLabel = item.title
            itemNode.accessibilityTraits = [.button]
            itemNode.hitTestSlop = UIEdgeInsets(top: -10.0, left: -5.0, bottom: -10.0, right: -5.0)
            itemNode.setTitle(item.title.uppercased(), with: textFont, with: .white, for: .normal)
            itemNode.titleNode.shadowColor = UIColor.black.cgColor
            itemNode.titleNode.shadowOffset = CGSize()
            itemNode.titleNode.layer.shadowRadius = 2.0
            itemNode.titleNode.layer.shadowOpacity = 0.3
            itemNode.titleNode.layer.masksToBounds = false
            itemNode.titleNode.layer.shouldRasterize = true
            itemNode.titleNode.layer.rasterizationScale = UIScreen.main.scale
            return itemNode
        }
        
        super.init()
        
        self.clipsToBounds = true
        
        self.addSubnode(self.containerNode)
        
        self.itemNodes.forEach(self.containerNode.addSubnode(_:))
        self.setupButtons()
    }
    
    override func didLoad() {
        super.didLoad()
        
        self.view.layer.mask = self.maskNode.layer
        
        self.view.disablesInteractiveTransitionGestureRecognizer = true
    }
    
    func updateLayout(size: CGSize, transition: ContainedViewLayoutTransition) {
        self.validLayout = size
        
        let bounds = CGRect(origin: CGPoint(), size: size)
        
        transition.updateFrame(node: self.maskNode, frame: bounds)
        
        let spacing: CGFloat = 15.0
        if !self.itemNodes.isEmpty {
            var leftOffset: CGFloat = 0.0
            var selectedItemNode: ASDisplayNode?
            for i in 0 ..< self.itemNodes.count {
                let itemNode = self.itemNodes[i]
                let itemSize = itemNode.measure(size)
                transition.updateFrame(node: itemNode, frame: CGRect(origin: CGPoint(x: leftOffset, y: (size.height - itemSize.height) / 2.0), size: itemSize))
                
                leftOffset += itemSize.width + spacing
                
                let isSelected = self.selectedIndex == i
                if isSelected {
                    selectedItemNode = itemNode
                }
                if itemNode.isSelected != isSelected {
                    itemNode.isSelected = isSelected
                    let title = itemNode.attributedTitle(for: .normal)?.string ?? ""
                    itemNode.setTitle(title, with: isSelected ? selectedTextFont : textFont, with: isSelected ? UIColor(rgb: 0xffd60a) : .white, for: .normal)
                    if isSelected {
                        itemNode.accessibilityTraits.insert(.selected)
                    } else {
                        itemNode.accessibilityTraits.remove(.selected)
                    }
                }
            }
            
            let totalWidth = leftOffset - spacing
            if let selectedItemNode = selectedItemNode {
                let itemCenter = selectedItemNode.frame.center
                transition.updateFrame(node: self.containerNode, frame: CGRect(x: bounds.width / 2.0 - itemCenter.x, y: 0.0, width: totalWidth, height: bounds.height))
                
                for i in 0 ..< self.itemNodes.count {
                    let itemNode = self.itemNodes[i]
                    let convertedBounds = itemNode.view.convert(itemNode.bounds, to: self.view)
                    let position = convertedBounds.center
                    let offset = position.x - bounds.width / 2.0
                    let angle = abs(offset / bounds.width * 0.99)
                    let sign: CGFloat = offset > 0 ? 1.0 : -1.0
                    
                    var transform = CATransform3DMakeTranslation(-22.0 * angle * angle * sign, 0.0, 0.0)
                    transform = CATransform3DRotate(transform, angle, 0.0, sign, 0.0)
                    transition.animateView {
                        itemNode.transform = transform
                    }
                }
            }
        }
    }
    
    private func setupButtons() {
        for i in 0 ..< self.itemNodes.count {
            let itemNode = self.itemNodes[i]
            itemNode.addTarget(self, action: #selector(self.buttonPressed(_:)), forControlEvents: .touchUpInside)
        }
    }
    
    @objc private func buttonPressed(_ button: HighlightTrackingButtonNode) {
        guard let index = self.itemNodes.firstIndex(of: button) else {
            return
        }
        
        self._selectedIndex = index
        self.selectedIndexChanged(index)
        if let size = self.validLayout {
            self.updateLayout(size: size, transition: .animated(duration: 0.2, curve: .slide))
        }
    }
}

import Foundation
import AsyncDisplayKit
import AvatarNode
import AccountContext
import Postbox
import TelegramCore

final class CallUserAvatarNode: ASDisplayNode {
    
    private let avatarNode: AvatarNode
    
    override init() {
        // INFO: видимо это аватар с буквами
        self.avatarNode = AvatarNode(font: avatarPlaceholderFont(size: 26.0))
        super.init()
        self.addSubnode(self.avatarNode)
    }
    
    func updateData(
        peer: Peer,
        account: Account,
        sharedAccountContext: SharedAccountContext
    ) {
        let accountContext = sharedAccountContext.makeTempAccountContext(account: account)
        self.avatarNode.setPeer(
            context: accountContext,
            theme: (accountContext.sharedContext.currentPresentationData.with { $0 }).theme,
            peer: EnginePeer(peer)
        )
    }
    
    func updateLayout() {
        self.avatarNode.frame = CGRect(origin: CGPoint(), size: self.frame.size)
    }
}

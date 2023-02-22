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
    
    private let avatarNode: AnimatedAvatarSetNode
    
    override init() {
        self.avatarNode = AnimatedAvatarSetNode()
        super.init()
        self.addSubnode(self.avatarNode)
    }
    
    func updateData(
        peer: Peer,
        account: Account,
        sharedAccountContext: SharedAccountContext
    ) {
        let avatarContext = AnimatedAvatarSetContext()
        
        let content = avatarContext.update(peers: [EnginePeer(peer)], animated: true)
        let size = self.avatarNode.update(
            context: sharedAccountContext.makeTempAccountContext(account: account),
            content: content,
//            itemSize: CGSize(width: 90, height: 90),
            animated: true,
            synchronousLoad: true
        )
        self.avatarNode.frame = CGRect(origin: CGPoint(), size: size)
        
//        self.avatarNode.updateAudioLevels(
//            color: UIColor.blue,
//            backgroundColor: UIColor.black,
//            levels: [peer.id:10000.0]
//        )
    }
    
    func updateLayout() {
        
    }
}

public extension Api {
    enum AccountDaysTTL: TypeConstructorDescription {
        case accountDaysTTL(days: Int32)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .accountDaysTTL(let days):
                    if boxed {
                        buffer.appendInt32(-1194283041)
                    }
                    serializeInt32(days, buffer: buffer, boxed: false)
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .accountDaysTTL(let days):
                return ("accountDaysTTL", [("days", String(describing: days))])
    }
    }
    
        public static func parse_accountDaysTTL(_ reader: BufferReader) -> AccountDaysTTL? {
            var _1: Int32?
            _1 = reader.readInt32()
            let _c1 = _1 != nil
            if _c1 {
                return Api.AccountDaysTTL.accountDaysTTL(days: _1!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum AttachMenuBot: TypeConstructorDescription {
        case attachMenuBot(flags: Int32, botId: Int64, shortName: String, icons: [Api.AttachMenuBotIcon])
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .attachMenuBot(let flags, let botId, let shortName, let icons):
                    if boxed {
                        buffer.appendInt32(-381896846)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    serializeInt64(botId, buffer: buffer, boxed: false)
                    serializeString(shortName, buffer: buffer, boxed: false)
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(icons.count))
                    for item in icons {
                        item.serialize(buffer, true)
                    }
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .attachMenuBot(let flags, let botId, let shortName, let icons):
                return ("attachMenuBot", [("flags", String(describing: flags)), ("botId", String(describing: botId)), ("shortName", String(describing: shortName)), ("icons", String(describing: icons))])
    }
    }
    
        public static func parse_attachMenuBot(_ reader: BufferReader) -> AttachMenuBot? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: Int64?
            _2 = reader.readInt64()
            var _3: String?
            _3 = parseString(reader)
            var _4: [Api.AttachMenuBotIcon]?
            if let _ = reader.readInt32() {
                _4 = Api.parseVector(reader, elementSignature: 0, elementType: Api.AttachMenuBotIcon.self)
            }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            let _c4 = _4 != nil
            if _c1 && _c2 && _c3 && _c4 {
                return Api.AttachMenuBot.attachMenuBot(flags: _1!, botId: _2!, shortName: _3!, icons: _4!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum AttachMenuBotIcon: TypeConstructorDescription {
        case attachMenuBotIcon(flags: Int32, name: String, icon: Api.Document, colors: [Api.AttachMenuBotIconColor]?)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .attachMenuBotIcon(let flags, let name, let icon, let colors):
                    if boxed {
                        buffer.appendInt32(-1297663893)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    serializeString(name, buffer: buffer, boxed: false)
                    icon.serialize(buffer, true)
                    if Int(flags) & Int(1 << 0) != 0 {buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(colors!.count))
                    for item in colors! {
                        item.serialize(buffer, true)
                    }}
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .attachMenuBotIcon(let flags, let name, let icon, let colors):
                return ("attachMenuBotIcon", [("flags", String(describing: flags)), ("name", String(describing: name)), ("icon", String(describing: icon)), ("colors", String(describing: colors))])
    }
    }
    
        public static func parse_attachMenuBotIcon(_ reader: BufferReader) -> AttachMenuBotIcon? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: String?
            _2 = parseString(reader)
            var _3: Api.Document?
            if let signature = reader.readInt32() {
                _3 = Api.parse(reader, signature: signature) as? Api.Document
            }
            var _4: [Api.AttachMenuBotIconColor]?
            if Int(_1!) & Int(1 << 0) != 0 {if let _ = reader.readInt32() {
                _4 = Api.parseVector(reader, elementSignature: 0, elementType: Api.AttachMenuBotIconColor.self)
            } }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            let _c4 = (Int(_1!) & Int(1 << 0) == 0) || _4 != nil
            if _c1 && _c2 && _c3 && _c4 {
                return Api.AttachMenuBotIcon.attachMenuBotIcon(flags: _1!, name: _2!, icon: _3!, colors: _4)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum AttachMenuBotIconColor: TypeConstructorDescription {
        case attachMenuBotIconColor(name: String, color: Int32)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .attachMenuBotIconColor(let name, let color):
                    if boxed {
                        buffer.appendInt32(1165423600)
                    }
                    serializeString(name, buffer: buffer, boxed: false)
                    serializeInt32(color, buffer: buffer, boxed: false)
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .attachMenuBotIconColor(let name, let color):
                return ("attachMenuBotIconColor", [("name", String(describing: name)), ("color", String(describing: color))])
    }
    }
    
        public static func parse_attachMenuBotIconColor(_ reader: BufferReader) -> AttachMenuBotIconColor? {
            var _1: String?
            _1 = parseString(reader)
            var _2: Int32?
            _2 = reader.readInt32()
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            if _c1 && _c2 {
                return Api.AttachMenuBotIconColor.attachMenuBotIconColor(name: _1!, color: _2!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum AttachMenuBots: TypeConstructorDescription {
        case attachMenuBots(hash: Int64, bots: [Api.AttachMenuBot], users: [Api.User])
        case attachMenuBotsNotModified
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .attachMenuBots(let hash, let bots, let users):
                    if boxed {
                        buffer.appendInt32(1011024320)
                    }
                    serializeInt64(hash, buffer: buffer, boxed: false)
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(bots.count))
                    for item in bots {
                        item.serialize(buffer, true)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(users.count))
                    for item in users {
                        item.serialize(buffer, true)
                    }
                    break
                case .attachMenuBotsNotModified:
                    if boxed {
                        buffer.appendInt32(-237467044)
                    }
                    
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .attachMenuBots(let hash, let bots, let users):
                return ("attachMenuBots", [("hash", String(describing: hash)), ("bots", String(describing: bots)), ("users", String(describing: users))])
                case .attachMenuBotsNotModified:
                return ("attachMenuBotsNotModified", [])
    }
    }
    
        public static func parse_attachMenuBots(_ reader: BufferReader) -> AttachMenuBots? {
            var _1: Int64?
            _1 = reader.readInt64()
            var _2: [Api.AttachMenuBot]?
            if let _ = reader.readInt32() {
                _2 = Api.parseVector(reader, elementSignature: 0, elementType: Api.AttachMenuBot.self)
            }
            var _3: [Api.User]?
            if let _ = reader.readInt32() {
                _3 = Api.parseVector(reader, elementSignature: 0, elementType: Api.User.self)
            }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            if _c1 && _c2 && _c3 {
                return Api.AttachMenuBots.attachMenuBots(hash: _1!, bots: _2!, users: _3!)
            }
            else {
                return nil
            }
        }
        public static func parse_attachMenuBotsNotModified(_ reader: BufferReader) -> AttachMenuBots? {
            return Api.AttachMenuBots.attachMenuBotsNotModified
        }
    
    }
}
public extension Api {
    enum AttachMenuBotsBot: TypeConstructorDescription {
        case attachMenuBotsBot(bot: Api.AttachMenuBot, users: [Api.User])
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .attachMenuBotsBot(let bot, let users):
                    if boxed {
                        buffer.appendInt32(-1816172929)
                    }
                    bot.serialize(buffer, true)
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(users.count))
                    for item in users {
                        item.serialize(buffer, true)
                    }
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .attachMenuBotsBot(let bot, let users):
                return ("attachMenuBotsBot", [("bot", String(describing: bot)), ("users", String(describing: users))])
    }
    }
    
        public static func parse_attachMenuBotsBot(_ reader: BufferReader) -> AttachMenuBotsBot? {
            var _1: Api.AttachMenuBot?
            if let signature = reader.readInt32() {
                _1 = Api.parse(reader, signature: signature) as? Api.AttachMenuBot
            }
            var _2: [Api.User]?
            if let _ = reader.readInt32() {
                _2 = Api.parseVector(reader, elementSignature: 0, elementType: Api.User.self)
            }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            if _c1 && _c2 {
                return Api.AttachMenuBotsBot.attachMenuBotsBot(bot: _1!, users: _2!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum Authorization: TypeConstructorDescription {
        case authorization(flags: Int32, hash: Int64, deviceModel: String, platform: String, systemVersion: String, apiId: Int32, appName: String, appVersion: String, dateCreated: Int32, dateActive: Int32, ip: String, country: String, region: String)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .authorization(let flags, let hash, let deviceModel, let platform, let systemVersion, let apiId, let appName, let appVersion, let dateCreated, let dateActive, let ip, let country, let region):
                    if boxed {
                        buffer.appendInt32(-1392388579)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    serializeInt64(hash, buffer: buffer, boxed: false)
                    serializeString(deviceModel, buffer: buffer, boxed: false)
                    serializeString(platform, buffer: buffer, boxed: false)
                    serializeString(systemVersion, buffer: buffer, boxed: false)
                    serializeInt32(apiId, buffer: buffer, boxed: false)
                    serializeString(appName, buffer: buffer, boxed: false)
                    serializeString(appVersion, buffer: buffer, boxed: false)
                    serializeInt32(dateCreated, buffer: buffer, boxed: false)
                    serializeInt32(dateActive, buffer: buffer, boxed: false)
                    serializeString(ip, buffer: buffer, boxed: false)
                    serializeString(country, buffer: buffer, boxed: false)
                    serializeString(region, buffer: buffer, boxed: false)
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .authorization(let flags, let hash, let deviceModel, let platform, let systemVersion, let apiId, let appName, let appVersion, let dateCreated, let dateActive, let ip, let country, let region):
                return ("authorization", [("flags", String(describing: flags)), ("hash", String(describing: hash)), ("deviceModel", String(describing: deviceModel)), ("platform", String(describing: platform)), ("systemVersion", String(describing: systemVersion)), ("apiId", String(describing: apiId)), ("appName", String(describing: appName)), ("appVersion", String(describing: appVersion)), ("dateCreated", String(describing: dateCreated)), ("dateActive", String(describing: dateActive)), ("ip", String(describing: ip)), ("country", String(describing: country)), ("region", String(describing: region))])
    }
    }
    
        public static func parse_authorization(_ reader: BufferReader) -> Authorization? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: Int64?
            _2 = reader.readInt64()
            var _3: String?
            _3 = parseString(reader)
            var _4: String?
            _4 = parseString(reader)
            var _5: String?
            _5 = parseString(reader)
            var _6: Int32?
            _6 = reader.readInt32()
            var _7: String?
            _7 = parseString(reader)
            var _8: String?
            _8 = parseString(reader)
            var _9: Int32?
            _9 = reader.readInt32()
            var _10: Int32?
            _10 = reader.readInt32()
            var _11: String?
            _11 = parseString(reader)
            var _12: String?
            _12 = parseString(reader)
            var _13: String?
            _13 = parseString(reader)
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            let _c4 = _4 != nil
            let _c5 = _5 != nil
            let _c6 = _6 != nil
            let _c7 = _7 != nil
            let _c8 = _8 != nil
            let _c9 = _9 != nil
            let _c10 = _10 != nil
            let _c11 = _11 != nil
            let _c12 = _12 != nil
            let _c13 = _13 != nil
            if _c1 && _c2 && _c3 && _c4 && _c5 && _c6 && _c7 && _c8 && _c9 && _c10 && _c11 && _c12 && _c13 {
                return Api.Authorization.authorization(flags: _1!, hash: _2!, deviceModel: _3!, platform: _4!, systemVersion: _5!, apiId: _6!, appName: _7!, appVersion: _8!, dateCreated: _9!, dateActive: _10!, ip: _11!, country: _12!, region: _13!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum AutoDownloadSettings: TypeConstructorDescription {
        case autoDownloadSettings(flags: Int32, photoSizeMax: Int32, videoSizeMax: Int32, fileSizeMax: Int32, videoUploadMaxbitrate: Int32)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .autoDownloadSettings(let flags, let photoSizeMax, let videoSizeMax, let fileSizeMax, let videoUploadMaxbitrate):
                    if boxed {
                        buffer.appendInt32(-532532493)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    serializeInt32(photoSizeMax, buffer: buffer, boxed: false)
                    serializeInt32(videoSizeMax, buffer: buffer, boxed: false)
                    serializeInt32(fileSizeMax, buffer: buffer, boxed: false)
                    serializeInt32(videoUploadMaxbitrate, buffer: buffer, boxed: false)
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .autoDownloadSettings(let flags, let photoSizeMax, let videoSizeMax, let fileSizeMax, let videoUploadMaxbitrate):
                return ("autoDownloadSettings", [("flags", String(describing: flags)), ("photoSizeMax", String(describing: photoSizeMax)), ("videoSizeMax", String(describing: videoSizeMax)), ("fileSizeMax", String(describing: fileSizeMax)), ("videoUploadMaxbitrate", String(describing: videoUploadMaxbitrate))])
    }
    }
    
        public static func parse_autoDownloadSettings(_ reader: BufferReader) -> AutoDownloadSettings? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: Int32?
            _2 = reader.readInt32()
            var _3: Int32?
            _3 = reader.readInt32()
            var _4: Int32?
            _4 = reader.readInt32()
            var _5: Int32?
            _5 = reader.readInt32()
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            let _c4 = _4 != nil
            let _c5 = _5 != nil
            if _c1 && _c2 && _c3 && _c4 && _c5 {
                return Api.AutoDownloadSettings.autoDownloadSettings(flags: _1!, photoSizeMax: _2!, videoSizeMax: _3!, fileSizeMax: _4!, videoUploadMaxbitrate: _5!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum AvailableReaction: TypeConstructorDescription {
        case availableReaction(flags: Int32, reaction: String, title: String, staticIcon: Api.Document, appearAnimation: Api.Document, selectAnimation: Api.Document, activateAnimation: Api.Document, effectAnimation: Api.Document, aroundAnimation: Api.Document?, centerIcon: Api.Document?)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .availableReaction(let flags, let reaction, let title, let staticIcon, let appearAnimation, let selectAnimation, let activateAnimation, let effectAnimation, let aroundAnimation, let centerIcon):
                    if boxed {
                        buffer.appendInt32(-1065882623)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    serializeString(reaction, buffer: buffer, boxed: false)
                    serializeString(title, buffer: buffer, boxed: false)
                    staticIcon.serialize(buffer, true)
                    appearAnimation.serialize(buffer, true)
                    selectAnimation.serialize(buffer, true)
                    activateAnimation.serialize(buffer, true)
                    effectAnimation.serialize(buffer, true)
                    if Int(flags) & Int(1 << 1) != 0 {aroundAnimation!.serialize(buffer, true)}
                    if Int(flags) & Int(1 << 1) != 0 {centerIcon!.serialize(buffer, true)}
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .availableReaction(let flags, let reaction, let title, let staticIcon, let appearAnimation, let selectAnimation, let activateAnimation, let effectAnimation, let aroundAnimation, let centerIcon):
                return ("availableReaction", [("flags", String(describing: flags)), ("reaction", String(describing: reaction)), ("title", String(describing: title)), ("staticIcon", String(describing: staticIcon)), ("appearAnimation", String(describing: appearAnimation)), ("selectAnimation", String(describing: selectAnimation)), ("activateAnimation", String(describing: activateAnimation)), ("effectAnimation", String(describing: effectAnimation)), ("aroundAnimation", String(describing: aroundAnimation)), ("centerIcon", String(describing: centerIcon))])
    }
    }
    
        public static func parse_availableReaction(_ reader: BufferReader) -> AvailableReaction? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: String?
            _2 = parseString(reader)
            var _3: String?
            _3 = parseString(reader)
            var _4: Api.Document?
            if let signature = reader.readInt32() {
                _4 = Api.parse(reader, signature: signature) as? Api.Document
            }
            var _5: Api.Document?
            if let signature = reader.readInt32() {
                _5 = Api.parse(reader, signature: signature) as? Api.Document
            }
            var _6: Api.Document?
            if let signature = reader.readInt32() {
                _6 = Api.parse(reader, signature: signature) as? Api.Document
            }
            var _7: Api.Document?
            if let signature = reader.readInt32() {
                _7 = Api.parse(reader, signature: signature) as? Api.Document
            }
            var _8: Api.Document?
            if let signature = reader.readInt32() {
                _8 = Api.parse(reader, signature: signature) as? Api.Document
            }
            var _9: Api.Document?
            if Int(_1!) & Int(1 << 1) != 0 {if let signature = reader.readInt32() {
                _9 = Api.parse(reader, signature: signature) as? Api.Document
            } }
            var _10: Api.Document?
            if Int(_1!) & Int(1 << 1) != 0 {if let signature = reader.readInt32() {
                _10 = Api.parse(reader, signature: signature) as? Api.Document
            } }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            let _c4 = _4 != nil
            let _c5 = _5 != nil
            let _c6 = _6 != nil
            let _c7 = _7 != nil
            let _c8 = _8 != nil
            let _c9 = (Int(_1!) & Int(1 << 1) == 0) || _9 != nil
            let _c10 = (Int(_1!) & Int(1 << 1) == 0) || _10 != nil
            if _c1 && _c2 && _c3 && _c4 && _c5 && _c6 && _c7 && _c8 && _c9 && _c10 {
                return Api.AvailableReaction.availableReaction(flags: _1!, reaction: _2!, title: _3!, staticIcon: _4!, appearAnimation: _5!, selectAnimation: _6!, activateAnimation: _7!, effectAnimation: _8!, aroundAnimation: _9, centerIcon: _10)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum BankCardOpenUrl: TypeConstructorDescription {
        case bankCardOpenUrl(url: String, name: String)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .bankCardOpenUrl(let url, let name):
                    if boxed {
                        buffer.appendInt32(-177732982)
                    }
                    serializeString(url, buffer: buffer, boxed: false)
                    serializeString(name, buffer: buffer, boxed: false)
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .bankCardOpenUrl(let url, let name):
                return ("bankCardOpenUrl", [("url", String(describing: url)), ("name", String(describing: name))])
    }
    }
    
        public static func parse_bankCardOpenUrl(_ reader: BufferReader) -> BankCardOpenUrl? {
            var _1: String?
            _1 = parseString(reader)
            var _2: String?
            _2 = parseString(reader)
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            if _c1 && _c2 {
                return Api.BankCardOpenUrl.bankCardOpenUrl(url: _1!, name: _2!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum BaseTheme: TypeConstructorDescription {
        case baseThemeArctic
        case baseThemeClassic
        case baseThemeDay
        case baseThemeNight
        case baseThemeTinted
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .baseThemeArctic:
                    if boxed {
                        buffer.appendInt32(1527845466)
                    }
                    
                    break
                case .baseThemeClassic:
                    if boxed {
                        buffer.appendInt32(-1012849566)
                    }
                    
                    break
                case .baseThemeDay:
                    if boxed {
                        buffer.appendInt32(-69724536)
                    }
                    
                    break
                case .baseThemeNight:
                    if boxed {
                        buffer.appendInt32(-1212997976)
                    }
                    
                    break
                case .baseThemeTinted:
                    if boxed {
                        buffer.appendInt32(1834973166)
                    }
                    
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .baseThemeArctic:
                return ("baseThemeArctic", [])
                case .baseThemeClassic:
                return ("baseThemeClassic", [])
                case .baseThemeDay:
                return ("baseThemeDay", [])
                case .baseThemeNight:
                return ("baseThemeNight", [])
                case .baseThemeTinted:
                return ("baseThemeTinted", [])
    }
    }
    
        public static func parse_baseThemeArctic(_ reader: BufferReader) -> BaseTheme? {
            return Api.BaseTheme.baseThemeArctic
        }
        public static func parse_baseThemeClassic(_ reader: BufferReader) -> BaseTheme? {
            return Api.BaseTheme.baseThemeClassic
        }
        public static func parse_baseThemeDay(_ reader: BufferReader) -> BaseTheme? {
            return Api.BaseTheme.baseThemeDay
        }
        public static func parse_baseThemeNight(_ reader: BufferReader) -> BaseTheme? {
            return Api.BaseTheme.baseThemeNight
        }
        public static func parse_baseThemeTinted(_ reader: BufferReader) -> BaseTheme? {
            return Api.BaseTheme.baseThemeTinted
        }
    
    }
}
public extension Api {
    enum Bool: TypeConstructorDescription {
        case boolFalse
        case boolTrue
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .boolFalse:
                    if boxed {
                        buffer.appendInt32(-1132882121)
                    }
                    
                    break
                case .boolTrue:
                    if boxed {
                        buffer.appendInt32(-1720552011)
                    }
                    
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .boolFalse:
                return ("boolFalse", [])
                case .boolTrue:
                return ("boolTrue", [])
    }
    }
    
        public static func parse_boolFalse(_ reader: BufferReader) -> Bool? {
            return Api.Bool.boolFalse
        }
        public static func parse_boolTrue(_ reader: BufferReader) -> Bool? {
            return Api.Bool.boolTrue
        }
    
    }
}
public extension Api {
    enum BotCommand: TypeConstructorDescription {
        case botCommand(command: String, description: String)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .botCommand(let command, let description):
                    if boxed {
                        buffer.appendInt32(-1032140601)
                    }
                    serializeString(command, buffer: buffer, boxed: false)
                    serializeString(description, buffer: buffer, boxed: false)
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .botCommand(let command, let description):
                return ("botCommand", [("command", String(describing: command)), ("description", String(describing: description))])
    }
    }
    
        public static func parse_botCommand(_ reader: BufferReader) -> BotCommand? {
            var _1: String?
            _1 = parseString(reader)
            var _2: String?
            _2 = parseString(reader)
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            if _c1 && _c2 {
                return Api.BotCommand.botCommand(command: _1!, description: _2!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum BotCommandScope: TypeConstructorDescription {
        case botCommandScopeChatAdmins
        case botCommandScopeChats
        case botCommandScopeDefault
        case botCommandScopePeer(peer: Api.InputPeer)
        case botCommandScopePeerAdmins(peer: Api.InputPeer)
        case botCommandScopePeerUser(peer: Api.InputPeer, userId: Api.InputUser)
        case botCommandScopeUsers
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .botCommandScopeChatAdmins:
                    if boxed {
                        buffer.appendInt32(-1180016534)
                    }
                    
                    break
                case .botCommandScopeChats:
                    if boxed {
                        buffer.appendInt32(1877059713)
                    }
                    
                    break
                case .botCommandScopeDefault:
                    if boxed {
                        buffer.appendInt32(795652779)
                    }
                    
                    break
                case .botCommandScopePeer(let peer):
                    if boxed {
                        buffer.appendInt32(-610432643)
                    }
                    peer.serialize(buffer, true)
                    break
                case .botCommandScopePeerAdmins(let peer):
                    if boxed {
                        buffer.appendInt32(1071145937)
                    }
                    peer.serialize(buffer, true)
                    break
                case .botCommandScopePeerUser(let peer, let userId):
                    if boxed {
                        buffer.appendInt32(169026035)
                    }
                    peer.serialize(buffer, true)
                    userId.serialize(buffer, true)
                    break
                case .botCommandScopeUsers:
                    if boxed {
                        buffer.appendInt32(1011811544)
                    }
                    
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .botCommandScopeChatAdmins:
                return ("botCommandScopeChatAdmins", [])
                case .botCommandScopeChats:
                return ("botCommandScopeChats", [])
                case .botCommandScopeDefault:
                return ("botCommandScopeDefault", [])
                case .botCommandScopePeer(let peer):
                return ("botCommandScopePeer", [("peer", String(describing: peer))])
                case .botCommandScopePeerAdmins(let peer):
                return ("botCommandScopePeerAdmins", [("peer", String(describing: peer))])
                case .botCommandScopePeerUser(let peer, let userId):
                return ("botCommandScopePeerUser", [("peer", String(describing: peer)), ("userId", String(describing: userId))])
                case .botCommandScopeUsers:
                return ("botCommandScopeUsers", [])
    }
    }
    
        public static func parse_botCommandScopeChatAdmins(_ reader: BufferReader) -> BotCommandScope? {
            return Api.BotCommandScope.botCommandScopeChatAdmins
        }
        public static func parse_botCommandScopeChats(_ reader: BufferReader) -> BotCommandScope? {
            return Api.BotCommandScope.botCommandScopeChats
        }
        public static func parse_botCommandScopeDefault(_ reader: BufferReader) -> BotCommandScope? {
            return Api.BotCommandScope.botCommandScopeDefault
        }
        public static func parse_botCommandScopePeer(_ reader: BufferReader) -> BotCommandScope? {
            var _1: Api.InputPeer?
            if let signature = reader.readInt32() {
                _1 = Api.parse(reader, signature: signature) as? Api.InputPeer
            }
            let _c1 = _1 != nil
            if _c1 {
                return Api.BotCommandScope.botCommandScopePeer(peer: _1!)
            }
            else {
                return nil
            }
        }
        public static func parse_botCommandScopePeerAdmins(_ reader: BufferReader) -> BotCommandScope? {
            var _1: Api.InputPeer?
            if let signature = reader.readInt32() {
                _1 = Api.parse(reader, signature: signature) as? Api.InputPeer
            }
            let _c1 = _1 != nil
            if _c1 {
                return Api.BotCommandScope.botCommandScopePeerAdmins(peer: _1!)
            }
            else {
                return nil
            }
        }
        public static func parse_botCommandScopePeerUser(_ reader: BufferReader) -> BotCommandScope? {
            var _1: Api.InputPeer?
            if let signature = reader.readInt32() {
                _1 = Api.parse(reader, signature: signature) as? Api.InputPeer
            }
            var _2: Api.InputUser?
            if let signature = reader.readInt32() {
                _2 = Api.parse(reader, signature: signature) as? Api.InputUser
            }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            if _c1 && _c2 {
                return Api.BotCommandScope.botCommandScopePeerUser(peer: _1!, userId: _2!)
            }
            else {
                return nil
            }
        }
        public static func parse_botCommandScopeUsers(_ reader: BufferReader) -> BotCommandScope? {
            return Api.BotCommandScope.botCommandScopeUsers
        }
    
    }
}
public extension Api {
    enum BotInfo: TypeConstructorDescription {
        case botInfo(userId: Int64, description: String, commands: [Api.BotCommand], menuButton: Api.BotMenuButton)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .botInfo(let userId, let description, let commands, let menuButton):
                    if boxed {
                        buffer.appendInt32(-468280483)
                    }
                    serializeInt64(userId, buffer: buffer, boxed: false)
                    serializeString(description, buffer: buffer, boxed: false)
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(commands.count))
                    for item in commands {
                        item.serialize(buffer, true)
                    }
                    menuButton.serialize(buffer, true)
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .botInfo(let userId, let description, let commands, let menuButton):
                return ("botInfo", [("userId", String(describing: userId)), ("description", String(describing: description)), ("commands", String(describing: commands)), ("menuButton", String(describing: menuButton))])
    }
    }
    
        public static func parse_botInfo(_ reader: BufferReader) -> BotInfo? {
            var _1: Int64?
            _1 = reader.readInt64()
            var _2: String?
            _2 = parseString(reader)
            var _3: [Api.BotCommand]?
            if let _ = reader.readInt32() {
                _3 = Api.parseVector(reader, elementSignature: 0, elementType: Api.BotCommand.self)
            }
            var _4: Api.BotMenuButton?
            if let signature = reader.readInt32() {
                _4 = Api.parse(reader, signature: signature) as? Api.BotMenuButton
            }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            let _c4 = _4 != nil
            if _c1 && _c2 && _c3 && _c4 {
                return Api.BotInfo.botInfo(userId: _1!, description: _2!, commands: _3!, menuButton: _4!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum BotInlineMessage: TypeConstructorDescription {
        case botInlineMessageMediaAuto(flags: Int32, message: String, entities: [Api.MessageEntity]?, replyMarkup: Api.ReplyMarkup?)
        case botInlineMessageMediaContact(flags: Int32, phoneNumber: String, firstName: String, lastName: String, vcard: String, replyMarkup: Api.ReplyMarkup?)
        case botInlineMessageMediaGeo(flags: Int32, geo: Api.GeoPoint, heading: Int32?, period: Int32?, proximityNotificationRadius: Int32?, replyMarkup: Api.ReplyMarkup?)
        case botInlineMessageMediaInvoice(flags: Int32, title: String, description: String, photo: Api.WebDocument?, currency: String, totalAmount: Int64, replyMarkup: Api.ReplyMarkup?)
        case botInlineMessageMediaVenue(flags: Int32, geo: Api.GeoPoint, title: String, address: String, provider: String, venueId: String, venueType: String, replyMarkup: Api.ReplyMarkup?)
        case botInlineMessageText(flags: Int32, message: String, entities: [Api.MessageEntity]?, replyMarkup: Api.ReplyMarkup?)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .botInlineMessageMediaAuto(let flags, let message, let entities, let replyMarkup):
                    if boxed {
                        buffer.appendInt32(1984755728)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    serializeString(message, buffer: buffer, boxed: false)
                    if Int(flags) & Int(1 << 1) != 0 {buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(entities!.count))
                    for item in entities! {
                        item.serialize(buffer, true)
                    }}
                    if Int(flags) & Int(1 << 2) != 0 {replyMarkup!.serialize(buffer, true)}
                    break
                case .botInlineMessageMediaContact(let flags, let phoneNumber, let firstName, let lastName, let vcard, let replyMarkup):
                    if boxed {
                        buffer.appendInt32(416402882)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    serializeString(phoneNumber, buffer: buffer, boxed: false)
                    serializeString(firstName, buffer: buffer, boxed: false)
                    serializeString(lastName, buffer: buffer, boxed: false)
                    serializeString(vcard, buffer: buffer, boxed: false)
                    if Int(flags) & Int(1 << 2) != 0 {replyMarkup!.serialize(buffer, true)}
                    break
                case .botInlineMessageMediaGeo(let flags, let geo, let heading, let period, let proximityNotificationRadius, let replyMarkup):
                    if boxed {
                        buffer.appendInt32(85477117)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    geo.serialize(buffer, true)
                    if Int(flags) & Int(1 << 0) != 0 {serializeInt32(heading!, buffer: buffer, boxed: false)}
                    if Int(flags) & Int(1 << 1) != 0 {serializeInt32(period!, buffer: buffer, boxed: false)}
                    if Int(flags) & Int(1 << 3) != 0 {serializeInt32(proximityNotificationRadius!, buffer: buffer, boxed: false)}
                    if Int(flags) & Int(1 << 2) != 0 {replyMarkup!.serialize(buffer, true)}
                    break
                case .botInlineMessageMediaInvoice(let flags, let title, let description, let photo, let currency, let totalAmount, let replyMarkup):
                    if boxed {
                        buffer.appendInt32(894081801)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    serializeString(title, buffer: buffer, boxed: false)
                    serializeString(description, buffer: buffer, boxed: false)
                    if Int(flags) & Int(1 << 0) != 0 {photo!.serialize(buffer, true)}
                    serializeString(currency, buffer: buffer, boxed: false)
                    serializeInt64(totalAmount, buffer: buffer, boxed: false)
                    if Int(flags) & Int(1 << 2) != 0 {replyMarkup!.serialize(buffer, true)}
                    break
                case .botInlineMessageMediaVenue(let flags, let geo, let title, let address, let provider, let venueId, let venueType, let replyMarkup):
                    if boxed {
                        buffer.appendInt32(-1970903652)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    geo.serialize(buffer, true)
                    serializeString(title, buffer: buffer, boxed: false)
                    serializeString(address, buffer: buffer, boxed: false)
                    serializeString(provider, buffer: buffer, boxed: false)
                    serializeString(venueId, buffer: buffer, boxed: false)
                    serializeString(venueType, buffer: buffer, boxed: false)
                    if Int(flags) & Int(1 << 2) != 0 {replyMarkup!.serialize(buffer, true)}
                    break
                case .botInlineMessageText(let flags, let message, let entities, let replyMarkup):
                    if boxed {
                        buffer.appendInt32(-1937807902)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    serializeString(message, buffer: buffer, boxed: false)
                    if Int(flags) & Int(1 << 1) != 0 {buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(entities!.count))
                    for item in entities! {
                        item.serialize(buffer, true)
                    }}
                    if Int(flags) & Int(1 << 2) != 0 {replyMarkup!.serialize(buffer, true)}
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .botInlineMessageMediaAuto(let flags, let message, let entities, let replyMarkup):
                return ("botInlineMessageMediaAuto", [("flags", String(describing: flags)), ("message", String(describing: message)), ("entities", String(describing: entities)), ("replyMarkup", String(describing: replyMarkup))])
                case .botInlineMessageMediaContact(let flags, let phoneNumber, let firstName, let lastName, let vcard, let replyMarkup):
                return ("botInlineMessageMediaContact", [("flags", String(describing: flags)), ("phoneNumber", String(describing: phoneNumber)), ("firstName", String(describing: firstName)), ("lastName", String(describing: lastName)), ("vcard", String(describing: vcard)), ("replyMarkup", String(describing: replyMarkup))])
                case .botInlineMessageMediaGeo(let flags, let geo, let heading, let period, let proximityNotificationRadius, let replyMarkup):
                return ("botInlineMessageMediaGeo", [("flags", String(describing: flags)), ("geo", String(describing: geo)), ("heading", String(describing: heading)), ("period", String(describing: period)), ("proximityNotificationRadius", String(describing: proximityNotificationRadius)), ("replyMarkup", String(describing: replyMarkup))])
                case .botInlineMessageMediaInvoice(let flags, let title, let description, let photo, let currency, let totalAmount, let replyMarkup):
                return ("botInlineMessageMediaInvoice", [("flags", String(describing: flags)), ("title", String(describing: title)), ("description", String(describing: description)), ("photo", String(describing: photo)), ("currency", String(describing: currency)), ("totalAmount", String(describing: totalAmount)), ("replyMarkup", String(describing: replyMarkup))])
                case .botInlineMessageMediaVenue(let flags, let geo, let title, let address, let provider, let venueId, let venueType, let replyMarkup):
                return ("botInlineMessageMediaVenue", [("flags", String(describing: flags)), ("geo", String(describing: geo)), ("title", String(describing: title)), ("address", String(describing: address)), ("provider", String(describing: provider)), ("venueId", String(describing: venueId)), ("venueType", String(describing: venueType)), ("replyMarkup", String(describing: replyMarkup))])
                case .botInlineMessageText(let flags, let message, let entities, let replyMarkup):
                return ("botInlineMessageText", [("flags", String(describing: flags)), ("message", String(describing: message)), ("entities", String(describing: entities)), ("replyMarkup", String(describing: replyMarkup))])
    }
    }
    
        public static func parse_botInlineMessageMediaAuto(_ reader: BufferReader) -> BotInlineMessage? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: String?
            _2 = parseString(reader)
            var _3: [Api.MessageEntity]?
            if Int(_1!) & Int(1 << 1) != 0 {if let _ = reader.readInt32() {
                _3 = Api.parseVector(reader, elementSignature: 0, elementType: Api.MessageEntity.self)
            } }
            var _4: Api.ReplyMarkup?
            if Int(_1!) & Int(1 << 2) != 0 {if let signature = reader.readInt32() {
                _4 = Api.parse(reader, signature: signature) as? Api.ReplyMarkup
            } }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = (Int(_1!) & Int(1 << 1) == 0) || _3 != nil
            let _c4 = (Int(_1!) & Int(1 << 2) == 0) || _4 != nil
            if _c1 && _c2 && _c3 && _c4 {
                return Api.BotInlineMessage.botInlineMessageMediaAuto(flags: _1!, message: _2!, entities: _3, replyMarkup: _4)
            }
            else {
                return nil
            }
        }
        public static func parse_botInlineMessageMediaContact(_ reader: BufferReader) -> BotInlineMessage? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: String?
            _2 = parseString(reader)
            var _3: String?
            _3 = parseString(reader)
            var _4: String?
            _4 = parseString(reader)
            var _5: String?
            _5 = parseString(reader)
            var _6: Api.ReplyMarkup?
            if Int(_1!) & Int(1 << 2) != 0 {if let signature = reader.readInt32() {
                _6 = Api.parse(reader, signature: signature) as? Api.ReplyMarkup
            } }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            let _c4 = _4 != nil
            let _c5 = _5 != nil
            let _c6 = (Int(_1!) & Int(1 << 2) == 0) || _6 != nil
            if _c1 && _c2 && _c3 && _c4 && _c5 && _c6 {
                return Api.BotInlineMessage.botInlineMessageMediaContact(flags: _1!, phoneNumber: _2!, firstName: _3!, lastName: _4!, vcard: _5!, replyMarkup: _6)
            }
            else {
                return nil
            }
        }
        public static func parse_botInlineMessageMediaGeo(_ reader: BufferReader) -> BotInlineMessage? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: Api.GeoPoint?
            if let signature = reader.readInt32() {
                _2 = Api.parse(reader, signature: signature) as? Api.GeoPoint
            }
            var _3: Int32?
            if Int(_1!) & Int(1 << 0) != 0 {_3 = reader.readInt32() }
            var _4: Int32?
            if Int(_1!) & Int(1 << 1) != 0 {_4 = reader.readInt32() }
            var _5: Int32?
            if Int(_1!) & Int(1 << 3) != 0 {_5 = reader.readInt32() }
            var _6: Api.ReplyMarkup?
            if Int(_1!) & Int(1 << 2) != 0 {if let signature = reader.readInt32() {
                _6 = Api.parse(reader, signature: signature) as? Api.ReplyMarkup
            } }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = (Int(_1!) & Int(1 << 0) == 0) || _3 != nil
            let _c4 = (Int(_1!) & Int(1 << 1) == 0) || _4 != nil
            let _c5 = (Int(_1!) & Int(1 << 3) == 0) || _5 != nil
            let _c6 = (Int(_1!) & Int(1 << 2) == 0) || _6 != nil
            if _c1 && _c2 && _c3 && _c4 && _c5 && _c6 {
                return Api.BotInlineMessage.botInlineMessageMediaGeo(flags: _1!, geo: _2!, heading: _3, period: _4, proximityNotificationRadius: _5, replyMarkup: _6)
            }
            else {
                return nil
            }
        }
        public static func parse_botInlineMessageMediaInvoice(_ reader: BufferReader) -> BotInlineMessage? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: String?
            _2 = parseString(reader)
            var _3: String?
            _3 = parseString(reader)
            var _4: Api.WebDocument?
            if Int(_1!) & Int(1 << 0) != 0 {if let signature = reader.readInt32() {
                _4 = Api.parse(reader, signature: signature) as? Api.WebDocument
            } }
            var _5: String?
            _5 = parseString(reader)
            var _6: Int64?
            _6 = reader.readInt64()
            var _7: Api.ReplyMarkup?
            if Int(_1!) & Int(1 << 2) != 0 {if let signature = reader.readInt32() {
                _7 = Api.parse(reader, signature: signature) as? Api.ReplyMarkup
            } }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            let _c4 = (Int(_1!) & Int(1 << 0) == 0) || _4 != nil
            let _c5 = _5 != nil
            let _c6 = _6 != nil
            let _c7 = (Int(_1!) & Int(1 << 2) == 0) || _7 != nil
            if _c1 && _c2 && _c3 && _c4 && _c5 && _c6 && _c7 {
                return Api.BotInlineMessage.botInlineMessageMediaInvoice(flags: _1!, title: _2!, description: _3!, photo: _4, currency: _5!, totalAmount: _6!, replyMarkup: _7)
            }
            else {
                return nil
            }
        }
        public static func parse_botInlineMessageMediaVenue(_ reader: BufferReader) -> BotInlineMessage? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: Api.GeoPoint?
            if let signature = reader.readInt32() {
                _2 = Api.parse(reader, signature: signature) as? Api.GeoPoint
            }
            var _3: String?
            _3 = parseString(reader)
            var _4: String?
            _4 = parseString(reader)
            var _5: String?
            _5 = parseString(reader)
            var _6: String?
            _6 = parseString(reader)
            var _7: String?
            _7 = parseString(reader)
            var _8: Api.ReplyMarkup?
            if Int(_1!) & Int(1 << 2) != 0 {if let signature = reader.readInt32() {
                _8 = Api.parse(reader, signature: signature) as? Api.ReplyMarkup
            } }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            let _c4 = _4 != nil
            let _c5 = _5 != nil
            let _c6 = _6 != nil
            let _c7 = _7 != nil
            let _c8 = (Int(_1!) & Int(1 << 2) == 0) || _8 != nil
            if _c1 && _c2 && _c3 && _c4 && _c5 && _c6 && _c7 && _c8 {
                return Api.BotInlineMessage.botInlineMessageMediaVenue(flags: _1!, geo: _2!, title: _3!, address: _4!, provider: _5!, venueId: _6!, venueType: _7!, replyMarkup: _8)
            }
            else {
                return nil
            }
        }
        public static func parse_botInlineMessageText(_ reader: BufferReader) -> BotInlineMessage? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: String?
            _2 = parseString(reader)
            var _3: [Api.MessageEntity]?
            if Int(_1!) & Int(1 << 1) != 0 {if let _ = reader.readInt32() {
                _3 = Api.parseVector(reader, elementSignature: 0, elementType: Api.MessageEntity.self)
            } }
            var _4: Api.ReplyMarkup?
            if Int(_1!) & Int(1 << 2) != 0 {if let signature = reader.readInt32() {
                _4 = Api.parse(reader, signature: signature) as? Api.ReplyMarkup
            } }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = (Int(_1!) & Int(1 << 1) == 0) || _3 != nil
            let _c4 = (Int(_1!) & Int(1 << 2) == 0) || _4 != nil
            if _c1 && _c2 && _c3 && _c4 {
                return Api.BotInlineMessage.botInlineMessageText(flags: _1!, message: _2!, entities: _3, replyMarkup: _4)
            }
            else {
                return nil
            }
        }
    
    }
}

import Foundation

public enum RulesType: String, Codable, CaseIterable {
    case adBlock
    case privacy
    case banners
    case trackers
    case advanced
    case secure
    case basic
    
    internal var getPathToFile: URL? {
        let fileManager = FileManager.default
        guard let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Constants.adblockGroupId) else {
            return nil
        }
        let fileURL = groupURL.appendingPathComponent("\(self.rawValue).json")
        return fileURL
    }

    internal func setRules(_ rules: String, emptyRules: Bool, groupID: String) {
        guard let filePath = filePathBy(groupID: groupID) else {
            return
        }
        
        do {
            try rules.write(to: filePath, atomically: true, encoding: .utf8)
            
            let fileHandle = try FileHandle(forWritingTo: filePath)
            try fileHandle.synchronize()
            try fileHandle.close()
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    private func filePathBy(groupID: String) -> URL? {
        let fileManager = FileManager.default
        guard let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
            return nil
        }
        let fileURL = groupURL.appendingPathComponent("\(self.rawValue).json")
        return fileURL
    }
}

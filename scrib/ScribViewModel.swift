import Foundation
import LinkPresentation

@MainActor
class ScribViewModel: ObservableObject {
    @Published private(set) var scribs: [Scrib] = []
    private let saveKey = "SavedScribs"
    
    init() {
        loadScribs()
    }
    
    func addScrib(_ content: String) {
        var scrib = Scrib(content: content)
        scribs.insert(scrib, at: 0)
        
        // Only extract and fetch metadata for the URL part
        if let url = content.extractURL() {
            Task {
                if let metadata = try? await LinkMetadataFetcher.fetchMetadata(for: url),
                   let wrapper = LinkMetadataWrapper(metadata: metadata) {
                    if let index = scribs.firstIndex(where: { $0.id == scrib.id }) {
                        scribs[index].linkMetadata = wrapper
                        saveScribs()
                    }
                }
            }
        }
        
        saveScribs()
    }
    
    func editScrib(id: UUID, newContent: String) {
        if let index = scribs.firstIndex(where: { $0.id == id }) {
            var updatedScrib = scribs[index]
            updatedScrib.content = newContent
            
            // Clear existing metadata
            updatedScrib.linkMetadata = nil
            
            // Update scrib
            scribs[index] = updatedScrib
            
            // Check for new URL and fetch metadata
            if let url = newContent.extractURL() {
                Task {
                    if let metadata = try? await LinkMetadataFetcher.fetchMetadata(for: url),
                       let wrapper = LinkMetadataWrapper(metadata: metadata) {
                        if let currentIndex = scribs.firstIndex(where: { $0.id == id }) {
                            scribs[currentIndex].linkMetadata = wrapper
                            saveScribs()
                        }
                    }
                }
            }
            
            saveScribs()
        }
    }
    
    func deleteScrib(id: UUID) {
        scribs.removeAll { $0.id == id }
        saveScribs()
    }
    
    private func saveScribs() {
        if let encoded = try? JSONEncoder().encode(scribs) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadScribs() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Scrib].self, from: data) {
            scribs = decoded
        }
    }
}

// MARK: - String Extension
extension String {
    func extractURL() -> URL? {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        
        if let match = matches?.first, let range = Range(match.range, in: self) {
            let urlString = String(self[range])
            return URL(string: urlString)
        }
        return nil
    }
}
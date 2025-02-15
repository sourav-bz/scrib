import Foundation
import LinkPresentation

// MARK: - Link Metadata
class LinkMetadataFetcher {
    static func fetchMetadata(for url: URL) async throws -> LPLinkMetadata {
        let provider = LPMetadataProvider()
        provider.timeout = 20
        
        // Configure provider for better previews
        let metadata = try await provider.startFetchingMetadata(for: url)
        return metadata
    }
}

struct Scrib: Identifiable, Codable {
    let id = UUID()
    let content: String
    let timestamp: Date
    var linkMetadata: LinkMetadataWrapper?
    
    init(content: String, timestamp: Date = Date()) {
        self.content = content
        self.timestamp = timestamp
    }
}

struct LinkMetadataWrapper: Codable {
    let url: URL
    let title: String?
    let description: String?
    let imageData: Data?
    let authorImageData: Data?
    
    init?(metadata: LPLinkMetadata) {
        guard let url = metadata.url else { return nil }
        self.url = url
        self.title = metadata.title
        self.description = metadata.description
        
        // Get preview image
        var imageData: Data? = nil
        if let imageProvider = metadata.imageProvider {
            let semaphore = DispatchSemaphore(value: 0)
            imageProvider.loadObject(ofClass: UIImage.self) { image, _ in
                if let image = image as? UIImage {
                    imageData = image.jpegData(compressionQuality: 0.7)
                }
                semaphore.signal()
            }
            _ = semaphore.wait(timeout: .now() + 5.0)
        }
        self.imageData = imageData
        
        // Get author/site image
        var authorData: Data? = nil
        if let iconProvider = metadata.iconProvider {
            let semaphore = DispatchSemaphore(value: 0)
            iconProvider.loadObject(ofClass: UIImage.self) { image, _ in
                if let image = image as? UIImage {
                    authorData = image.jpegData(compressionQuality: 0.7)
                }
                semaphore.signal()
            }
            _ = semaphore.wait(timeout: .now() + 5.0)
        }
        self.authorImageData = authorData
    }
}
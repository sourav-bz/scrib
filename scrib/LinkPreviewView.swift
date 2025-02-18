import SwiftUI
import LinkPresentation

struct LinkPreviewView: View {
    let metadata: LinkMetadataWrapper
    let isDarkMode: Bool
    @State private var previewImage: UIImage?
    @State private var authorImage: UIImage?
    
    var body: some View {
        Link(destination: metadata.url) {
            VStack(alignment: .leading, spacing: 10) {
                // Author/Site info
                HStack(spacing: 10) {
                    if let authorImage = authorImage {
                        Image(uiImage: authorImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        if let title = metadata.title {
                            Text(title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(isDarkMode ? .white : .black)
                                .lineLimit(2)
                        }
                        Text(metadata.url.host ?? "")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                // Preview Image
                if let previewImage = previewImage {
                    Image(uiImage: previewImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(12)
            .background(
                isDarkMode ? 
                    Color(red: 0.13, green: 0.13, blue: 0.13) : 
                    Color(uiColor: .secondarySystemBackground)
            )
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isDarkMode ? 
                            Color.white.opacity(0.1) : 
                            Color.black.opacity(0.1),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            loadImages()
        }
    }
    
    private func loadImages() {
        // Load preview image
        if let imageData = metadata.imageData {
            self.previewImage = UIImage(data: imageData)
        }
        
        // Load author/site image
        if let authorData = metadata.authorImageData {
            self.authorImage = UIImage(data: authorData)
        }
    }
}
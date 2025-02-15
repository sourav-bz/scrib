//
//  ContentView.swift
//  scrib
//
//  Created by Sourav on 16/02/25.
//

import SwiftUI
import LinkPresentation

struct TimelineScribView: View {
    let scrib: Scrib
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Timeline elements
            VStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
                    .padding(.top, 0)

                if !isLast {
                    Rectangle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                        .padding(.bottom, 18)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    if scrib.content.contains("https://") || scrib.content.contains("http://") {
                        Text(scrib.content)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.blue)
                    } else {
                        Text(scrib.content)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    if let metadata = scrib.linkMetadata {
                        LinkPreviewView(metadata: metadata)
                            .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                .cornerRadius(12)
                
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text(scrib.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(.leading, 20)
                .padding(.bottom, 8)
            }
            .padding(.leading, 12)
            .padding(.trailing, 16)
        }
        .padding(.leading, 16)
    }
}

// MARK: - Link Preview Components
struct LinkPreviewView: View {
    let metadata: LinkMetadataWrapper
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
                                .foregroundColor(.white)
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
            .background(Color(red: 0.13, green: 0.13, blue: 0.13))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
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


struct NewScribView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var newScribText: String
    var onPost: () -> Void
    
    // Character limit
    private let characterLimit = 280
    
    private var remainingCharacters: Int {
        characterLimit - newScribText.count
    }
    
    private var isOverLimit: Bool {
        remainingCharacters < 0
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.12, green: 0.12, blue: 0.12)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Text Editor Area
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $newScribText)
                            .scrollContentBackground(.hidden)
                            .frame(maxHeight: .infinity)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 40)
                            .background(Color(red: 0.18, green: 0.18, blue: 0.18))
                            .cornerRadius(16)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            
                        
                        if newScribText.isEmpty {
                            Text("What's on your mind?")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 20)
                                .padding(.top, 24)
                                .allowsHitTesting(false)
                        }
                    }
                    
                    // Bottom Action Area
                    HStack(spacing: 16) {
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Cancel")
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .fill(Color(red: 0.22, green: 0.22, blue: 0.22))
                                )
                        }
                        
                        Button(action: {
                            onPost()
                            dismiss()
                        }) {
                            HStack {
                                Text("Post")
                                Image(systemName: "arrow.up.circle.fill")
                            }
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.0, green: 0.5, blue: 1.0),
                                                Color(red: 0.0, green: 0.4, blue: 0.8)
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .opacity(isPostButtonEnabled ? 1.0 : 0.5)
                            )
                            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(!isPostButtonEnabled)
                    }
                    .padding(.top, 16)
                }
                .padding(16)
            }
            .navigationTitle("New Scrib")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var isPostButtonEnabled: Bool {
        !newScribText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isOverLimit
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ScribViewModel()
    @State private var newScribText = ""
    @State private var showingNewScribSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.12, green: 0.12, blue: 0.12)
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(viewModel.scribs.enumerated()), id: \.element.id) { index, scrib in
                            TimelineScribView(
                                scrib: scrib,
                                isLast: index == viewModel.scribs.count - 1
                            )
                        }
                        // Add some bottom padding for the last item
                        Color.clear.frame(height: 100)
                    }
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingNewScribSheet = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title2.weight(.semibold))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.0, green: 0.5, blue: 1.0),
                                            Color(red: 0.0, green: 0.4, blue: 0.8)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(30)
                                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("My Scribs")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingNewScribSheet) {
                NewScribView(newScribText: $newScribText) {
                    if !newScribText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        viewModel.addScrib(newScribText)
                        newScribText = ""
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}

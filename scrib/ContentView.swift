//
//  ContentView.swift
//  scrib
//
//  Created by Sourav on 16/02/25.
//

import SwiftUI
import LinkPresentation

extension Date {
    func timeAgoDisplay() -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.hour, .minute], from: self, to: now)
        
        if let hours = components.hour {
            if hours < 24 {
                if hours == 0 {
                    // Less than an hour ago
                    if let minutes = components.minute {
                        if minutes == 0 {
                            return "just now"
                        }
                        return "\(minutes) \(minutes == 1 ? "minute" : "minutes") ago"
                    }
                }
                return "\(hours) \(hours == 1 ? "hour" : "hours") ago"
            }
        }
        
        // More than 23 hours, show full date and time
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

struct TimelineScribView: View {
    let scrib: Scrib
    let isLast: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Timeline elements
            VStack {
                Circle()
                    .fill(colorScheme == .dark ? .white : .black)
                    .frame(width: 10, height: 10)
                    .padding(.top, 0)

                if !isLast {
                    Rectangle()
                        .fill((colorScheme == .dark ? Color.white : Color.black).opacity(0.3))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                        .padding(.bottom, 18)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    if let metadata = scrib.linkMetadata {
                        LinkPreviewView(metadata: metadata)
                            .padding(.top, 4)
                    }

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

                    Text(scrib.timestamp.timeAgoDisplay())
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(colorScheme == .dark ? Color(red: 0.16, green: 0.16, blue: 0.16) : .white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0 : 0.05), radius: 8, x: 0, y: 2)
            }
            .padding(.leading, 12)
            .padding(.trailing, 16)
            .padding(.bottom, 18)
        }
        .padding(.leading, 16)
    }
}

// MARK: - Link Preview Components
struct LinkPreviewView: View {
    let metadata: LinkMetadataWrapper
    @State private var previewImage: UIImage?
    @State private var authorImage: UIImage?
    @Environment(\.colorScheme) var colorScheme
    
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
                                .foregroundColor(colorScheme == .dark ? .white : .black)
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
                colorScheme == .dark ? 
                    Color(red: 0.13, green: 0.13, blue: 0.13) : 
                    Color(uiColor: .secondarySystemBackground)
            )
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        colorScheme == .dark ? 
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


struct NewScribView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Binding var newScribText: String
    var onPost: () -> Void
    
    private var isPostButtonEnabled: Bool {
        !newScribText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(colorScheme == .dark ? UIColor.systemBackground : .init(red: 0.96, green: 0.96, blue: 0.96, alpha: 1))
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
                            .background(colorScheme == .dark ? Color(red: 0.16, green: 0.16, blue: 0.16) : .white)
                            .cornerRadius(16)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0 : 0.05), radius: 8, x: 0, y: 2)
                        
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
                                        .fill(colorScheme == .dark ? Color(red: 0.16, green: 0.16, blue: 0.16) : .white)
                                        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0 : 0.05), radius: 4, x: 0, y: 2)
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
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(colorScheme == .dark ? .white : .black)
                                    .opacity(isPostButtonEnabled ? 1.0 : 0.5)
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
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
}


struct ContentView: View {
    @StateObject private var viewModel = ScribViewModel()
    @State private var newScribText = ""
    @State private var showingNewScribSheet = false
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(isDarkMode ? UIColor.systemBackground : .init(red: 0.96, green: 0.96, blue: 0.96, alpha: 1))
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Sticky Header
                    HStack {
                        Image(isDarkMode ? "scrib-dark" : "scrib-light")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 38)
                        Spacer()
                        Button(action: {
                            isDarkMode.toggle()
                        }) {
                            Image(systemName: isDarkMode ? "sun.max" : "moon.fill")
                                .font(.system(size: 18))
                                .foregroundColor(isDarkMode ? .black : .white)
                                .padding(4)
                                .background(
                                    Circle()
                                        .fill(isDarkMode ? .white : .black)
                                )
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 18)
                    .padding(.bottom, 18)
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            LazyVStack(spacing: 0) {
                                ForEach(Array(viewModel.scribs.enumerated()), id: \.element.id) { index, scrib in
                                    TimelineScribView(
                                        scrib: scrib,
                                        isLast: index == viewModel.scribs.count - 1
                                    )
                                }
                                Color.clear.frame(height: 100)
                            }
                        }
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
                            Image(systemName: "pencil")
                                .font(.title2.weight(.semibold))
                                .foregroundColor(isDarkMode ? .black : .white)
                                .frame(width: 50, height: 50)
                                .background(
                                    isDarkMode ? Color.white : Color.black
                                )
                                .cornerRadius(25)
                                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingNewScribSheet) {
                NewScribView(newScribText: $newScribText) {
                    if !newScribText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        viewModel.addScrib(newScribText)
                        newScribText = ""
                    }
                }
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    ContentView()
}

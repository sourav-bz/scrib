import SwiftUI

struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @StateObject private var viewModel = ScribViewModel()
    @State private var newScribText = ""
    @State private var showingNewScribSheet = false
    private var appSettings: AppSettings = .init()
    private let title: String = "Scrib"
    
    var body: some View {
        GeometryReader { outer in
            NavigationStack {
                ZStack {
                    ListView(
                        title: title,
                        outer: outer,
                        appSettings: appSettings,
                        isDarkMode: isDarkMode,
                        toggleDarkMode: { isDarkMode.toggle() },
                        viewModel: viewModel
                    )
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            ToolbarTitle(
                                title: title,
                                appSettings: appSettings,
                                isDarkMode: isDarkMode
                            )
                            .background(isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.1) : Color.white)
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            ToolbarButtons(
                                isDarkMode: isDarkMode, 
                                toggleDarkMode: { isDarkMode.toggle() }, 
                                viewModel: viewModel,
                                appSettings: appSettings
                            )
                            .background(isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.1) : Color.white)
                        }
                    }
                    .toolbarBackground(isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.1) : Color.white, for: .navigationBar)
                    
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
            }
            .sheet(isPresented: $showingNewScribSheet) {
                NewScribView(
                    isDarkMode: isDarkMode,
                    newScribText: $newScribText
                ) {
                    if !newScribText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        viewModel.addScrib(newScribText)
                        newScribText = ""
                    }
                }
            }
        }
    }
}


struct ListView: View {
    let title: String
    let outer: GeometryProxy
    let appSettings: AppSettings
    let isDarkMode: Bool
    let toggleDarkMode: () -> Void
    @ObservedObject var viewModel: ScribViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HeaderView(
                    title: title,
                    outer: outer,
                    appSettings: appSettings,
                    isDarkMode: isDarkMode,
                    toggleDarkMode: toggleDarkMode
                )
                .padding(.horizontal)
                
                LazyVStack(spacing: 0) {
                    ForEach(Array(viewModel.scribs.enumerated()), id: \.element.id) { index, scrib in
                        TimelineScribView(
                            scrib: scrib,
                            isLast: index == viewModel.scribs.count - 1,
                            isDarkMode: isDarkMode,
                            viewModel: viewModel
                        )
                    }
                    Color.clear.frame(height: 100)
                }
            }
        }
        .background(isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.1) : Color.white)
    }
}

struct HeaderView: View {
    let title: String
    let outer: GeometryProxy
    let appSettings: AppSettings
    let isDarkMode: Bool
    let toggleDarkMode: () -> Void
    
    var body: some View {
        HStack {
            Image(isDarkMode ? "scrib-dark" : "scrib-light")
                .resizable()
                .scaledToFit()
                .frame(height: 38)
                .transition(.opacity)
            
            Spacer()
            
            HeaderButtons(isDarkMode: isDarkMode, toggleDarkMode: toggleDarkMode)
        }
        .listRowInsets(.init(top: 4, leading: 0, bottom: 4, trailing: 0))
        .foregroundStyle(isDarkMode ? .white : .black)
        .background(isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.1) : Color.white)
        .background {
            appSettings.scrollDetector(topInsets: outer.safeAreaInsets.top)
        }
        .padding(.bottom, 18)
    }
}

struct HeaderButtons: View {
    @Environment(\.colorScheme) var colorScheme
    let isDarkMode: Bool
    let toggleDarkMode: () -> Void
    @State private var showingSearchSheet = false
    @StateObject private var viewModel = ScribViewModel()
    
    var body: some View {
        HStack(spacing: 8) {
            // Search button
            Button {
                showingSearchSheet = true
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18))
                    .foregroundColor(isDarkMode ? .white : .black)
                    .padding(4)
            }
            .sheet(isPresented: $showingSearchSheet) {
                SearchView(isDarkMode: isDarkMode, viewModel: viewModel)
            }
            
            // Dark mode toggle
            Button {
                toggleDarkMode()
            } label: {
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
    }
}

struct ToolbarTitle: View {
    let title: String
    let appSettings: AppSettings
    let isDarkMode: Bool
    
    var body: some View {
        Image(isDarkMode ? "scrib-dark" : "scrib-light")
            .resizable()
            .scaledToFit()
            .frame(height: 24)
            .opacity(appSettings.showingScrolledTitle ? 1 : 0)
            .animation(.easeInOut, value: appSettings.showingScrolledTitle)
    }
}

struct ToolbarButtons: View {
    @Environment(\.colorScheme) var colorScheme
    let isDarkMode: Bool
    let toggleDarkMode: () -> Void
    @ObservedObject var viewModel: ScribViewModel
    @State private var showingSearchSheet = false
    let appSettings: AppSettings
    
    var body: some View {
        HStack(spacing: 8) {
            Button {
                showingSearchSheet = true
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12))
                    .foregroundColor(isDarkMode ? .white : .black)
                    .padding(4)
            }
            .sheet(isPresented: $showingSearchSheet) {
                SearchView(isDarkMode: isDarkMode, viewModel: viewModel)
            }

            Button {
                toggleDarkMode()
            } label: {
                Image(systemName: isDarkMode ? "sun.max" : "moon.fill")
                    .font(.system(size: 10))
                    .foregroundColor(isDarkMode ? .black : .white)
                    .padding(4)
                    .background(
                        Circle()
                            .fill(isDarkMode ? .white : .black)
                    )
            }
        }
        .opacity(appSettings.showingScrolledTitle ? 1 : 0)
        .animation(.easeInOut, value: appSettings.showingScrolledTitle)
    }
}

@Observable
final class AppSettings {
    var showingScrolledTitle = false
    func scrollDetector(topInsets: CGFloat) -> some View {
        GeometryReader { proxy in
            let minY = proxy.frame(in: .global).minY
            let isUnderToolbar = minY - topInsets < 0

            Color.clear.onChange(of: isUnderToolbar) { _, newVal in
                self.showingScrolledTitle = newVal
            }
        }
    }
}

struct TimelineScribView: View {
    let scrib: Scrib
    let isLast: Bool
    let isDarkMode: Bool
    @ObservedObject var viewModel: ScribViewModel
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Timeline elements
            VStack {
                Circle()
                    .fill(isDarkMode ? .white : .black)
                    .frame(width: 10, height: 10)
                    .padding(.top, 0)

                if !isLast {
                    Rectangle()
                        .fill((isDarkMode ? Color.white : Color.black).opacity(0.3))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                        .padding(.bottom, 18)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    if let metadata = scrib.linkMetadata {
                        LinkPreviewView(metadata: metadata, isDarkMode: isDarkMode)
                            .padding(.top, 4)
                    }

                    Text(LocalizedStringKey(scrib.content))
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(isDarkMode ? .white : .black)

                    Text(scrib.timestamp.timeAgoDisplay())
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(isDarkMode ? Color(red: 0.16, green: 0.16, blue: 0.16) : .white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(isDarkMode ? 0 : 0.05), radius: 8, x: 0, y: 2)
                .contextMenu {
                    Button(action: {
                        hapticFeedback()
                        showingEditSheet = true
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: {
                        hapticFeedback()
                        showingDeleteAlert = true
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .confirmationDialog("Delete Scrib", isPresented: $showingDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        viewModel.deleteScrib(id: scrib.id)
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Are you sure you want to delete this scrib?")
                }
            }
            .padding(.leading, 12)
            .padding(.trailing, 16)
            .padding(.bottom, 18)
        }
        .padding(.leading, 16)
        .sheet(isPresented: $showingEditSheet) {
            EditScribView(isDarkMode: isDarkMode, scrib: scrib, viewModel: viewModel)
        }
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

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
                            .foregroundColor(isDarkMode ? .gray : .gray)
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
                    Color(red: 0.16, green: 0.16, blue: 0.16) : 
                    Color.white
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
            .shadow(color: Color.black.opacity(isDarkMode ? 0 : 0.05), radius: 8, x: 0, y: 2)
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
    let isDarkMode: Bool
    @Binding var newScribText: String
    var onPost: () -> Void
    
    private var isPostButtonEnabled: Bool {
        !newScribText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(isDarkMode ? UIColor.systemBackground : .init(red: 0.96, green: 0.96, blue: 0.96, alpha: 1))
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
                            .background(isDarkMode ? Color(red: 0.16, green: 0.16, blue: 0.16) : .white)
                            .cornerRadius(16)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .shadow(color: Color.black.opacity(isDarkMode ? 0 : 0.05), radius: 8, x: 0, y: 2)
                        
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
                                        .fill(isDarkMode ? Color(red: 0.16, green: 0.16, blue: 0.16) : .white)
                                        .shadow(color: Color.black.opacity(isDarkMode ? 0 : 0.05), radius: 4, x: 0, y: 2)
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
                            .foregroundColor(isDarkMode ? .black : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(isDarkMode ? .white : .black)
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
            .toolbarColorScheme(isDarkMode ? .dark : .light, for: .navigationBar)
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

struct EditScribView: View {
    @Environment(\.dismiss) var dismiss
    let isDarkMode: Bool
    let scribId: UUID
    @State private var editedText: String
    @ObservedObject var viewModel: ScribViewModel
    
    init(isDarkMode: Bool, scrib: Scrib, viewModel: ScribViewModel) {
        self.isDarkMode = isDarkMode
        self.scribId = scrib.id
        self._editedText = State(initialValue: scrib.content)
        self.viewModel = viewModel
    }
    
    private var isUpdateButtonEnabled: Bool {
        !editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(isDarkMode ? UIColor.systemBackground : .init(red: 0.96, green: 0.96, blue: 0.96, alpha: 1))
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Text Editor Area
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $editedText)
                            .scrollContentBackground(.hidden)
                            .frame(maxHeight: .infinity)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 40)
                            .background(isDarkMode ? Color(red: 0.16, green: 0.16, blue: 0.16) : .white)
                            .cornerRadius(16)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .shadow(color: Color.black.opacity(isDarkMode ? 0 : 0.05), radius: 8, x: 0, y: 2)
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
                                        .fill(isDarkMode ? Color(red: 0.16, green: 0.16, blue: 0.16) : .white)
                                        .shadow(color: Color.black.opacity(isDarkMode ? 0 : 0.05), radius: 4, x: 0, y: 2)
                                )
                        }
                        
                        Button(action: {
                            if isUpdateButtonEnabled {
                                viewModel.editScrib(id: scribId, newContent: editedText)
                                dismiss()
                            }
                        }) {
                            HStack {
                                Text("Update")
                                Image(systemName: "checkmark.circle.fill")
                            }
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(isDarkMode ? .black : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(isDarkMode ? .white : .black)
                                    .opacity(isUpdateButtonEnabled ? 1.0 : 0.5)
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        .disabled(!isUpdateButtonEnabled)
                    }
                    .padding(.top, 16)
                }
                .padding(16)
            }
            .navigationTitle("Edit Scrib")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(isDarkMode ? .dark : .light, for: .navigationBar)
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

struct SearchView: View {
    @Environment(\.dismiss) var dismiss
    let isDarkMode: Bool
    @ObservedObject var viewModel: ScribViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(isDarkMode ? UIColor.systemBackground : .init(red: 0.96, green: 0.96, blue: 0.96, alpha: 1))
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search scribs...", text: $viewModel.searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        
                        if !viewModel.searchText.isEmpty {
                            Button(action: {
                                viewModel.searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(12)
                    .background(isDarkMode ? Color(red: 0.16, green: 0.16, blue: 0.16) : .white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top)
                    
                    if viewModel.searchText.isEmpty {
                        // Placeholder when no search
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("Search your scribs")
                                .font(.title3)
                                .foregroundColor(.gray)
                            Text("Type something to start searching")
                                .font(.subheadline)
                                .foregroundColor(.gray.opacity(0.8))
                        }
                        .frame(maxHeight: .infinity)
                    } else if viewModel.filteredScribs.isEmpty {
                        // No results found
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("No results found")
                                .font(.title3)
                                .foregroundColor(.gray)
                            Text("Try searching with different keywords")
                                .font(.subheadline)
                                .foregroundColor(.gray.opacity(0.8))
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        // Results List
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.filteredScribs) { scrib in
                                    VStack(alignment: .leading, spacing: 8) {
                                        if let metadata = scrib.linkMetadata {
                                            LinkPreviewView(metadata: metadata, isDarkMode: isDarkMode)
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
                                                .foregroundColor(isDarkMode ? .white : .black)
                                        }
                                        
                                        Text(scrib.timestamp.timeAgoDisplay())
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(isDarkMode ? Color(red: 0.16, green: 0.16, blue: 0.16) : .white)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(isDarkMode ? 0 : 0.05), radius: 8, x: 0, y: 2)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
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
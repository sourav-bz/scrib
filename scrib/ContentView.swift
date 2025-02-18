import SwiftUI

struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    private var appSettings: AppSettings = .init()
    private let title: String = "Scrib"
    
    var body: some View {
        GeometryReader { outer in
            NavigationStack {
                ListView(
                    title: title,
                    outer: outer,
                    appSettings: appSettings,
                    isDarkMode: isDarkMode,
                    toggleDarkMode: { isDarkMode.toggle() }
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
                            appSettings: appSettings
                        )
                        .background(isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.1) : Color.white)
                    }
                }
                .toolbarBackground(isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.1) : Color.white, for: .navigationBar)
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
    @StateObject private var viewModel = ScribViewModel()
    
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
                            isDarkMode: isDarkMode
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
    
    var body: some View {
        HStack(spacing: 8) {
            // Search button
            Button {
                // Search action
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18))
                    .foregroundColor(isDarkMode ? .white : .black)
                    .padding(4)
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

    let appSettings: AppSettings
    
    var body: some View {
        HStack(spacing: 8) {
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(isDarkMode ? Color(red: 0.16, green: 0.16, blue: 0.16) : .white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(isDarkMode ? 0 : 0.05), radius: 8, x: 0, y: 2)
            }
            .padding(.leading, 12)
            .padding(.trailing, 16)
            .padding(.bottom, 18)
        }
        .padding(.leading, 16)
    }
}
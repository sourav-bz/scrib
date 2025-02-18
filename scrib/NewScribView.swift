import SwiftUI
import LinkPresentation

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
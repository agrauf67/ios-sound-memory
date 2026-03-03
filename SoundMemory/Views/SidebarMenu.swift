import SwiftUI

struct SidebarMenu: View {
    @Binding var selectedScreen: Screen
    @Binding var isShowing: Bool
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack(alignment: .leading) {
            // Dimmed background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isShowing = false
                    }
                }

            // Drawer content
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    Text("Sound Memory")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                        .padding(.bottom, 16)

                    Divider()
                        .padding(.bottom, 8)

                    // Menu items
                    ForEach(Screen.drawerItems) { screen in
                        Button {
                            selectedScreen = screen
                            withAnimation(.easeInOut(duration: 0.25)) {
                                isShowing = false
                            }
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: screen.icon)
                                    .frame(width: 24)
                                Text(screen.rawValue)
                                    .font(.body)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                selectedScreen == screen
                                    ? AppTheme.primary(for: colorScheme).opacity(0.12)
                                    : Color.clear
                            )
                            .cornerRadius(12)
                            .padding(.horizontal, 12)
                        }
                        .foregroundStyle(
                            selectedScreen == screen
                                ? AppTheme.primary(for: colorScheme)
                                : AppTheme.onSurface(for: colorScheme)
                        )
                    }

                    Spacer()
                }
                .frame(width: 280)
                .background(AppTheme.surface(for: colorScheme))

                Spacer()
            }
        }
        .transition(.move(edge: .leading))
    }
}

import SwiftUI

struct StatsScreen: View {
    @Binding var showSidebar: Bool

    var body: some View {
        VStack {
            Spacer()
            Text("Game Statistics")
                .font(.title)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showSidebar = true
                    }
                } label: {
                    Image(systemName: "line.3.horizontal")
                }
            }
        }
    }
}

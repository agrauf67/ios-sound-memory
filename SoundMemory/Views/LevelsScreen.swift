import SwiftUI

struct LevelsScreen: View {
    @Binding var showSidebar: Bool

    var body: some View {
        VStack {
            Spacer()
            Text("Level Selection")
                .font(.title)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Select Level")
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

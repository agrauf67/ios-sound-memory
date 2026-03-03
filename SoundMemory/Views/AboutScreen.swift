import SwiftUI

struct AboutScreen: View {
    var onBack: () -> Void

    var body: some View {
        VStack {
            Spacer()
            Text("Sound Memory")
                .font(.title)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    onBack()
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }
}

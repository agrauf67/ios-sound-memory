import SwiftUI

private let backImage = "0000"

struct MemoryCardView: View {
    let card: MemoryCard
    let onTap: () -> Void

    var body: some View {
        let displayImage = (card.isFlipped || card.isMatched) ? card.imageFileName : backImage

        Button(action: onTap) {
            if let uiImage = loadImage(named: displayImage) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .overlay(Text("?").font(.title))
            }
        }
        .buttonStyle(.plain)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }

    private func loadImage(named name: String) -> UIImage? {
        if let path = Bundle.main.path(forResource: name, ofType: "jpg", inDirectory: "Images") {
            return UIImage(contentsOfFile: path)
        }
        return nil
    }
}

import SwiftUI

struct PlayScreen: View {
    @EnvironmentObject var viewModel: SoundMemoryViewModel
    @Binding var showSidebar: Bool

    private let columns = 4
    private let rows = 6

    var body: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 6
            let padding: CGFloat = 8
            let availableWidth = geometry.size.width - padding * 2 - spacing * CGFloat(columns - 1)
            let availableHeight = geometry.size.height - padding * 2 - spacing * CGFloat(rows - 1)
            let cardWidth = availableWidth / CGFloat(columns)
            let cardHeight = availableHeight / CGFloat(rows)

            VStack(spacing: spacing) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<columns, id: \.self) { col in
                            let index = row * columns + col
                            if index < viewModel.cards.count {
                                MemoryCardView(
                                    card: viewModel.cards[index],
                                    onTap: {
                                        viewModel.onCardClicked(cardId: viewModel.cards[index].id)
                                    }
                                )
                                .frame(width: cardWidth, height: cardHeight)
                            }
                        }
                    }
                }
            }
            .padding(padding)
        }
        .navigationTitle("Sound Memory")
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

import SwiftUI
import StoreKit

struct StoreScreen: View {
    let storeManager: StoreManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.yellow)

                    Text("Unlock Games")
                        .font(.title2.bold())

                    Text("Buy game packs to unlock new game sets. Use your credits to choose which games to unlock.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
                .padding(.top, 16)

                creditsCard

                if storeManager.products.isEmpty && !storeManager.productsLoaded {
                    ProgressView()
                        .padding(32)
                } else if storeManager.products.isEmpty {
                    Text("Products are currently unavailable. Please try again later.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(32)
                } else {
                    VStack(spacing: 12) {
                        ForEach(storeManager.products, id: \.id) { product in
                            PackCard(product: product, storeManager: storeManager)
                        }
                    }
                }

                Button("Restore Purchases") {
                    Task {
                        await storeManager.restorePurchases()
                    }
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 8)

                Spacer().frame(height: 16)
            }
            .padding(16)
        }
        .navigationTitle("Store")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
        .task {
            await storeManager.loadProducts()
        }
    }

    private var creditsCard: some View {
        HStack {
            Image(systemName: "creditcard.fill")
                .font(.title2)
                .foregroundStyle(.tint)
            VStack(alignment: .leading) {
                Text("Available Credits")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(storeManager.unlockCredits)")
                    .font(.title.bold())
            }
            Spacer()
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct PackCard: View {
    let product: Product
    let storeManager: StoreManager

    var body: some View {
        let credits = storeManager.creditsForProduct(product)
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(packTitle(credits))
                    .font(.headline)
                Text(packDescription(credits))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                Task {
                    await storeManager.purchase(product)
                }
            } label: {
                Text(product.displayPrice)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .disabled(storeManager.purchaseInProgress)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func packTitle(_ credits: Int) -> LocalizedStringKey {
        switch credits {
        case 1: return "1 Game"
        case 2: return "2 Games"
        case 3: return "3 Games"
        case 5: return "5 Games"
        default: return "\(credits) Games"
        }
    }

    private func packDescription(_ credits: Int) -> LocalizedStringKey {
        switch credits {
        case 1: return "Unlock 1 game of your choice"
        case 2: return "Unlock 2 games of your choice"
        case 3: return "Unlock 3 games of your choice"
        case 5: return "Unlock 5 games of your choice"
        default: return "Unlock \(credits) games of your choice"
        }
    }
}

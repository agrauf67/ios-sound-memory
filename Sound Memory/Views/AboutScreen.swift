import SwiftUI

struct AboutScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image("AppIcon")
                    .resizable()
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.secondary.opacity(0.3), lineWidth: 1)
                    )

                VStack(spacing: 4) {
                    Text("Sound Memory")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Version 1.0")
                        .foregroundStyle(.secondary)
                }

                Divider()

                Text("A memory card game where you match pairs by listening to sounds instead of looking at pictures. Train your memory and learn new words in German, English, French, and Spanish!")
                    .multilineTextAlignment(.center)

                Divider()

                VStack(spacing: 8) {
                    InfoRow(label: "Developer", value: "Andreas Grauf")
                    InfoRow(label: "Contact", value: "agrauf67@gmail.com")
                }

                Divider()

                VStack(spacing: 8) {
                    LinkButton(title: "Website", urlString: "https://djvlk.de/soundmemory")

                    let langSuffix: String = {
                        let lang = Locale.current.language.languageCode?.identifier ?? "en"
                        return ["de", "fr", "es"].contains(lang) ? lang : "en"
                    }()
                    LinkButton(title: "Privacy Policy",
                               urlString: "https://djvlk.de/soundmemory/privacy_policy_\(langSuffix).html")
                    LinkButton(title: "Terms of Service",
                               urlString: "https://djvlk.de/soundmemory/terms_of_service_\(langSuffix).html")
                }

                Divider()

                Text("Made with Swift & SwiftUI")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(24)
        }
        .navigationTitle("About")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
    }
}

private struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .fontWeight(.bold)
        }
    }
}

private struct LinkButton: View {
    let title: String
    let urlString: String

    var body: some View {
        Button {
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        } label: {
            Text(title)
                .foregroundStyle(.tint)
        }
    }
}

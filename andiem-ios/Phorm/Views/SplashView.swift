import SwiftUI

/// Brief launch flourish — gold seal + Ấn Điểm wordmark on cinnabar lacquer.
/// Lives between the static iOS launch screen and HomeView on cold start.
/// Total visible time ~0.9s; tap anywhere to skip.
///
/// Static `UILaunchScreen` is already flat cinnabar (`LaunchBackground.colorset`),
/// so the system→splash→home transition reads as one continuous surface deepening
/// then revealing the seal.
struct SplashView: View {
    @Binding var isVisible: Bool

    @State private var sealVisible = false
    @State private var wordmarkVisible = false
    @State private var captionVisible = false

    var body: some View {
        ZStack {
            LacquerBackground()
                .ignoresSafeArea()

            VStack(spacing: Spacing.lg) {
                Image("BrandMark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .opacity(sealVisible ? 1 : 0)
                    .scaleEffect(sealVisible ? 1 : 0.86)

                VStack(spacing: 6) {
                    Text("Ấn Điểm")
                        .font(.system(size: 52, weight: .bold, design: .serif).italic())
                        .foregroundStyle(Color.phormCream)
                        .opacity(wordmarkVisible ? 1 : 0)
                        .offset(y: wordmarkVisible ? 0 : 6)

                    SectionLabel(text: "Sổ ghi điểm", tone: .gold)
                        .opacity(captionVisible ? 1 : 0)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { dismiss() }
        .onAppear {
            withAnimation(.easeOut(duration: 0.32)) { sealVisible = true }
            withAnimation(.easeOut(duration: 0.28).delay(0.12)) { wordmarkVisible = true }
            withAnimation(.easeOut(duration: 0.24).delay(0.22)) { captionVisible = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.90) { dismiss() }
        }
    }

    private func dismiss() {
        guard isVisible else { return }
        withAnimation(.easeIn(duration: 0.30)) { isVisible = false }
    }
}

#Preview {
    SplashView(isVisible: .constant(true))
}

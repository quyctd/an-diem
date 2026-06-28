import SwiftUI

struct EmptyHomeView: View {
    @State private var showNewSession = false
    @State private var showHistory = false

    /// Top gap as a fraction of usable screen height — pulls the seal +
    /// headline block up to the natural eye-line when the host is holding
    /// the phone. 0.28 ≈ upper third on every iPhone size.
    private let topOffsetRatio: CGFloat = 0.28

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                VStack(spacing: Spacing.xl) {
                    Spacer()
                        .frame(height: geo.size.height * topOffsetRatio)

                    VStack(spacing: Spacing.lg) {
                        Image("BrandMark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 132, height: 132)

                        VStack(spacing: 6) {
                            SectionLabel(text: "Sổ ghi điểm")
                            Text("Ấn Điểm")
                                .font(.system(size: 36, weight: .bold, design: .serif).italic())
                                .foregroundStyle(Color.phormCream)
                                .multilineTextAlignment(.center)
                            Text("Ghi điểm cho bàn phỏm, tá lả, sâm lốc. Mở là chơi — cuối bàn rõ ai ăn ai thua, không cần nhẩm, không ai cãi.")
                                .font(.phormBodyMd)
                                .foregroundStyle(Color.phormCream.opacity(0.65))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, Spacing.lg)
                                .padding(.top, Spacing.xs)
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, Spacing.xl)

                VStack(spacing: Spacing.sm) {
                    LacquerPrimaryButton(title: "Mở phiên mới") {
                        showNewSession = true
                    }
                    LacquerOutlineButton(title: "Lịch sử") {
                        showHistory = true
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.md)
            }
        }
        .lacquerBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationTitle("")
        .sheet(isPresented: $showNewSession) {
            NewSessionView()
                .preferredColorScheme(.dark)
        }
        .navigationDestination(isPresented: $showHistory) {
            HistoryView()
        }
        #if DEBUG
        .onAppear {
            if ScreenshotSupport.openTarget == .newSession { showNewSession = true }
        }
        #endif
    }
}

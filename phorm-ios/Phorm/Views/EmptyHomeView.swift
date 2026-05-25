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
                        Seal(glyph: "壹", variant: .winner, size: 80)
                            .shadow(color: .black.opacity(0.3), radius: 8, y: 4)

                        VStack(spacing: 6) {
                            SectionLabel(text: "Sổ ghi điểm")
                            Text("Bắt đầu phiên đầu")
                                .font(.phormDisplayMd)
                                .italic()
                                .foregroundStyle(Color.phormCream)
                                .multilineTextAlignment(.center)
                            Text("phỏm, sâm lốc — sổ thay trí nhớ, mỗi vòng một dấu vàng, không ai cãi được.")
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
    }
}

import SwiftUI

struct EmptyHomeView: View {
    @State private var showNewSession = false
    @State private var showHistory = false

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: Spacing.xl) {
                Spacer()

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
                        Text("phỏm, sâm lốc, hay bất cứ ván nào — app chỉ ghi điểm, không phân định luật.")
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

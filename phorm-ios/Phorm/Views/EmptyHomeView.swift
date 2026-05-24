import SwiftUI

struct EmptyHomeView: View {
    @State private var showNewSession = false

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.system(size: 64))
                .foregroundStyle(Color.phormMuted)
            Text("Chưa có ván nào")
                .font(.phormTitleLg)
                .foregroundStyle(Color.bodyText)
            Text("Tạo session mới để bắt đầu ghi điểm")
                .font(.phormBodyMd)
                .foregroundStyle(Color.phormMuted)
                .multilineTextAlignment(.center)
            Spacer()
            Button {
                showNewSession = true
            } label: {
                Text("+ Tạo session mới")
                    .font(.phormButton)
                    .foregroundStyle(Color.onPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.phormPrimary)
                    .continuousRounded(Radius.lg)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xl)
        }
        .padding(.horizontal, Spacing.xl)
        .background(Color.canvas)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    HistoryView()
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundStyle(Color.phormPrimary)
                }
            }
        }
        .sheet(isPresented: $showNewSession) {
            NewSessionView()
        }
    }
}

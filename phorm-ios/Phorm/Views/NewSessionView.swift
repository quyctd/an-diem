import SwiftUI
import SwiftData

struct NewSessionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var sessionName: String = Self.defaultName()
    @State private var players: [String] = []
    @State private var nameInput: String = ""

    @Query(sort: [SortDescriptor(\Session.createdAt, order: .reverse)])
    private var allSessions: [Session]

    /// Distinct player names across history, ordered by recency of last appearance.
    private var distinctPlayerNames: [String] {
        var seen = Set<String>(), result: [String] = []
        for s in allSessions {
            for name in s.playerNames where !seen.contains(name) {
                seen.insert(name); result.append(name)
            }
        }
        return result
    }

    private var lastGroup: Session? {
        allSessions.first(where: { !$0.playerNames.isEmpty })
    }

    private var autosuggestMatches: [String] {
        let q = nameInput.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return [] }
        return distinctPlayerNames
            .filter { $0.lowercased().contains(q) && !players.contains($0) }
            .prefix(5)
            .map { $0 }
    }

    private static func defaultName() -> String {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy HH:mm"
        return f.string(from: .now)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    if let group = lastGroup, players.isEmpty {
                        reuseCard(group)
                    }
                    sectionLabel("TÊN SESSION")
                    TextField("", text: $sessionName)
                        .font(.phormTitleSm)
                        .foregroundStyle(Color.bodyText)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .frame(height: 50)
                        .background(Color.surfaceElevated)
                        .continuousRounded(Radius.md)

                    sectionLabel("NGƯỜI CHƠI")
                    chipFlow
                    addPlayerField
                }
                .padding(Spacing.lg)
            }
            .navigationTitle("Session mới")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Hủy") { dismiss() }
                        .foregroundStyle(Color.phormPrimary)
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    create()
                } label: {
                    Text("Bắt đầu →")
                        .font(.phormButton)
                        .foregroundStyle(Color.onPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(players.count >= 2 ? Color.phormPrimary : Color.phormPrimaryDisabled)
                        .continuousRounded(Radius.lg)
                }
                .disabled(players.count < 2)
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.sm)
            }
        }
    }

    @ViewBuilder private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.phormCaptionSection)
            .tracking(0.6)
            .textCase(.uppercase)
            .foregroundStyle(Color.phormMuted)
    }

    @ViewBuilder private func reuseCard(_ group: Session) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Nhóm vừa rồi")
                    .font(.phormCaptionSection)
                    .tracking(0.6).textCase(.uppercase)
                    .foregroundStyle(Color.phormMuted)
                Text(group.playerNames.joined(separator: " · "))
                    .font(.phormTitleSm)
                    .foregroundStyle(Color.bodyText)
            }
            Spacer()
            Button {
                players = group.playerNames
            } label: {
                Text("Dùng lại")
                    .font(.phormCaption)
                    .foregroundStyle(Color.onPrimary)
                    .padding(.horizontal, Spacing.sm + 2)
                    .padding(.vertical, 6)
                    .background(Color.phormPrimary)
                    .continuousRounded(Radius.pill)
            }
        }
        .padding(Spacing.md)
        .background(.regularMaterial)
        .continuousRounded(Radius.lg)
    }

    private var chipFlow: some View {
        FlowLayout(spacing: Spacing.xs) {
            ForEach(Array(players.enumerated()), id: \.offset) { idx, name in
                HStack(spacing: Spacing.xs) {
                    Text(name).font(.phormBodyMd).foregroundStyle(Color.bodyText)
                    Button {
                        players.remove(at: idx)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.phormMuted)
                    }
                }
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, 6)
                .background(Color.surfaceElevated)
                .continuousRounded(Radius.pill)
            }
        }
    }

    private var addPlayerField: some View {
        VStack(spacing: Spacing.xs) {
            HStack {
                TextField("+ Thêm người…", text: $nameInput)
                    .font(.phormBodyMd)
                    .submitLabel(.done)
                    .onSubmit { commitPlayer() }
                if !nameInput.trimmingCharacters(in: .whitespaces).isEmpty {
                    Button("Thêm") { commitPlayer() }
                        .foregroundStyle(Color.phormPrimary)
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, 10)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .strokeBorder(Color.hairline, style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
            )

            if !autosuggestMatches.isEmpty {
                VStack(spacing: 0) {
                    ForEach(autosuggestMatches, id: \.self) { name in
                        Button {
                            players.append(name); nameInput = ""
                        } label: {
                            HStack {
                                Text(name)
                                    .font(.phormBodyMd)
                                    .foregroundStyle(Color.bodyText)
                                Spacer()
                            }
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.sm)
                        }
                        if name != autosuggestMatches.last { Divider().background(Color.hairline) }
                    }
                }
                .background(.regularMaterial)
                .continuousRounded(Radius.md)
            }
        }
    }

    private func commitPlayer() {
        let trimmed = nameInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !players.contains(trimmed) else { return }
        players.append(trimmed)
        nameInput = ""
    }

    private func create() {
        do {
            _ = try SessionActions.createSession(
                name: sessionName.trimmingCharacters(in: .whitespaces),
                playerNames: players,
                in: context
            )
            dismiss()
        } catch {
            print("createSession failed: \(error)")
        }
    }
}

// MARK: - FlowLayout (chips wrap to next line)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            sub.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

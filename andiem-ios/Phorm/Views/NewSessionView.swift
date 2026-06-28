import SwiftUI
import SwiftData

struct NewSessionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var sessionName: String = Self.defaultName()
    @State private var players: [String] = []
    @State private var nameInput: String = ""
    @FocusState private var nameInputFocused: Bool

    @Query(sort: [SortDescriptor(\Session.createdAt, order: .reverse)])
    private var allSessions: [Session]

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

    /// Autosuggest only when the user is typing a single token. As soon as a
    /// space appears (i.e., they're entering multiple names at once), step out
    /// of the way — the "Thêm N" pill is the better affordance there.
    private var autosuggestMatches: [String] {
        let trimmed = nameInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty,
              !trimmed.contains(where: { $0.isWhitespace }) else { return [] }
        let q = trimmed.lowercased()
        return distinctPlayerNames
            .filter { $0.lowercased().contains(q) && !players.contains($0) }
            .prefix(5)
            .map { $0 }
    }

    private static func defaultName() -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "vi_VN")
        // vi_VN locale renders EEEE as "Thứ Sáu" / "Chủ Nhật" already — no
        // .capitalized; that would title-case "tối" too, which is wrong in Vietnamese.
        f.dateFormat = "EEEE 'tối' dd/MM"
        return f.string(from: .now)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerStrip
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.lg)

                    RuleHairline()
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.md)

                    sessionNameBlock
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.xl)

                    if let group = lastGroup, players.isEmpty {
                        reuseBlock(group)
                            .padding(.horizontal, Spacing.lg)
                            .padding(.top, Spacing.lg)
                    }

                    playersBlock
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.xl)

                    Spacer().frame(height: 140) // CTA clearance
                }
            }
            .scrollIndicators(.hidden)

            cta
        }
        .appBackground()
        .presentationBackground(Color.phormSurfaceCinnabar)
        .presentationDragIndicator(.visible)
    }

    // MARK: - Header

    private var headerStrip: some View {
        HStack(alignment: .top) {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.phormCreamDim)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Color.black.opacity(0.18)))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                SectionLabel(text: "Khai phiên")
                Text("Mở phiên mới")
                    .font(.phormTitleLg)
                    .foregroundStyle(Color.phormCream)
            }
        }
    }

    // MARK: - Session name

    private var sessionNameBlock: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionLabel(text: "Tên phiên")
            TextField("", text: $sessionName)
                .font(.phormNameDisplay)
                .foregroundStyle(Color.phormCream)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(Color.black.opacity(0.18))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .stroke(Color.phormCream.opacity(0.30), lineWidth: 1)
                )
        }
    }

    // MARK: - Reuse last group

    @ViewBuilder
    private func reuseBlock(_ group: Session) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                SectionLabel(text: "Nhóm vừa rồi")
                Text(group.playerNames.joined(separator: " · "))
                    .font(.phormNameMd)
                    .foregroundStyle(Color.phormCream)
                    .lineLimit(2)
            }
            Spacer(minLength: Spacing.sm)
            Button {
                players = group.playerNames
            } label: {
                Text("Dùng lại")
                    .font(.phormCaptionSection)
                    .tracking(1.6)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.onPrimary)
                    .padding(.horizontal, Spacing.sm + 2)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(Color.phormPrimary)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Color.black.opacity(0.18))
        .overlay(
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .stroke(Color.phormCream.opacity(0.18), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
    }

    // MARK: - Players block

    private var playersBlock: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(alignment: .firstTextBaseline) {
                SectionLabel(text: "Người chơi")
                Spacer()
                Text("\(players.count)")
                    .font(.phormNumberSm)
                    .foregroundStyle(Color.phormCream)
            }

            if !players.isEmpty {
                FlowLayout(spacing: Spacing.xs) {
                    ForEach(Array(players.enumerated()), id: \.offset) { idx, name in
                        playerChip(name: name, index: idx)
                    }
                }
            }

            addPlayerField

            if !autosuggestMatches.isEmpty {
                autosuggestList
            }
        }
    }

    @ViewBuilder
    private func playerChip(name: String, index: Int) -> some View {
        HStack(spacing: Spacing.xs) {
            Text(name)
                .font(.phormNameMd)
                .foregroundStyle(Color.phormCream)
            Button {
                players.remove(at: index)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.phormCreamDim)
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, 6)
        .background(Color.phormPrimary.opacity(0.10))
        .overlay(
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .stroke(Color.phormPrimary.opacity(0.55), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
    }

    private var addPlayerField: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: Spacing.xs) {
                Text("+")
                    .font(.phormNameDisplay)
                    .foregroundStyle(Color.phormPrimary)
                TextField("Nam Hà \"Anh Tuấn\" Mai…", text: $nameInput, onCommit: commitPlayers)
                    .font(.phormNameMd)
                    .foregroundStyle(Color.phormCream)
                    .focused($nameInputFocused)
                    .submitLabel(.done)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                if pendingTokenCount > 0 {
                    Button(action: commitPlayers) {
                        Text("Thêm \(pendingTokenCount)")
                            .font(.phormCaptionSection)
                            .tracking(1.6)
                            .textCase(.uppercase)
                            .foregroundStyle(Color.phormPrimary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(Color.black.opacity(0.18))
            .overlay(
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .stroke(
                        nameInputFocused ? Color.phormPrimary : Color.phormCream.opacity(0.30),
                        style: StrokeStyle(lineWidth: nameInputFocused ? 1.5 : 1, dash: nameInputFocused ? [] : [4, 3])
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))

            Text("Cách nhau bằng dấu cách · dùng \"…\" cho tên dài hai từ")
                .font(.phormCaptionSection)
                .tracking(1.4)
                .textCase(.uppercase)
                .foregroundStyle(Color.phormCreamDim.opacity(0.7))
                .padding(.leading, 2)
        }
    }

    /// Tokens in `nameInput` that aren't already in `players` — drives the "Thêm N" affordance.
    private var pendingTokenCount: Int {
        parseTokens(nameInput).count
    }

    /// Split on whitespace + commas, but keep `"…"` (straight or curly) as one token.
    /// Trim, dedupe against current roster + each other, preserve order.
    private func parseTokens(_ input: String) -> [String] {
        let quoteChars: Set<Character> = ["\"", "\u{201C}", "\u{201D}"] // " " "
        let separators: Set<Character> = [" ", "\t", "\n", ","]

        var raw: [String] = []
        var current = ""
        var inQuotes = false
        for ch in input {
            if quoteChars.contains(ch) {
                inQuotes.toggle()
                continue
            }
            if !inQuotes, separators.contains(ch) {
                if !current.isEmpty { raw.append(current); current = "" }
                continue
            }
            current.append(ch)
        }
        if !current.isEmpty { raw.append(current) }

        var seen = Set(players.map { $0.lowercased() })
        var out: [String] = []
        for token in raw {
            let trimmed = token.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            let key = trimmed.lowercased()
            guard !seen.contains(key) else { continue }
            seen.insert(key)
            out.append(trimmed)
        }
        return out
    }

    private var autosuggestList: some View {
        VStack(spacing: 0) {
            ForEach(autosuggestMatches, id: \.self) { name in
                Button {
                    players.append(name); nameInput = ""
                } label: {
                    HStack {
                        Text(name)
                            .font(.phormNameMd)
                            .foregroundStyle(Color.phormCream)
                        Spacer()
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.phormPrimary)
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    // Spacer is transparent — without contentShape the dead
                    // middle of the row swallows taps between name and plus.
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                if name != autosuggestMatches.last {
                    Rectangle()
                        .fill(Color.phormCream.opacity(0.12))
                        .frame(height: 1)
                }
            }
        }
        .background(Color.black.opacity(0.18))
        .overlay(
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .stroke(Color.phormCream.opacity(0.18), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))
    }

    // MARK: - CTA

    private var cta: some View {
        VStack(spacing: Spacing.xs) {
            TactilePrimaryButton(
                title: players.count >= 2 ? "Bắt đầu — \(players.count) người" : "Cần ít nhất 2 người",
                enabled: players.count >= 2,
                action: create
            )
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.sm)
        .background(
            LinearGradient(
                colors: [.clear, .phormSurfaceCinnabarDeep.opacity(0.55), .phormSurfaceCinnabarDeep.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 120)
            .allowsHitTesting(false),
            alignment: .bottom
        )
    }

    /// Append every fresh whitespace-separated token in `nameInput`.
    /// Pre-existing roster names (case-insensitive) are silently dropped.
    private func commitPlayers() {
        let tokens = parseTokens(nameInput)
        guard !tokens.isEmpty else { return }
        players.append(contentsOf: tokens)
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

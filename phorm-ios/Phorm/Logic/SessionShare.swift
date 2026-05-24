import Foundation

// MARK: - Wire-format DTOs

struct SessionDTO: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let createdAt: Date
    let players: [String]
    let rounds: [RoundDTO]

    struct RoundDTO: Codable, Equatable {
        let index: Int
        let createdAt: Date
        let scores: [String: Int]   // playerName → value
    }
}

extension SessionDTO {
    /// Lossy snapshot of a `Session` for URL handoff. `archivedAt` is intentionally
    /// dropped — the receiver decides activation locally.
    init(from session: Session) {
        self.id = session.id
        self.name = session.name
        self.createdAt = session.createdAt
        self.players = session.playerNames
        self.rounds = (session.rounds ?? [])
            .sorted { $0.index < $1.index }
            .map { round in
                let scores = Dictionary(
                    uniqueKeysWithValues: (round.scores ?? []).map { ($0.playerName, $0.value) }
                )
                return RoundDTO(index: round.index, createdAt: round.createdAt, scores: scores)
            }
    }
}

// MARK: - URL encode/decode

enum SessionShare {
    enum ShareError: Error {
        case invalidURL
        case invalidPayload
    }

    /// `Session` → `SessionDTO` → JSON → zlib → base64url → `phorm://import?s=<…>`
    static func url(for session: Session) throws -> URL {
        let dto = SessionDTO(from: session)
        let json = try JSONEncoder().encode(dto)
        let zlib = try (json as NSData).compressed(using: .zlib) as Data
        let b64url = zlib.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")

        var c = URLComponents()
        c.scheme = "phorm"
        c.host = "import"
        c.queryItems = [URLQueryItem(name: "s", value: b64url)]
        guard let url = c.url else { throw ShareError.invalidPayload }
        return url
    }

    /// Reverse of `url(for:)`. Throws `ShareError.invalidURL` for bad scheme/host/query
    /// or `ShareError.invalidPayload` for malformed base64/zlib/JSON.
    static func decode(_ url: URL) throws -> SessionDTO {
        guard url.scheme == "phorm", url.host == "import" else {
            throw ShareError.invalidURL
        }
        guard let raw = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "s" })?.value,
              !raw.isEmpty else {
            throw ShareError.invalidURL
        }

        // base64url → base64 (re-pad)
        var b64 = raw
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let pad = (4 - b64.count % 4) % 4
        b64.append(String(repeating: "=", count: pad))

        guard let zlib = Data(base64Encoded: b64) else {
            throw ShareError.invalidPayload
        }
        do {
            let json = try (zlib as NSData).decompressed(using: .zlib) as Data
            return try JSONDecoder().decode(SessionDTO.self, from: json)
        } catch {
            throw ShareError.invalidPayload
        }
    }
}

import Testing
@testable import Phorm

@Suite("Sanity")
struct SanityTests {
    @Test func canImportAppModule() {
        #expect(Bool(true))
    }
}

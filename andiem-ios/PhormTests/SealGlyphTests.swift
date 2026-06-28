import Testing
@testable import Phorm

@Suite("SealGlyph")
struct SealGlyphTests {
    @Test func ranksRenderAsArabic() {
        #expect(SealGlyph.forRank(1) == "1")
        #expect(SealGlyph.forRank(8) == "8")
        #expect(SealGlyph.forRank(12) == "12")
    }
    @Test func nonPositiveIsEmpty() {
        #expect(SealGlyph.forRank(0) == "")
        #expect(SealGlyph.forRank(-3) == "")
    }
}

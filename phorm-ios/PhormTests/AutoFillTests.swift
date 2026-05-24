import Testing
@testable import Phorm

@Suite("AutoFill")
struct AutoFillTests {
    @Test func returnsNilWhenAllEmpty() {
        #expect(AutoFill.suggestion(for: [nil, nil, nil, nil]) == nil)
    }

    @Test func returnsNilWhenOnlyOneFilled() {
        #expect(AutoFill.suggestion(for: [5, nil, nil, nil]) == nil)
    }

    @Test func suggestsNegativeSumWhenAllButOneFilled() {
        #expect(AutoFill.suggestion(for: [1, 2, 3, nil]) == -6)
    }

    @Test func returnsNilWhenAllFilled() {
        #expect(AutoFill.suggestion(for: [1, 2, 3, -6]) == nil)
    }

    @Test func handlesNegativesAndZeros() {
        #expect(AutoFill.suggestion(for: [-3, 0, 5, nil]) == -2)
    }

    @Test func suggestsZeroWhenFilledAlreadyBalance() {
        #expect(AutoFill.suggestion(for: [1, -1, nil]) == 0)
    }
}

import Testing
@testable import IPCalculator

struct IPAddressValidatorTests {

    private let validator = IPAddressValidator()

    @Test(arguments: ["0.0.0.0", "192.168.1.10", "255.255.255.255"])
    func acceptsPlainAddress(_ input: String) throws {
        let components = try #require(validator.cidrComponents(from: input))

        #expect(components.address == input)
        #expect(components.prefix == nil)
        #expect(validator.isValidFinalIP(input))
    }

    @Test(arguments: [0, 1, 24, 32])
    func acceptsCIDRSuffix(prefix: Int) throws {
        let components = try #require(validator.cidrComponents(from: "192.168.1.10/\(prefix)"))

        #expect(components.address == "192.168.1.10")
        #expect(components.prefix == prefix)
    }

    @Test(arguments: [
        "", "1.2.3", "1.2.3.4.5", "256.1.1.1", "01.2.3.4", ".1.2.3.4", "1.2.3.4.", "1..2.3", "a.b.c.d",
        "10.0.0.0/", "10.0.0.0/33", "10.0.0.0/-1", "10.0.0.0/ab", "10.0.0.0/2/4"
    ])
    func rejectsInvalidFinalInput(_ input: String) {
        #expect(validator.cidrComponents(from: input)?.address == nil)
        #expect(!validator.isValidFinalIP(input))
    }

    @Test(arguments: [
        "", "1", "192", "192.", "192.168", "192.168.1.", "192.168.1.10",
        "192.168.1.10/", "192.168.1.10/2", "192.168.1.10/32"
    ])
    func acceptsInputWhileTyping(_ input: String) {
        #expect(validator.isValidIntermediateInput(input))
    }

    @Test(arguments: [
        "256", "01", "a", ".1", "1..2", "1.2.3.4.", "1.2.3.4.5",
        "192.168.1.10/33", "192.168.1.10/100", "192.168.1.10/2/4"
    ])
    func rejectsInputWhileTyping(_ input: String) {
        #expect(!validator.isValidIntermediateInput(input))
    }
}

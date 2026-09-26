import Testing
@testable import IPCalculator

struct SubnetSplitServiceTests {

    private let formatter = IPAddressFormatter()
    private let service = SubnetSplitService(
        calculator: IPCalculationService(classDetector: NetworkClassService())
    )

    // MARK: - Equal parts

    @Test func splitsIntoEqualSubnetsInOrder() throws {
        let subnets = try split("192.168.1.0", prefix: 24, into: 26)

        #expect(subnets.map { formatter.string(from: $0.network) } == ["192.168.1.0", "192.168.1.64", "192.168.1.128", "192.168.1.192"])
        #expect(subnets.map { formatter.string(from: $0.broadcast) } == ["192.168.1.63", "192.168.1.127", "192.168.1.191", "192.168.1.255"])
        #expect(subnets.allSatisfy { $0.prefix == 26 && $0.hostCount == 62 })
        #expect(formatter.string(from: subnets[1].usableHostMin) == "192.168.1.65")
        #expect(formatter.string(from: subnets[1].usableHostMax) == "192.168.1.126")
    }

    @Test func prefixLongerByOneGivesTwoSubnetsFromNetworkAddress() throws {
        let subnets = try split("192.168.1.77", prefix: 24, into: 25)

        #expect(subnets.map { formatter.string(from: $0.network) } == ["192.168.1.0", "192.168.1.128"])
    }

    @Test func splitsSlash31IntoTwoHostRoutes() throws {
        let subnets = try split("10.0.0.0", prefix: 31, into: 32)

        #expect(subnets.map { formatter.string(from: $0.network) } == ["10.0.0.0", "10.0.0.1"])
        #expect(subnets.allSatisfy { $0.hostCount == 1 })
    }

    @Test(arguments: [(32, 32), (24, 24), (24, 23), (0, 0)])
    func rejectsPrefixThatIsNotLonger(prefix: Int, newPrefix: Int) {
        #expect(throws: SubnetSplitError.invalidPrefix) {
            try split("10.0.0.0", prefix: prefix, into: newPrefix)
        }
    }

    @Test func splitsLastNetworkWithoutOverflow() throws {
        let quarters = try split("255.255.255.0", prefix: 24, into: 26)
        let hosts = try split("255.255.255.0", prefix: 24, into: 32)

        #expect(formatter.string(from: quarters[3].network) == "255.255.255.192")
        #expect(formatter.string(from: quarters[3].broadcast) == "255.255.255.255")
        #expect(hosts.count == 256)
        #expect(formatter.string(from: hosts[255].network) == "255.255.255.255")
    }

    @Test(arguments: [(20, 32), (0, 12)])
    func allowsSubnetCountAtLimit(prefix: Int, newPrefix: Int) throws {
        let subnets = try split("10.0.0.0", prefix: prefix, into: newPrefix)

        #expect(subnets.count == SubnetSplitService.maxSubnetCount)
    }

    @Test(arguments: [(19, 32), (0, 13), (8, 30)])
    func rejectsSubnetCountOverLimit(prefix: Int, newPrefix: Int) {
        #expect(throws: SubnetSplitError.tooManySubnets) {
            try split("10.0.0.0", prefix: prefix, into: newPrefix)
        }
    }

    // MARK: - Host counts (VLSM)

    @Test func allocatesSmallestSubnetsLargestFirst() throws {
        let allocations = try split("192.168.10.0", prefix: 24, hostCounts: [60, 25, 2])

        #expect(allocations.map(describe) == ["192.168.10.0/26", "192.168.10.64/27", "192.168.10.96/30"])
        #expect(allocations.map(\.requestIndex) == [0, 1, 2])
        #expect(allocations.map(\.hostsNeeded) == [60, 25, 2])
    }

    @Test func keepsRequestIndexWhenReordering() throws {
        let allocations = try split("192.168.10.0", prefix: 24, hostCounts: [2, 60, 25, 2])

        #expect(allocations.map(\.requestIndex) == [1, 2, 0, 3])
        #expect(allocations.map(describe) == ["192.168.10.0/26", "192.168.10.64/27", "192.168.10.96/30", "192.168.10.100/30"])
    }

    @Test(arguments: [(1, 30), (2, 30), (3, 29), (6, 29), (7, 28), (62, 26), (63, 25)])
    func givesSmallestSubnetWithNetworkAndBroadcast(hosts: Int, expectedPrefix: Int) throws {
        let allocations = try split("10.0.0.0", prefix: 8, hostCounts: [hosts])

        #expect(allocations.first?.subnet.prefix == expectedPrefix)
    }

    @Test func fillsNetworkExactly() throws {
        let allocations = try split("192.168.1.0", prefix: 24, hostCounts: [126, 62, 30, 14, 6, 2, 2])

        #expect(allocations.last.map(describe) == "192.168.1.252/30")
        #expect(allocations.last.map { formatter.string(from: $0.subnet.broadcast) } == "192.168.1.255")
    }

    @Test func reportsRequirementThatDoesNotFit() {
        #expect(throws: SubnetSplitError.notEnoughSpace(requestIndex: 5, hostCount: 2)) {
            try split("192.168.1.0", prefix: 24, hostCounts: [126, 62, 30, 14, 6, 2, 3])
        }
    }

    @Test func fitsWholeNetworkButNotOneHostMore() throws {
        let allocations = try split("192.168.1.0", prefix: 24, hostCounts: [254])

        #expect(allocations.map(describe) == ["192.168.1.0/24"])
        #expect(throws: SubnetSplitError.notEnoughSpace(requestIndex: 0, hostCount: 255)) {
            try split("192.168.1.0", prefix: 24, hostCounts: [255])
        }
    }

    @Test(arguments: [30, 31, 32])
    func rejectsRequirementLargerThanSmallNetwork(prefix: Int) {
        let hosts = prefix == 30 ? 3 : 1
        #expect(throws: SubnetSplitError.notEnoughSpace(requestIndex: 0, hostCount: hosts)) {
            try split("10.0.0.0", prefix: prefix, hostCounts: [hosts])
        }
    }

    @Test func allocatesLastNetworkWithoutOverflow() throws {
        let allocations = try split("255.255.255.0", prefix: 24, hostCounts: [126, 126])

        #expect(allocations.map(describe) == ["255.255.255.0/25", "255.255.255.128/25"])
        #expect(allocations.last.map { formatter.string(from: $0.subnet.broadcast) } == "255.255.255.255")
    }

    @Test func allocatesWholeAddressSpace() throws {
        let allocations = try split("0.0.0.0", prefix: 0, hostCounts: [4_294_967_294])

        #expect(allocations.map(describe) == ["0.0.0.0/0"])
        #expect(throws: SubnetSplitError.notEnoughSpace(requestIndex: 0, hostCount: 4_294_967_295)) {
            try split("0.0.0.0", prefix: 0, hostCounts: [4_294_967_295])
        }
    }

    @Test(arguments: [0, -1])
    func rejectsHostCountBelowOne(hosts: Int) {
        #expect(throws: SubnetSplitError.invalidHostCount) {
            try split("10.0.0.0", prefix: 8, hostCounts: [10, hosts])
        }
    }

    @Test func returnsNothingForNoRequirements() throws {
        #expect(try split("10.0.0.0", prefix: 8, hostCounts: []).isEmpty)
    }
}

private extension SubnetSplitServiceTests {
    func split(_ address: String, prefix: Int, into newPrefix: Int) throws -> [IPCalculationModel] {
        let ip = try #require(formatter.uint32(from: address))
        return try service.split(ip: ip, subnetMask: SubnetMaskModel(prefix: prefix), into: SubnetMaskModel(prefix: newPrefix))
    }

    func split(_ address: String, prefix: Int, hostCounts: [Int]) throws -> [SubnetAllocation] {
        let ip = try #require(formatter.uint32(from: address))
        return try service.split(ip: ip, subnetMask: SubnetMaskModel(prefix: prefix), hostCounts: hostCounts)
    }

    func describe(_ allocation: SubnetAllocation) -> String {
        return "\(formatter.string(from: allocation.subnet.network))/\(allocation.subnet.prefix)"
    }
}

import Foundation

struct SubnetMaskModel {
    let prefix: Int
    let subnet: UInt32

    init(prefix: Int) {
        self.prefix = prefix
        self.subnet = prefix == 0 ? 0 : ~UInt32(0) << (32 - prefix)
    }

    static let `default`: [SubnetMaskModel] = (0...32).map { SubnetMaskModel(prefix: $0) }
}

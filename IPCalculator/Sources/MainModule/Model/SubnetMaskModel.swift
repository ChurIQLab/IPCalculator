import Foundation

struct SubnetMaskModel {
    let prefix: Int
    let subnet: String

    static func subnetString(for prefix: Int) -> String {
        var bytes: [UInt8] = []

        for i in 0..<4 {
            let onesInByte = min(max(prefix - 8 * i, 0), 8)
            if onesInByte == 0 {
                bytes.append(0)
            } else {
                let byte = UInt8((1 << onesInByte) - 1) << (8 - onesInByte)
                bytes.append(byte)
            }
        }

        return bytes.map { String($0) }.joined(separator: ".")
    }

    static let all: [SubnetMaskModel] = (0...32).map {
        SubnetMaskModel(prefix: $0, subnet: SubnetMaskModel.subnetString(for: $0))
    }
}

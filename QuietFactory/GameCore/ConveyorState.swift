import Foundation

struct ConveyorCrate: Hashable, Codable, Sendable {
    let id: CrateID
    let color: CrateColor
}

struct ConveyorState: Codable, Sendable {
    let capacity: Int
    var slots: [ConveyorCrate]

    init(capacity: Int, slots: [ConveyorCrate] = []) {
        self.capacity = capacity
        self.slots = slots
    }

    var isFull: Bool { slots.count >= capacity }

    var hasSpace: Bool { slots.count < capacity }
}

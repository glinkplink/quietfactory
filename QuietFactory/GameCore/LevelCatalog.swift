import Foundation

enum LevelCatalog {
    static let all: [LevelDefinition] = onboarding + normal + sequencing + difficult

    static var onboarding: [LevelDefinition] {
        [
            LevelDefinition(
                id: "onb-1",
                name: "First Release",
                width: 3,
                height: 3,
                crates: [
                    CrateDefinition(x: 1, y: 1, direction: .north, color: .red)
                ],
                matchSize: 3,
                conveyorCapacity: 5,
                category: .onboarding
            ),
            LevelDefinition(
                id: "onb-2",
                name: "Two Colors",
                width: 4,
                height: 3,
                crates: [
                    CrateDefinition(x: 0, y: 1, direction: .east, color: .red),
                    CrateDefinition(x: 3, y: 1, direction: .west, color: .blue)
                ],
                matchSize: 3,
                conveyorCapacity: 5,
                category: .onboarding
            ),
            LevelDefinition(
                id: "onb-3",
                name: "Blocked Path",
                width: 4,
                height: 3,
                crates: [
                    CrateDefinition(x: 1, y: 1, direction: .east, color: .green),
                    CrateDefinition(x: 2, y: 1, direction: .west, color: .green)
                ],
                matchSize: 3,
                conveyorCapacity: 5,
                category: .onboarding
            )
        ]
    }

    static var normal: [LevelDefinition] {
        [
            LevelDefinition(
                id: "norm-1",
                name: "Cross Traffic",
                width: 5,
                height: 5,
                crates: [
                    CrateDefinition(x: 0, y: 2, direction: .east, color: .red),
                    CrateDefinition(x: 4, y: 2, direction: .west, color: .blue),
                    CrateDefinition(x: 2, y: 0, direction: .south, color: .green)
                ],
                matchSize: 3,
                conveyorCapacity: 5,
                category: .normal
            ),
            LevelDefinition(
                id: "norm-2",
                name: "Stacked Lanes",
                width: 5,
                height: 5,
                crates: [
                    CrateDefinition(x: 1, y: 1, direction: .north, color: .yellow),
                    CrateDefinition(x: 3, y: 3, direction: .south, color: .yellow),
                    CrateDefinition(x: 2, y: 2, direction: .east, color: .orange)
                ],
                matchSize: 3,
                conveyorCapacity: 5,
                category: .normal
            ),
            LevelDefinition(
                id: "norm-3",
                name: "Corner Exit",
                width: 4,
                height: 4,
                crates: [
                    CrateDefinition(x: 1, y: 1, direction: .north, color: .purple),
                    CrateDefinition(x: 2, y: 2, direction: .east, color: .purple),
                    CrateDefinition(x: 0, y: 3, direction: .north, color: .red)
                ],
                matchSize: 3,
                conveyorCapacity: 5,
                category: .normal
            ),
            LevelDefinition(
                id: "norm-4",
                name: "Gatekeeper",
                width: 5,
                height: 4,
                crates: [
                    CrateDefinition(x: 2, y: 1, direction: .north, color: .blue),
                    CrateDefinition(x: 2, y: 2, direction: .south, color: .green),
                    CrateDefinition(x: 0, y: 1, direction: .east, color: .blue),
                    CrateDefinition(x: 4, y: 2, direction: .west, color: .green)
                ],
                matchSize: 3,
                conveyorCapacity: 5,
                category: .normal
            ),
            LevelDefinition(
                id: "norm-5",
                name: "Rainbow Row",
                width: 6,
                height: 4,
                crates: [
                    CrateDefinition(x: 0, y: 2, direction: .north, color: .red),
                    CrateDefinition(x: 1, y: 2, direction: .north, color: .blue),
                    CrateDefinition(x: 2, y: 2, direction: .north, color: .green),
                    CrateDefinition(x: 3, y: 2, direction: .north, color: .yellow)
                ],
                matchSize: 3,
                conveyorCapacity: 5,
                category: .normal
            )
        ]
    }

    static var sequencing: [LevelDefinition] {
        [
            LevelDefinition(
                id: "seq-1",
                name: "Buffer Pressure",
                width: 5,
                height: 5,
                crates: [
                    CrateDefinition(x: 0, y: 2, direction: .east, color: .red),
                    CrateDefinition(x: 1, y: 2, direction: .east, color: .red),
                    CrateDefinition(x: 2, y: 2, direction: .east, color: .blue),
                    CrateDefinition(x: 3, y: 2, direction: .east, color: .red)
                ],
                matchSize: 3,
                conveyorCapacity: 5,
                category: .sequencing
            ),
            LevelDefinition(
                id: "seq-2",
                name: "Order Matters",
                width: 5,
                height: 5,
                crates: [
                    CrateDefinition(x: 2, y: 0, direction: .south, color: .green),
                    CrateDefinition(x: 2, y: 3, direction: .north, color: .green),
                    CrateDefinition(x: 0, y: 2, direction: .east, color: .green),
                    CrateDefinition(x: 4, y: 2, direction: .west, color: .yellow),
                    CrateDefinition(x: 2, y: 2, direction: .north, color: .yellow)
                ],
                matchSize: 3,
                conveyorCapacity: 5,
                category: .sequencing
            ),
            LevelDefinition(
                id: "seq-3",
                name: "Conveyor Trap",
                width: 5,
                height: 5,
                crates: [
                    CrateDefinition(x: 1, y: 1, direction: .south, color: .orange),
                    CrateDefinition(x: 3, y: 1, direction: .south, color: .orange),
                    CrateDefinition(x: 1, y: 3, direction: .north, color: .purple),
                    CrateDefinition(x: 3, y: 3, direction: .north, color: .purple),
                    CrateDefinition(x: 2, y: 2, direction: .east, color: .orange)
                ],
                matchSize: 3,
                conveyorCapacity: 5,
                category: .sequencing
            )
        ]
    }

    static var difficult: [LevelDefinition] {
        [
            LevelDefinition(
                id: "hard-1",
                name: "Near Stuck",
                width: 6,
                height: 5,
                crates: [
                    CrateDefinition(x: 0, y: 2, direction: .east, color: .red),
                    CrateDefinition(x: 1, y: 2, direction: .east, color: .blue),
                    CrateDefinition(x: 2, y: 2, direction: .east, color: .red),
                    CrateDefinition(x: 3, y: 2, direction: .east, color: .blue),
                    CrateDefinition(x: 4, y: 2, direction: .east, color: .red),
                    CrateDefinition(x: 5, y: 2, direction: .north, color: .blue)
                ],
                matchSize: 3,
                conveyorCapacity: 5,
                category: .difficult
            ),
            LevelDefinition(
                id: "hard-2",
                name: "Tight Squeeze",
                width: 5,
                height: 6,
                crates: [
                    CrateDefinition(x: 1, y: 1, direction: .south, color: .green),
                    CrateDefinition(x: 3, y: 1, direction: .south, color: .yellow),
                    CrateDefinition(x: 1, y: 4, direction: .north, color: .green),
                    CrateDefinition(x: 3, y: 4, direction: .north, color: .yellow),
                    CrateDefinition(x: 2, y: 2, direction: .east, color: .green),
                    CrateDefinition(x: 2, y: 3, direction: .west, color: .yellow)
                ],
                matchSize: 3,
                conveyorCapacity: 5,
                category: .difficult
            )
        ]
    }
}

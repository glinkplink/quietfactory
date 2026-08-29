import Foundation

enum LevelCatalog {
    static let all: [LevelDefinition] = onboarding + normal + sequencing + difficult

    /// Parallel south exits on the bottom row — one crate per column, no lane blocking.
    private static func southLaneRow(
        colors: [(Int, CrateColor)],
        width: Int,
        row: Int
    ) -> [CrateDefinition] {
        colors.map { col, color in
            CrateDefinition(x: col, y: row, direction: .south, color: color)
        }
    }

    static var onboarding: [LevelDefinition] {
        [
            LevelDefinition(
                id: "onb-1",
                name: "First Match",
                width: 5,
                height: 2,
                crates: southLaneRow(
                    colors: [(0, .red), (1, .red), (2, .red)],
                    width: 5,
                    row: 1
                ),
                matchSize: 3,
                conveyorCapacity: 5,
                category: .onboarding
            ),
            LevelDefinition(
                id: "onb-2",
                name: "Two Colors",
                width: 6,
                height: 2,
                crates: southLaneRow(
                    colors: [
                        (0, .red), (1, .red), (2, .red),
                        (3, .blue), (4, .blue), (5, .blue)
                    ],
                    width: 6,
                    row: 1
                ),
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
                    CrateDefinition(x: 2, y: 0, direction: .south, color: .green),
                    CrateDefinition(x: 2, y: 1, direction: .south, color: .green),
                    CrateDefinition(x: 3, y: 1, direction: .south, color: .green)
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
                name: "Triple Lanes",
                width: 9,
                height: 2,
                crates: southLaneRow(
                    colors: [
                        (0, .red), (1, .red), (2, .red),
                        (3, .blue), (4, .blue), (5, .blue),
                        (6, .green), (7, .green), (8, .green)
                    ],
                    width: 9,
                    row: 1
                ),
                matchSize: 3,
                conveyorCapacity: 5,
                category: .normal
            ),
            LevelDefinition(
                id: "norm-2",
                name: "Stacked Lanes",
                width: 6,
                height: 2,
                crates: southLaneRow(
                    colors: [
                        (0, .yellow), (1, .yellow), (2, .yellow),
                        (3, .orange), (4, .orange), (5, .orange)
                    ],
                    width: 6,
                    row: 1
                ),
                matchSize: 3,
                conveyorCapacity: 5,
                category: .normal
            ),
            LevelDefinition(
                id: "norm-3",
                name: "North Exit",
                width: 5,
                height: 3,
                crates: [
                    CrateDefinition(x: 0, y: 0, direction: .north, color: .purple),
                    CrateDefinition(x: 1, y: 0, direction: .north, color: .purple),
                    CrateDefinition(x: 2, y: 0, direction: .north, color: .purple)
                ],
                matchSize: 3,
                conveyorCapacity: 5,
                category: .normal
            ),
            LevelDefinition(
                id: "norm-4",
                name: "Gatekeeper",
                width: 6,
                height: 2,
                crates: southLaneRow(
                    colors: [
                        (0, .blue), (1, .blue), (2, .blue),
                        (3, .green), (4, .green), (5, .green)
                    ],
                    width: 6,
                    row: 1
                ),
                matchSize: 3,
                conveyorCapacity: 5,
                category: .normal
            ),
            LevelDefinition(
                id: "norm-5",
                name: "Rainbow Row",
                width: 9,
                height: 2,
                crates: southLaneRow(
                    colors: [
                        (0, .red), (1, .red), (2, .red),
                        (3, .blue), (4, .blue), (5, .blue),
                        (6, .green), (7, .green), (8, .green)
                    ],
                    width: 9,
                    row: 1
                ),
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
                width: 6,
                height: 2,
                crates: southLaneRow(
                    colors: [
                        (0, .red), (1, .red), (2, .red),
                        (3, .red), (4, .red), (5, .red)
                    ],
                    width: 6,
                    row: 1
                ),
                matchSize: 3,
                conveyorCapacity: 5,
                category: .sequencing
            ),
            LevelDefinition(
                id: "seq-2",
                name: "Order Matters",
                width: 7,
                height: 3,
                crates: [
                    CrateDefinition(x: 0, y: 2, direction: .west, color: .blue),
                    CrateDefinition(x: 1, y: 2, direction: .west, color: .blue),
                    CrateDefinition(x: 2, y: 2, direction: .west, color: .blue),
                    CrateDefinition(x: 3, y: 2, direction: .east, color: .red),
                    CrateDefinition(x: 4, y: 2, direction: .east, color: .red),
                    CrateDefinition(x: 5, y: 2, direction: .east, color: .red)
                ],
                matchSize: 3,
                conveyorCapacity: 5,
                category: .sequencing
            ),
            LevelDefinition(
                id: "seq-3",
                name: "Conveyor Trap",
                width: 6,
                height: 2,
                crates: southLaneRow(
                    colors: [
                        (0, .orange), (1, .purple), (2, .orange),
                        (3, .purple), (4, .orange), (5, .purple)
                    ],
                    width: 6,
                    row: 1
                ),
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
                height: 3,
                crates: [
                    CrateDefinition(x: 0, y: 2, direction: .south, color: .red),
                    CrateDefinition(x: 1, y: 2, direction: .south, color: .purple),
                    CrateDefinition(x: 2, y: 2, direction: .south, color: .purple),
                    CrateDefinition(x: 3, y: 2, direction: .south, color: .red),
                    CrateDefinition(x: 4, y: 2, direction: .south, color: .purple),
                    CrateDefinition(x: 5, y: 2, direction: .south, color: .red),
                    CrateDefinition(x: 1, y: 1, direction: .south, color: .orange),
                    CrateDefinition(x: 2, y: 1, direction: .south, color: .orange),
                    CrateDefinition(x: 2, y: 0, direction: .south, color: .orange)
                ],
                matchSize: 3,
                conveyorCapacity: 5,
                category: .difficult
            ),
            LevelDefinition(
                id: "hard-2",
                name: "Tight Squeeze",
                width: 6,
                height: 2,
                crates: southLaneRow(
                    colors: [
                        (0, .green), (1, .yellow), (2, .green),
                        (3, .yellow), (4, .green), (5, .yellow)
                    ],
                    width: 6,
                    row: 1
                ),
                matchSize: 3,
                conveyorCapacity: 5,
                category: .difficult
            )
        ]
    }
}

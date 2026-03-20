//
//  SequenceExtension.swift
//  Code taken from https://www.swiftbysundell.com/articles/async-and-concurrent-forEach-and-map/
//

import Foundation

extension Sequence {
    func concurrentForEach(
            _ operation: @escaping (Element) async -> Void
    ) async {
        // A task group automatically waits for all of its
        // sub-tasks to complete, while also performing those
        // tasks in parallel:
        await withTaskGroup(of: Void.self) { group in
            for element in self {
                group.addTask {
                    await operation(element)
                }
            }
        }
    }
}

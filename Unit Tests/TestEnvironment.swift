//
//  TestFramework.swift
//  Tests iOS
//
//  Created by Piper McCorkle on 3/10/22.
//

import Foundation
import CoreData
@testable import Fleetbox

struct TestEnvironment {
    let controller: PersistenceController
    let viewContext: NSManagedObjectContext

    init() {
        controller = PersistenceController(inMemory: true)
        viewContext = controller.container.viewContext
    }

    func addFixtures() throws -> PersistenceController.Fixtures {
        try PersistenceController.Fixtures(viewContext: viewContext)
    }
}

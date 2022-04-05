//  SPDX-License-Identifier: GPL-3.0-or-later
//  Fleetbox, a tool for managing vehicle maintenance logs
//  Copyright (C) 2022 Lutris, Inc
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

import Foundation
import CoreData
import XCTest
@testable import Fleetbox

struct TestEnvironment {
    let controller: PersistenceController
    let viewContext: NSManagedObjectContext

    init() {
        controller = PersistenceController(inMemory: true)
        viewContext = controller.container.viewContext
    }

    func addFixtures() throws -> PersistenceController.Fixtures {
        try PersistenceController.Fixtures(viewContext: viewContext, save: false)
    }
}

class TestEnvironmentTestCase: XCTestCase {
    var env: TestEnvironment = TestEnvironment()

    override func setUp() {
        super.setUp()
        env = TestEnvironment()
    }
}

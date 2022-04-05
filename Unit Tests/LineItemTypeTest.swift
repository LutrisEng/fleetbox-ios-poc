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

import XCTest
@testable import Fleetbox

class LineItemTypeTest: XCTestCase {
    func testDeserializes() throws {
        _ = try LineItemTypes()
    }

    func testMiscExists() throws {
        XCTAssertNotNil(lineItemTypes.allTypesById["misc"])
    }

    func testReplaceExists() throws {
        for type in lineItemTypes.allTypes {
            if let replaces = type.replaces {
                XCTAssertNotNil(
                    lineItemTypes.allComponentsById[replaces],
                    "Type \(type.id) refers to nonexistent component \(replaces)"
                )
            }
        }
    }

    func testFilterExists() throws {
        for component in lineItemTypes.allComponents {
            if let filter = component.filter {
                XCTAssertNotNil(
                    lineItemTypes.allComponentsById[filter],
                    "Component \(component.id) refers to nonexistent component \(filter) as filter"
                )
            }
        }
    }
}

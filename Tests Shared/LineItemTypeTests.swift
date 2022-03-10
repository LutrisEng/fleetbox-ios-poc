//
//  LineItemTypeTests.swift
//  Tests macOS
//
//  Created by Piper McCorkle on 3/2/22.
//

import XCTest
import Fleetbox

class LineItemTypeTests: XCTestCase {
    func testSerializesAndDeserializes() throws {
        for type in LineItemType.allCases {
            XCTAssertEqual(type, LineItemType.from(string: type.description))
        }
    }
}

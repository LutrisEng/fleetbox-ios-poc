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

struct VINDecoderResponseResult: Codable {
    let value: String?
    let valueId: String?
    let variable: String?
    let variableId: Int?

    enum CodingKeys: String, CodingKey {
        case value = "Value"
        case valueId = "ValueId"
        case variable = "Variable"
        case variableId = "VariableId"
    }
}

struct VINDecoderResponse: Codable {
    let count: Int
    let message: String
    let searchCriteria: String
    let results: [VINDecoderResponseResult]

    enum CodingKeys: String, CodingKey {
        case count = "Count"
        case message = "Message"
        case searchCriteria = "SearchCriteria"
        case results = "Results"
    }

    func toResult() -> VINDecoderResult {
        var result = VINDecoderResult()
        for item in results {
            if let value = item.value {
                switch item.variableId {
                case 143: result.errorCode = Int(value) ?? result.errorCode
                case 26: result.make = value
                case 28: result.model = value
                case 29: result.modelYear = Int(value) ?? result.modelYear
                default: break
                }
            }
        }
        return result
    }
}

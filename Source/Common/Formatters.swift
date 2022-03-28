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

struct Formatter {
    static let wholePercentage: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    static func formatWholePercentage(proportion: Double) -> String {
        return wholePercentage.string(from: proportion) ?? "\(proportion / 100)%"
    }

    static func formatWholePercentage(numerator: Double, denominator: Double) -> String {
        return formatWholePercentage(proportion: numerator / denominator)
    }

    static func formatWholePercentage(numerator: Int64, denominator: Int64) -> String {
        return formatWholePercentage(numerator: Double(numerator), denominator: Double(denominator))
    }
}

extension NumberFormatter {
    func string(from number: Int64) -> String? {
        return string(from: NSNumber(value: number))
    }

    func string(from number: Double) -> String? {
        return string(from: NSNumber(value: number))
    }
}

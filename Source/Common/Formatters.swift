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
    static func createNumberFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        return formatter
    }

    static func createNumberFormatter(_ block: (NumberFormatter) -> Void) -> NumberFormatter {
        let formatter = createNumberFormatter()
        block(formatter)
        return formatter
    }

    static let number: NumberFormatter = createNumberFormatter()

    static func format(number: NSNumber) -> String {
        return self.number.string(from: number) ?? "\(number)"
    }

    static func format(number: Int64) -> String {
        return self.number.string(from: number) ?? "\(number)"
    }

    static func format(number: Int16) -> String {
        return self.number.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    static let wholeNumber: NumberFormatter = createNumberFormatter { formatter in
        formatter.maximumFractionDigits = 0
    }

    static func format(wholeNumber: Double) -> String {
        return self.wholeNumber.string(from: wholeNumber) ?? "\(wholeNumber)"
    }

    static let wholePercentage: NumberFormatter = createNumberFormatter { formatter in
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
    }

    static func format(wholePercentage: Double) -> String {
        return self.wholePercentage.string(from: wholePercentage) ?? "\(wholePercentage / 100)%"
    }

    static let durationLabel: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.month, .weekOfMonth, .day, .hour, .minute]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.includesApproximationPhrase = true
        formatter.zeroFormattingBehavior = .dropAll
        return formatter
    }()

    static func format(durationLabel: TimeInterval) -> String {
        return self.durationLabel.string(from: durationLabel) ?? ""
    }

    static let dateLabel: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()

    static func format(dateLabel: Date) -> String {
        return self.dateLabel.string(from: dateLabel)
    }

    static let dateTimeLabel: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    static func format(dateTimeLabel: Date) -> String {
        return self.dateTimeLabel.string(from: dateTimeLabel)
    }

    static let bytes: ByteCountFormatter = ByteCountFormatter()

    static func format(bytes: Int64) -> String {
        return self.bytes.string(fromByteCount: bytes)
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

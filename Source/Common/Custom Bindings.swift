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

import SwiftUI

func convertToStringBinding(int64: Binding<Int64>) -> Binding<String> {
    Binding<String>(
            get: {
                if int64.wrappedValue == 0 {
                    return ""
                } else {
                    return String(int64.wrappedValue)
                }
            },
            set: { value in
                let filtered = value.filter {
                    $0.isNumber
                }
                int64.wrappedValue = Int64(filtered) ?? 0
            }
    )
}

func convertToStringBinding(int16: Binding<Int16>) -> Binding<String> {
    Binding<String>(
            get: {
                if int16.wrappedValue == 0 {
                    return ""
                } else {
                    return String(int16.wrappedValue)
                }
            },
            set: { value in
                let filtered = value.filter {
                    $0.isNumber
                }
                int16.wrappedValue = Int16(filtered) ?? 0
            }
    )
}

func convertToNumberFormattingBinding(string: Binding<String>) -> Binding<String> {
    Binding<String>(
            get: {
                if let number = Formatter.number.number(
                    from: string.wrappedValue.filter { $0.isNumber }
                ) {
                    return Formatter.format(number: number)
                } else {
                    return string.wrappedValue
                }
            },
            set: { value in
                string.wrappedValue = value
            }
    )
}

func convertToNillableBinding(string: Binding<String>) -> Binding<String?> {
    Binding<String?>(
            get: { string.wrappedValue.normalized },
            set: { value in
                string.wrappedValue = value.denormalized
            }
    )
}

func convertToNonNilBinding(date: Binding<Date?>) -> Binding<Date> {
    Binding<Date>(
            get: { date.wrappedValue ?? Date.distantPast },
            set: { value in
                date.wrappedValue = value
            }
    )
}

func convertToNonNilBinding(string: Binding<String?>) -> Binding<String> {
    Binding<String>(
        get: { string.wrappedValue.denormalized },
        set: { value in
            string.wrappedValue = value.normalized
        }
    )
}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    // swiftlint:disable:next identifier_name
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    // swiftlint:disable:next identifier_name
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}

func formatPhoneNumber(phoneNumber: String) -> String {
    let filtered = phoneNumber.filter { $0.isNumber }
    switch filtered.count {
    case 0: return ""
    case 1, 2: return "(\(filtered)"
    case 3: return "(\(filtered))"
    case 4, 5: return "(\(filtered.substring(to: 3)) \(filtered.substring(from: 3))"
    case 6: return "(\(filtered.substring(to: 3))) \(filtered.substring(from: 3)) "
    // swiftlint:disable:next line_length
    case 7, 8, 9, 10: return "(\(filtered.substring(to: 3))) \(filtered.substring(with: 3..<6))-\(filtered.substring(from: 6))"
    default: return phoneNumber
    }
}

func phoneNumberBinding(string: Binding<String?>) -> Binding<String?> {
    Binding<String?>(
        get: {
            if let value = string.wrappedValue {
                return formatPhoneNumber(phoneNumber: value)
            } else {
                return nil
            }
        },
        set: {
            if let newValue = $0 {
                string.wrappedValue = formatPhoneNumber(phoneNumber: newValue)
            } else {
                string.wrappedValue = nil
            }
        }
    )
}

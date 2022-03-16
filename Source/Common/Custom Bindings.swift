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
import SwiftUI

class NumbersOnly: ObservableObject {
    @Published var value = "0" {
        didSet {
            let filtered = value.filter {
                $0.isNumber
            }
            if value != filtered {
                value = filtered
            }
        }
    }

    var numericValue: Int64 {
        get {
            Int64(value)!
        }

        set(newValue) {
            value = String(newValue)
        }
    }
}

func convertToStringBinding(int64: Binding<Int64>) -> Binding<String> {
    Binding<String>(
            get: { String(int64.wrappedValue) },
            set: { value in
                let filtered = value.filter {
                    $0.isNumber
                }
                int64.wrappedValue = Int64(filtered) ?? 0
            }
    )
}

func convertToNillableBinding(string: Binding<String>) -> Binding<String?> {
    Binding<String?>(
            get: { string.wrappedValue },
            set: { value in
                string.wrappedValue = value ?? ""
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
            get: { string.wrappedValue ?? "" },
            set: { value in
                string.wrappedValue = value
            }
    )
}

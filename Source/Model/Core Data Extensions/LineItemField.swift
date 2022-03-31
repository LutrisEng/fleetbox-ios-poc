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

extension LineItemField {
    var type: LineItemTypeField? {
        get {
            guard let typeId = typeId else {
                return nil
            }
            guard let lineItem = lineItem else {
                return nil
            }
            guard let lineItemType = lineItem.type else {
                return nil
            }
            return lineItemType.fieldsById[typeId]
        }

        set {
            typeId = newValue?.id
        }
    }

    var displayValue: String? {
        switch type?.type {
        case .string:
            if stringValue == "" {
                return nil
            } else {
                return stringValue
            }
        case .enumeration:
            guard let stringValue = stringValue else {
                return nil
            }
            return type?.enumValuesById[stringValue]?.displayName
        case .tireSet: return tireSetValue?.displayName
        case .boolean:
            let booleanFormat = type?.booleanFormat ?? LineItemTypeBooleanFormat.defaultFormat
            if stringValue == "true" {
                return booleanFormat.trueFormat
            } else if stringValue == "false" {
                return booleanFormat.falseFormat
            } else {
                return nil
            }
        case .integer:
            if integerValue == 0 {
                return nil
            } else {
                let formatter = NumberFormatter()
                if let formatted = formatter.string(from: NSNumber(value: integerValue)) {
                    if let unit = type?.unit {
                        return "\(formatted) \(unit)"
                    } else {
                        return formatted
                    }
                } else {
                    return "\(integerValue)"
                }
            }
        case nil: return nil
        }
    }

    func setDefaultValue(vehicle: Vehicle?) {
        if let defaultValue = type?.defaultValue {
            stringValue = defaultValue
        } else if let defaultFrom = type?.defaultValueFrom {
            switch defaultFrom {
            case .vehicleMake:
                stringValue = vehicle?.make
            case .vehicleRegistrationState:
                stringValue = vehicle?.registrationState
            case .vehicleOilViscosity:
                stringValue = vehicle?.lastOilViscosity
            case .vehicleCurrentTires:
                tireSetValue = vehicle?.currentTireSet
            }
        }
    }
}

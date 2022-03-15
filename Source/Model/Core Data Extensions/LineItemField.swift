//
//  LineItemField.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/5/22.
//

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
            return type?.enumValues[stringValue]?.displayName
        case .tireSet: return tireSetValue?.displayName
        case .boolean:
            if let booleanFormat = type?.booleanFormat {
                if booleanValue {
                    return booleanFormat.trueFormat
                } else {
                    return booleanFormat.falseFormat
                }
            } else {
                if booleanValue {
                    return "Yes"
                } else {
                    return "No"
                }
            }
        case nil: return nil
        }
    }

    func setDefaultValue(vehicle: Vehicle?) {
        if let defaultValue = type?.defaultValue {
            switch type?.type {
            case .boolean:
                switch defaultValue {
                case "true":
                    booleanValue = true
                default:
                    booleanValue = false
                }
            default:
                stringValue = defaultValue
            }
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

    override public func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        self.objectWillChange.send()
        lineItem?.objectWillChange.send()
        lineItem?.logItem?.objectWillChange.send()
        lineItem?.logItem?.vehicle?.objectWillChange.send()
    }
}
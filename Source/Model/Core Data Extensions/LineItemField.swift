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

    override public func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        self.objectWillChange.send()
        lineItem?.objectWillChange.send()
        lineItem?.logItem?.objectWillChange.send()
        lineItem?.logItem?.vehicle?.objectWillChange.send()
    }
}

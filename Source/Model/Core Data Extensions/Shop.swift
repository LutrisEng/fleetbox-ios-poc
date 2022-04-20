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
import Sentry

extension Shop: Sortable, HasRawLogItems, HasLogItems {
    var mapURL: URL? {
        if let location = location?.normalized, var url = URLComponents(string: "http://maps.apple.com/") {
            url.queryItems = [URLQueryItem(name: "q", value: location)]
            return url.url
        } else {
            return nil
        }
    }

    var emailURL: URL? {
        if let email = email?.normalized {
            return URL(string: "mailto:\(email)")
        } else {
            return nil
        }
    }

    var phoneURL: URL? {
        if let phoneNumber = phoneNumber?.normalized {
            return URL(string: "tel:\(phoneNumber.filter { $0.isNumber })")
        } else {
            return nil
        }
    }

    var smsURL: URL? {
        if let phoneNumber = phoneNumber?.normalized {
            return URL(string: "sms:\(phoneNumber)")
        } else {
            return nil
        }
    }

    var urlURL: URL? {
        if let url = url?.normalized {
            if url.starts(with: "http://") || url.starts(with: "https://") {
                return URL(string: url)
            } else {
                return URL(string: "http://\(url)")
            }
        } else {
            return nil
        }
    }

    func mergeWith(_ other: Shop) {
        if other.objectID == objectID {
            sentryCapture(message: "Refusing to merge shop with itself")
            return
        }
        for item in other.logItems {
            item.shop = self
        }
        if let context = other.managedObjectContext {
            context.delete(other)
        }
    }
}

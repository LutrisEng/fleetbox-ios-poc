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

extension Attachment: Sortable {
    var owner: HasRawAttachments? {
        get {
            if let logItem = logItem {
                return logItem
            } else if let vehicle = vehicle {
                return vehicle
            } else if let tireSet = tireSet {
                return tireSet
            } else {
                return nil
            }
        }
        set {
            if let logItem = newValue as? LogItem {
                self.logItem = logItem
            } else if let vehicle = newValue as? Vehicle {
                self.vehicle = vehicle
            } else if let tireSet = newValue as? TireSet {
                self.tireSet = tireSet
            }
        }
    }

    func normalize() {
        if fileExtension == nil || fileExtension == "" {
            if var split = fileName?.split(separator: ".") {
                if let newExtension = split.popLast() {
                    fileExtension = String(newExtension)
                }
                fileName = split.joined(separator: ".")
            }
        }
        if fileSize == 0, let fileContents = fileContents {
            fileSize = Int64(fileContents.count)
        }
    }

    func importFile(url: URL) throws {
        let contents = try Data(contentsOf: url)
        fileContents = contents
        fileName = url.deletingPathExtension().lastPathComponent
        fileExtension = url.pathExtension
        fileSize = Int64(contents.count)
    }
}

extension Array where Element == Attachment {
    func normalize() -> Self {
        for attachment in self {
            attachment.normalize()
        }
        return self
    }
}

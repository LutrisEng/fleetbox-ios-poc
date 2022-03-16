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

struct ExportableAttachment: Codable {
    let sortOrder: Int16
    let fileName: String?
    let fileContents: String?

    init(attachment: Attachment) {
        sortOrder = attachment.sortOrder
        fileName = attachment.fileName
        fileContents = attachment.fileContents?.base64EncodedString()
    }

    func importAttachment(context: NSManagedObjectContext) -> Attachment {
        let attachment = Attachment(context: context)
        attachment.sortOrder = sortOrder
        attachment.fileName = fileName
        if let fileContents = fileContents {
            attachment.fileContents = Data(base64Encoded: fileContents)
        }
        return attachment
    }
}

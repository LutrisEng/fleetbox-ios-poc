//
//  ExportableAttachment.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/10/22.
//

import Foundation
import CoreData

struct ExportableAttachment : Codable {
    let sortOrder: Int16
    let fileName: String?
    let fileContents: String?
    
    init(attachment: Attachment) {
        self.sortOrder = attachment.sortOrder
        self.fileName = attachment.fileName
        self.fileContents = attachment.fileContents?.base64EncodedString()
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

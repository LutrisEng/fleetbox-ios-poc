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
import Sentry

struct AttachmentView: View {
    let attachment: Attachment
    @State private var fileURL: URL?

    init(attachment: Attachment) {
        self.attachment = attachment
    }

    func tryToWriteFile() {
        if let contents = attachment.fileContents {
            do {
                let tempFileURL = temporaryFileURL(filename: attachment.fileName)
                try contents.write(to: tempFileURL)
                fileURL = tempFileURL
            } catch {
                SentrySDK.capture(error: error)
                print("Error writing file", error)
            }
        } else {
            fileURL = nil
        }
    }

    func tryToRemoveFile() {
        if let fileURL = fileURL {
            ignoreErrors {
                try FileManager.default.removeItem(at: fileURL)
            }
        }
        fileURL = nil
    }

    var body: some View {
        HStack {
            if let fileURL = fileURL {
                QuickViewController(url: fileURL)
            } else {
                Text("An error occurred previewing this attachment")
            }
        }
        .navigationTitle(attachment.fileName ?? "Attachment")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: tryToWriteFile)
        .onDisappear(perform: tryToRemoveFile)
    }
}

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
    @State private var loading: Bool = true

    init(attachment: Attachment) {
        self.attachment = attachment
    }

    func tryToWriteFile() {
        DispatchQueue.global(qos: .userInteractive).async {
            if let contents = attachment.fileContents {
                let tempFileURL = temporaryFileURL(filename: attachment.fileName)
                ignoreErrors {
                    try contents.write(to: tempFileURL)
                }
                DispatchQueue.main.async {
                    fileURL = tempFileURL
                    loading = false
                }
            } else {
                DispatchQueue.main.async {
                    fileURL = nil
                    loading = false
                }
            }
         }
    }

    func tryToRemoveFile() {
        if let fileURL = fileURL {
            DispatchQueue.global(qos: .background).async {
                ignoreErrors {
                    try FileManager.default.removeItem(at: fileURL)
                }
            }
        }
        fileURL = nil
    }

    var body: some View {
        Group {
            if loading {
                ProgressView()
            } else if let fileURL = fileURL {
                QuickViewController(url: fileURL)
            } else {
                Text("An error occurred previewing this attachment")
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: share) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
        }
        .navigationTitle(attachment.fileName ?? "Attachment")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: tryToWriteFile)
        .onDisappear(perform: tryToRemoveFile)
    }

    private func share() {
        guard let fileURL = fileURL else {
            return
        }
        guard let keyWindow = UIApplication.shared.keyWindow else {
            return
        }
        let activityViewController = UIActivityViewController(
            activityItems: [fileURL], applicationActivities: nil
        )
        keyWindow.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
}

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
import FilePicker
import ImagePickerView

struct AttachmentsView<T: ObservableObject & HasRawAttachments & HasAttachments & Notifiable>: View {
    @Environment(\.editable) private var editable
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var owner: T

    @State private var adding: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var showCamera: Bool = false

    var body: some View {
        let attachments = owner.attachments.sorted
        ForEachObjects(attachments) { attachment in
            NavigationLink(
                destination: {
                    AttachmentView(attachment: attachment)
                },
                label: {
                    AttachmentLabelView(attachment: attachment)
                }
            )
        }
        .onMove {
            print("notify change")
            owner.notifyChange()
        }
        .onAppear {
            attachments.normalize()
        }
        if adding {
            ProgressView()
        } else if editable {
            FilePicker(
                types: [.data],
                allowMultiple: true,
                onPicked: addAttachments,
                label: {
                    Text("\(Image(systemName: "plus")) Add attachment")
                }
            )
            Button("\(Image(systemName: "plus")) Add image") {
                showImagePicker = true
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(sourceType: .photoLibrary, onImagePicked: addImage)
            }
            Button("\(Image(systemName: "camera")) Capture image") {
                showCamera = true
            }
            .sheet(isPresented: $showCamera) {
                ImagePickerView(sourceType: .camera, onImagePicked: addImage)
            }
        }
    }

    private func addImage(image: UIImage) {
        withAnimation {
            adding = true
        }
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = image.heicData {
                let attachment = Attachment(context: viewContext)
                attachment.fileExtension = "heic"
                attachment.fileName = "Image"
                attachment.fileContents = data
                attachment.fileSize = Int64(data.count)
                DispatchQueue.main.async {
                    attachment.sortOrder = (owner.attachments.map(\.sortOrder).max() ?? 0) + 1
                    attachment.owner = owner
                    adding = false
                }
            } else {
                DispatchQueue.main.async {
                    withAnimation {
                        adding = false
                    }
                }
            }
        }
    }

    private func addAttachments(urls: [URL]) {
        withAnimation {
            adding = true
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let attachments = urls.compactMap { url -> Attachment? in
                ignoreErrors {
                    let attachment = Attachment(context: viewContext)
                    try attachment.importFile(url: url)
                    return attachment
                }
            }
            DispatchQueue.main.async {
                withAnimation {
                    var sortOrder = (owner.attachments.map(\.sortOrder).max() ?? 0) + 1
                    for attachment in attachments {
                        attachment.owner = owner
                        attachment.sortOrder = sortOrder
                        sortOrder += 1
                    }
                    adding = false
                    ignoreErrors {
                        try viewContext.save()
                    }
                }
            }
        }
    }
}

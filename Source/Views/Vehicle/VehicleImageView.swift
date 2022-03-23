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
import ImagePickerView

struct VehicleImageView: View {
    @Environment(\.editable) private var editable
    @Environment(\.managedObjectContext) private var viewContext

    @Binding var imageData: Data?

    @State private var image: UIImage?

    @State private var showImagePicker: Bool = false

    @ViewBuilder
    func imagePickerSheet() -> some View {
        ImagePickerView(sourceType: .photoLibrary) { image in
            imageData = (image.resize(maxWidth: 750) ?? image).jpegData(compressionQuality: 6)
        }
    }

    @ViewBuilder
    func imageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(20)
    }

    var body: some View {
        Group {
            if let image = image {
                if editable {
                    ZStack(alignment: .topTrailing) {
                        Button(
                            action: {
                                showImagePicker = true
                            }, label: {
                                imageView(image)
                            }
                        )
                        Button(
                            action: {
                                self.imageData = nil
                            }, label: {
                                if editable {
                                    Image(systemName: "xmark.circle")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: 20, maxHeight: 20)
                                        .foregroundColor(.red)
                                        .padding(15)
                                }
                            }
                        )
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(EmptyView())
                } else {
                    imageView(image)
                        .listRowBackground(EmptyView())
                }
            } else if editable {
                Button("Add image") {
                    showImagePicker = true
                }
            } else {
                Text("No image")
            }
        }
        .sheet(isPresented: $showImagePicker, content: imagePickerSheet)
        .onAppear {
            if let imageData = imageData {
                image = UIImage(data: imageData)
            }
        }
        .onChange(of: imageData) { newImageData in
            if let newImageData = newImageData {
                image = UIImage(data: newImageData)
            } else {
                image = nil
            }
        }
    }
}

#if DEBUG
struct VehicleImageView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            List {
                VehicleImageView(imageData: Binding(
                    get: { fixtures.vehicle.imageData },
                    set: { _ in }
                ))
            }
        }
    }
}
#endif

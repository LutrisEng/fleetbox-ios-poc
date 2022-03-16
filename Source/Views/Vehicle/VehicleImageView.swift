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
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var vehicle: Vehicle

    @State private var showImagePicker: Bool = false

    @ViewBuilder
    func imagePickerSheet() -> some View {
        ImagePickerView(sourceType: .photoLibrary) { image in
            vehicle.image = image
            ignoreErrors {
                try viewContext.save()
            }
        }
    }

    var body: some View {
        if let image = vehicle.image {
            Section {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .listRowBackground(EmptyView())
            Section {
                Button("Remove image") {
                    vehicle.image = nil
                    ignoreErrors {
                        try viewContext.save()
                    }
                }
                Button("Change image") {
                    showImagePicker = true
                }
            }
            .sheet(isPresented: $showImagePicker, content: imagePickerSheet)
        } else {
            Section {
                Button("Add image") {
                    showImagePicker = true
                }
            }
            .sheet(isPresented: $showImagePicker, content: imagePickerSheet)
        }
    }
}

struct VehicleImageView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            List {
                VehicleImageView(vehicle: fixtures.vehicle)
            }
        }
    }
}

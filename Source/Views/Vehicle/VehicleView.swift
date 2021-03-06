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
import Gzip

enum ExportError: Error {
    case unknownError
}

struct VehicleView: View {
    @Environment(\.editable) private var editable

    @ObservedObject var vehicle: Vehicle

    @State private var exporting: Bool = false

    @ViewBuilder
    var formList: some View {
        VehicleDetailsView(vehicle: vehicle)
        WarrantiesView(underlying: vehicle)
        Section(header: Text("Attachments")) {
            AttachmentsView(owner: vehicle)
        }
        MaintenanceLogView(vehicle: vehicle)
    }

    var body: some View {
        VStack {
            GeometryReader { geometry in
                if geometry.size.width > 750 && vehicle.imageData != nil {
                    HStack {
                        VStack {
                            Spacer()
                            VehicleImageView(imageData: $vehicle.imageData)
                                .padding()
                            Spacer()
                        }
                        Form {
                            formList
                        }
                    }
                    .background(Color(UIColor.systemGroupedBackground))
                } else {
                    Form {
                        VehicleImageView(imageData: $vehicle.imageData)
                        formList
                    }
                }
            }
        }
        .modifier(SaveOnLeave())
        .navigationTitle(vehicle.fullModelName)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if editable {
                    if exporting {
                        ProgressView()
                    } else {
                        Menu(
                            content: {
                                Button(
                                    "Share with attachments",
                                    action: {
                                        share(
                                            settings: ExportSettings(
                                                includeAttachments: true,
                                                includeImages: true
                                            )
                                        )
                                    }
                                )
                                Button(
                                    "Share without attachments",
                                    action: {
                                        share(
                                            settings: ExportSettings(
                                                includeAttachments: false,
                                                includeImages: false
                                            )
                                        )
                                    }
                                )
                            },
                            label: {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                        )
                    }
                    NavigationLink(
                        destination: {
                            OdometerReadingFormView(vehicle: vehicle)
                        },
                        label: {
                            Label("Add odometer reading", systemImage: "123.rectangle")
                        }
                    )
                    EditButton()
                }
            }
        }
    }

    private func share(settings: ExportSettings) {
        withAnimation {
            exporting = true
        }
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                guard let data = try vehicle.export(settings: settings) else {
                    throw ExportError.unknownError
                }
                let gzipped = try data.gzipped()
                let fileURL = temporaryFileURL(
                    fileName: vehicle.displayNameWithFallback,
                    fileExtension: "fleetboxvehicle"
                )
                try gzipped.write(to: fileURL)
                DispatchQueue.main.async {
                    withAnimation {
                        if let keyWindow = UIApplication.shared.keyWindow {
                            let activityViewController = UIActivityViewController(
                                activityItems: [fileURL], applicationActivities: nil
                            )
                            keyWindow.rootViewController?.present(activityViewController, animated: true) {
                                exporting = false
                            }
                        }
                    }
                }
            } catch {
                sentryCapture(error: error)
                withAnimation {
                    exporting = false
                }
            }
        }
    }
}

#if DEBUG
struct VehicleView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            VehicleView(vehicle: fixtures.vehicle)
        }
    }
}
#endif

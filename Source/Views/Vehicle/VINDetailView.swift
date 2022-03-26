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

struct VINDetailView: View {
    @Environment(\.editable) private var editable
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var vehicle: Vehicle
    @State private var state: ViewState = .base
    @State private var err: Bool = false
    @State private var success: Bool = false

    private func setState(_ newState: ViewState) async {
        state = newState
        switch newState {
        case .ok:
            err = false
            success = true
            await ignoreErrors {
                try await Task.sleep(nanoseconds: 3 * UInt64(NSEC_PER_SEC))
            }
            await setState(.base)
        case .err:
            err = true
            success = false
            await ignoreErrors {
                try await Task.sleep(nanoseconds: 3 * UInt64(NSEC_PER_SEC))
            }
            await setState(.base)
        case .base:
            err = false
            success = false
        case .loading:
            err = false
            success = false
        }
    }

    enum ViewState {
        // swiftlint:disable:next identifier_name
        case base, loading, ok, err
    }

    var body: some View {
        HStack {
            FleetboxTextField(value: $vehicle.vin, name: "VIN", example: dummyData.vin)
                .textInputAutocapitalization(.characters)
            if editable, let vin = vehicle.vin, vin != "" {
                switch state {
                case .base:
                    Button(
                            action: decode,
                            label: {
                                Image(systemName: "square.and.arrow.down")
                            }
                    )
                            .padding(.trailing, 8)
                            .frame(width: 30)
                            .buttonStyle(BorderlessButtonStyle())
                case .loading:
                    ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding(.trailing, 8)
                            .frame(width: 30)
                case .ok:
                    Image(systemName: "checkmark")
                            .padding(.trailing, 8)
                            .frame(width: 30)
                            .foregroundColor(.green)
                case .err:
                    Image(systemName: "xmark")
                            .padding(.trailing, 8)
                            .frame(width: 30)
                            .foregroundColor(.red)
                }
            }
        }
        .alert("VIN decoded!", isPresented: $success, actions: {}, message: {
            Text("The VIN was successfully decoded into year, make, and/or model.")
        })
        .alert("Failed to decode VIN", isPresented: $err, actions: {}, message: {
            Text(
                    "An error occurred while decoding your VIN. Check to make sure you typed your VIN " +
                            "correctly, and check your network connection."
            )
        })
    }

    private func decode() {
        if let vin = vehicle.vin, vin != "" {
            Task.init {
                await setState(.loading)
                do {
                    let decoderResult = try await decodeVIN(vin)
                    if decoderResult.errorCode != 0 {
                        print("error code", decoderResult.errorCode)
                        await setState(.err)
                        return
                    }
                    if let modelYear = decoderResult.modelYear {
                        vehicle.year = Int64(modelYear)
                    }
                    vehicle.make = decoderResult.make ?? vehicle.make
                    vehicle.model = decoderResult.model ?? vehicle.model
                } catch {
                    SentrySDK.capture(error: error)
                    await setState(.err)
                    return
                }
                await setState(.ok)
            }
        }
    }
}

#if DEBUG
struct VINDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            VINDetailView(vehicle: fixtures.vehicle)
        }
    }
}
#endif

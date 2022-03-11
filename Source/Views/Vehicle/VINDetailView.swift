//
//  VINDetailView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/11/22.
//

import SwiftUI
import Sentry

struct VINDetailView: View {
    @ObservedObject var vehicle: Vehicle
    @State private var state: ViewState = .base
    @State private var err: Bool = false
    
    enum ViewState {
        case base, loading, ok, err
    }
    
    var body: some View {
        HStack {
            FleetboxTextField(value: $vehicle.vin, name: "VIN", example: dummyData.vin)
            if let vin = vehicle.vin, vin != "" {
                switch state {
                case .base:
                    Button(
                        action: {
                            Task.init {
                                state = .loading
                                do {
                                    // TODO: error dialog
                                    let decoderResult = try await decodeVIN(vin)
                                    if decoderResult.errorCode != 0 {
                                        print("error code", decoderResult.errorCode)
                                        state = .err
                                        err = true
                                        await ignoreErrors {
                                            try await Task.sleep(nanoseconds: 3 * UInt64(NSEC_PER_SEC))
                                        }
                                        state = .base
                                        return
                                    }
                                    if let modelYear = decoderResult.modelYear {
                                        vehicle.year = Int64(modelYear)
                                    }
                                    vehicle.make = decoderResult.make ?? vehicle.make
                                    vehicle.model = decoderResult.model ?? vehicle.model
                                } catch {
                                    SentrySDK.capture(error: error)
                                    state = .err
                                    err = true
                                    await ignoreErrors {
                                        try await Task.sleep(nanoseconds: 3 * UInt64(NSEC_PER_SEC))
                                    }
                                    state = .base
                                    return
                                }
                                state = .ok
                                await ignoreErrors {
                                    try await Task.sleep(nanoseconds: 3 * UInt64(NSEC_PER_SEC))
                                }
                                state = .base
                            }
                        }
                    ) {
                        Image(systemName: "square.and.arrow.down")
                    }
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
        .alert("Failed to decode VIN", isPresented: $err, actions: {}) {
            Text("An error occurred while decoding your VIN. Check to make sure you typed your VIN correctly, and check your network connection.")
        }
    }
}

struct VINDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            VINDetailView(vehicle: fixtures.vehicle)
        }
    }
}

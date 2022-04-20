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
import VehicleKit

struct VehicleKitAuthenticationView: View {
    enum ViewState {
        case loading
        case prompt(api: VKVehicleAPI, prompt: VKAuthenticationPrompt)
    }

    @Environment(\.dismiss) private var dismiss

    @ObservedObject var vehicle: Vehicle
    let api: VKAPIDirectory.API

    @State var state: ViewState = .loading
    @State var error: Error?
    @State var showError: Bool = false

    func beginAuthentication() {
        Task.init {
            do {
                let vehicleAPI = api.type.init()
                if let prompt = try await vehicleAPI.beginAuthentication() {
                    self.state = .prompt(api: vehicleAPI, prompt: prompt)
                } else {
                    finishAuthentication(api: vehicleAPI, response: .viewDismissed)
                }
            } catch {
                self.error = error
                showError = true
            }
        }
    }

    func finishAuthentication(api: VKVehicleAPI, response: VKAuthenticationResponse) {
        let oldState = state
        state = .loading
        Task.init {
            do {
                try await api.finishAuthentication(response: response)
                dismiss()
            } catch {
                self.error = error
                showError = true
                state = oldState
            }
        }
    }

    var body: some View {
        Group {
            switch state {
            case .loading: ProgressView()
            case .prompt(let api, let prompt):
                VehicleKitAuthenticationPromptView(prompt: prompt) {
                    finishAuthentication(api: api, response: $0)
                }
            }
        }
        .onAppear(perform: beginAuthentication)
        .navigationTitle("\(api.name)")
        .alert("Error", isPresented: $showError, actions: {}, message: {
            if let error = error {
                Text(error.localizedDescription)
            } else {
                Text("An error occurred.")
            }
        })
    }
}

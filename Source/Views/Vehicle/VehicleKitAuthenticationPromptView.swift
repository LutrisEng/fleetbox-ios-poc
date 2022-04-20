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

struct VehicleKitAuthenticationPromptView: View {
    let prompt: VKAuthenticationPrompt
    let onComplete: (VKAuthenticationResponse) -> Void

    @State var tokenValue: String?
    @State var usernameValue: String?
    @State var passwordValue: String?

    var body: some View {
        switch prompt {
        case .token:
            Form {
                FleetboxTextField(value: $tokenValue, name: "Authentication token", example: "abc123")
                    .password()
                Button("Submit") {
                    onComplete(.token(token: tokenValue.denormalized))
                }
            }
        case .usernamePassword:
            Form {
                FleetboxTextField(value: $usernameValue, name: "Username", example: nil)
                    .textContentType(.username)
                FleetboxTextField(value: $passwordValue, name: "Password", example: "hunter2")
                    .password()
                Button("Login") {
                    onComplete(.usernamePassword(
                        username: usernameValue.denormalized,
                        password: passwordValue.denormalized
                    ))
                }
            }
        case .view(let view):
            view
        }
    }
}

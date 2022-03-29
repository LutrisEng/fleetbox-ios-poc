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

struct OSProject: Identifiable {
    let name: String
    let url: URL
    let license: String

    var id: String {
        name
    }
}

let osProjects: [OSProject] = [
    OSProject(
        name: "Fleetbox",
        url: URL(string: "https://github.com/LutrisEng/fleetbox")!,
        license: "GPL-3.0-or-later"
    ),
    OSProject(
        name: "Alamofire",
        url: URL(string: "https://github.com/Alamofire/Alamofire")!,
        license: "MIT"
    ),
    OSProject(
        name: "sentry-cocoa",
        url: URL(string: "https://github.com/getsentry/sentry-cocoa")!,
        license: "MIT"
    ),
    OSProject(
        name: "ImagePickerView",
        url: URL(string: "https://github.com/ralfebert/ImagePickerView")!,
        license: "MIT"
    ),
    OSProject(
        name: "FilePicker",
        url: URL(string: "https://github.com/markrenaud/FilePicker")!,
        license: "MIT"
    ),
    OSProject(
        name: "GzipSwift",
        url: URL(string: "https://github.com/1024jp/GzipSwift")!,
        license: "MIT"
    ),
    OSProject(
        name: "SwiftUI-Introspect",
        url: URL(string: "https://github.com/siteline/SwiftUI-Introspect")!,
        license: "MIT"
    )
]

struct AboutView: View {
    var body: some View {
        NavigationView {
            List {
                HStack {
                    Spacer()
                    Image(debug ? "FleetboxLogo-Debug" : "FleetboxLogo").cornerRadius(20)
                    Spacer()
                }
                .listRowBackground(EmptyView())
                #if DEBUG
                Section(header: Text("Developer Mode")) {
                    Text("This Fleetbox build was done in developer (or \"") +
                    Text("DEBUG").font(.body.monospaced()) +
                    Text("\") mode.")

                    Text("Your developer mode data is stored separately from your release mode " +
                         "data, so that you don't end up corrupting your important data during development.")

                    Text("Developer mode builds are done without optimizations, so you may experience performance " +
                         "issues - check a release mode build to see if a performance issue actually matters.")
                }
                #endif
                Section(header: Text("Private beta")) {
                    Text(
                        "Fleetbox is currently in a private beta. Please report any issues using " +
                        "TestFlight or by contacting your Lutris contact."
                    )
                }
                Section(header: Text("Open-source projects")) {
                    Text(
                        "Not only is Fleetbox open-source, we depend on the work done by a " +
                        "bunch of other open-source projects to make this thing work!"
                    )
                    ForEach(osProjects) { osProject in
                        Link(destination: osProject.url) {
                            VStack {
                                Text(osProject.name)
                                    .font(.body.bold())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("License (in SPDX format): \(osProject.license)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
            }
            .navigationTitle("About Fleetbox")
        }
        .navigationViewStyle(.stack)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}

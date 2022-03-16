//
//  AboutView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/15/22.
//

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
    OSProject(name: "Fleetbox", url: "https://github.com/LutrisEng/fleetbox", license: "GPL-3.0-or-later WITH AppStore-exception"),
    OSProject(
        name: "Alamofire",
        url: URL(string: "https://github.com/Alamofire/Alamofire")!,
        license: "MIT"
    ),
    OSProject(
        name: "sentry-cocoa",
        url: URL(string: "https://github.com/getsentry/sentry-cocoa")!,
        license: "MIT"
    )
]

struct AboutView: View {
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Image("FleetboxLogo")
                    Text("Private Beta")
                        .font(.title)
                    Text(
                        "Fleetbox is currently in a private beta. Please report any issues using " +
                        "TestFlight or by contacting your Lutris contact."
                    )
                    Text("Open-source projects")
                        .font(.title)
                    Text(
                        "Not only is Fleetbox open-source, we depend on the work done by a " +
                        "bunch of other open-source projects to make this thing work!"
                    )
                }
                .padding()
                List {
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
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}

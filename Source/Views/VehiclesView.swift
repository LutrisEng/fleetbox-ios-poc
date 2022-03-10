//
//  ContentView.swift
//  Shared
//
//  Created by Piper McCorkle on 2/28/22.
//

import SwiftUI
import CoreData
import CoreSpotlight
import Sentry

struct VehiclesView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Vehicle.sortOrder, ascending: true)],
        animation: .default)
    private var vehicles: FetchedResults<Vehicle>
    
    @State private var selection: String? = nil

    var body: some View {
        NavigationView {
            List {
                ForEach(vehicles, id: \.self) { vehicle in
                    NavigationLink(
                        vehicle.displayNameWithFallback,
                        destination: VehicleView(vehicle: vehicle),
                        tag: vehicle.objectID.uriRepresentation().absoluteString,
                        selection: $selection)
                }.onDelete { offsets in
                    withAnimation {
                        offsets.map { vehicles[$0] }.forEach(viewContext.delete)

                        do {
                            try viewContext.save()
                        } catch {
                            SentrySDK.capture(error: error)
                            // Replace this implementation with code to handle the error appropriately.
                            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    }
                }
            }.navigationTitle("Vehicles")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
//                    ToolbarItem {
//                        Button(action: addVehicle) {
//                            Label("Add Vehicle", systemImage: "plus")
//                        }
//                    }
                    ToolbarItem {
                        Button(action: addFixtures) {
                            Label("Add Fixtures", systemImage: "plus")
                        }
                    }
                }
            Text("Select a vehicle")
        }.onContinueUserActivity(CSSearchableItemActionType, perform: handleSpotlight)
    }
    
    private func handleSpotlight(_ userActivity: NSUserActivity) {
        print("handle spotlight")
        if let id = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            print("id \(id)")
            self.selection = id
        }
    }

    private func addVehicle() {
        withAnimation {
            let vehicle = Vehicle(context: viewContext)
            vehicle.year = 2022
            vehicle.make = "BMW"
            vehicle.model = "M340i"
            vehicle.vin = "3MW5U7J09N8C40580"
            let firstLogItem = LogItem(context: viewContext)
            firstLogItem.vehicle = vehicle
            firstLogItem.performedAt = Date.now
            let firstLineItem = LineItem(context: viewContext)
            firstLineItem.logItem = firstLogItem
            firstLineItem.typeId = "engineOilChange"
            selection = vehicle.objectID.uriRepresentation().absoluteString

            do {
                try viewContext.save()
            } catch {
                SentrySDK.capture(error: error)
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func addFixtures() {
        withAnimation {
            _ = PersistenceController.Fixtures(viewContext: viewContext)
        }
    }
}

struct VehiclesView_Previews: PreviewProvider {
    static var previews: some View {
        VehiclesView().environment(\.managedObjectContext, PersistenceController.preview.viewContext)
    }
}

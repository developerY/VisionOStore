//
//  RideLinksView.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 5/28/25.
//
import SwiftUI

struct RideLinksView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Ride Screens") {
// ModelTestView
                    NavigationLink("Store Front View") {
                        //SettingsView()
                        StoreFrontSplitView()
                    }
                    
                    NavigationLink("Test View") {
                        //SettingsView()
                        ModelTestView()
                    }
                    
                    NavigationLink("Test DB") {
                        //SettingsView()
                        SwiftDataTestView()
                    }
                    
                    NavigationLink("Test Chart DB") {
                        //SettingsView()
                        SwiftDataChartTestView()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Ride Menu")
        }
    }
}

#Preview() {
    RideLinksView()
}

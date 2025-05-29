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
                    NavigationLink("Original Item List") {
                        //SettingsView()
                        OpenContentView()
                    }
                    NavigationLink("Text Nav") {
                        //SettingsView()
                        NavTestView()
                    }
                    NavigationLink("Text Nav") {
                        //SettingsView()
                        NavTestView()
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

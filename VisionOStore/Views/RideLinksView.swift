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
                    
                    
                    NavigationLink("Store") {
                        StoreFrontSplitView()
                    }
                    
                    
                    NavigationLink("Original Item List") {
                        //SettingsView()
                        OpenContentView()
                    }
                    NavigationLink("Text Nav") {
                        //SettingsView()
                        NavTestView()
                    }
                    NavigationLink("Store Front View") {
                        //SettingsView()
                        StoreFrontView()
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

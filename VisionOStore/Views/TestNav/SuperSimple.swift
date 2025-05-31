//
//  SuperSimple.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 5/30/25.
//
import SwiftUI
import SwiftData



struct SuperSimple: View {
    @State private var selectedItem: String?

    var body: some View {
        NavigationSplitView {
            SidebarView(selectedItem: $selectedItem)
        } detail: {
            DetailView(selectedItem: $selectedItem)
        }
    }
}

struct SidebarView: View {
    @Binding var selectedItem: String?

    private let items = ["Item 1", "Item 2", "Item 3", "Item 4"]

    var body: some View {
        List(items, id: \.self, selection: $selectedItem) { item in
            Text(item)
                .onTapGesture {
                    selectedItem = item
                }
        }
        .navigationTitle("Items")
    }
}

struct DetailView: View {
    @Binding var selectedItem: String?

    var body: some View {
        if let item = selectedItem {
            Text("Detail view for \(item)")
                .navigationTitle(item)
        } else {
            Text("Select an item")
                .navigationTitle("Details")
        }
    }
}

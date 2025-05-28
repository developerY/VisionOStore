//
//  OpenContentView.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 5/23/25.
//
import SwiftUI
import SwiftData

struct OpenContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [DataExampleItem]

    var body: some View {
        // ← add this
        NavigationStack {
            NavigationSplitView {
                List(items, id: \.id) { item in
                    // ⚠️ VALUE‐BASED LINK
                    NavigationLink(value: item) {
                        Text(item.timestamp, format: .dateTime)
                    }
                }
                .toolbar {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
#if os(macOS)
                .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
                .toolbar {
#if os(iOS)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
#endif
                    ToolbarItem {
                        Button(action: addItem) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
            } detail: {
                // placeholder when nothing’s selected
                Text("Select an item")
            }
            // ⚠️ THIS WILL NOW ACTUALLY RUN
            .navigationDestination(for: DataExampleItem.self) { item in
                Text("Item at \(item.timestamp, format: .dateTime)")
                    .navigationTitle("Detail")
            }
        }
    }
        
        private func addItem() {
            withAnimation {
                let newItem = DataExampleItem(timestamp: Date())
                modelContext.insert(newItem)
            }
        }
    
}

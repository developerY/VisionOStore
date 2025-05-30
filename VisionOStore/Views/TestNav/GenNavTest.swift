//
//  GenNavTest.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 5/30/25.
//
import SwiftUI
import SwiftData

// 1) Your data model
@Model
class Item {
    var id = UUID()
    var name: String

    init(name: String) {
        self.name = name
    }
}

// 2) The split view
struct GenNavTestView: View {
    @Query var items: [Item]
    @State private var selection: Item?

    var body: some View {
        NavigationSplitView {
            List(items, selection: $selection) { item in
                Text(item.name)
            }
            .navigationTitle("Items")
        } detail: {
            if let item = selection {
                Text(item.name)
                    .font(.largeTitle)
                    .padding()
            } else {
                Text("Select an item")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// 3) Preview with in-memory container and sample data
#Preview {
    let container = try! ModelContainer(
        for: Item.self,
        configurations: .init(isStoredInMemoryOnly: true)
    )

    ContentView()
        .modelContainer(container)
        .onAppear {
            let ctx = container.mainContext
            ctx.insert(Item(name: "Apple"))
            ctx.insert(Item(name: "Banana"))
            ctx.insert(Item(name: "Cherry"))
        }
}


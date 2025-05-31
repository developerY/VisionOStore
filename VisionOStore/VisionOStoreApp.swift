//
//  VisionOStoreApp.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 5/28/25.
//

import SwiftUI
import SwiftData
import OSLog

let logger = Logger(subsystem: "com.yourcompany.app", category: "Data")


@main
struct VisionOStoreApp: App {

    @State private var appModel = AppModel()
    
    
    var sharedModelContainer: ModelContainer = {
            let schema = Schema([
                DataExampleItem.self, // Example Data
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }()
    
    init() {
        do {
            // Define the schema for the ModelContainer
            let schema = Schema([
                ProductSplit.self,
                // Add other models here if you have them
            ])

            // Configure the ModelContainer
            // For in-memory store (testing/previews):
            // let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            // For persistent store (default):
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

            sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])

            // Call the function to populate data after the container is successfully created
            populateSampleDataIfNeeded(modelContext: sharedModelContainer.mainContext)

        } catch {
            // Handle the error appropriately in a real app
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
                .modelContainer(sharedModelContainer)
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .modelContainer(sharedModelContainer)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}

extension ModelContext {
    func dumpAllProducts() {
        do {
            let all: [ProductSplit] = try fetch(FetchDescriptor<ProductSplit>())
            logger.info("⛓️ ⁨Found \(all.count) products⁩")
            for p in all {
                logger.info("• \(p.name)") // — $\(String(format: \"%.2f\", p.price))")
            }
        } catch {
            logger.error("Failed to fetch products: \(error.localizedDescription)")
        }
    }
}


// Function to populate sample data if the store is empty for this model type
func populateSampleDataIfNeeded(modelContext: ModelContext) {
    // Perform a fetch to see if any ProductSplit objects already exist
    // This is a simple way to check; for more complex scenarios, you might use a version flag or similar
    let fetchDescriptor = FetchDescriptor<ProductSplit>()

    do {
        let existingProducts = try modelContext.fetch(fetchDescriptor)
        if existingProducts.isEmpty {
            // If no products exist, insert the sample data
            print("No existing ProductSplit data found. Populating sample data...")
            for product in sampleProductsSplit {
                // Important: Create a new instance for insertion if sampleProductsSplit
                // are not already Model objects tied to a context.
                // If sampleProductsSplit were already @Model objects from another context,
                // you'd need a different approach (like deep copying or re-fetching).
                // Since sampleProductsSplit is just a plain array of structs/classes,
                // we insert them directly.
                modelContext.insert(product)
            }
            // Optionally, save the context immediately if needed,
            // though SwiftData often auto-saves.
            // try modelContext.save()
            print("Sample ProductSplit data populated.")
        } else {
            print("\(existingProducts.count) ProductSplit items already exist. No new sample data populated.")
        }
    } catch {
        // Handle fetch or save errors appropriately
        print("Failed to fetch or populate sample data: \(error)")
    }
}

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
    let modelContainer: ModelContainer

    
    init() {
        do {
            let schema = Schema([ProductSplit.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            
            // Step 1: Create the container
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Step 2: Perform subsequent setup using the now-initialized container
            populateSampleDataIfNeeded(modelContext: modelContainer.mainContext)
            
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }


    

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
                .modelContainer(modelContainer)
        }
        
        WindowGroup(id: "shopping-cart-window") {
            CartView()
        }
        .modelContainer(modelContainer)
        .defaultSize(width: 400, height: 600)

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .modelContainer(modelContainer)
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

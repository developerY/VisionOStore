//
//  VisionOStoreApp.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 5/28/25.
//

import SwiftUI
import SwiftData
import OSLog
@main
struct VisionOStoreApp: App {

    // Initialize the AppModel as a StateObject or just a let if its properties are @Published
    // With @Observable, a simple @State is fine.
    @State private var appModel = AppModel()
    let modelContainer: ModelContainer
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.yourapp", category: "YourApp")

    init() {
        Self.logger.info("Starting App...")

        do {
            let schema = Schema([
                    ProductSplit.self,
                    CartItem.self // <-- ADD THIS LINE
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            
            // Step 1: Create the container
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Step 2: Perform subsequent setup using the now-initialized container
            populateSampleDataIfNeeded(modelContext: modelContainer.mainContext)
            
        } catch {
            Self.logger.error("Could not create ModelContainer: \(error.localizedDescription)")
             fatalError("Could not create ModelContainer: \(error)")
        }
    }


    

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)

        }
        .modelContainer(modelContainer)
        
        WindowGroup(id: "shopping-cart-window") {
            CartView()
                .environment(appModel) // Also inject if CartView needs it
        }
        .modelContainer(modelContainer)
        .defaultSize(width: 400, height: 600)
        
        
        // Immersive Space for showing the selected product interactively
        ImmersiveSpace(id: appModel.generalImmersiveSpaceID) {
            GeneralImmersiveView()
                .environment(appModel)
                // .modelContainer(modelContainer) // Only if GeneralImmersiveView uses @Query or SwiftData directly
                .onAppear { appModel.immersiveSpaceState = .open }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                    appModel.selectedProductForImmersiveView = nil
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed) //(.full), in: .full)

        
        // Immersive Space for showing the selected product interactively
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel) // Inject AppModel
                .modelContainer(modelContainer) // If ImmersiveView needs SwiftData
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                    appModel.selectedProductForImmersiveView = nil // Clear selection when space closes
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)  //(.full), in: .full) // As per your previous code
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

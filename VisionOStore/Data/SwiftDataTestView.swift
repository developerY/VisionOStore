//
//  SwiftDataTestView.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 6/1/25.
//
import SwiftUI
import SwiftData
import OSLog

// MARK: - SwiftDataTestView (For basic SwiftData operations testing)
struct SwiftDataTestView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CartItem.productName) private var cartItems: [CartItem] // To display count and list
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.yourapp", category: "SwiftDataTestView")

    var body: some View {
        VStack(spacing: 20) {
            Text("SwiftData Basic Test")
                .font(.largeTitle)
                .padding(.bottom, 20)
            
            Text("Cart Items in Store (via @Query): \(cartItems.count)")
                .font(.headline)

            Button("Add Test CartItem & Save") {
                addTestItem()
            }
            .buttonStyle(.borderedProminent)
            .padding()

            Button("Fetch All CartItems (Log Only)") {
                fetchAllItems(messagePrefix: "Manual Fetch Button Pressed")
            }
            .buttonStyle(.bordered)
            
            Text("Items from @Query:")
            if cartItems.isEmpty {
                Text("No items found by @Query.")
            } else {
                List(cartItems) { item in
                    Text("\(item.productName) - Qty: \(item.quantity), Price: \(item.price, format: .currency(code: "USD"))")
                }
            }
        }
        .padding()
        .onAppear {
            logger.info("SwiftDataTestView appeared. Initial cart items via @Query: \(cartItems.count)")
            if !cartItems.isEmpty {
                for item in cartItems {
                    logger.info("--> Initial @Query Item: \(item.productName), Qty: \(item.quantity)")
                }
            }
        }
    }

    func addTestItem() {
        logger.notice("--- Attempting to add TestItem ---")
        logger.info("Context hasChanges (start of addTestItem): \(modelContext.hasChanges)")

        let testProductName = "Test Shoe \(Int.random(in: 1...1000))" // Unique name for testing
        let newItem = CartItem(productName: testProductName, price: 1.99, quantity: 1, modelName: "test.usdz")
        logger.info("Created new CartItem: \(newItem.productName)")

        modelContext.insert(newItem)
        logger.info("Called modelContext.insert(). Context hasChanges (after insert): \(modelContext.hasChanges)")

        do {
            logger.info("Attempting to save context. Context hasChanges (before save): \(modelContext.hasChanges)")
            try modelContext.save()
            logger.info("Model context saved successfully. Context hasChanges (after save): \(modelContext.hasChanges)")
        } catch {
            logger.error("Error saving context: \(error.localizedDescription)")
        }
        
        fetchAllItems(messagePrefix: "Verification fetch immediately after addTestItem")
    }
    
    func fetchAllItems(messagePrefix: String = "Fetching all items") {
        logger.info("--- \(messagePrefix) ---")
        let fetchDescriptor = FetchDescriptor<CartItem>(sortBy: [SortDescriptor(\.productName)])
        do {
            let items = try modelContext.fetch(fetchDescriptor)
            logger.info("Fetched \(items.count) items via manual fetch.")
            if items.isEmpty {
                logger.warning("No items found in manual fetch.")
            } else {
                for item in items {
                    logger.info("--> Manually Fetched Item: \(item.productName), Qty: \(item.quantity)")
                }
            }
        } catch {
            logger.error("Error fetching items: \(error.localizedDescription)")
        }
        logger.info("Context hasChanges (after manual fetch): \(modelContext.hasChanges)")
        logger.info("------------------------------------")
    }
}

// Preview for the test view (optional, but good for isolation)
#Preview("SwiftDataTestView_Preview") {
    // For previewing this view in isolation, you'd need to set up a sample ModelContainer
    // This is more involved if the view is in a separate file from YourApp.swift
    // For now, rely on running it as the root view in YourApp.
    
    // Example of how you might set up a preview if needed:
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: CartItem.self, ProductSplit.self, configurations: config) // Add all models used
        
        // Optionally populate with test data for the preview
        // let sampleItem = CartItem(productName: "Preview Item", price: 9.99, quantity: 1, modelName: "preview.usdz")
        // container.mainContext.insert(sampleItem)
        
        return SwiftDataTestView()
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}

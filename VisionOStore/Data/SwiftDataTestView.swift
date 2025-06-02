//
//  SwiftDataTestView.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 6/1/25.
//
import SwiftUI
import SwiftData
import OSLog

// MARK: - SwiftDataTestView (Now testing ProductSplit)
struct SwiftDataTestView: View {
    @Environment(\.modelContext) private var modelContext
    // Temporarily query ProductSplit to see if it works
    @Query(sort: \ProductSplit.name) private var products: [ProductSplit]
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.yourapp", category: "SwiftDataTestView")

    var body: some View {
        VStack(spacing: 20) {
            Text("SwiftData Basic Test (ProductSplit)")
                .font(.largeTitle)
                .padding(.bottom, 20)
            
            Text("ProductSplits in Store (via @Query): \(products.count)")
                .font(.headline)

            Button("Add Test ProductSplit & Save") {
                addTestProductSplit()
            }
            .buttonStyle(.borderedProminent)
            .padding()

            Button("Fetch All ProductSplits (Log Only)") {
                fetchAllProductSplits(messagePrefix: "Manual Fetch Button Pressed")
            }
            .buttonStyle(.bordered)
            
            Text("Items from @Query:")
            if products.isEmpty {
                Text("No ProductSplits found by @Query.")
            } else {
                List(products) { product in
                    Text("\(product.name) - Price: \(product.price, format: .currency(code: "USD"))")
                }
            }
        }
        .padding()
        .onAppear {
            logger.info("SwiftDataTestView appeared. Initial ProductSplits via @Query: \(products.count)")
            if !products.isEmpty {
                for product in products {
                    logger.info("--> Initial @Query Product: \(product.name)")
                }
            }
             // Fetch all on appear to check initial state
            fetchAllProductSplits(messagePrefix: "OnAppear Fetch")
        }
    }

    func addTestProductSplit() {
        logger.notice("--- Attempting to add Test ProductSplit ---")
        logger.info("Context hasChanges (start of addTestProductSplit): \(modelContext.hasChanges)")

        let testProductName = "Test Product \(Int.random(in: 1...1000))"
        let newItem = ProductSplit(name: testProductName, price: 9.99, modelName: "test_product.usdz", thumbnailName: "photo", scale: 1.0)
        logger.info("Created new ProductSplit: \(newItem.name)")

        modelContext.insert(newItem)
        logger.info("Called modelContext.insert(). Context hasChanges (after insert): \(modelContext.hasChanges)")

        do {
            logger.info("Attempting to save context. Context hasChanges (before save): \(modelContext.hasChanges)")
            try modelContext.save()
            logger.info("Model context saved successfully. Context hasChanges (after save): \(modelContext.hasChanges)")
        } catch {
            logger.error("Error saving context: \(error.localizedDescription)")
        }
        
        fetchAllProductSplits(messagePrefix: "Verification fetch immediately after addTestProductSplit")
    }
    
    func fetchAllProductSplits(messagePrefix: String = "Fetching all ProductSplits") {
        logger.info("--- \(messagePrefix) ---")
        let fetchDescriptor = FetchDescriptor<ProductSplit>(sortBy: [SortDescriptor(\.name)])
        do {
            let items = try modelContext.fetch(fetchDescriptor)
            logger.info("Fetched \(items.count) ProductSplits via manual fetch.")
            if items.isEmpty {
                logger.warning("No ProductSplits found in manual fetch.")
            } else {
                for item in items {
                    logger.info("--> Manually Fetched ProductSplit: \(item.name)")
                }
            }
        } catch {
            logger.error("Error fetching ProductSplits: \(error.localizedDescription)")
        }
        logger.info("Context hasChanges (after manual fetch): \(modelContext.hasChanges)")
        logger.info("------------------------------------")
    }
}

// Preview for the test view
#Preview("SwiftDataTestView_ProductSplit_Preview") {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        // Ensure schema includes ProductSplit for this test
        let container = try ModelContainer(for: ProductSplit.self, CartItem.self, configurations: config)
        
        // Optionally populate with test data for the preview if needed
        // let sampleProduct = ProductSplit(name: "Preview Product", price: 19.99, modelName: "preview.usdz", thumbnailName: "photo", scale: 1.0)
        // container.mainContext.insert(sampleProduct)
        
        return SwiftDataTestView()
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}

//
//  SwiftDataChart.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 6/1/25.
//
import SwiftUI
import SwiftData
import OSLog

// MARK: - SwiftDataTestView (Now re-testing CartItem)
struct SwiftDataChartTestView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CartItem.productName) private var cartItems: [CartItem]
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.yourapp", category: "SwiftDataTestView")

    var body: some View {
        VStack(spacing: 20) {
            Text("SwiftData Basic Test (CartItem)")
                .font(.largeTitle)
                .padding(.bottom, 20)
            
            Text("Cart Items in Store (via @Query): \(cartItems.count)")
                .font(.headline)

            Button("Add Test CartItem & Save") {
                addTestCartItem()
            }
            .buttonStyle(.borderedProminent)
            .padding()

            Button("Fetch All CartItems (Log Only)") {
                fetchAllCartItems(messagePrefix: "Manual Fetch Button Pressed")
            }
            .buttonStyle(.bordered)
            
            Text("Items from @Query:")
            if cartItems.isEmpty {
                Text("No CartItems found by @Query.")
            } else {
                List(cartItems) { item in
                    Text("\(item.productName) - Qty: \(item.quantity), Price: \(item.price, format: .currency(code: "USD"))")
                }
            }
        }
        .padding()
        .onAppear {
            logger.info("SwiftDataTestView appeared. Initial CartItems via @Query: \(cartItems.count)")
            if !cartItems.isEmpty {
                for item in cartItems {
                    logger.info("--> Initial @Query CartItem: \(item.productName), Qty: \(item.quantity)")
                }
            }
            fetchAllCartItems(messagePrefix: "OnAppear Fetch")
        }
    }

    func addTestCartItem() {
        logger.notice("--- Attempting to add Test CartItem ---")
        logger.info("Context hasChanges (start of addTestCartItem): \(modelContext.hasChanges)")

        let testProductName = "Test Cart Item \(Int.random(in: 1...1000))"
        let newItem = CartItem(productName: testProductName, price: 2.99, quantity: 1, modelName: "cart_item_test.usdz")
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
        
        fetchAllCartItems(messagePrefix: "Verification fetch immediately after addTestCartItem")
    }
    
    func fetchAllCartItems(messagePrefix: String = "Fetching all CartItems") {
        logger.info("--- \(messagePrefix) ---")
        let fetchDescriptor = FetchDescriptor<CartItem>(sortBy: [SortDescriptor(\.productName)])
        do {
            let items = try modelContext.fetch(fetchDescriptor)
            logger.info("Fetched \(items.count) CartItems via manual fetch.")
            if items.isEmpty {
                logger.warning("No CartItems found in manual fetch.")
            } else {
                for item in items {
                    logger.info("--> Manually Fetched CartItem: \(item.productName), Qty: \(item.quantity)")
                }
            }
        } catch {
            logger.error("Error fetching CartItems: \(error.localizedDescription)")
        }
        logger.info("Context hasChanges (after manual fetch): \(modelContext.hasChanges)")
        logger.info("------------------------------------")
    }
}

// Preview for the test view
#Preview("SwiftDataTestView_CartItem_Preview") {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: CartItem.self, ProductSplit.self, configurations: config)
        
        return SwiftDataTestView()
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}

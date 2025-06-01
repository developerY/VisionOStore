//
//  StorFront.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 5/29/25.
//
import OSLog
import RealityKit  // if you want to inject 3D previews later
import RealityKitContent
import SwiftData
import SwiftUI

// MARK: – Your Data Model

// MARK: - Sample Data (Updated with scale values)
let sampleProductsSplit: [ProductSplit] = [
    .init(name: "Low Poly Shoe", price: 49.99, modelName: "StoreItems/Shoes/Shoes_low_poly", thumbnailName: "shoe.2.fill", scale: 0.5),
    .init(name: "Nike Air Zoom Pegasus 36", price: 129.99, modelName: "StoreItems/Shoes/Nike_Air_Zoom_Pegasus_36", thumbnailName: "shoe.fill", scale: 0.5),
    .init(name: "Classic Airforce Sneaker", price: 99.99, modelName: "StoreItems/Shoes/sneaker_airforce", thumbnailName: "shoe.2.fill", scale: 0.5),
    // Give this oversized model a smaller scale factor
    .init(name: "Nike Defy All Day", price: 79.50, modelName: "StoreItems/Shoes/Nike_Defy_All_Day_walking_sneakers_shoes", thumbnailName: "figure.walk", scale: 0.5),
    .init(name: "Adidas Sports Shoe", price: 110.00, modelName: "StoreItems/Shoes/Scanned_Adidas_Sports_Shoe", thumbnailName: "figure.run", scale: 0.5),
]


// MARK: – StoreFrontView
let log = Logger(subsystem: "com.yourcompany.app", category: "StoreFront")
// MARK: - Main Content View with NavigationSplitView
struct StoreFrontSplitView: View {
    @Query(sort: \ProductSplit.name) private var products: [ProductSplit]
    @State private var selectedProductForDetail: ProductSplit?

    var body: some View {
        NavigationSplitView {
            ProductSidebarView(
                products: products,
                selectedProduct: $selectedProductForDetail
            )
        } detail: {
            ProductDetailView(selectedProduct: selectedProductForDetail)
        }
    }
}
    

// MARK: - Product Row View
struct ProductRowView: View {
    let product: ProductSplit

    var body: some View {
        HStack {
            Image(systemName: product.thumbnailName)
                .symbolRenderingMode(.multicolor) // Make SF Symbols more colorful
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .cornerRadius(6)
                //.foregroundColor(.accentColor) // multicolor rendering overrides this
            VStack(alignment: .leading) {
                Text(product.name)
                    .font(.headline)
                Text(String(format: "$%.2f", product.price))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

    
// MARK: - Preview
#Preview {
    // Ensure the preview also has access to the model container
    // and sample data for ProductSplit if DetailView or its children use @Query or @Environment(\.modelContext)
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container: ModelContainer
    do {
        container = try ModelContainer(for: ProductSplit.self, configurations: config)
        // Populate with sample data for the preview
        let modelContext = container.mainContext
        if try modelContext.fetch(FetchDescriptor<ProductSplit>()).isEmpty {
            sampleProductsSplit.forEach { modelContext.insert($0) }
        }
        
        // Return the ContentView for a more complete preview,
        // or a specific DetailView instance if testing it in isolation.
        return ContentView()
            .modelContainer(container)
            
    } catch {
        fatalError("Failed to create model container for preview: \(error)")
    }
}

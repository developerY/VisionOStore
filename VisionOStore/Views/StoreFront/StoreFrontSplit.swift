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

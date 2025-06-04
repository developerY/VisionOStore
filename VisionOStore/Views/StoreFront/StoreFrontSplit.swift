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
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace // Action to open immersive spaces
    @Environment(AppModel.self) var appModel // Access AppModel
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.yourapp", category: "ContentView")


    var body: some View {
        NavigationSplitView {
            ProductSidebarView(
                products: products,
                selectedProduct: $selectedProductForDetail
            )
        } detail: {
            ProductDetailView(selectedProduct: selectedProductForDetail)
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) { // Example placement for immersive space buttons
                Button {
                    Task {
                        Self.logger.info("Attempting to open default immersive scene.")
                        await openImmersiveSpace(id: appModel.immersiveSpaceID)
                    }
                } label: {
                    Label("Default Scene", systemImage: "arkit.badge.xmark") // Icon for default scene
                }
                // Disable button if an immersive space is already open to prevent conflicts
                .disabled(appModel.immersiveSpaceState == .open && appModel.selectedProductForImmersiveView == nil)

                Spacer() // Use Spacer to push buttons apart or to one side

                // This button is more logically placed in DetailView as it's product-specific
                // But can be here for general access if desired.
                // Button {
                //     if let product = selectedProductForDetail ?? products.first { // Fallback to first product if none selected
                //         appModel.selectedProductForImmersiveView = product
                //         Task {
                //             Self.logger.info("Attempting to open general immersive space for \(product.name).")
                //             await openImmersiveSpace(id: appModel.generalImmersiveSpaceID)
                //         }
                //     } else {
                //         Self.logger.warning("No product selected or available to view immersively.")
                //     }
                // } label: {
                //     Label("View Product Immersively", systemImage: "rotate.3d")
                // }
                // .disabled(appModel.immersiveSpaceState == .open && appModel.selectedProductForImmersiveView != nil)
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

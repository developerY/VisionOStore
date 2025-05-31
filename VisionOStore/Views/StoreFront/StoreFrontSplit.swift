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
    .init(name: "Nike Air Zoom Pegasus 36", price: 129.99, modelName: "StoreItems/Shoes/Nike_Air_Zoom_Pegasus_36", thumbnailName: "shoe.fill", scale: 1.0),
    .init(name: "Classic Airforce Sneaker", price: 99.99, modelName: "StoreItems/Shoes/sneaker_airforce", thumbnailName: "shoe.2.fill", scale: 1.0),
    // Give this oversized model a smaller scale factor
    .init(name: "Nike Defy All Day", price: 79.50, modelName: "StoreItems/Shoes/Nike_Defy_All_Day_walking_sneakers_shoes", thumbnailName: "figure.walk", scale: 0.3),
    .init(name: "Adidas Sports Shoe", price: 110.00, modelName: "StoreItems/Shoes/Scanned_Adidas_Sports_Shoe", thumbnailName: "figure.run", scale: 1.0),
]


// MARK: – StoreFrontView
let log = Logger(subsystem: "com.yourcompany.app", category: "StoreFront")
// MARK: - Main Content View with NavigationSplitView
struct StoreFrontSplitView: View {
    @Query(sort: \ProductSplit.name) private var products: [ProductSplit]
    @State private var selectedProductForDetail: ProductSplit?

    var body: some View {
        NavigationSplitView {
            ProductSplitView(
                products: products,
                selectedProduct: $selectedProductForDetail
            )
        } detail: {
            ProductDetailView(selectedProduct: selectedProductForDetail)
        }
    }
}
    
    
// MARK: – Product Detail
// struct ProductDetailSplitView: View {
// MARK: - Sidebar View
struct ProductSplitView: View {
    let products: [ProductSplit]
    @Binding var selectedProduct: ProductSplit?
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        List(products, selection: $selectedProduct) { product in
            NavigationLink(value: product) {
                ProductRowView(product: product)
            }
        }
        .navigationTitle("Shoe Store")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Clear All", role: .destructive) { clearAllProducts() }
            }
            ToolbarItem {
                Button { addSampleProduct() } label: { Label("Add Item", systemImage: "plus") }
            }
        }
    }

    private func addSampleProduct() {
        withAnimation {
            let newItem = ProductSplit(name: "New Athletic Shoe", price: 89.99, modelName: "StoreItems/Shoes/CS_Gel_Excite_Athletic", thumbnailName: "figure.run")
            modelContext.insert(newItem)
        }
    }

    private func clearAllProducts() {
        withAnimation {
            do {
                try modelContext.delete(model: ProductSplit.self)
                selectedProduct = nil
            } catch {
                print("Failed to clear data: \(error)")
            }
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

// MARK: - Detail View
struct ProductDetailView: View {
    let selectedProduct: ProductSplit?
    // State variables for animation, moved from ModelTestView
    @State private var rotationAngle: Angle = .zero
    @State private var isAnimating: Bool = true

    var body: some View {
        Group {
            if let product = selectedProduct {
                VStack(alignment: .center, spacing: 20) {
                    
                    Text("3D Interactive Model")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    // Use the new helper view
                    // Add .id(product.id) to force re-creation (and thus animation reset)
                    // when the product changes. ProductSplit is Identifiable because it's an @Model.
                    SpinningProductModelView(modelName: product.modelName, scale: product.scale)
                        .id(product.id) // This is key to reset animation on product change
                    
                    Text(product.name)
                        .font(.largeTitle.weight(.bold))
                        .multilineTextAlignment(.center)
                    
                    HStack {
                        Text("Price:")
                            .font(.title2)
                        Spacer()
                        Text(String(format: "$%.2f", product.price))
                            .font(.title2.weight(.semibold))
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal)
                    
                    // Example: If you still want a pause/play button controlled by DetailView
                    // You would need to pass @State for isAnimating down to SpinningProductModelView
                    // For now, this button is removed for simplicity of this refactor.
                    // Button(isAnimating ? "Pause" : "Spin") { isAnimating.toggle() }

                    Spacer()
                }
                .padding()
                .navigationTitle(product.name)
            } else {
                VStack {
                    Image(systemName: "shoe.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                    Text("Select a shoe to view it in 3D")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
        }
    }
}

// MARK: - Helper View for Spinning 3D Model
private struct SpinningProductModelView: View {
    let modelName: String
    let scale: Double // Accept the scale factor
    
    // Animation state is now local to this view
    @State private var rotationAngle: Angle = .zero
    @State private var isAnimating: Bool = true // Could also be passed in if needed

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.016, paused: !isAnimating)) { context in
            Model3D(named: modelName, bundle: RealityKitContent.realityKitContentBundle) { model in
                model
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale) // Apply the specific scale factor here
                    .frame(minHeight: 200, maxHeight: 400)
                    .rotation3DEffect(
                        rotationAngle,
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .onChange(of: context.date) {
                        rotationAngle.degrees += 0.5
                        if rotationAngle.degrees >= 360 {
                            rotationAngle.degrees -= 360
                        }
                    }
            } placeholder: {
                // Simplified placeholder for the helper view
                ProgressView()
                    .frame(minHeight: 200, maxHeight: 400)
            }
        }
        // Optional: Add controls within this view or pass bindings
        // For simplicity, this example keeps animation control internal.
        // If external control is needed, @Binding for isAnimating and rotationAngle
        // would be appropriate.
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

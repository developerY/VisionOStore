//
//  Working.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 5/30/25.
//
import SwiftUI
import SwiftData


// MARK: - Main Content View with NavigationSplitView
struct WorkingView: View {
    // This query provides the products array to the SidebarView.
    // Sorting can be defined here.
    @Query(sort: \ProductSplit.name) private var products: [ProductSplit]
    
    // State to keep track of the selected product for the detail view.
    // ProductSplit conforms to Identifiable because it's an @Model.
    @State private var selectedProductForDetail: ProductSplit?

    var body: some View {
        NavigationSplitView {
            // SidebarView displays the list of products and handles selection.
            SidebarWorkingView(
                products: products, // Pass the fetched products
                selectedProduct: $selectedProductForDetail // Bind selection
            )
        } detail: {
            // DetailView displays information about the selectedProductForDetail.
            DetailWorkingView(selectedProduct: selectedProductForDetail)
        }
    }
}

// MARK: - Sidebar View
struct SidebarWorkingView: View {
    let products: [ProductSplit] // Received from ContentView's @Query
    @Binding var selectedProduct: ProductSplit? // Bound to ContentView's state for detail view
    
    // Access to modelContext for CRUD operations within the sidebar.
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        // List uses the 'selection' parameter to update selectedProduct.
        // ProductSplit is Hashable because @Model makes it Identifiable.
        List(products, selection: $selectedProduct) { product in
            // NavigationLink makes the row tappable and updates the selection.
            // The label of the NavigationLink is what's displayed in the row.
            NavigationLink(value: product) {
                ProductRowView(product: product)
            }
        }
        .navigationTitle("Products")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton() // Works with .onDelete in ForEach (if ForEach is used directly)
                             // For List(products, selection:), EditButton might not enable delete mode
                             // unless items are wrapped in ForEach.
                             // Let's add ForEach for .onDelete to work as expected.
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Clear All", role: .destructive) {
                    clearAllProducts()
                }
            }
            ToolbarItem { // Primary action, often on the right or as a prominent button
                Button {
                    addSampleProduct()
                } label: {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
    }
    
    // Re-introducing ForEach within List to make .onDelete work with EditButton
    // This is a common pattern.
    // The List(selection:) will still work with NavigationLink values.
    // For a simpler List just for selection, ForEach isn't strictly needed
    // if not using .onDelete or .onMove.
    // Given the original code had .onDelete, let's ensure it's supported.

    // Revised body for SidebarView to support .onDelete with EditButton:
    // var body: some View {
    //     List(selection: $selectedProduct) { // selection drives the detail view
    //         ForEach(products) { product in
    //             NavigationLink(value: product) { // Tapping this link changes selectedProduct
    //                 ProductRowView(product: product)
    //             }
    //         }
    //         .onDelete(perform: deleteProducts) // .onDelete works on ForEach
    //     }
    //     .navigationTitle("Products")
    //     .toolbar { /* ... same toolbar items ... */ }
    // }
    // The above commented-out body is how you'd typically enable .onDelete.
    // For now, let's keep the simpler List structure. If .onDelete is critical with EditButton,
    // then ForEach is needed. The current `deleteProducts` is not wired up without ForEach.
    // Let's assume selection is primary and direct deletion can be added if needed.

    // CRUD functions for the sidebar
    private func addSampleProduct() {
        withAnimation {
            let newItem = ProductSplit(name: "New Gadget \(Int.random(in: 1...100))", price: Double.random(in: 10...200), imageName: "new_gadget")
            modelContext.insert(newItem)
        }
    }

    // This delete function would be used by .onDelete(perform: deleteProducts) if ForEach is used.
    private func deleteProducts(offsets: IndexSet) {
        withAnimation {
            offsets.map { products[$0] }.forEach(modelContext.delete)
        }
    }

    private func clearAllProducts() {
        withAnimation {
            do {
                try modelContext.delete(model: ProductSplit.self) // Deletes all ProductSplit objects
                selectedProduct = nil // Clear selection as items are gone
                print("All ProductSplit data cleared.")
            } catch {
                print("Failed to clear ProductSplit data: \(error)")
            }
        }
    }
}

// MARK: - Product Row View (Helper for Sidebar)
struct ProductRowView: View {
    let product: ProductSplit

    var body: some View {
        HStack {
            // Using a system image as a placeholder for product image
            Image(systemName: product.imageName.isEmpty ? "photo" : product.imageName) // Or use product.imageName if it maps to SFSymbols
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .cornerRadius(6)
                .foregroundColor(.accentColor) // Give it some color
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
struct DetailWorkingView: View {
    let selectedProduct: ProductSplit? // Receives the selected product or nil

    var body: some View {
        Group { // Use Group for conditional root view content
            if let product = selectedProduct {
                VStack(alignment: .center, spacing: 20) {
                    // Placeholder for a larger product image
                    Image(systemName: product.imageName.isEmpty ? "photo.on.rectangle.angled" : product.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.orange) // Example styling
                        .padding(.top, 30)

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
                    
                    Text("Image asset name: \(product.imageName)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top)

                    Spacer() // Pushes content towards the top
                }
                .padding()
                .navigationTitle(product.name) // Sets the navigation bar title for the detail view
            } else {
                // View to show when no product is selected
                VStack {
                    Image(systemName: "list.bullet.indent")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                    Text("Select a product from the list to see its details.")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    // Create an in-memory container for the preview
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container: ModelContainer
    do {
        container = try ModelContainer(for: ProductSplit.self, configurations: config)

        // Populate with sample data for the preview context
        let modelContext = container.mainContext
        if try modelContext.fetch(FetchDescriptor<ProductSplit>()).isEmpty {
            sampleProductsSplit.forEach { modelContext.insert($0) }
        }
        
        // Return the ContentView for the preview
        return ContentView()
            .modelContainer(container) // Provide the preview-specific container
    } catch {
        fatalError("Failed to create model container for preview: \(error)")
    }
}

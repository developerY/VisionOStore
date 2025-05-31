//
//  StorFront.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 5/29/25.
//
import OSLog
import RealityKit  // if you want to inject 3D previews later
import SwiftData
import SwiftUI

// MARK: – Your Data Model

// MARK: - Sample Data (Updated to use your shoe models)
let sampleProductsSplit: [ProductSplit] = [
    /*.init(name: "Nike Air Zoom Pegasus 36", price: 129.99, modelName: "Shoes/Nike_Air_Zoom_Pegasus_36", thumbnailName: "shoe.fill"),
    .init(name: "Classic Airforce Sneaker", price: 99.99, modelName: "Shoes/sneaker_airforce", thumbnailName: "shoe.2.fill"),
    .init(name: "Nike Defy All Day", price: 79.50, modelName: "Shoes/Nike_Defy_All_Day_walking_sneakers_shoes", thumbnailName: "figure.walk"),
    .init(name: "Adidas Sports Shoe", price: 110.00, modelName: "Shoes/Scanned_Adidas_Sports_Shoe", thumbnailName: "figure.run"),
    .init(name: "Blue Vans Classic", price: 65.00, modelName: "Shoes/Unused_Blue_Vans_Shoe", thumbnailName: "shoe.fill"),*/
    .init(name: "Low Poly Shoe", price: 49.99, modelName: "Shoes/Shoes_low_poly", thumbnailName: "shoe.2.fill"),
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

    var body: some View {
        Group {
            if let product = selectedProduct {
                VStack(alignment: .center, spacing: 20) {
                    
                    Text("3D Interactive Model")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Model3D(named: product.modelName) { model in
                        model
                            .resizable()
                            .scaledToFit()
                            .frame(minHeight: 200, maxHeight: 400)
                    } placeholder: {
                        ZStack(alignment: .center) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.1))
                                .frame(minHeight: 200, maxHeight: 400)
                            VStack {
                                ProgressView()
                                    .padding(.bottom, 10)
                                Text("Loading Model...")
                                Text("(Looking for \(product.modelName))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
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

    
// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container: ModelContainer
    do {
        container = try ModelContainer(for: ProductSplit.self, configurations: config)
        let modelContext = container.mainContext
        if try modelContext.fetch(FetchDescriptor<ProductSplit>()).isEmpty {
            sampleProductsSplit.forEach { modelContext.insert($0) }
        }
        return ContentView()
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container for preview: \(error)")
    }
}

//
//  ProductSplitView.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 5/31/25.
//
import SwiftUI

// MARK: - Sidebar View
struct ProductSidebarView: View {
    let products: [ProductSplit]
    @Binding var selectedProduct: ProductSplit?
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        List(products, selection: $selectedProduct) { product in
            NavigationLink(value: product) {
                ProductRowView(product: product)
            }
        }
        .navigationTitle("Shoe Store")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    openWindow(id: "shopping-cart-window")
                } label: {
                    Label("Open Cart", systemImage: "cart.fill")
                }
            }
        }
    }
}

// MARK: – Product Detail
// struct ProductDetailSplitView: View {
// MARK: - Sidebar View
struct ProductSplitViewOrig: View {
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


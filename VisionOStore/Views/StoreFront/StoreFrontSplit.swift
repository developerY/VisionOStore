//
//  StorFront.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 5/29/25.
//
import SwiftUI
import RealityKit    // if you want to inject 3D previews later

// MARK: – Your Data Model

struct ProductSplit: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let price: Double
    let imageName: String
}

// Sample products
let sampleProductsSplit: [ProductSplit] = [
    .init(name: "Vision Pro Case", price: 49.99, imageName: "case"),
    .init(name: "Spatial Speaker",  price: 129.00, imageName: "speaker"),
    .init(name: "AirLink Earbuds", price: 199.99, imageName: "earbuds"),
    .init(name: "HoloKey Keyboard",price: 89.50, imageName: "keyboard"),
]

// MARK: – StoreFrontView

struct StoreFrontSplitView: View {
    var body: some View {
        NavigationStack {
            NavigationSplitView {
                // Product shelf
                List(sampleProductsSplit) { product in
                    NavigationLink(value: product) {
                        HStack(spacing: 12) {
                            Image(product.imageName)
                                .resizable()
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                            VStack(alignment: .leading) {
                                Text(product.name)
                                    .font(.headline)
                                Text("$\(product.price, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .navigationTitle("Store Front")
                .toolbar {
                    Button {
                        // handle “Add to cart” or whatever
                    } label: {
                        Label("Cart", systemImage: "cart")
                    }
                }
            } detail: {
                // Placeholder when nothing selected
                Text("Select a product")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            // Hook up the detail screen
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(product: product)
            }
        }
    }
}

// MARK: – Product Detail

struct ProductDetailSplitView: View {
    let product: ProductSplit

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(product.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300, maxHeight: 300)
                    .cornerRadius(12)
                    .shadow(radius: 8)

                Text(product.name)
                    .font(.largeTitle.bold())

                Text("$\(product.price, specifier: "%.2f")")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                Button(action: {
                    // add to cart action
                }) {
                    Label("Add to Cart", systemImage: "cart.fill.badge.plus")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(40)
        }
        .navigationTitle(product.name)
    }
}

// MARK: – Previews
// MARK: – Previews

#Preview("Store Front Split View") {
    StoreFrontSplitView()
        .frame(width: 600, height: 400)
}

#Preview("Product Detail – Vision Pro Case") {
    ProductDetailSplitView(product: sampleProductsSplit[0])
        .frame(width: 400, height: 400)
        .environment(\.colorScheme, .light)
}

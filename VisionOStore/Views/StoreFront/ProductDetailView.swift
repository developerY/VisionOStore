//
//  ProductDetailView.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 5/31/25.
//
import SwiftUI
import SwiftData
import OSLog
import RealityKit
import RealityKitContent

// MARK: - Detail View
struct ProductDetailView: View {
    let selectedProduct: ProductSplit?
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Group {
            if let product = selectedProduct {
                VStack(alignment: .center, spacing: 20) {
                    SpinningProductModelView(modelName: product.modelName, scale: product.scale)
                        .id(product.id)

                    Text(product.name)
                        .font(.largeTitle.weight(.bold))
                    
                    HStack {
                        Text("Price:")
                            .font(.title2)
                        Spacer()
                        Text(String(format: "$%.2f", product.price))
                            .font(.title2.weight(.semibold))
                    }
                    .padding(.horizontal)

                    Button {
                        addToCart(product: product)
                    } label: {
                        Label("Add to Cart", systemImage: "cart.badge.plus")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()

                    Spacer()
                }
                .padding()
                .navigationTitle(product.name)
            } else {
                Text("Select a shoe to view it in 3D").font(.title)
            }
        }
    }

    private func addToCart(product: ProductSplit) {
            logger.info("addToCart called for product: '\(product.name)'")
            let nameToMatch = product.name
            
            let predicate = #Predicate<CartItem> { $0.productName == nameToMatch }
            var fetchDescriptor = FetchDescriptor(predicate: predicate)
            fetchDescriptor.fetchLimit = 1

            do {
                logger.debug("Executing fetch for existing cart item.")
                if let existingCartItem = try modelContext.fetch(fetchDescriptor).first {
                    existingCartItem.quantity += 1
                    logger.info("Item exists. Incremented quantity to \(existingCartItem.quantity).")
                } else {
                    logger.info("Item does not exist. Creating new CartItem.")
                    let newCartItem = CartItem(
                        productName: product.name,
                        price: product.price,
                        quantity: 1,
                        modelName: product.modelName
                    )
                    modelContext.insert(newCartItem)
                    logger.info("Successfully inserted new item '\(newCartItem.productName)' into context.")
                }
            } catch {
                logger.error("Failed to add item to cart: \(error.localizedDescription)")
            }
        }
}

// MARK: - Other Helper Views
private struct SpinningProductModelView: View {
    let modelName: String
    let scale: Double
    @State private var rotationAngle: Angle = .zero
    var body: some View {
        TimelineView(.animation) { context in
            Model3D(named: modelName, bundle: RealityKitContent.realityKitContentBundle) { model in
                model.resizable().scaledToFit().scaleEffect(scale).frame(minHeight: 200, maxHeight: 400)
                    .rotation3DEffect(rotationAngle, axis: (x: 0, y: 1, z: 0))
                    .onChange(of: context.date) { rotationAngle.degrees += 0.5 }
            } placeholder: { ProgressView().frame(minHeight: 200, maxHeight: 400) }
        }
        .id(modelName)
    }
}

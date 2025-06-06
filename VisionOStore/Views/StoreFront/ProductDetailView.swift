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
    @Environment(AppModel.self) var appModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace


    
    private let logger = Logger(subsystem: "com.yourapp.VisionOStore", category: "DetailView")


    var body: some View {
        Group {
            if let product = selectedProduct {
                VStack(alignment: .center, spacing: 20) {
                    SpinningProductModelView(modelName: product.modelName, scale: product.scale).id(product.id)

                    Text(product.name).font(.largeTitle.weight(.bold))
                                        HStack { Text("Price:").font(.title2); Spacer(); Text(String(format: "$%.2f", product.price)).font(.title2.weight(.semibold)) }.padding(.horizontal)
                                        
                                        HStack(spacing: 15) {
                                            Button { addToCart(product: product) } label: { Label("Add to Cart", systemImage: "cart.badge.plus") }
                                            .buttonStyle(.borderedProminent)
                                            
                                            Button {
                                                appModel.selectedProductForImmersiveView = product
                                                Task {
                                                    logger.info("Opening General Immersive Space for \(product.name)")
                                                    await openImmersiveSpace(id: appModel.generalImmersiveSpaceID)
                                                }
                                            } label: { Label("View Product Immersively", systemImage: "rotate.3d") }
                                            .buttonStyle(.bordered)
                                        }
                                        .padding()
                                        Spacer()
                                    }.padding().navigationTitle(product.name)
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
                
                // --- NEW LOGGING ADDED HERE ---
                logger.info("Attempting to save context. Context hasChanges (before save): \(modelContext.hasChanges)")
                try modelContext.save()
                logger.info("Model context saved successfully after add/update. Context hasChanges (after save): \(modelContext.hasChanges)")
                
                logger.info("--- Verifying cart contents post-save ---")
                let allItemsFetchDescriptor = FetchDescriptor<CartItem>(sortBy: [SortDescriptor(\.productName)])
                let allItems = try modelContext.fetch(allItemsFetchDescriptor)
                logger.info("Context hasChanges (after verification fetch): \(modelContext.hasChanges)")
                
                if allItems.isEmpty {
                    logger.warning("Cart is empty after fetch.")
                } else {
                    logger.info("Total items in cart context: \(allItems.count)")
                    for item in allItems {
                        logger.info("--> Item: \(item.productName), Qty: \(item.quantity)")
                    }
                }
                logger.info("------------------------------------")
                
                // --- END OF NEW LOGGING ---
            
                
            } catch {
                logger.error("Failed to add item to cart: \(error.localizedDescription)")
            }
        }
}

/* MARK: - Other Helper Views
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
}*/

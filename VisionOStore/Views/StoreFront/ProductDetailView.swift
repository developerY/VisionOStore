//
//  ProductDetailView.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 5/31/25.
//
import SwiftUI
import SwiftData

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
           // Capture product.name in a local constant before using it in the predicate
           let nameToMatch = product.name
           
           let predicate = #Predicate<CartItem> { $0.productName == nameToMatch }
           var fetchDescriptor = FetchDescriptor(predicate: predicate)
           fetchDescriptor.fetchLimit = 1

           do {
               if let existingCartItem = try modelContext.fetch(fetchDescriptor).first {
                   existingCartItem.quantity += 1
               } else {
                   let newCartItem = CartItem(
                       productName: product.name, // Use original product.name for creating new item
                       price: product.price,
                       quantity: 1,
                       modelName: product.modelName
                   )
                   modelContext.insert(newCartItem)
               }
           } catch {
               print("Failed to add item to cart: \(error)")
           }
       }
}


// MARK: - Detail View
struct ProductDetailViewOrig: View {
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

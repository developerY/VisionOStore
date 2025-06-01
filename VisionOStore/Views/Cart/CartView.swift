//
//  CartView.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 5/31/25.
//
import SwiftUI
import SwiftData

// MARK: - Cart View
struct CartView: View {
    @Query(sort: \CartItem.productName) private var cartItems: [CartItem]
    @Environment(\.modelContext) private var modelContext

    private var totalPrice: Double {
        cartItems.reduce(0) { $0 + $1.lineTotal }
    }

    var body: some View {
        NavigationStack {
            VStack {
                if cartItems.isEmpty {
                    ContentUnavailableView("Your Cart is Empty", systemImage: "cart")
                } else {
                    List {
                        ForEach(cartItems) { item in
                            HStack {
                                Text(item.productName)
                                Spacer()
                                Stepper("Qty: \(item.quantity)", value: .init(
                                    get: { item.quantity },
                                    set: { newQuantity in
                                        if newQuantity > 0 {
                                            item.quantity = newQuantity
                                        } else {
                                            modelContext.delete(item)
                                        }
                                    }
                                ))
                                .frame(width: 150)
                                Text(String(format: "$%.2f", item.lineTotal))
                                    .frame(width: 80, alignment: .trailing)
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }

                    HStack {
                        Text("Total:").font(.title2.bold())
                        Spacer()
                        Text(String(format: "$%.2f", totalPrice)).font(.title2.bold())
                    }
                    .padding()
                }
            }
            .navigationTitle("Shopping Cart")
            .toolbar {
                if !cartItems.isEmpty {
                    ToolbarItem(placement: .topBarLeading) { EditButton() }
                }
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets { modelContext.delete(cartItems[index]) }
        }
    }
}


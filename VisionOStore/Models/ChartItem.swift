//
//  ChartItem.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 5/31/25.
//
import SwiftData

// 1. New Model for items in the shopping cart
@Model
class CartItem {
    // --- FIX FOR SWIFT 6 ---
    // These properties must be `var` for the @Model macro to manage them.
    var productName: String
    var price: Double
    var modelName: String
    // --- END OF FIX ---
    
    var quantity: Int
    
    var lineTotal: Double {
        return price * Double(quantity)
    }

    init(productName: String, price: Double, quantity: Int, modelName: String) {
        self.productName = productName
        self.price = price
        self.quantity = quantity
        self.modelName = modelName
    }
}

//
//  ProductSplit.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 5/31/25.
//
import SwiftData

// MARK: - Data Model (Updated with scale property)
@Model
class ProductSplit {
    var name: String
    var price: Double
    var modelName: String
    var thumbnailName: String
    var scale: Double // Property to hold model-specific scale

    init(name: String, price: Double, modelName: String, thumbnailName: String, scale: Double = 1.0) {
        self.name = name
        self.price = price
        self.modelName = modelName
        self.thumbnailName = thumbnailName
        self.scale = scale
    }
}

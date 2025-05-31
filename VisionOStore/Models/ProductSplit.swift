//
//  ProductSplit.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 5/31/25.
//
import SwiftData

@Model
class ProductSplit {
    var name: String
    var price: Double
    var modelName: String // Path to the .usdz file, e.g., "Shoes/Nike_Air_Zoom_Pegasus_36"
    var thumbnailName: String // Name of an SF Symbol for the list view

    init(name: String, price: Double, modelName: String, thumbnailName: String) {
        self.name = name
        self.price = price
        self.modelName = modelName
        self.thumbnailName = thumbnailName
    }
}

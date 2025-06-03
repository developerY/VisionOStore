//
//  SampleData.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 6/1/25.
//
import SwiftData
import OSLog

// MARK: – Your Data Model

// MARK: - Sample Data (Updated with scale values)
let sampleProductsSplit: [ProductSplit] = [
    .init(name: "Low Poly Shoe", price: 49.99, modelName: "StoreItems/Shoes/Shoes_low_poly", thumbnailName: "shoe.2.fill", scale: 0.5),
    .init(name: "Nike Air Zoom Pegasus 36", price: 129.99, modelName: "StoreItems/Shoes/Nike_Air_Zoom_Pegasus_36", thumbnailName: "shoe.fill", scale: 0.5),
    .init(name: "Classic Airforce Sneaker", price: 99.99, modelName: "StoreItems/Shoes/sneaker_airforce", thumbnailName: "shoe.2.fill", scale: 0.5),
    // Give this oversized model a smaller scale factor
    .init(name: "Nike Defy All Day", price: 79.50, modelName: "StoreItems/Shoes/Nike_Defy_All_Day_walking_sneakers_shoes", thumbnailName: "figure.walk", scale: 0.5),
    .init(name: "Adidas Sports Shoe", price: 110.00, modelName: "StoreItems/Shoes/Scanned_Adidas_Sports_Shoe", thumbnailName: "figure.run", scale: 0.5),
]


let logger = Logger(subsystem: "com.yourcompany.app", category: "Data")

extension ModelContext {
    func dumpAllProducts() {
        do {
            let all: [ProductSplit] = try fetch(FetchDescriptor<ProductSplit>())
            logger.info("⛓️ ⁨Found \(all.count) products⁩")
            for p in all {
                logger.info("• \(p.name)") // — $\(String(format: \"%.2f\", p.price))")
            }
        } catch {
            logger.error("Failed to fetch products: \(error.localizedDescription)")
        }
    }
}


//
//  Untitled.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 6/2/25.
//
import SwiftUI
import SwiftData
import RealityKit
import RealityKitContent
import OSLog

// MARK: - GeneralImmersiveView (Refactored for Non-AR Placement)
struct GeneralImmersiveView: View {
    @Environment(AppModel.self) var appModel
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.yourapp", category: "GeneralImmersiveView")

    // State for the main interactive model (floating)
    @State private var mainModelEntity: ModelEntity? = nil
    @State private var yRotation: Angle = .zero
    @State private var xRotation: Angle = .zero
    @State private var accumulatedYRotation: Angle = .zero
    @State private var accumulatedXRotation: Angle = .zero
    @State private var currentMagnification: CGFloat = 1.0
    @State private var accumulatedMagnification: CGFloat = 1.0
    @State private var isAutoSpinning: Bool = true
    @State private var isDraggingRotation: Bool = false
    private let dragSensitivity: Double = 0.5
    private let minMagnification: CGFloat = 0.2
    private let maxMagnification: CGFloat = 3.0

    // State for placed model entities (no longer anchors)
    @State private var placedModelEntities: [ModelEntity] = []
    private let placedModelBaseName = "placedShoe"
    
    // Root entity to which all models will be added
    private var rootEntity = Entity()

    var body: some View {
        RealityView { content in
            Self.logger.info("GeneralImmersiveView RealityView 'make' closure executing.")
            content.add(rootEntity) // Add a common root for all our entities
            
            if let product = appModel.selectedProductForImmersiveView {
                loadMainModel(product: product)
            }
        } update: { content in
            Self.logger.info("GeneralImmersiveView RealityView 'update' closure executing.")
            
            // Update main model if selection changes or if it wasn't loaded
            if let currentProduct = appModel.selectedProductForImmersiveView {
                if mainModelEntity == nil || mainModelEntity?.name != currentProduct.modelName {
                    Self.logger.info("Product selection changed or main model nil, reloading for: \(currentProduct.name)")
                    mainModelEntity?.removeFromParent() // Remove old one if it exists
                    mainModelEntity = nil
                    resetGestureStates()
                    loadMainModel(product: currentProduct)
                }
            } else { // No product selected, remove main model
                if mainModelEntity != nil {
                    Self.logger.info("No product selected, removing main model.")
                    mainModelEntity?.removeFromParent()
                    mainModelEntity = nil
                    resetGestureStates()
                }
            }

            // Apply transformations to the main model
            if let entity = mainModelEntity {
                var transform = Transform()
                transform.rotation = simd_quatf(angle: Float(xRotation.radians), axis: [1,0,0]) * simd_quatf(angle: Float(yRotation.radians), axis: [0,1,0])
                transform.scale = SIMD3<Float>(repeating: Float(appModel.selectedProductForImmersiveView?.scale ?? 1.0) * Float(currentMagnification))
                // Keep existing position or set a default if not set by loadMainModel
                transform.translation = entity.position
                entity.transform = transform
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    if !isDraggingRotation { isDraggingRotation = true; isAutoSpinning = false }
                    yRotation = accumulatedYRotation + Angle(degrees: Double(value.translation.width) * dragSensitivity)
                    xRotation = accumulatedXRotation + Angle(degrees: -Double(value.translation.height) * dragSensitivity)
                }
                .onEnded { value in
                    isDraggingRotation = false
                    accumulatedYRotation = yRotation
                    accumulatedXRotation = xRotation
                }
        )
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    isAutoSpinning = false
                    let newMagnification = accumulatedMagnification * value
                    currentMagnification = min(max(newMagnification, minMagnification), maxMagnification)
                }
                .onEnded { value in
                    accumulatedMagnification = currentMagnification
                }
        )
        .overlay(alignment: .bottom) {
            HStack(spacing: 20) {
                Button {
                    withAnimation { resetGestureStates(restartAutoSpin: true) }
                } label: { Image(systemName: "arrow.counterclockwise.circle.fill").font(.largeTitle) }
                .disabled(appModel.selectedProductForImmersiveView == nil || mainModelEntity == nil)

                Button {
                    placeModelCopy()
                } label: { Image(systemName: "plus.circle.fill").font(.largeTitle) } // Changed icon
                .disabled(appModel.selectedProductForImmersiveView == nil || mainModelEntity == nil)
                
                if !placedModelEntities.isEmpty {
                    Button {
                        clearPlacedModels()
                    } label: { Image(systemName: "trash.circle.fill").font(.largeTitle) }
                }
            }
            .padding(30)
            .glassBackgroundEffect()
        }
        .onAppear {
            Self.logger.info("GeneralImmersiveView onAppear.")
            resetGestureStates()
            // ARKit session for plane detection is removed
        }
        .onDisappear {
            Self.logger.info("GeneralImmersiveView onDisappear.")
            // ARKit session stop is removed
            clearPlacedModels()
            mainModelEntity?.removeFromParent()
            mainModelEntity = nil
        }
        .task(id: isAutoSpinning) {
            if isAutoSpinning && appModel.selectedProductForImmersiveView != nil && mainModelEntity != nil {
                do {
                    while isAutoSpinning && !isDraggingRotation {
                        try await Task.sleep(for: .milliseconds(16))
                        if isAutoSpinning && !isDraggingRotation {
                            yRotation.degrees += 0.3
                            if yRotation.degrees >= 360 { yRotation.degrees -= 360 }
                            accumulatedYRotation = yRotation
                        }
                    }
                } catch { Self.logger.info("Auto-spin task cancelled.") }
            }
        }
    }

    private func loadMainModel(product: ProductSplit) {
        Task {
            do {
                Self.logger.info("Loading main model: \(product.modelName)")
                let entity = try await ModelEntity(named: product.modelName, in: RealityKitContent.realityKitContentBundle)
                entity.name = product.modelName
                entity.position = [0, 0, -1.0] // Position 1m in front, at eye level
                self.mainModelEntity = entity
                rootEntity.addChild(entity) // Add to our common root
                Self.logger.info("Main model \(product.modelName) loaded and added to scene.")
                resetGestureStates(restartAutoSpin: true) // Ensure gestures are reset for new model
            } catch {
                Self.logger.error("Failed to load main model \(product.modelName): \(error)")
            }
        }
    }
    
    private func placeModelCopy() {
        guard let productToPlace = appModel.selectedProductForImmersiveView, let mainModel = mainModelEntity else {
            Self.logger.warning("PlaceModelCopy: No product selected or main model not loaded.")
            return
        }
        Self.logger.info("PlaceModelCopy: Attempting to place a copy of \(productToPlace.name).")

        Task {
            do {
                let newEntity = try await ModelEntity(named: productToPlace.modelName, in: RealityKitContent.realityKitContentBundle)
                newEntity.name = "\(placedModelBaseName)_\(placedModelEntities.count)"
                
                // Position it to the right of the main model, for example
                var newPosition = mainModel.position // Start from main model's position
                newPosition.x += 0.5 + (Float(placedModelEntities.count) * 0.1) // Offset to the right, slightly more for each new one
                newEntity.position = newPosition
                
                // Apply the product's base scale
                newEntity.scale = SIMD3<Float>(repeating: Float(productToPlace.scale))
                
                newEntity.generateCollisionShapes(recursive: true) // Good for potential future interactions

                rootEntity.addChild(newEntity) // Add to our common root
                placedModelEntities.append(newEntity) // Keep track of it
                Self.logger.info("Placed copy \(newEntity.name) at \(newEntity.position).")

            } catch {
                Self.logger.error("PlaceModelCopy: Failed to load model for placing: \(error)")
            }
        }
    }
    
    private func clearPlacedModels() {
        Self.logger.info("Clearing \(placedModelEntities.count) placed models.")
        for entity in placedModelEntities {
            entity.removeFromParent()
        }
        placedModelEntities.removeAll()
    }

    private func resetGestureStates(restartAutoSpin: Bool = false) {
        xRotation = .zero; yRotation = .zero; accumulatedXRotation = .zero; accumulatedYRotation = .zero
        currentMagnification = 1.0; accumulatedMagnification = 1.0
        isDraggingRotation = false
        if restartAutoSpin {
            isAutoSpinning = true
        }
    }
}

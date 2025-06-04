//
//  Untitled.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 6/2/25.
//
// MARK: - GeneralImmersiveView (Refactored for Non-AR Placement)
import SwiftUI
import RealityKit
import RealityKitContent // Ensure this is imported for RealityKitContent.realityKitContentBundle
import OSLog

struct GeneralImmersiveView: View {
    @Environment(AppModel.self) var appModel
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.yourapp", category: "GeneralImmersiveView")

    // State for the main interactive model (floating)
    @State private var mainModelEntity: ModelEntity? = nil
    
    // Gesture and animation states
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

    // State for placed model entities (for "Place a Copy" feature)
    @State private var placedModelEntities: [ModelEntity] = []
    private let placedModelBaseName = "placedShoeCopy"
    
    // Root entity for all dynamic content in this view
    @State private var viewRootEntity = Entity()

    var body: some View {
        RealityView { content in
            Self.logger.info("RealityView 'make': Adding viewRootEntity.")
            content.add(viewRootEntity)
            // Initial model loading is handled by the .task(id: appModel.selectedProductForImmersiveView?.id)
        } update: { content in
            Self.logger.info("RealityView 'update': Applying transforms. Selected product: \(appModel.selectedProductForImmersiveView?.name ?? "None"). Main model entity exists: \(mainModelEntity != nil)")
            
            // Apply transformations to the mainModelEntity if it exists
            if let entity = mainModelEntity, let product = appModel.selectedProductForImmersiveView {
                var newTransform = Transform.identity // Start with identity for clarity
                newTransform.rotation = simd_quatf(angle: Float(xRotation.radians), axis: [1,0,0]) * simd_quatf(angle: Float(yRotation.radians), axis: [0,1,0])
                newTransform.scale = SIMD3<Float>(repeating: Float(product.scale) * Float(currentMagnification))
                newTransform.translation = entity.position // Preserve position set during loading
                entity.transform = newTransform
                // Self.logger.debug("RealityView 'update': Applied transform to mainModelEntity '\(entity.name)'. Scale: \(newTransform.scale.x)")
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
                    isAutoSpinning = false // Stop auto-spin on any interaction
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
                .disabled(mainModelEntity == nil)

                Button {
                    placeModelCopy()
                } label: { Image(systemName: "plus.circle.fill").font(.largeTitle) }
                .disabled(mainModelEntity == nil)
                
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
            Self.logger.info("GeneralImmersiveView onAppear. Selected product: \(appModel.selectedProductForImmersiveView?.name ?? "None")")
            // Model loading is now handled by the .task below, keyed to product ID
        }
        .onDisappear {
            Self.logger.info("GeneralImmersiveView onDisappear. Removing models and clearing state.")
            clearPlacedModels()
            mainModelEntity?.removeFromParent()
            mainModelEntity = nil
            // viewRootEntity is part of the RealityView content, will be removed when view disappears
        }
        .task(id: appModel.selectedProductForImmersiveView?.id) { // Runs when view appears or selectedProduct.id changes
            Self.logger.info(".task(id: product.id) triggered. Product: \(appModel.selectedProductForImmersiveView?.name ?? "None")")
            
            // Clear previous model and reset states first
            if mainModelEntity != nil {
                mainModelEntity?.removeFromParent()
                mainModelEntity = nil
            }
            resetGestureStates(restartAutoSpin: true) // Prepare for new model

            if let product = appModel.selectedProductForImmersiveView {
                await loadMainModel(product: product)
            }
        }
        .task(id: isAutoSpinning) { // Task to handle auto-spin animation
            guard isAutoSpinning, mainModelEntity != nil else {
                Self.logger.info("Auto-spin task: Not starting or stopping (isAutoSpinning: \(isAutoSpinning), mainModelEntity nil: \(mainModelEntity == nil)).")
                return
            }

            Self.logger.info("Auto-spin task started for model: \(mainModelEntity?.name ?? "Unknown")")
            do {
                while isAutoSpinning && !isDraggingRotation && mainModelEntity != nil {
                    try await Task.sleep(for: .milliseconds(16)) // ~60 FPS
                    // Check conditions again after sleep, as state might have changed
                    if isAutoSpinning && !isDraggingRotation && mainModelEntity != nil {
                        yRotation.degrees += 0.3
                        if yRotation.degrees >= 360 { yRotation.degrees -= 360 }
                        accumulatedYRotation = yRotation
                    } else {
                        break // Exit loop if conditions no longer met
                    }
                }
            } catch {
                Self.logger.info("Auto-spin task cancelled (e.g., view disappeared).")
            }
            Self.logger.info("Auto-spin task loop ended. isAutoSpinning: \(isAutoSpinning), isDraggingRotation: \(isDraggingRotation)")
        }
    }

    // This function now loads the model and adds it to `viewRootEntity`
    // It also updates the @State mainModelEntity property on the MainActor
    private func loadMainModel(product: ProductSplit) async {
        Self.logger.info("loadMainModel: Attempting to load ModelEntity for '\(product.modelName)'")
        do {
            let entity = try await ModelEntity(named: product.modelName, in: RealityKitContent.realityKitContentBundle)
            entity.name = product.modelName // For identification
            
            // Set initial transform (position and base scale)
            var initialTransform = Transform.identity
            initialTransform.translation = [0, 0, -1.0] // Position 1m in front, at eye level
            initialTransform.scale = SIMD3<Float>(repeating: Float(product.scale))
            entity.transform = initialTransform
            
            // Update state on the main actor
            await MainActor.run {
                // Remove old model if any, before adding the new one to viewRootEntity
                mainModelEntity?.removeFromParent()
                
                viewRootEntity.addChild(entity)
                self.mainModelEntity = entity // Store reference
                Self.logger.info("loadMainModel: Successfully loaded and added '\(entity.name)' to viewRootEntity. Position: \(entity.position), Scale: \(entity.scale.x)")
            }
        } catch {
            Self.logger.error("loadMainModel: Failed to load model '\(product.modelName)': \(error.localizedDescription)")
            await MainActor.run {
                mainModelEntity?.removeFromParent() // Ensure no old model lingers
                self.mainModelEntity = nil
            }
        }
    }
    
    private func placeModelCopy() {
        guard let productToPlace = appModel.selectedProductForImmersiveView, mainModelEntity != nil else {
            Self.logger.warning("PlaceModelCopy: No product selected or main model not loaded.")
            return
        }
        Self.logger.info("PlaceModelCopy: Attempting to place a copy of \(productToPlace.name).")

        Task {
            do {
                let newEntity = try await ModelEntity(named: productToPlace.modelName, in: RealityKitContent.realityKitContentBundle)
                newEntity.name = "\(placedModelBaseName)_\(placedModelEntities.count)"
                
                var newPosition = self.mainModelEntity?.position ?? [0,0,-1] // Base off main model or default
                newPosition.x += 0.5 + (Float(placedModelEntities.count) * 0.1)
                newEntity.position = newPosition
                
                newEntity.scale = SIMD3<Float>(repeating: Float(productToPlace.scale))
                newEntity.generateCollisionShapes(recursive: true)

                await MainActor.run { // Add to scene on main actor
                    viewRootEntity.addChild(newEntity)
                    placedModelEntities.append(newEntity)
                }
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
        Self.logger.info("Resetting gesture states. Restart auto-spin: \(restartAutoSpin)")
        xRotation = .zero; yRotation = .zero; accumulatedXRotation = .zero; accumulatedYRotation = .zero
        currentMagnification = 1.0; accumulatedMagnification = 1.0
        isDraggingRotation = false
        if restartAutoSpin {
            isAutoSpinning = true
        } else {
            // If not explicitly restarting, ensure it respects the current isAutoSpinning desired state
            // or set to false if interaction should stop it.
            // For now, let's keep it simple: if restart is true, it's true, else it's unchanged
            // unless an interaction just happened.
        }
    }
}

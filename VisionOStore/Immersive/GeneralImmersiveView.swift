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

// MARK: - GeneralImmersiveView (With Pre-warming Logic)
// MARK: - GeneralImmersiveView (Cleaner Pre-warm Logic)
struct GeneralImmersiveView: View {
    @Environment(AppModel.self) var appModel
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.yourapp", category: "GeneralImmersiveView")

    @State private var mainModelEntity: Entity? = nil
    // Gesture states...
    @State private var yRotation: Angle = .zero
    @State private var xRotation: Angle = .zero
    @State private var accumulatedYRotation: Angle = .zero
    @State private var accumulatedXRotation: Angle = .zero
    @State private var currentMagnification: CGFloat = 1.0
    @State private var accumulatedMagnification: CGFloat = 1.0
    @State private var isAutoSpinning: Bool = true
    @State private var isDraggingRotation: Bool = false
    private let dragSensitivity: Double = 0.5
    private let minMagnification: CGFloat = 0.1
    private let maxMagnification: CGFloat = 2.0

    @State private var placedModelEntities: [Entity] = []
    private let placedModelBaseName = "placedShoeCopy"
    
    // Root entity for our dynamic, interactive content
    @State private var dynamicContentRoot = Entity()
    // Name of the scene to load for pre-warming asset loading
    private let prewarmSceneName = "Immersive/Scene"

    var body: some View {
        RealityView { content in
            Self.logger.info("GeneralImmersiveView RealityView 'make' executing.")
            // Add the root for our dynamic content (shoes)
            content.add(dynamicContentRoot)
            // The initial model loading (including pre-warm) is now handled by the .task(id:...)
            
        } update: { content in
            // Update applies transforms to the mainModelEntity
            if let entity = mainModelEntity, let product = appModel.selectedProductForImmersiveView {
                var newTransform = Transform()
                newTransform.rotation = simd_quatf(angle: Float(xRotation.radians), axis: [1,0,0]) * simd_quatf(angle: Float(yRotation.radians), axis: [0,1,0])
                newTransform.scale = SIMD3<Float>(repeating: Float(product.scale) * Float(currentMagnification))
                newTransform.translation = entity.position
                entity.transform = newTransform
            }
        }
        // Gestures and Overlay are the same as before
        .gesture(DragGesture().onChanged { value in
            if !isDraggingRotation { isDraggingRotation = true; isAutoSpinning = false }
            yRotation = accumulatedYRotation + Angle(degrees: Double(value.translation.width) * dragSensitivity)
            xRotation = accumulatedXRotation + Angle(degrees: -Double(value.translation.height) * dragSensitivity)
        }.onEnded { value in
            isDraggingRotation = false
            accumulatedYRotation = yRotation
            accumulatedXRotation = xRotation
        })
        .gesture(MagnificationGesture().onChanged { value in
            isAutoSpinning = false
            let newMagnification = accumulatedMagnification * value
            currentMagnification = min(max(newMagnification, minMagnification), maxMagnification)
        }.onEnded { value in
            accumulatedMagnification = currentMagnification
        })
        .overlay(alignment: .bottom) {
            HStack(spacing: 20) {
                // Button to reset the model's orientation and zoom
                Button {
                    withAnimation { resetGestureStates(restartAutoSpin: true) }
                } label: { Image(systemName: "arrow.counterclockwise.circle.fill").font(.largeTitle) }
                .disabled(mainModelEntity == nil)

                // Button to place a copy of the model
                Button {
                    placeModelCopy()
                } label: { Image(systemName: "plus.circle.fill").font(.largeTitle) }
                .disabled(mainModelEntity == nil)
                
                // Button to clear all placed copies, only appears if copies exist
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
        }
        .onDisappear {
            Self.logger.info("GeneralImmersiveView onDisappear.")
            clearPlacedModels()
            mainModelEntity?.removeFromParent()
            mainModelEntity = nil
        }
        .task(id: appModel.selectedProductForImmersiveView?.id) {
            Self.logger.info(".task(id: product.id) triggered for product: \(appModel.selectedProductForImmersiveView?.name ?? "None")")
            
            await MainActor.run { // Ensure state modifications are on main actor
                mainModelEntity?.removeFromParent()
                mainModelEntity = nil
            }
            resetGestureStates(restartAutoSpin: true)

            // --- PRE-WARM ATTEMPT (Load but don't add to scene) ---
            // This happens before trying to load the actual product model.
            Self.logger.info("Attempting pre-warm load of '\(prewarmSceneName)'...")
            do {
                _ = try await Entity(named: prewarmSceneName, in: RealityKitContent.realityKitContentBundle)
                Self.logger.info("Pre-warm load of '\(prewarmSceneName)' successful (entity not added to scene).")
            } catch {
                Self.logger.error("Pre-warm load of '\(prewarmSceneName)' FAILED: \(error.localizedDescription)")
            }
            // --- END PRE-WARM ---

            if let product = appModel.selectedProductForImmersiveView {
                await loadMainModel(product: product)
            }
        }
        .task(id: isAutoSpinning) { /* ... (auto-spin task remains the same) ... */ }
    }

    private func loadMainModel(product: ProductSplit) async {
        Self.logger.info("loadMainModel: Attempting to load ModelEntity for '\(product.modelName)'")
        do {
            let entity = try await Entity(named: product.modelName, in: RealityKitContent.realityKitContentBundle)
            entity.name = "interactive_\(product.modelName)"
            
            var initialTransform = Transform.identity
            initialTransform.translation = [0, 0, -1.0]
            initialTransform.scale = SIMD3<Float>(repeating: Float(product.scale))
            entity.transform = initialTransform
            
            await MainActor.run {
                self.mainModelEntity = entity
                self.dynamicContentRoot.addChild(entity)
                Self.logger.info("loadMainModel: Successfully loaded and added '\(entity.name)' to dynamicContentRoot. Initial Base Scale: \(entity.scale.x)")
            }
        } catch {
            Self.logger.error("loadMainModel: Failed to load model '\(product.modelName)': \(error.localizedDescription)")
            await MainActor.run {
                self.mainModelEntity = nil
                let errorText = ModelEntity(mesh: .generateText("Error: '\(product.modelName)' not found.", extrusionDepth: 0.01, font: .systemFont(ofSize: 0.05)), materials: [SimpleMaterial(color: .red, isMetallic: false)])
                errorText.position = [0,0,-1]
                self.dynamicContentRoot.addChild(errorText)
            }
        }
    }
    
    private func placeModelCopy() {
        guard let productToPlace = appModel.selectedProductForImmersiveView else {
            Self.logger.warning("PlaceModelCopy: No product selected.")
            return
        }
        Task {
            do {
                let newEntity = try await Entity(named: productToPlace.modelName, in: RealityKitContent.realityKitContentBundle)
                newEntity.name = "\(placedModelBaseName)_\(placedModelEntities.count)"
                var newPosition = self.mainModelEntity?.position ??  SIMD3<Float>(0, 0, -1.0)
                newPosition.x += 0.5 + (Float(placedModelEntities.count) * 0.1)
                newEntity.position = newPosition
                newEntity.scale = SIMD3<Float>(repeating: Float(productToPlace.scale))
                newEntity.generateCollisionShapes(recursive: true)
                await MainActor.run {
                    self.dynamicContentRoot.addChild(newEntity)
                    placedModelEntities.append(newEntity)
                }
                Self.logger.info("Placed copy \(newEntity.name).")
            } catch { Self.logger.error("PlaceModelCopy: Failed to load '\(productToPlace.modelName)': \(error)") }
        }
    }
    
    private func clearPlacedModels() {
        Self.logger.info("Clearing \(placedModelEntities.count) placed models.")
        for entity in placedModelEntities {
            // Ensure they are removed from the correct root
            entity.removeFromParent() // This works if they were added to rootEntityForDynamicContent
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
        }
    }
}

//
//  DefaultSceneImmersiveView.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 6/3/25.
//
// MARK: - View for Default Immersive Scene
import SwiftUI
import SwiftData
import RealityKit
import RealityKitContent
import OSLog

struct DefaultSceneImmersiveView: View {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.yourapp", category: "DefaultSceneImmersiveView")
    // The path "Immersive/Scene" is based on your project screenshot.
    // This refers to Scene.usdz inside an Immersive.rkassets folder,
    // or a top-level Scene.usdz in an "Immersive" group/folder if not using .rkassets structure for it.
    // If "Immersive" is the name of the .rkassets folder itself, then "Scene" might be top-level in it.
    // Let's assume "Immersive/Scene" refers to a named entity within the bundle.
    private let defaultSceneName = "Immersive/Scene"


    var body: some View {
        RealityView { content in
            Self.logger.info("DefaultSceneImmersiveView: Attempting to load default scene: '\(defaultSceneName)'")
            do {
                let sceneEntity = try await Entity(named: defaultSceneName, in: RealityKitContent.realityKitContentBundle)
                content.add(sceneEntity)
                Self.logger.info("DefaultSceneImmersiveView: Successfully loaded and added default scene '\(defaultSceneName)'")
            } catch {
                Self.logger.error("DefaultSceneImmersiveView: Failed to load default scene '\(defaultSceneName)': \(error.localizedDescription)")
                // Optionally, add a visible error indicator in the immersive space
                let errorText = ModelEntity(mesh: .generateText("Error: Could not load default scene.",
                                                               extrusionDepth: 0.01,
                                                               font: .systemFont(ofSize: 0.1)),
                                            materials: [SimpleMaterial(color: .red, isMetallic: false)])
                errorText.position = [0, 0, -1] // Position in front
                content.add(errorText)
            }
        }
    }
}


//
//  SpinningProductModelView.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 5/31/25.
//
import SwiftUI
import RealityKit
import RealityKitContent

// MARK: - Other Helper Views
struct SpinningProductModelView: View {
    let modelName: String
    let scale: Double
    @State private var rotationAngle: Angle = .zero
    var body: some View {
        TimelineView(.animation) { context in
            Model3D(named: modelName, bundle: RealityKitContent.realityKitContentBundle) { model in
                model.resizable().scaledToFit().scaleEffect(scale).frame(minHeight: 200, maxHeight: 400)
                    .rotation3DEffect(rotationAngle, axis: (x: 0, y: 1, z: 0))
                    .onChange(of: context.date) { rotationAngle.degrees += 0.5 }
            } placeholder: { ProgressView().frame(minHeight: 200, maxHeight: 400) }
        }
        .id(modelName)
    }
}

// MARK: - Helper View for Spinning 3D Model
private struct SpinningProductModelViewOrig: View {
    let modelName: String
    let scale: Double // Accept the scale factor
    
    // Animation state is now local to this view
    @State private var rotationAngle: Angle = .zero
    @State private var isAnimating: Bool = true // Could also be passed in if needed

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.016, paused: !isAnimating)) { context in
            Model3D(named: modelName, bundle: RealityKitContent.realityKitContentBundle) { model in
                model
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale) // Apply the specific scale factor here
                    .frame(minHeight: 200, maxHeight: 400)
                    .rotation3DEffect(
                        rotationAngle,
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .onChange(of: context.date) {
                        rotationAngle.degrees += 0.5
                        if rotationAngle.degrees >= 360 {
                            rotationAngle.degrees -= 360
                        }
                    }
            } placeholder: {
                // Simplified placeholder for the helper view
                ProgressView()
                    .frame(minHeight: 200, maxHeight: 400)
            }
        }
        // Optional: Add controls within this view or pass bindings
        // For simplicity, this example keeps animation control internal.
        // If external control is needed, @Binding for isAnimating and rotationAngle
        // would be appropriate.
    }
}

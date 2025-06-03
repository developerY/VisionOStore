//
//  ImmersiveView.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 5/28/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

// MARK: - ImmersiveView (New View for Hand Interaction)
struct ImmersiveView: View {
    @Environment(AppModel.self) var appModel // Get the AppModel from environment

    // Gesture states for the immersive model
    @State private var yRotation: Angle = .zero
    @State private var xRotation: Angle = .zero
    @State private var zRotation: Angle = .zero // Optional: for 3D rotation gesture

    @State private var accumulatedYRotation: Angle = .zero
    @State private var accumulatedXRotation: Angle = .zero
    @State private var accumulatedZRotation: Angle = .zero

    @State private var currentMagnification: CGFloat = 1.0
    @State private var accumulatedMagnification: CGFloat = 1.0
    private let minMagnification: CGFloat = 0.2
    private let maxMagnification: CGFloat = 3.0
    
    // Optional: For positioning if you want to move the object
    @State private var offset: SIMD3<Float> = .zero

    private let dragSensitivity: Double = 0.5 // Adjust for rotation speed

    var body: some View {
        Group {
            if let product = appModel.selectedProductForImmersiveView {
                Model3D(named: product.modelName, bundle: RealityKitContent.realityKitContentBundle) { model in
                    model
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(product.scale * currentMagnification) // Apply base scale and gesture magnification
                        .rotation3DEffect(xRotation, axis: .x)
                        .rotation3DEffect(yRotation, axis: .y)
                        .rotation3DEffect(zRotation, axis: .z) // Apply Z rotation
                        .offset(x: CGFloat(offset.x), y: CGFloat(offset.y)) // Z offset for depth if needed via .offset(z:) for Model3D
                        // For spatial positioning, you'd typically use .position3D() or wrap in RealityView for Entity manipulation
                        
                } placeholder: {
                    ProgressView().scaleEffect(2) // Make placeholder larger
                }
                // --- Gestures for Hand Interaction ---
                .gesture(
                    DragGesture(minimumDistance: 0.0) // Allows for rotation and translation
                        .targetedToAnyEntity() // Allows gesture to work even if not directly on model, common in visionOS
                        .onChanged { value in
                            // Simple orbital rotation for now based on 2D translation
                            // For translation, you'd convert value.location3D / value.translation3D to offset
                            yRotation = accumulatedYRotation + Angle(degrees: Double(value.translation.width) * dragSensitivity)
                            xRotation = accumulatedXRotation + Angle(degrees: -Double(value.translation.height) * dragSensitivity)
                        }
                        .onEnded { value in
                            accumulatedYRotation = yRotation
                            accumulatedXRotation = xRotation
                        }
                )
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let newMagnification = accumulatedMagnification * value
                            currentMagnification = min(max(newMagnification, minMagnification), maxMagnification)
                        }
                        .onEnded { value in
                            accumulatedMagnification = currentMagnification
                        }
                )
                // Optional: RotationGesture3D for two-hand rotation
                // .gesture(
                //     RotationGesture3D()
                //         .onChanged { value in
                //             zRotation = accumulatedZRotation + value.angle // Or apply to other axes based on gesture
                //         }
                //         .onEnded { value in
                //             accumulatedZRotation = zRotation
                //         }
                // )
            } else {
                Text("No Product Selected for Immersive View")
                    .font(.largeTitle)
            }
        }
        .onAppear {
            resetGestureStates() // Reset when the space appears
        }
        .onChange(of: appModel.selectedProductForImmersiveView) { // Reset when product changes
            resetGestureStates()
        }
    }

    private func resetGestureStates() {
        xRotation = .zero
        yRotation = .zero
        zRotation = .zero
        accumulatedXRotation = .zero
        accumulatedYRotation = .zero
        accumulatedZRotation = .zero
        currentMagnification = 1.0
        accumulatedMagnification = 1.0
        offset = .zero
    }
}



#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}

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
// Updated SpinningProductModelView with DragGesture for manual rotation
struct SpinningProductModelView: View {
    let modelName: String
    let scale: Double

    // Rotation state for both X and Y axes
    @State private var yRotationAngle: Angle = .zero
    @State private var xRotationAngle: Angle = .zero
    
    // To accumulate rotation from drag gestures
    @State private var accumulatedYRotation: Angle = .zero
    @State private var accumulatedXRotation: Angle = .zero
    
    // Controls the automatic spinning
    @State private var isAutoSpinning: Bool = true
    // Tracks if a drag gesture is active
    @State private var isDragging: Bool = false

    // Sensitivity for drag rotation
    private let dragSensitivity: Double = 0.5

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.016, paused: !isAutoSpinning || isDragging )) { context in
            Model3D(named: modelName, bundle: RealityKitContent.realityKitContentBundle) { model in
                model
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .frame(minHeight: 200, maxHeight: 400)
                    // Apply X rotation first, then Y for more standard orbital control
                    .rotation3DEffect(xRotationAngle, axis: (x: 1, y: 0, z: 0))
                    .rotation3DEffect(yRotationAngle, axis: (x: 0, y: 1, z: 0))
                    .onChange(of: context.date) { // Drives auto-spin
                        if isAutoSpinning && !isDragging {
                            yRotationAngle.degrees += 0.5 // Auto-spin around Y
                            if yRotationAngle.degrees >= 360 { yRotationAngle.degrees -= 360 }
                            // Keep accumulated in sync if auto-spinning
                            accumulatedYRotation = yRotationAngle
                        }
                    }
            } placeholder: {
                ProgressView().frame(minHeight: 200, maxHeight: 400)
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    if !isDragging { // First time onChanged is called for this drag
                        isDragging = true
                        isAutoSpinning = false // Stop auto-spin
                    }
                    // Calculate new rotation based on drag from the last accumulated rotation
                    yRotationAngle = accumulatedYRotation + Angle(degrees: Double(value.translation.width) * dragSensitivity)
                    xRotationAngle = accumulatedXRotation + Angle(degrees: -Double(value.translation.height) * dragSensitivity) // Negative for intuitive up/down swipe
                }
                .onEnded { value in
                    isDragging = false
                    // Store the final rotation from this drag as the new accumulated base
                    accumulatedYRotation = yRotationAngle
                    accumulatedXRotation = xRotationAngle
                    // Optional: Add a button or logic to re-enable auto-spin if desired
                }
        )
        .id(modelName) // Resets state when modelName changes
        // Optional: Add a button to toggle isAutoSpinning
        // .overlay(alignment: .bottom) {
        //     Button(isAutoSpinning ? "Pause Spin" : "Resume Spin") {
        //         isAutoSpinning.toggle()
        //         if isAutoSpinning { // If resuming, start from current accumulated yRotation
        //            yRotationAngle = accumulatedYRotation
        //         }
        //     }
        //     .padding()
        //}
    }
}

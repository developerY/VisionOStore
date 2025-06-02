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
// MARK: - Other Helper Views
// Updated SpinningProductModelView with MagnificationGesture for zoom
struct SpinningProductModelView: View {
    let modelName: String
    let scale: Double // Renamed from 'scale' to 'baseScale' for clarity

    // Rotation state
    @State private var yRotationAngle: Angle = .zero
    @State private var xRotationAngle: Angle = .zero
    @State private var accumulatedYRotation: Angle = .zero
    @State private var accumulatedXRotation: Angle = .zero
    @State private var isAutoSpinning: Bool = true
    @State private var isDraggingRotation: Bool = false
    private let dragSensitivity: Double = 0.5

    // Zoom/Magnification state
    @State private var currentMagnification: CGFloat = 1.0
    @State private var accumulatedMagnification: CGFloat = 1.0
    // Define min and max zoom levels
    private let minMagnification: CGFloat = 0.5
    private let maxMagnification: CGFloat = 3.0

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.016, paused: !isAutoSpinning || isDraggingRotation )) { context in
            Model3D(named: modelName, bundle: RealityKitContent.realityKitContentBundle) { model in
                model
                    .resizable()
                    .scaledToFit()
                    // Apply base scale from product and then interactive magnification
                    .scaleEffect(scale * currentMagnification)
                    .frame(minHeight: 200, maxHeight: 400)
                    .rotation3DEffect(xRotationAngle, axis: (x: 1, y: 0, z: 0))
                    .rotation3DEffect(yRotationAngle, axis: (x: 0, y: 1, z: 0))
                    .onChange(of: context.date) {
                        if isAutoSpinning && !isDraggingRotation {
                            yRotationAngle.degrees += 0.5
                            if yRotationAngle.degrees >= 360 { yRotationAngle.degrees -= 360 }
                            accumulatedYRotation = yRotationAngle
                        }
                    }
            } placeholder: {
                ProgressView().frame(minHeight: 200, maxHeight: 400)
            }
        }
        // Combine DragGesture for rotation and MagnificationGesture for zoom
        // Applying them sequentially usually works fine. If conflicts arise, SimultaneousGesture could be used.
        .gesture(
            DragGesture()
                .onChanged { value in
                    if !isDraggingRotation {
                        isDraggingRotation = true
                        isAutoSpinning = false
                    }
                    yRotationAngle = accumulatedYRotation + Angle(degrees: Double(value.translation.width) * dragSensitivity)
                    xRotationAngle = accumulatedXRotation + Angle(degrees: -Double(value.translation.height) * dragSensitivity)
                }
                .onEnded { value in
                    isDraggingRotation = false
                    accumulatedYRotation = yRotationAngle
                    accumulatedXRotation = xRotationAngle
                }
        )
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    // Stop auto-spin when zooming
                    isAutoSpinning = false
                    // Calculate new magnification, ensuring it stays within min/max bounds
                    let newMagnification = accumulatedMagnification * value
                    currentMagnification = min(max(newMagnification, minMagnification), maxMagnification)
                }
                .onEnded { value in
                    // Store the final magnification from this gesture
                    accumulatedMagnification = currentMagnification
                }
        )
        .id(modelName) // Resets state (including zoom and rotation) when modelName changes
        // Optional: Button to reset zoom and rotation
        .overlay(alignment: .topTrailing) {
            Button {
                withAnimation {
                    xRotationAngle = .zero
                    yRotationAngle = .zero
                    accumulatedXRotation = .zero
                    accumulatedYRotation = .zero
                    currentMagnification = 1.0
                    accumulatedMagnification = 1.0
                    isAutoSpinning = true // Optionally restart auto-spin
                }
            } label: {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(.title2)
                    .padding()
            }
            .buttonStyle(.plain) // Use plain style for better appearance as an overlay
            .opacity(isDraggingRotation || (currentMagnification != 1.0) || (xRotationAngle != .zero) || (yRotationAngle != .zero && !isAutoSpinning) ? 0.8 : 0.3) // Show more clearly when interacted
        }
    }
}

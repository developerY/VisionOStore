//
//  ModelTestView.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 5/31/25.
//
import SwiftUI
import RealityKit
import RealityKitContent // 1. Import the package to access its bundle

// MARK: - ModelTestView (Updated to Spin the Model)
struct ModelTestView: View {
    //private let modelToTest = "Scene" // Or "Shoes/Shoes_low_poly" etc.
    private let modelToTest = "StoreItems/Shoes/Shoes_low_poly" //etc.
    private let realityKitContentBundle = RealityKitContent.realityKitContentBundle

    // State variable to hold the rotation angle
    @State private var rotationAngle: Angle = .degrees(0)
    // State variable to control animation
    @State private var isAnimating: Bool = true


    var body: some View {
        VStack(spacing: 20) {
            Text("Spinning Model Test")
                .font(.largeTitle)

            Text("Loading: \(modelToTest)")
                .font(.headline)
                .foregroundStyle(.secondary)

            Divider()

            // TimelineView to drive the animation
            TimelineView(.animation(minimumInterval: 0.016, paused: !isAnimating)) { context in
                Model3D(named: modelToTest, bundle: realityKitContentBundle) { model in
                    model
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        // Apply the rotation effect
                        .rotation3DEffect(
                            rotationAngle,
                            axis: (x: 0.2, y: 1, z: 0.1) // Spin around a slightly tilted Y-axis
                        )
                        .onChange(of: context.date) { // Use context.date from TimelineView
                            // Increment the angle smoothly
                            rotationAngle.degrees += 0.5 // Adjust speed here
                            if rotationAngle.degrees >= 360 {
                                rotationAngle.degrees -= 360 // Keep angle within 0-360
                            }
                        }
                } placeholder: {
                    ProgressView()
                }
            }
            .padding(.bottom, 50)

            Divider()

            Button(isAnimating ? "Pause Animation" : "Resume Animation") {
                isAnimating.toggle()
            }
            .padding()

        }
        .padding(40)
        .onAppear {
            isAnimating = true // Ensure animation starts when view appears
        }
    }
}


#Preview {
    ModelTestView()
}

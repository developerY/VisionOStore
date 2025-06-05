//
//  CyclingHudView.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 6/5/25.
//
import SwiftUI
import RealityKit // For potential future spatial interactions, though not used directly for this 2D overlay

// In a visionOS app, this view would be placed in an ImmersiveSpace.
// It's designed to overlay the user's view, so its own background should be clear.
struct CyclingHudView: View {
    @State private var speed: Double = 28.5
    @State private var speedUnit: String = "km/h" // or "mph"
    @State private var heartRate: Int = 135
    @State private var navigationDistance: String = "200m"
    @State private var navigationInstruction: String = "Main Street"
    @State private var navigationIconName: String = "arrow.turn.up.right" // SF Symbol name
    @State private var elapsedTime: String = "01:12:30"
    @State private var distanceTravelled: String = "25.7"

    // HUD elements often benefit from a subtle effect to ensure legibility
    // against varying backgrounds. This can be a very light shadow or a
    // minimal glass background effect on individual elements.
    // For this example, we'll keep it clean and rely on text/icon color.

    var body: some View {
        // ZStack to layer elements in fixed positions over the passthrough view.
        // The coordinate space for an ImmersiveSpace can be complex.
        // For a simple fixed HUD, we can use screen-space-like positioning
        // or anchor elements to the user's view.
        // This example assumes a screen-space overlay approach for simplicity.
        ZStack {
            // --- Navigation Display (Top Center) ---
            VStack {
                NavigationCueView(
                    iconName: navigationIconName,
                    distance: navigationDistance,
                    instruction: navigationInstruction
                )
                Spacer() // Pushes navigation to the top
            }
            .padding(.top, 30) // Adjust for visionOS safe areas/comfort

            // --- Speed Display (Bottom Leading) ---
            VStack {
                Spacer() // Pushes speed to the bottom
                HStack {
                    SpeedIndicatorView(speed: speed, unit: speedUnit)
                    Spacer() // Pushes speed to the leading edge
                }
            }
            .padding(.leading, 40)
            .padding(.bottom, 50)

            // --- Heart Rate Display (Bottom Trailing) ---
            VStack {
                Spacer() // Pushes heart rate to the bottom
                HStack {
                    Spacer() // Pushes heart rate to the trailing edge
                    HeartRateMonitorView(heartRate: heartRate)
                }
            }
            .padding(.trailing, 40)
            .padding(.bottom, 50)
            
            // --- Trip Stats (Top Leading) ---
            VStack {
                HStack {
                    TripStatsView(elapsedTime: elapsedTime, distanceTravelled: distanceTravelled)
                    Spacer() // Pushes to leading
                }
                Spacer() // Pushes to top
            }
            .padding(.leading, 40)
            .padding(.top, 30)

        }
        .font(.system(size: 28, weight: .medium, design: .default)) // Default font for HUD
        .foregroundColor(.white) // Default text color, good for contrast on passthrough
        // Add a subtle shadow to all text/icons for better legibility
        .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Ensure the ZStack itself doesn't have a background unless desired
        // For a HUD, it should be clear to see the passthrough.
    }
}

struct HudElementBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            // In visionOS, you might use a subtle glassBackgroundEffect
            // or a very semi-transparent material.
            // For a minimal HUD, often no explicit background per element is cleaner.
            // This example uses a very subtle semi-transparent black for contrast.
            .background(.black.opacity(0.25))
            .cornerRadius(15)
    }
}

struct NavigationCueView: View {
    let iconName: String
    let distance: String
    let instruction: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(.cyan) // Accent color
            Text(distance)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.cyan) // Accent color
            Text(instruction)
                .font(.system(size: 22, weight: .regular))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .modifier(HudElementBackground())
    }
}

struct SpeedIndicatorView: View {
    let speed: Double
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(String(format: "%.1f", speed))
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(.green) // Accent color
                    .lineLimit(1)
                Text(unit)
                    .font(.system(size: 20, weight: .medium))
                    .padding(.bottom, 8) // Align with baseline of larger text
            }
            Text("SPEED")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
        }
        .modifier(HudElementBackground())
    }
}

struct HeartRateMonitorView: View {
    let heartRate: Int

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.red) // Accent color
                Text("\(heartRate)")
                    .font(.system(size: 48, weight: .semibold, design: .rounded))
                    .foregroundColor(.red) // Accent color
                    .lineLimit(1)
            }
             Text("BPM")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
        }
        .modifier(HudElementBackground())
    }
}

struct TripStatsView: View {
    let elapsedTime: String
    let distanceTravelled: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "timer")
                    .font(.caption)
                Text(elapsedTime)
                    .font(.title3)
            }
            HStack {
                 Image(systemName: "point.topleft.down.curvedto.point.bottomright.up.fill") // Generic route icon
                    .font(.caption)
                Text("\(distanceTravelled) km")
                    .font(.headline)
            }
        }
        .modifier(HudElementBackground())
    }
}


// MARK: - Previews
#Preview(windowStyle: .plain) { // Use .plain for a non-windowed preview if needed, or specific window style
    // To preview for visionOS, you'd typically run on device or simulator.
    // This preview will show in Xcode.
    // For a more realistic HUD preview, you'd place this in an ImmersiveSpace.
    ZStack {
        // Placeholder for a background, in a real app this is the camera feed
        Image(systemName: "bicycle.circle.fill") // Example background content
            .resizable()
            .scaledToFill()
            .opacity(0.3)
            .ignoresSafeArea()

        CyclingHudView()
    }
}

#Preview {
    NavigationCueView(iconName: "arrow.turn.up.left", distance: "150ft", instruction: "Oak Avenue")
        .padding()
        .background(.gray)
}

#Preview {
    SpeedIndicatorView(speed: 22.8, unit: "mph")
        .padding()
        .background(.gray)
}

#Preview {
    HeartRateMonitorView(heartRate: 142)
        .padding()
        .background(.gray)
}

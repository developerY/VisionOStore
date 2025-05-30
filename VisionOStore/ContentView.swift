//
//  ContentView.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 5/28/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    var body: some View {
        VStack {
            Model3D(named: "Scene", bundle: realityKitContentBundle)
                .padding(.bottom, 50)

            Text("Hello, world!")
            RideLinksView()

            ToggleImmersiveSpaceButton()
            
            
            /*TimelineView(.animation) { timeline in
                        // Rotate at 45° per second
                        let degrees = timeline.date.timeIntervalSinceReferenceDate * 45
                        Model3D(
                            named: "StoreItems/sneaker_airforce",
                            bundle: realityKitContentBundle
                        )
                        .padding(.bottom, 50)
                        .rotation3DEffect(
                            .degrees(degrees),
                            axis: (x: 0, y: 1, z: 0)
                        )
                    }*/
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}

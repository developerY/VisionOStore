//
//  AppModel.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 5/28/25.
//

import SwiftUI

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    // Product selected for the immersive experience
    var selectedProductForImmersiveView: ProductSplit? = nil
    var productForARTryOn: ProductSplit? = nil // Renamed for clarity
    
    
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
}

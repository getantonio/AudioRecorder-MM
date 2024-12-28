import SwiftUI

enum WaveformStyle: String, CaseIterable {
    case bars      // Traditional bar visualization
    case blocks    // Blocks that stack vertically
    case circle    // Circular/spiral visualization
    case spectrum  // Spectrum analyzer style
    
    var animation: Animation {
        switch self {
        case .bars:
            return .easeOut(duration: 0.05)
        case .blocks:
            return .spring(dampingFraction: 0.7)
        case .circle:
            return .easeInOut(duration: 0.1)
        case .spectrum:
            return .easeOut(duration: 0.08)
        }
    }
} 
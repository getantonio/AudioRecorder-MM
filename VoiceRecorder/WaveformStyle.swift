import SwiftUI

enum WaveformStyle: String, CaseIterable {
    case bars      // Traditional bar visualization
    case blocks    // Blocks that stack vertically
    case wave      // Smooth wave visualization
    case spectrum  // Spectrum analyzer style
    
    var animation: Animation {
        switch self {
        case .bars:
            return .easeOut(duration: 0.05)
        case .blocks:
            return .spring(dampingFraction: 0.7)
        case .wave:
            return .easeInOut(duration: 0.2)
        case .spectrum:
            return .easeOut(duration: 0.08)
        }
    }
} 
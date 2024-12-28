import SwiftUI

enum WaveformStyle {
    case bars
    case line
    case mirror
    
    var animation: Animation {
        switch self {
        case .bars:
            return .easeOut(duration: 0.05)
        case .line:
            return .easeInOut(duration: 0.1)
        case .mirror:
            return .spring(dampingFraction: 0.7)
        }
    }
} 
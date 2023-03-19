//
//  Lifecycleable.swift
//  
//
//  Created by Ido on 18/03/2023.
//

import Foundation

enum MNLifecycleState {
    case initalizing
    case loading
    case enabled
    case disabled
    
    case saving
    case saved
    
    case deininiting
    case deinited
    
    enum Simplified : Int {
        case initalizing = 1
        case loading  = 2
        
        case enabled = 10
        case disabled = 11
        
        case saving = 20
        case saved = 21
        
        case deininiting = 50
        case deinited = 99
    }
    
    var simplified : Simplified {
        switch self {
        case .initalizing:  return .initalizing
        case .loading:      return .loading
        case .enabled:      return .enabled
        case .disabled:     return .disabled
        case .saving:       return .saving
        case .saved:        return .saved
        case .deininiting:  return .deininiting
        case .deinited:     return .deinited
        }
    }
}


struct MNState {
    var state : MNLifecycleState
    var progress : Int?
    var progressTitle : String?
    var progressSubtitle : String?
    var progressIntCount : Int?
    var progressIntTotal : Int?
}

protocol LifecycleStatable {
//    var curState: LifecycleState : { get }
    // _ application: Application) throws
    
}

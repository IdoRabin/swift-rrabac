//
//  RRabacCRUDAction.swift
//  
//
//  Created by Ido on 06/07/2023.
//

import Foundation
import MNUtils

public enum RRabacCRUDAction : String, MNDBEnum {
    case create = "rrbc_create"
    case read   = "rrbc_read"
    case update = "rrbc_update"
    case delete = "rrbc_delete"
}

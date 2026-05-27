//
//  RepositoryError.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-27.
//

import Foundation
internal import CoreData

/// Errors during repository operations.
enum RepositoryError: Error {
    
    /// A band or venue with the name already exists.
    case duplicateEntry
    
    /// An unknown error occurred.
    case unknown(any Error)
    
}

//
//  RepositoryError.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-27.
//

import Foundation
internal import CoreData

// TODO: Remove this error, it's useless.

/// Errors during repository operations.
enum RepositoryError: Error {
    
    /// An unknown error occurred.
    case unknown(any Error)
    
}

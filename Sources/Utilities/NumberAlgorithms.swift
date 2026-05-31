//
//  NumberAlgorithms.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-31.
//

import Foundation

extension FixedWidthInteger {
    
    /// Calculate true modulo (euclidean remainder).
    ///
    /// Swift's `%` operator returns the remainder. The difference affects negative quotients:
    /// * `-7 % 3 == -1`
    /// * `(-7).modulo(3) == 2`
    @inlinable
    func modulo(_ other: Self) -> Self {
        let remainder = self % other
        if remainder >= 0 {
            return remainder
        }
        if other >= 0 {
            return remainder + other
        }
        return remainder - other
    }
    
}

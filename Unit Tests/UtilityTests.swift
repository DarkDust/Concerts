//
//  UtilityTests.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-31.
//

import Foundation
import Testing


struct UtilityTests {
    
    @Test
    func testModulo() {
        #expect(7.modulo(3) == 1)
        #expect((-7).modulo(3) == 2)
        #expect((-5).modulo(20) == 15)
    }
    
}

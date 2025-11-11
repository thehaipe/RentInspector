//
//  URL+Extensions.swift
//  RentInspector
//
//  Created by Valentyn on 11.11.2025.
//

import Foundation
// Дозволяє використовувати URL з .sheet(item:)
extension URL: @retroactive Identifiable {
    public var id: String { self.absoluteString }
}

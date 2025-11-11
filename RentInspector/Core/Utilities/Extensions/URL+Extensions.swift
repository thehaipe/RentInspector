/*
 Розширення для роботи з URL (з бібліотеки Foundation)
 */
import Foundation
// Дозволяє використовувати URL з .sheet(item:)
extension URL: @retroactive Identifiable {
    public var id: String { self.absoluteString }
}

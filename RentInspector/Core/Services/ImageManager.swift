import SwiftUI

class ImageManager {
    static let shared = ImageManager()
    
    // Отримуємо шлях до папки Documents
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func saveImage(_ data: Data) -> String? {
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileName
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    func loadImage(named fileName: String) -> UIImage? {
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        do {
            let data = try Data(contentsOf: fileURL)
            return UIImage(data: data)
        } catch {
            print("Error loading image: \(error)")
            return nil
        }
    }
    
    func deleteImage(named fileName: String) {
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: fileURL)
    }
}

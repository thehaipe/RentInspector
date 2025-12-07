/*
 Класс для формування PDF-версії звіту для відправки.
 На майбутнє: Розтягнути зображення у звіті для кращої читабельності.
 */
import UIKit
import PDFKit
import RealmSwift
internal import SwiftUI

class PDFExportService {
    static let shared = PDFExportService()
    
    private init() {}
    
    // MARK: - Public Method
    
    func generatePDF(for record: Record) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "RentInspector",
            kCGPDFContextAuthor: "RentInspector App",
            kCGPDFContextTitle: record.titleString
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        // A4 розмір: 595 x 842 points
        let pageWidth: CGFloat = 595
        let pageHeight: CGFloat = 842
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            var yPosition: CGFloat = 60
            
            context.beginPage()
            
            // MARK: - Header (Назва звіту)
            yPosition = drawTitle(record.titleString, at: yPosition, in: pageRect, context: context)
            
            // MARK: - Загальна інформація
            yPosition = drawGeneralInfo(for: record, at: yPosition, in: pageRect, context: context)
            
            // MARK: - Статистика кімнат
            yPosition = drawRoomStatistics(for: record, at: yPosition, in: pageRect, context: context)
            
            // Divider
            yPosition = drawDivider(at: yPosition, in: pageRect)
            
            // MARK: - Секції кімнат
            for (index, room) in record.rooms.enumerated() {
                // Перевірка чи потрібна нова сторінка
                if yPosition > pageHeight - 200 {
                    context.beginPage()
                    yPosition = 60
                }
                
                yPosition = drawRoomSection(
                    room: room,
                    index: index + 1,
                    at: yPosition,
                    in: pageRect,
                    context: context
                )
                
                if index < record.rooms.count - 1 {
                    yPosition = drawDivider(at: yPosition, in: pageRect)
                }
            }
            
            // MARK: - Footer
            drawFooter(at: pageHeight - 40, in: pageRect)
        }
        
        let safeFilename = "report-\(UUID().uuidString).pdf"
        return savePDF(data: data, filename: safeFilename)
    }
    
    // MARK: - Drawing Methods
    
    private func drawTitle(_ title: String, at yPosition: CGFloat, in pageRect: CGRect, context: UIGraphicsPDFRendererContext) -> CGFloat {
            let titleFont = UIFont.boldSystemFont(ofSize: 24)
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor.black
            ]
            
            let titleSize = title.size(withAttributes: titleAttributes)
            let titleRect = CGRect(
                x: 40,
                y: yPosition,
                width: pageRect.width - 80,
                height: titleSize.height
            )
            
            title.draw(in: titleRect, withAttributes: titleAttributes)
            
            return yPosition + titleSize.height + 20
        }
    
    private func drawGeneralInfo(for record: Record, at yPosition: CGFloat, in pageRect: CGRect, context: UIGraphicsPDFRendererContext) -> CGFloat {
            var currentY = yPosition
            
            let infoFont = UIFont.systemFont(ofSize: 12)
            let infoAttributes: [NSAttributedString.Key: Any] = [
                .font: infoFont,
                .foregroundColor: UIColor.darkGray
            ]
            
            let dateString = record.createdAt.formatted(date: .long, time: .shortened)
            let dateText = String(format: NSLocalizedString("pdf_date_created", comment: ""), dateString)
            
            let dateSize = dateText.size(withAttributes: infoAttributes)
            let dateRect = CGRect(x: 40, y: currentY, width: pageRect.width - 80, height: dateSize.height)
            dateText.draw(in: dateRect, withAttributes: infoAttributes)
            currentY += dateSize.height + 8
            
            let stageLabel = NSLocalizedString("form_stage_label", comment: "")
            let stageValue = record.recordStage.localizedStringValue
            let stageText = "\(stageLabel): \(stageValue)"
            
            let stageSize = stageText.size(withAttributes: infoAttributes)
            let stageRect = CGRect(x: 40, y: currentY, width: pageRect.width - 80, height: stageSize.height)
            stageText.draw(in: stageRect, withAttributes: infoAttributes)
            currentY += stageSize.height + 8
            
            // 3. Нагадування (Локалізовано)
            if record.reminderInterval > 0 {
                let reminderLabel = NSLocalizedString("form_reminder_label", comment: "")
                let intervalText = String(format: NSLocalizedString("form_reminder_days", comment: ""), record.reminderInterval)
                let reminderText = "\(reminderLabel): \(intervalText)"
                let reminderSize = reminderText.size(withAttributes: infoAttributes)
                let reminderRect = CGRect(x: 40, y: currentY, width: pageRect.width - 80, height: reminderSize.height)
                reminderText.draw(in: reminderRect, withAttributes: infoAttributes)
                currentY += reminderSize.height + 8
            }
            
            return currentY + 20
        }
    
    private func drawRoomStatistics(for record: Record, at yPosition: CGFloat, in pageRect: CGRect, context: UIGraphicsPDFRendererContext) -> CGFloat {
            var currentY = yPosition
            
            let headerFont = UIFont.boldSystemFont(ofSize: 16)
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: headerFont,
                .foregroundColor: UIColor.black
            ]
            let headerText = NSLocalizedString("pdf_statistics_title", comment: "Statistics header")
            let headerSize = headerText.size(withAttributes: headerAttributes)
            let headerRect = CGRect(x: 40, y: currentY, width: pageRect.width - 80, height: headerSize.height)
            headerText.draw(in: headerRect, withAttributes: headerAttributes)
            currentY += headerSize.height + 12
            let roomCounts = Dictionary(grouping: Array(record.rooms), by: { $0.roomType })
                .mapValues { $0.count }
                .sorted {
                    $0.key.localizedStringValue < $1.key.localizedStringValue
                }
            let statFont = UIFont.systemFont(ofSize: 12)
            let statAttributes: [NSAttributedString.Key: Any] = [
                .font: statFont,
                .foregroundColor: UIColor.darkGray
            ]
            
            for (roomType, count) in roomCounts {
                let statText = "\(roomType.localizedStringValue) - x\(count)"
                let statSize = statText.size(withAttributes: statAttributes)
                let statRect = CGRect(x: 60, y: currentY, width: pageRect.width - 100, height: statSize.height)
                statText.draw(in: statRect, withAttributes: statAttributes)
                currentY += statSize.height + 6
            }
            
            let photoText = String(format: NSLocalizedString("pdf_total_photos", comment: ""), record.totalPhotos)
            let photoSize = photoText.size(withAttributes: statAttributes)
            let photoRect = CGRect(x: 60, y: currentY, width: pageRect.width - 100, height: photoSize.height)
            photoText.draw(in: photoRect, withAttributes: statAttributes)
            currentY += photoSize.height + 20
            
            return currentY
        }
    
    private func drawRoomSection(room: Room, index: Int, at yPosition: CGFloat, in pageRect: CGRect, context: UIGraphicsPDFRendererContext) -> CGFloat {
            var currentY = yPosition
            let roomFont = UIFont.boldSystemFont(ofSize: 18)
            let roomAttributes: [NSAttributedString.Key: Any] = [
                .font: roomFont,
                .foregroundColor: UIColor.black
            ]
            
            let roomTitle = room.displayNameString
            let roomSize = roomTitle.size(withAttributes: roomAttributes)
            let roomRect = CGRect(x: 40, y: currentY, width: pageRect.width - 80, height: roomSize.height)
            roomTitle.draw(in: roomRect, withAttributes: roomAttributes)
            currentY += roomSize.height + 12
            
            if !room.comment.isEmpty {
                let commentFont = UIFont.systemFont(ofSize: 12)
                let commentAttributes: [NSAttributedString.Key: Any] = [
                    .font: commentFont,
                    .foregroundColor: UIColor.darkGray
                ]
                
                let commentLabel = NSLocalizedString("records_comment", comment: "")
                let commentText = "\(commentLabel): \(room.comment)"
                let commentSize = commentText.boundingRect(
                    with: CGSize(width: pageRect.width - 80, height: 1000),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: commentAttributes,
                    context: nil
                )
                
                commentText.draw(in: CGRect(x: 40, y: currentY, width: pageRect.width - 80, height: commentSize.height), withAttributes: commentAttributes)
                currentY += commentSize.height + 16
            }
            
            if !room.photoPaths.isEmpty {
                let photoTitleFont = UIFont.boldSystemFont(ofSize: 14)
                let photoTitleAttributes: [NSAttributedString.Key: Any] = [
                    .font: photoTitleFont,
                    .foregroundColor: UIColor.black
                ]
                
                let photoTitleText = NSLocalizedString("records_photos", comment: "") + ":"
                let photoTitleSize = photoTitleText.size(withAttributes: photoTitleAttributes)
                let photoTitleRect = CGRect(x: 40, y: currentY, width: pageRect.width - 80, height: photoTitleSize.height)
                photoTitleText.draw(in: photoTitleRect, withAttributes: photoTitleAttributes)
                currentY += photoTitleSize.height + 12
                
                for (photoIndex, photoPath) in room.photoPaths.enumerated() {
                    if currentY > pageRect.height - 300 {
                        context.beginPage()
                        currentY = 60
                    }
                    
                    if let image = ImageManager.shared.loadImage(named: photoPath) {
                        let maxWidth: CGFloat = pageRect.width - 120
                        let maxHeight: CGFloat = 250
                        let aspectRatio = image.size.width / image.size.height
                        var imageWidth = maxWidth
                        var imageHeight = imageWidth / aspectRatio
                        
                        if imageHeight > maxHeight {
                            imageHeight = maxHeight
                            imageWidth = imageHeight * aspectRatio
                        }
                        
                        let imageRect = CGRect(
                            x: (pageRect.width - imageWidth) / 2,
                            y: currentY,
                            width: imageWidth,
                            height: imageHeight
                        )
                        
                        image.draw(in: imageRect)
                        currentY += imageHeight + 8
 
                        let captionFont = UIFont.systemFont(ofSize: 10)
                        let captionAttributes: [NSAttributedString.Key: Any] = [
                            .font: captionFont,
                            .foregroundColor: UIColor.lightGray
                        ]
                        
                        let captionText = String(format: NSLocalizedString("photo_number_format", comment: ""), photoIndex + 1)
                        let captionSize = captionText.size(withAttributes: captionAttributes)
                        let captionRect = CGRect(
                            x: (pageRect.width - captionSize.width) / 2,
                            y: currentY,
                            width: captionSize.width,
                            height: captionSize.height
                        )
                        captionText.draw(in: captionRect, withAttributes: captionAttributes)
                        currentY += captionSize.height + 16
                    }
                }
            } else {
                let noPhotoFont = UIFont.italicSystemFont(ofSize: 12)
                let noPhotoAttributes: [NSAttributedString.Key: Any] = [
                    .font: noPhotoFont,
                    .foregroundColor: UIColor.lightGray
                ]
                
                let noPhotoText = NSLocalizedString("records_no_photos", comment: "")
                
                let noPhotoSize = noPhotoText.size(withAttributes: noPhotoAttributes)
                let noPhotoRect = CGRect(x: 40, y: currentY, width: pageRect.width - 80, height: noPhotoSize.height)
                noPhotoText.draw(in: noPhotoRect, withAttributes: noPhotoAttributes)
                currentY += noPhotoSize.height + 16
            }
            
            return currentY + 10
        }
    
    private func drawDivider(at yPosition: CGFloat, in pageRect: CGRect) -> CGFloat {
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor.lightGray.cgColor)
        context?.setLineWidth(1.0)
        context?.move(to: CGPoint(x: 40, y: yPosition))
        context?.addLine(to: CGPoint(x: pageRect.width - 40, y: yPosition))
        context?.strokePath()
        
        return yPosition + 20
    }
    
    private func drawFooter(at yPosition: CGFloat, in pageRect: CGRect) {
            let footerFont = UIFont.systemFont(ofSize: 10)
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: footerFont,
                .foregroundColor: UIColor.lightGray
            ]
            
            let dateString = Date().formatted(date: .abbreviated, time: .shortened)
            let footerText = String(format: NSLocalizedString("pdf_generated_by", comment: ""), dateString)
            
            let footerSize = footerText.size(withAttributes: footerAttributes)
            let footerRect = CGRect(
                x: (pageRect.width - footerSize.width) / 2,
                y: yPosition,
                width: footerSize.width,
                height: footerSize.height
            )
            
            footerText.draw(in: footerRect, withAttributes: footerAttributes)
        }
    
    // MARK: - Save PDF
    
    private func savePDF(data: Data, filename: String) -> URL? {
        let documentsPath = FileManager.default.temporaryDirectory
        
        // Створюємо повний шлях до файлу
        let pdfPath = documentsPath.appendingPathComponent(filename)
        
        do {
            try data.write(to: pdfPath, options: .atomic)
            print("✅ PDF saved at: \(pdfPath.path)")
            return pdfPath
        } catch {
            print("❌ Error saving PDF: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Share PDF
    
    func sharePDF(url: URL, from viewController: UIViewController) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        // Для iPad
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = viewController.view
            popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        viewController.present(activityVC, animated: true)
    }
}

//
//  PDFExportService.swift
//  RentInspector
//
//  Created by Valentyn on 07.11.2025.
//
import UIKit
import PDFKit

class PDFExportService {
    static let shared = PDFExportService()
    
    private init() {}
    
    // MARK: - Public Method
    
    func generatePDF(for record: Record) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "RentInspector",
            kCGPDFContextAuthor: "RentInspector App",
            kCGPDFContextTitle: record.displayTitle
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
            yPosition = drawTitle(record.displayTitle, at: yPosition, in: pageRect, context: context)
            
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
                
                // Divider між кімнатами
                if index < record.rooms.count - 1 {
                    yPosition = drawDivider(at: yPosition, in: pageRect)
                }
            }
            
            // MARK: - Footer
            drawFooter(at: pageHeight - 40, in: pageRect)
        }
        
        // Зберігання PDF
        return savePDF(data: data, filename: "\(record.displayTitle).pdf")
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
        
        // Дата створення
        let dateText = "Дата створення: \(record.createdAt.formatted(date: .long, time: .shortened))"
        let dateSize = dateText.size(withAttributes: infoAttributes)
        let dateRect = CGRect(x: 40, y: currentY, width: pageRect.width - 80, height: dateSize.height)
        dateText.draw(in: dateRect, withAttributes: infoAttributes)
        currentY += dateSize.height + 8
        
        // Етап
        let stageText = "Етап: \(record.recordStage.displayName)"
        let stageSize = stageText.size(withAttributes: infoAttributes)
        let stageRect = CGRect(x: 40, y: currentY, width: pageRect.width - 80, height: stageSize.height)
        stageText.draw(in: stageRect, withAttributes: infoAttributes)
        currentY += stageSize.height + 8
        
        // Нагадування
        if record.reminderInterval > 0 {
            let reminderText = "Нагадування: кожні \(record.reminderInterval) днів"
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
        
        let headerText = "Статистика"
        let headerSize = headerText.size(withAttributes: headerAttributes)
        let headerRect = CGRect(x: 40, y: currentY, width: pageRect.width - 80, height: headerSize.height)
        headerText.draw(in: headerRect, withAttributes: headerAttributes)
        currentY += headerSize.height + 12
        
        // Підрахунок кількості кожного типу кімнат
        let roomCounts = Dictionary(grouping: record.rooms, by: { $0.roomType })
            .mapValues { $0.count }
            .sorted { $0.key.displayName < $1.key.displayName }
        
        let statFont = UIFont.systemFont(ofSize: 12)
        let statAttributes: [NSAttributedString.Key: Any] = [
            .font: statFont,
            .foregroundColor: UIColor.darkGray
        ]
        
        for (roomType, count) in roomCounts {
            let statText = "\(roomType.displayName) - x\(count)"
            let statSize = statText.size(withAttributes: statAttributes)
            let statRect = CGRect(x: 60, y: currentY, width: pageRect.width - 100, height: statSize.height)
            statText.draw(in: statRect, withAttributes: statAttributes)
            currentY += statSize.height + 6
        }
        
        // Загальна кількість фото
        let photoText = "Всього фото: \(record.totalPhotos)"
        let photoSize = photoText.size(withAttributes: statAttributes)
        let photoRect = CGRect(x: 60, y: currentY, width: pageRect.width - 100, height: photoSize.height)
        photoText.draw(in: photoRect, withAttributes: statAttributes)
        currentY += photoSize.height + 20
        
        return currentY
    }
    
    private func drawRoomSection(room: Room, index: Int, at yPosition: CGFloat, in pageRect: CGRect, context: UIGraphicsPDFRendererContext) -> CGFloat {
        var currentY = yPosition
        
        // Назва кімнати
        let roomFont = UIFont.boldSystemFont(ofSize: 18)
        let roomAttributes: [NSAttributedString.Key: Any] = [
            .font: roomFont,
            .foregroundColor: UIColor.black
        ]
        
        let roomTitle = room.displayName
        let roomSize = roomTitle.size(withAttributes: roomAttributes)
        let roomRect = CGRect(x: 40, y: currentY, width: pageRect.width - 80, height: roomSize.height)
        roomTitle.draw(in: roomRect, withAttributes: roomAttributes)
        currentY += roomSize.height + 12
        
        // Коментарі
        if !room.comment.isEmpty {
            let commentFont = UIFont.systemFont(ofSize: 12)
            let commentAttributes: [NSAttributedString.Key: Any] = [
                .font: commentFont,
                .foregroundColor: UIColor.darkGray
            ]
            
            let commentText = "Коментар: \(room.comment)"
            let commentBounds = CGRect(x: 40, y: currentY, width: pageRect.width - 80, height: 1000)
            let commentSize = commentText.boundingRect(
                with: CGSize(width: pageRect.width - 80, height: 1000),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: commentAttributes,
                context: nil
            )
            
            commentText.draw(in: CGRect(x: 40, y: currentY, width: pageRect.width - 80, height: commentSize.height), withAttributes: commentAttributes)
            currentY += commentSize.height + 16
        }
        
        // Фотографії
        if !room.photoData.isEmpty {
            let photoTitleFont = UIFont.boldSystemFont(ofSize: 14)
            let photoTitleAttributes: [NSAttributedString.Key: Any] = [
                .font: photoTitleFont,
                .foregroundColor: UIColor.black
            ]
            
            let photoTitleText = "Фотографії:"
            let photoTitleSize = photoTitleText.size(withAttributes: photoTitleAttributes)
            let photoTitleRect = CGRect(x: 40, y: currentY, width: pageRect.width - 80, height: photoTitleSize.height)
            photoTitleText.draw(in: photoTitleRect, withAttributes: photoTitleAttributes)
            currentY += photoTitleSize.height + 12
            
            // Рендеринг кожного фото
            for (photoIndex, photoData) in room.photoData.enumerated() {
                // Перевірка чи потрібна нова сторінка
                if currentY > pageRect.height - 300 {
                    context.beginPage()
                    currentY = 60
                }
                
                if let image = UIImage(data: photoData) {
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
                    
                    // Підпис фото
                    let captionFont = UIFont.systemFont(ofSize: 10)
                    let captionAttributes: [NSAttributedString.Key: Any] = [
                        .font: captionFont,
                        .foregroundColor: UIColor.lightGray
                    ]
                    
                    let captionText = "Фото \(photoIndex + 1)"
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
            // Якщо немає фото
            let noPhotoFont = UIFont.italicSystemFont(ofSize: 12)
            let noPhotoAttributes: [NSAttributedString.Key: Any] = [
                .font: noPhotoFont,
                .foregroundColor: UIColor.lightGray
            ]
            
            let noPhotoText = "Немає фотографій"
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
        
        let footerText = "Згенеровано RentInspector • \(Date().formatted(date: .abbreviated, time: .shortened))"
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
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pdfPath = documentsPath.appendingPathComponent(filename)
        
        do {
            try data.write(to: pdfPath)
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

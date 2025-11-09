//
//  CreateRecordCoordinator.swift
//  RentInspector
//
//  Created by Valentyn on 08.11.2025.
//
import SwiftUI

struct CreateRecordCoordinator: View {
    @StateObject private var viewModel = CreateRecordViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Основний контент
                if !viewModel.showSuccessView {
                    VStack(spacing: 0) {
                        // Progress Bar
                        progressBar
                        
                        // Контент відповідного кроку
                        currentStepView
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                } else {
                    // Success View
                    RecordSuccessView(
                        recordTitle: viewModel.recordTitle.isEmpty
                            ? "Record \(Date().formatted(date: .abbreviated, time: .omitted))"
                            : viewModel.recordTitle,
                        onExportPDF: {
                            exportPDF()
                        },
                        onDismiss: {
                            viewModel.reset()
                            dismiss()
                        }
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.showSuccessView)
        }
    }
    
    // MARK: - Progress Bar
    
    private var progressBar: some View {
        VStack(spacing: 0) {
            // Прогрес
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(AppTheme.tertiaryBackgroundColor)
                        .frame(height: 4)
                    
                    // Progress
                    Rectangle()
                        .fill(AppTheme.primaryColor)
                        .frame(width: geometry.size.width * progressPercentage, height: 4)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.currentStep)
                }
            }
            .frame(height: 4)
            
            // Текст прогресу
            HStack {
                Text(stepTitle)
                    .font(AppTheme.callout)
                    .foregroundColor(AppTheme.textSecondary)
                
                Spacer()
                
                Text("\(viewModel.currentStep.rawValue + 1)/\(CreateRecordViewModel.OnboardingStep.allCases.count)")
                    .font(AppTheme.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(AppTheme.backgroundColor)
    }
    
    private var progressPercentage: CGFloat {
        let totalSteps = CGFloat(CreateRecordViewModel.OnboardingStep.allCases.count)
        return CGFloat(viewModel.currentStep.rawValue + 1) / totalSteps
    }
    
    private var stepTitle: String {
        switch viewModel.currentStep {
        case .roomCount:
            return "Крок 1: Кількість кімнат"
        case .balconyLoggia:
            return "Крок 2: Балкон та лоджія"
        case .additionalRooms:
            return "Крок 3: Додаткові приміщення"
        case .recordForm:
            return "Крок 4: Заповнення звіту"
        }
    }
    
    // MARK: - Current Step View
    
    @ViewBuilder
    private var currentStepView: some View {
        switch viewModel.currentStep {
        case .roomCount:
            RoomCountSelectionView(viewModel: viewModel)
            
        case .balconyLoggia:
            BalconySelectionView(viewModel: viewModel)
            
        case .additionalRooms:
            AdditionalRoomsSelectionView(viewModel: viewModel)
            
        case .recordForm:
            RecordFormView(viewModel: viewModel)
        }
    }
    
    // MARK: - PDF Export
    
    private func exportPDF() {
        // TODO: Реалізація експорту PDF
        print("📄 Експорт PDF для звіту: \(viewModel.recordTitle)")
    }
}

#Preview {
    CreateRecordCoordinator()
}

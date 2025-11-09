//
//  PhotoViewerView.swift
//  RentInspector
//
//  Created by Valentyn on 08.11.2025.
//
import SwiftUI

struct PhotoViewerView: View {
    let image: UIImage
    let onDismiss: () -> Void
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let delta = value / lastScale
                            lastScale = value
                                                        scale = min(max(scale * delta, 1.0), 5.0)
                                                    }
                                                    .onEnded { _ in
                                                        lastScale = 1.0
                                                        if scale < 1.0 {
                                                            withAnimation(.spring(response: 0.3)) {
                                                                scale = 1.0
                                                                offset = .zero
                                                            }
                                                        }
                                                    }
                                            )
                                            .gesture(
                                                DragGesture()
                                                    .onChanged { value in
                                                        if scale > 1.0 {
                                                            offset = CGSize(
                                                                width: lastOffset.width + value.translation.width,
                                                                height: lastOffset.height + value.translation.height
                                                            )
                                                        }
                                                    }
                                                    .onEnded { _ in
                                                        lastOffset = offset
                                                    }
                                            )
                                            .onTapGesture(count: 2) {
                                                withAnimation(.spring(response: 0.3)) {
                                                    if scale > 1.0 {
                                                        scale = 1.0
                                                        offset = .zero
                                                        lastOffset = .zero
                                                    } else {
                                                        scale = 2.0
                                                    }
                                                }
                                            }
                                        
                                        // Close Button
                                        VStack {
                                            HStack {
                                                Spacer()
                                                
                                                Button(action: {
                                                    onDismiss()
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .font(.system(size: 30))
                                                        .foregroundColor(.white)
                                                        .shadow(color: .black.opacity(0.3), radius: 5)
                                                }
                                                .padding()
                                            }
                                            
                                            Spacer()
                                        }
                                    }
                                }
                            }

                            #Preview {
                                PhotoViewerView(
                                    image: UIImage(systemName: "photo")!,
                                    onDismiss: {}
                                )
                            }

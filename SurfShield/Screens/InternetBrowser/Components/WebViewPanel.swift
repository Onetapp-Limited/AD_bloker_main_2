//
//  WebViewPanel.swift
//  SufrShield
//
//  Created by Артур Кулик on 03.09.2025.
//

import SwiftUI

struct WebViewPanel: View {
    @State private var currentURL = "https://google.com"
    @State private var showProgress = false
    
    var observables: WebViewObservables
    // Closures для внешних действий
    let onGoBack: () -> Void
    let onGoForward: () -> Void
    let onRefresh: () -> Void
    let onGoToURL: (String) -> Void
    let onShare: (String) -> Void
    
    init(
        observables: WebViewObservables,
        onGoBack: @escaping () -> Void = {},
        onGoForward: @escaping () -> Void = {},
        onRefresh: @escaping () -> Void = {},
        onGoToURL: @escaping (String) -> Void = { _ in },
        onShare: @escaping (String) -> Void = { _ in }
    ) {
        self.observables = observables
        self.onGoBack = onGoBack
        self.onGoForward = onGoForward
        self.onRefresh = onRefresh
        self.onGoToURL = onGoToURL
        self.onShare = onShare
    }
    
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Панель навигации
            HStack(spacing: 12) {
                // Кнопки навигации (убираются из layout при фокусе адресной строки)
                if !isFocused {
                    HStack(spacing: 8) {
                        BrowserNavigationButton(.back, isEnabled: observables.canGoBack, action: onGoBack)
                        BrowserNavigationButton(.forward, isEnabled: observables.canGoForward, action: onGoForward)
                        BrowserNavigationButton(.refresh, action: onRefresh)
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity).animation(.easeInOut(duration: 0.25).delay(0.25)),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                }
                
                // Адресная строка (расширяется при скрытии кнопок)
                AddressBarView(
                    urlText: observables.url.absoluteString,
                    onGoAction: { currentURL in
                        onGoToURL(currentURL)
                    }
                )
                .focused($isFocused)
                
                // Кнопка поделиться (убирается из layout при фокусе адресной строки)
                if !isFocused {
                    BrowserNavigationButton(.share) {
                        onShare(currentURL)
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing)
                            .animation(.easeInOut(duration: 0.8).delay(0))
                            .combined(with: .opacity).animation(.easeInOut(duration: 0.25).delay(0.25)),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
                }
            }
            .animation(.easeInOut(duration: 0.4), value: isFocused)
            .clipped()
            .padding(.horizontal, .regular)
            .padding(.vertical, .regular)
            .background(.ultraThinMaterial)
            .shadow(
                color: .black.opacity(0.1),
                radius: 8,
                x: 0,
                y: 4
            )
            .shadow(
                color: .black.opacity(0.05),
                radius: 2,
                x: 0,
                y: 1
            )
            
        }
        .overlay(alignment: .bottom) {
            // Индикатор загрузки
            if showProgress {
                ProgressView(value: observables.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .tm.success))
                    .frame(height: 3)
                    .background(Color.blue.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 2))
                    .animation(.easeInOut(duration: 0.3), value: observables.progress)
            }

        }
        .onChange(of: observables.progress) { newProgress in
            if newProgress > 0 {
                showProgress = true
            }
            
            if newProgress >= 1.0 {
                // Задержка перед исчезновением, чтобы показать полную загрузку
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeOut(duration: 0.05)) {
                        showProgress = false
                    }
                }
            }
        }
    }
}

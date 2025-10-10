import SwiftUI

/// Современный браузер с модным дизайном
struct BrowserInternetView: View {
    @StateObject var interactor = BrowserInternetInteractor()
    
    @State private var addressInput: String = ""
    @State private var isAddressBarFocused: Bool = false
    
    private let palette = Colors()
    
    var body: some View {
        // VStack для строгого вертикального размещения: Панель -> WebView -> Тулбар.
        // Это гарантирует, что WebView будет строго зажат между двумя панелями.
        VStack(spacing: 0) {
            
            // 1. Современная верхняя панель (Слой 2: выше WebView)
            modernNavigationBar
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .background(
                    // Фон, который гарантированно скроет WebView под собой
                    // и заполнит область статус-бара
                    palette.background.ignoresSafeArea(.container, edges: .top)
                )
                .zIndex(2) // Панель выше WebView
            
            // 2. WebView контент (СТРОГО ЗАЖАТ) (Слой 1)
            // Он занимает только оставшееся доступное вертикальное пространство.
            WebView(interactor: interactor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .zIndex(1) // WebView находится под панелями, но над основным фоном

            // 3. Нижняя панель инструментов (Слой 2: выше WebView)
            modernBottomToolbar
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    // Весь старый background с тенями и градиентом
                    palette.container
                        .overlay(
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            palette.accent.opacity(0.05),
                                            Color.clear
                                        ],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: -4)
                        // Обязательно: заполняет нижнюю системную полосу
                        .ignoresSafeArea(.container, edges: .bottom)
                )
                .zIndex(2) // Панель выше WebView
        }
        // Фон (Слой 0) - Применяется ко всему VStack и игнорирует безопасные области
        // (Гарантирует, что фон полностью покрывает экран)
        .background(palette.background.ignoresSafeArea())
        // Ваши onAppear/onChange (корневые модификаторы)
        .onAppear {
            addressInput = interactor.googleUrl.absoluteString
        }
        .onChange(of: interactor.googleUrl) { newValue in
            if !isAddressBarFocused {
                addressInput = newValue.absoluteString
            }
        }
    }
    
    // MARK: - Современная навигационная панель
    @ViewBuilder
    var modernNavigationBar: some View {
        VStack(spacing: 12) {
            // Адресная строка с floating дизайном
            HStack(spacing: 12) {
                // Иконка безопасности/статуса
                Image(systemName: interactor.googleUrl.absoluteString.hasPrefix("https") ? "lock.shield.fill" : "globe")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(interactor.googleUrl.absoluteString.hasPrefix("https") ? palette.success : palette.subTitle)
                    .frame(width: 28)
                
                // Поле ввода адреса
                TextField("Search or enter URL", text: $addressInput, onEditingChanged: { focused in
                    isAddressBarFocused = focused
                }, onCommit: {
                    interactor.goToUrl(string: addressInput)
                    isAddressBarFocused = false
                })
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(palette.title)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .keyboardType(.webSearch)
                
                // Кнопка обновления
                Button(action: {
                    interactor.refreshPage()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(palette.accent)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(palette.accent.opacity(0.12))
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(palette.container)
                    .shadow(color: palette.accent.opacity(0.12), radius: 16, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        palette.accent.opacity(isAddressBarFocused ? 0.3 : 0.08),
                                        palette.accentSecondary.opacity(isAddressBarFocused ? 0.2 : 0.04)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isAddressBarFocused ? 2 : 1
                            )
                    )
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isAddressBarFocused)
        }
    }
    
    // MARK: - Современная нижняя панель
    @ViewBuilder
    var modernBottomToolbar: some View {
        HStack(spacing: 0) {
            // Кнопка "Назад"
            modernToolbarButton(
                icon: "chevron.left",
                isEnabled: interactor.needBackGo,
                action: { interactor.goBack(true) }
            )
            
            Spacer()
            
            // Кнопка "Вперед"
            modernToolbarButton(
                icon: "chevron.right",
                isEnabled: interactor.needForwardGo,
                action: { interactor.goForward(true) }
            )
            
            Spacer()
            
            // Кнопка "Поделиться"
            modernToolbarButton(
                icon: "square.and.arrow.up",
                isEnabled: true,
                isPrimary: true,
                action: {
                    shareCurrentURL()
                }
            )
            
            Spacer()
            
            // Кнопка "Закладки" (placeholder)
            modernToolbarButton(
                icon: "book.fill",
                isEnabled: true,
                action: {
                    // Placeholder для закладок
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            )
            
            Spacer()
            
            // Кнопка "Меню" (placeholder)
            modernToolbarButton(
                icon: "line.3.horizontal",
                isEnabled: true,
                action: {
                    // Placeholder для меню
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            )
        }
    }
    
    // MARK: - Компонент кнопки тулбара
    @ViewBuilder
    func modernToolbarButton(
        icon: String,
        isEnabled: Bool,
        isPrimary: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            action()
            if isEnabled {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }) {
            ZStack {
                if isPrimary {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    palette.accent,
                                    palette.accentSecondary
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                        .shadow(color: palette.accent.opacity(0.4), radius: 12, x: 0, y: 4)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(isEnabled ? palette.title : palette.calmSecondary)
                        .frame(width: 44, height: 44)
                }
            }
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.4)
    }
    
    // MARK: - Share функция
    private func shareCurrentURL() {
        let urlString = interactor.googleUrl.absoluteString
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController else {
            return
        }
        
        let activityVC = UIActivityViewController(
            activityItems: [urlString],
            applicationActivities: nil
        )
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = window
            popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        rootVC.present(activityVC, animated: true)
    }
}

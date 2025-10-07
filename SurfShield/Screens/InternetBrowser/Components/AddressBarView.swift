//
//  AddressBarView.swift
//  SufrShield
//
//  Created by Артур Кулик on 03.09.2025.
//

import SwiftUI

struct AddressBarView: View {
    var urlText: String
    let onGoAction: (String) -> Void
    
    @FocusState private var isFocused
    @State private var displayText: String = ""
    
    var body: some View {
        content
            .onChange(of: urlText) { newValue in
                print("DEBUG: newValue \(newValue)")
            }
            .onAppear {
                print("DEBUG: url text \(urlText)")
            }
    }
    
    var content: some View {
        HStack(alignment: .center, spacing: 12) {
            // Поле ввода
            TextField("Введите адрес сайта", text: $displayText)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 16))
                .autocorrectionDisabled(true)
                .keyboardType(.webSearch)
                .textInputAutocapitalization(.never)
                .focused($isFocused)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 36, alignment: .center)
                .onSubmit {
                    // Восстанавливаем полный URL с протоколом при отправке
                    onGoAction(displayText)
                }
                .onChange(of: isFocused) { focused in
                    if focused {
                        // При фокусе показываем полный URL (без анимации для мгновенного отклика)
                        displayText = urlText
                        // Выделяем весь текст
                        DispatchQueue.main.async {
                            selectAllText()
                        }
                    } else {
                        // При потере фокуса убираем протокол
                        displayText = removeProtocol(from: urlText)
                    }
                }
                .onChange(of: displayText) { newValue in
                    // Обновляем urlText при изменении displayText
                    if isFocused {
//                        urlText = newValue
                    }
                }
            
            // Кнопка очистки с тенью (показываем только когда поле активно)
//            if isFocused && !displayText.isEmpty {
                Button(action: {
//                    urlText = ""
                    displayText = ""
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray4))
                            .frame(width: 18, height: 18)
                            .shadow(
                                color: .black.opacity(0.1),
                                radius: 2,
                                x: 0,
                                y: 1
                            )
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                    .opacity(isFocused && !displayText.isEmpty ? 1 : 0)
                }
//            }
        }
        .padding(.horizontal, isFocused ? 20 : 16)
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(
                            isFocused ? .title.opacity(0.05) : Color.clear,
                            lineWidth: isFocused ? 1 : 0
                        )
                        .padding(0.5)
                )
                .shadow(
                    color: .black.opacity(0.08),
                    radius: 4,
                    x: 0,
                    y: 2
                )
                .shadow(
                    color: .black.opacity(0.04),
                    radius: 1,
                    x: 0,
                    y: 0
                )
        )
        .onAppear {
            // Инициализируем displayText без протокола
            displayText = removeProtocol(from: urlText)
        }
        .onChange(of: urlText) { newValue in
            // Обновляем displayText при изменении urlText извне
            if !isFocused {
                displayText = removeProtocol(from: newValue)
            }
        }
    }
    
    // Функция для удаления протокола из URL
    private func removeProtocol(from url: String) -> String {
        var cleanUrl = url
        
        // Убираем http://
        if cleanUrl.hasPrefix("http://") {
            cleanUrl = String(cleanUrl.dropFirst(7))
        }
        
        // Убираем https://
        if cleanUrl.hasPrefix("https://") {
            cleanUrl = String(cleanUrl.dropFirst(8))
        }
        
        return cleanUrl
    }
    
    // Функция для выделения всего текста
    private func selectAllText() {
        // Находим UITextField в иерархии представлений
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            findAndSelectAllInTextField(in: window)
        }
    }
    
    private func findAndSelectAllInTextField(in view: UIView) {
        for subview in view.subviews {
            if let textField = subview as? UITextField {
                // Выделяем весь текст
                textField.selectAll(nil)
                return
            } else {
                findAndSelectAllInTextField(in: subview)
            }
        }
    }
}

#Preview {
    AddressBarView(urlText: "https://google.com", onGoAction: { url in })
}

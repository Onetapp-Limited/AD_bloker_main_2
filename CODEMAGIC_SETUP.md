# Настройка Codemagic CI/CD для SurfShield

## Обзор

Этот файл содержит инструкции по настройке Codemagic для автоматической сборки и деплоя приложения SurfShield и всех его Content Blocker расширений.

## Структура проекта

- **Основное приложение**: SurfShield (com.surfshield.app)
- **Content Blocker расширения**:
  - banners (com.surfshield.app.banners)
  - adblocker (com.surfshield.app.adblocker)
  - trackers (com.surfshield.app.trackers)
  - secure (com.surfshield.app.secure)
  - basic (com.surfshield.app.basic)
  - privacy (com.surfshield.app.privacy)
  - advanced (com.surfshield.app.advanced)

## Workflow'ы

### 1. surfshield-app
- Собирает только основное приложение
- Публикует в TestFlight
- Запускается при push в main/develop/release ветки

### 2. content-blockers
- Собирает все Content Blocker расширения
- Не публикует в App Store
- Запускается при push в main/develop/release ветки

### 3. test
- Запускает тесты приложения
- Запускается при push в main/develop/release ветки

### 4. full-build
- Полная сборка: приложение + все расширения + тесты
- Публикует в TestFlight
- Запускается при push в main/develop/release ветки

## Настройка переменных окружения

### В Codemagic Dashboard добавьте следующие переменные:

#### App Store Connect API
```
APP_STORE_CONNECT_ISSUER_ID=your_issuer_id
APP_STORE_CONNECT_KEY_IDENTIFIER=your_key_id
APP_STORE_CONNECT_PRIVATE_KEY=your_private_key_content
```

#### Сертификаты
```
CERTIFICATE_PRIVATE_KEY=your_certificate_private_key
```

### Как получить App Store Connect API ключи:

1. Войдите в [App Store Connect](https://appstoreconnect.apple.com)
2. Перейдите в Users and Access > Keys
3. Нажмите "+" для создания нового API ключа
4. Выберите "App Manager" роль
5. Скачайте .p8 файл и сохраните его содержимое
6. Запишите Key ID и Issuer ID

### Как получить сертификат:

1. В [Apple Developer Portal](https://developer.apple.com) создайте iOS Distribution сертификат
2. Скачайте .cer файл и конвертируйте в .p12
3. Экспортируйте приватный ключ в формате PEM

## Настройка файлов экспорта

### 1. export_options.plist
Замените `YOUR_TEAM_ID` на ваш Team ID из Apple Developer Portal.

### 2. export_options_extension.plist
Замените:
- `YOUR_TEAM_ID` на ваш Team ID
- `YOUR_*_PROVISIONING_PROFILE` на имена ваших Provisioning Profiles для каждого расширения

## Настройка уведомлений

В файле `codemagic.yaml` замените `your-email@example.com` на ваш email для получения уведомлений о сборке.

## Триггеры

Сборка автоматически запускается при:
- Push в ветки: main, develop, release/*
- Создании тегов: v*

## Рекомендации

1. **Тестирование**: Сначала протестируйте на ветке develop
2. **Мониторинг**: Следите за логами сборки в Codemagic Dashboard
3. **Безопасность**: Никогда не коммитьте секретные ключи в репозиторий
4. **Версионирование**: Используйте семантическое версионирование для тегов

## Troubleshooting

### Частые проблемы:

1. **Ошибки подписи**: Проверьте, что все Bundle ID зарегистрированы в App Store Connect
2. **Ошибки Provisioning Profile**: Убедитесь, что профили созданы для всех расширений
3. **Ошибки сборки**: Проверьте зависимости CocoaPods

### Логи:
Все логи доступны в Codemagic Dashboard в разделе "Build logs"

## Поддержка

При возникновении проблем:
1. Проверьте логи сборки
2. Убедитесь, что все переменные окружения настроены правильно
3. Проверьте статус сертификатов в Apple Developer Portal

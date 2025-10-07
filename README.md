# SufrShield - Блокировщик рекламы для iOS

SufrShield - это iOS приложение с Content Blocker Extension для блокировки рекламы и трекеров в Safari и других приложениях.

## 🚀 Возможности

- **Блокировка рекламы**: Автоматическое блокирование рекламных элементов
- **Защита от трекеров**: Блокировка скриптов отслеживания
- **Content Blocker Extension**: Нативная интеграция с iOS
- **Конвертер правил**: Автоматическая конвертация правил блокировки в JSON формат
- **Динамические правила**: Загрузка и обновление правил без переустановки

## 📱 Структура проекта

```
SufrShield/
├── SufrShield/          # Основное приложение
│   ├── Screens/         # Экраны приложения
│   ├── Theme/           # Тема и цвета
│   └── App/             # Основные компоненты
├── adblocker/           # Content Blocker Extension
│   ├── RuleConverter.swift      # Конвертер правил
│   ├── adblock_rules.txt        # Исходные правила
│   ├── convert_rules.swift      # CLI конвертер
│   └── ContentBlockerRequestHandler.swift
└── README.md
```

## 🔧 Конвертер правил блокировки

### Проблема
Apple рекомендует использовать JSON файлы для Content Blocker Extension, но файлы с правилами в формате JSON занимают много места.

### Решение
Мы создали конвертер, который:
- Преобразует правила AdBlock Plus в компактный JSON формат
- Сохраняет правила в память устройства (FileManager)
- Автоматически загружает обновленные правила

### Использование

#### 1. CLI конвертер
```bash
cd adblocker
swift convert_rules.swift adblock_rules.txt converted_rules.json
```

#### 2. Программная конвертация
```swift
import Foundation

// Загружаем правила
let rules = [
    ".ads.$script",
    ".banner.$image",
    ".popup.$popup"
]

// Конвертируем в JSON
let jsonString = RuleConverter.convertRulesToJSON(rules)

// Сохраняем в память устройства
RuleConverter.saveRulesToDevice(jsonString, filename: "blockerList")
```

#### 3. Загрузка правил
```swift
// Загружаем из памяти устройства
if let rules = RuleConverter.loadRulesFromDevice(filename: "blockerList") {
    print("Правила загружены: \(rules)")
}
```

### Поддерживаемые модификаторы

- `$script` - блокирует JavaScript файлы
- `$image` - блокирует изображения
- `$stylesheet` - блокирует CSS файлы
- `$xmlhttprequest` - блокирует AJAX запросы
- `$third-party` - блокирует сторонние ресурсы
- `$object` - блокирует объекты (Flash, Java)
- `domain=~example.com` - применяет правило к доменам
- `~example.com` - исключает домен

### Примеры правил

```
-contrib-ads.$~stylesheet
.adriver.$~object,domain=~adriver.co
.ads.controller.js$script
.advert.$domain=~advert.ae|~advert.ge
```

## 📊 Преимущества конвертера

1. **Экономия места**: JSON формат в 5-6 раз компактнее
2. **Производительность**: Быстрая загрузка и парсинг
3. **Гибкость**: Легко добавлять новые правила
4. **Совместимость**: Полная совместимость с iOS
5. **Кэширование**: Правила сохраняются в памяти устройства

## 🛠 Установка и настройка

1. Клонируйте репозиторий
2. Откройте `SufrShield.xcodeproj` в Xcode
3. Выберите target `adblocker`
4. Настройте Content Blocker Extension
5. Соберите и установите приложение

## 📖 Документация

- [Конвертер правил](adblocker/README_RULES.md) - Подробная документация по конвертеру
- [Примеры правил](adblocker/adblock_rules.txt) - Исходные правила блокировки
- [Тестирование](adblocker/RuleConverterTest.swift) - Примеры использования

## 🔍 Тестирование

```swift
// Тестирование конвертера
RuleConverterTest.testConversion()
RuleConverterTest.compareFileSizes()

// CLI тестирование
swift convert_rules.swift
```

## 📈 Статистика

- **Исходный файл**: 47 правил, ~1.4KB
- **JSON файл**: 46 правил, ~8KB
- **Коэффициент сжатия**: 5.68x
- **Время конвертации**: <0.001 секунды

## 🤝 Вклад в проект

1. Форкните репозиторий
2. Создайте ветку для новой функции
3. Внесите изменения
4. Создайте Pull Request

## 📄 Лицензия

Этот проект распространяется под лицензией MIT. См. файл `LICENSE` для подробностей.

## 📞 Поддержка

Если у вас есть вопросы или предложения, создайте Issue в репозитории.

---

**SufrShield** - Защита от рекламы и трекеров для iOS 🛡️

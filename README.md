# 🏋️ bar_fit

Фитнес-приложение на Flutter с тёмной темой, быстрым интерфейсом и возможностью масштабирования.  

---

## 🚀 Запуск проекта

```bash
git clone https://github.com/Prime-Apps-Dev/bar_fit.git
cd bar_fit
flutter pub get
cp .env.template .env
# Заполни .env и запускай
flutter run
```

---

## 📦 Сборка APK

```bash
flutter build apk --release
```

---

## 🧪 Покрытие тестами

```bash
flutter test --coverage
```

Артефакт `coverage/lcov.info` создаётся автоматически.

---

## 🤖 GitHub Actions

CI автоматически:
- устанавливает зависимости
- запускает тесты
- билдит `.apk`
- публикует GitHub Release

---

## 📁 Структура проекта

```
lib/
├── features/       # Экраны
├── services/       # API, prefs
├── widgets/        # Переиспользуемые виджеты
├── core/           # Тема, утилиты
```

---

## 📄 Файлы

- `.env.template` — заполни и скопируй в `.env`
- `GUIDE.md` — гайд по Git и GitHub
- `CONTRIBUTING.md` — как вносить вклад

---

## 🧠 Документация

Смотри [GUIDE.md](GUIDE.md) для полного гида по Git, GitHub и CI/CD.

---

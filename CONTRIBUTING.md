# 🤝 CONTRIBUTING.md — как вносить вклад в bar_fit

Добро пожаловать в проект `bar_fit`!  
Если ты разработчик и хочешь внести вклад, следуй этим правилам:

---

## 🚀 Быстрый старт

```bash
git clone https://github.com/Prime-Apps-Dev/bar_fit.git
cd bar_fit
flutter pub get
cp .env.template .env
# Заполни .env и запускай:
flutter run
```

---

## 🔀 Работа с ветками

- Используй `feature/`, `bugfix/`, `hotfix/` префиксы:

```bash
git checkout -b feature/new-screen
```

---

## ✅ Коммиты

Пиши сообщения коммитов осмысленно:

```bash
git commit -m "feat: добавлен экран входа"
```

---

## ⬆️ Пуш и Pull Request

1. Заверши работу
2. Пуш в GitHub:

```bash
git push origin feature/new-screen
```

3. Перейди в GitHub → Создай **Pull Request**
4. Дождись проверки и **merge**

---

## 🧪 Тесты

```bash
flutter test --coverage
```

Покрытие сохраняется как `coverage/lcov.info`

---

## 📦 Сборка

```bash
flutter build apk --release
```

CI собирает `.apk` сам и публикует релиз.

---

## 🛡 Правила

- Не коммить `.env`, `.apk`, или секреты
- Не пушить в `main`, если не договорено
- Всегда создавать ветки под задачи

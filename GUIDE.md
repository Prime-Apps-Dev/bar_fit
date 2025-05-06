# 🧠 Полный гайд по Git и GitHub для проекта `bar_fit`

Этот документ объясняет, как любой разработчик может работать с Git, GitHub и нашим репозиторием `bar_fit`. Здесь описано всё: от установки до пуша кода и выпуска релиза.

---

## 🗂 Основы

### ✅ Репозиторий (repository)
Это **папка с кодом**, которая отслеживается системой Git.  
На GitHub — это онлайн-хранилище проекта: https://github.com/Prime-Apps-Dev/bar_fit

---

### ✅ Ветка (branch)
Ветка — это **отдельная линия разработки**. Она создаётся от `main` и не мешает основной версии приложения.

| Ветка             | Для чего                    |
|------------------|-----------------------------|
| `main`           | стабильная версия           |
| `feature/...`    | добавление новой фичи       |
| `bugfix/...`     | исправление ошибки          |
| `hotfix/...`     | срочные правки на проде     |
| `dev`, `test`    | опциональные окружения      |

```bash
git checkout -b feature/new-screen
```

---

### ✅ Commit
Это **снимок изменений** в коде. Коммиты формируют историю.

```bash
git add .
git commit -m "feat: добавлен экран профиля"
```

---

### ✅ Push
Отправка коммитов на GitHub:

```bash
git push origin feature/new-screen
```

---

### ✅ Pull Request (PR)
После завершения работы в ветке:
1. Заходи на GitHub
2. Нажми **Compare & pull request**
3. Создай PR, чтобы отправить код в `main`
4. После одобрения — **Merge**

---

### ✅ Merge
Слияние твоей ветки в `main`. Выполняется вручную через GitHub.

---

### ✅ Fork vs Clone

- `Clone` — копия репозитория на твой ПК:

```bash
git clone https://github.com/Prime-Apps-Dev/bar_fit.git
```

- `Fork` — своя версия чужого репозитория. Не нужен в bar_fit, если ты collaborator.

---

## 🚀 CI (GitHub Actions)

CI запускается автоматически при каждом пуше. Он:
- устанавливает зависимости
- запускает тесты
- билдит `.apk`
- публикует релиз с номером версии

---

## 🏷 Tag и Release

- **Tag** — версия кода, например: `v1.0.0+12`
- **Release** — GitHub автоматически прикрепляет `.apk`

---

## 📦 Artifact

`.apk` файл, собранный CI и прикреплённый к GitHub Release.

---

## 🔐 Secrets

Токены и ключи (например, Firebase) хранятся в GitHub → Settings → Secrets.
Они **автоматически подставляются в CI**, не хранятся в коде.

---

## 👥 Роли

| Роль         | Права                                   |
|--------------|------------------------------------------|
| Owner        | Полный доступ                            |
| Collaborator | Может пушить, создавать ветки и PR       |
| Contributor  | Через fork и PR                          |
| Viewer       | Только просмотр                          |

---

## ✏️ Пример стандартного рабочего процесса

```bash
git checkout -b feature/timer-screen
# редактируй код
git add .
git commit -m "feat: добавлен экран с таймером"
git push origin feature/timer-screen
# на GitHub → Pull Request → Merge
```

---

## 🧪 Как запустить проект локально

```bash
git clone https://github.com/Prime-Apps-Dev/bar_fit.git
cd bar_fit
flutter pub get
cp .env.template .env
# (заполни .env вручную)
flutter run
```

---

## 📦 Как собрать .apk локально

```bash
flutter build apk --release
```

---

## ✅ Финально

- Всегда делай отдельные ветки под задачи
- Не пушь напрямую в `main`, если не уверен
- Читай README.md и .env.template
- GitHub Actions сам сделает сборку и релиз

---

С любовью к чистому процессу 🛠

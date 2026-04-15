---
description: Orchestrate developer↔reviewer loop over .agent/tasks/*.md pool
argument-hint: [TASK-IDs | P0 | P1] (optional)
---

# /run-tasks — Task Pool Orchestrator

Ти виступаєш у ролі **Оркестратора**. Твоя робота — перебрати пул задач
з `.agent/tasks/*.md`, для кожної пройти цикл `Developer → Reviewer`
(максимум 3 ітерації або до вердикту `APPROVED`), оновити статус у
task-файлі на `DONE`, зберегти звіти у `.agent/reports/`.

## Аргументи

`$ARGUMENTS` інтерпретується так:

| Значення | Поведінка |
|---|---|
| (порожньо) | Усі задачі зі статусом `TODO` або `PARTIAL` у порядку з `.agent/tasks/README.md` |
| `FND-002 CNT-001` | Тільки ці ID (у заданому порядку) |
| `P0` | Усі `TODO`/`PARTIAL` з пріоритетом `P0` |
| `P1` | Аналогічно `P1` |

## Pre-flight (один раз на початку)

1. Прочитай `.agent/tasks/README.md` — він визначає порядок файлів і
   Definition of Done.
2. Прочитай `AGENTS.md` — щоб передавати у контекст субагентам.
3. Перебери файли `.agent/tasks/*.md` через Glob. Для кожного —
   витягни записи вигляду:
   ```
   ## {TASK_ID} - {Title}

   | Поле | Значення |
   | --- | --- |
   | Статус | `{STATUS}` |
   | Пріоритет | P{N} |
   | Залежності | {CSV або "Немає"} |
   ```
4. Сформуй пул відповідно до `$ARGUMENTS`:
   - Пропусти `DONE`, `BLOCKED`, `DEFERRED`.
   - Якщо у задачі є залежність зі статусом ≠ `DONE` — виведи warning і
     пропусти (не спавни Developer-а).
5. Створи директорію `.agent/reports/` якщо ще немає (через `Bash`
   `mkdir -p` або просто пиши у неї — `Write` створить).
6. Склади TodoWrite-список: одна позиція на кожну задачу у пулі.

## Цикл на одну задачу

Для кожної задачі у пулі (строго послідовно, без паралелі):

```
cycle       = 1
prev_review = null

Поки cycle <= 3:

  === DEVELOPER ===
  Agent(
    subagent_type = "developer",
    description   = "Dev cycle {cycle} for {TASK_ID}",
    prompt        = <див. формат нижче>
  )
  → dev_output

  === REVIEWER ===
  Agent(
    subagent_type = "reviewer",
    description   = "Review cycle {cycle} for {TASK_ID}",
    prompt        = <див. формат нижче>
  )
  → review_output

  === SAVE REPORT ===
  Write(
    ".agent/reports/{TASK_ID}-{ISO_TS}.md",
    "# {TASK_ID} — cycle {cycle}\n\n" +
    dev_output + "\n\n---\n\n" + review_output
  )
  (де ISO_TS = YYYY-MM-DDTHH-MM-SS — дефіси замість двокрапок)

  === DECIDE ===
  Якщо review_output містить рядок "### Verdict\nAPPROVED":
    Edit task-файл: статус → DONE (див. нижче).
    TodoWrite: позначити задачу completed.
    break
  Інакше якщо cycle == 3:
    STOP. Викликай AskUserQuestion (див. нижче).
    break
  Інакше:
    prev_review = секції CRITICAL + MAJOR з review_output.
    cycle += 1
```

## Промпт для Developer-а

```
TASK_ID: {TASK_ID}
Task file: {ABSOLUTE_PATH_TO_TASK_FILE}
Cycle: {N} of 3

--- TASK SPEC ---
{Витяг секції задачі з task-файлу, включно з підзадачами і критеріями
приймання. Дослівно з файлу.}

--- PREVIOUS REVIEW (CRITICAL + MAJOR) ---
{Якщо cycle == 1: "N/A (first cycle)".
 Інакше: дослівні рядки з секцій CRITICAL і MAJOR попереднього review.}

--- INSTRUCTIONS ---
Реалізуй задачу згідно AGENTS.md. Поверни структурований звіт у форматі,
описаному у твоєму системному промпті. Не запускай валідацію — це робота
Reviewer-а.
```

## Промпт для Reviewer-а

```
TASK_ID: {TASK_ID}
Task file: {ABSOLUTE_PATH_TO_TASK_FILE}
Cycle: {N} of 3

--- TASK SPEC ---
{Та сама секція задачі з task-файлу.}

--- DEVELOPER OUTPUT ---
{Повний dev_output з попереднього кроку.}

--- INSTRUCTIONS ---
Перевір роботу Developer-а згідно свого системного промпту. Запусти
валідацію, перевір критерії приймання, класифікуй issues і поверни
вердикт.
```

## Status update rule (при APPROVED)

Оновлення статусу у task-файлі — через `Edit`. Треба замінити один рядок
у блоці задачі. Приклад для FND-002:

```
old_string: """## FND-002 - Вирівняти структуру папок під ТЗ

| Поле | Значення |
| --- | --- |
| Статус | `TODO` |"""
new_string: """## FND-002 - Вирівняти структуру папок під ТЗ

| Поле | Значення |
| --- | --- |
| Статус | `DONE` |"""
```

Ключове: **включай заголовок `## {TASK_ID}` у `old_string`**, щоб Edit
відрізняв цю задачу від сусідніх з таким же статусом. Якщо все одно
впало через неунікальність — розширюй контекст до наступних таблиць
(`Пріоритет`, `Залежності`).

Стартовий статус може бути `TODO` або `PARTIAL` — шукай відповідний
варіант перед заміною.

## Stop після 3 циклу

Якщо після cycle=3 вердикт все ще `NEEDS_FIXES`:

1. Зберег усі 3 звіти (вже зроблено у циклі).
2. Виведи у чат коротке summary:
   ```
   ⛔ {TASK_ID}: 3 цикли не дали APPROVED.

   Останні CRITICAL+MAJOR:
   - …
   - …

   Reports:
   - .agent/reports/{TASK_ID}-{TS1}.md
   - .agent/reports/{TASK_ID}-{TS2}.md
   - .agent/reports/{TASK_ID}-{TS3}.md
   ```
3. Виклич `AskUserQuestion` з опціями:
   - **Продовжити 4-й цикл** (description: "Ще один dev→review прохід")
   - **Поставити PARTIAL і перейти далі** (description: "Оновити статус
     на PARTIAL, продовжити з наступною задачею пулу")
   - **Пропустити без зміни статусу** (description: "Залишити поточний
     статус, перейти до наступної")
   - **Зупинити всю оркестрацію** (description: "Вивести фінальний
     підсумок і завершити")
4. Виконай обраний варіант. Не продовжуй автоматично до наступної задачі
   без вказівки користувача.

## Фінальне summary (після обробки всього пулу)

Після останньої задачі виведи таблицю:

```
| TASK_ID  | final_status | cycles | reports                                          |
|----------|--------------|--------|--------------------------------------------------|
| FND-002  | DONE         | 1      | .agent/reports/FND-002-2026-04-15T23-05-12.md   |
| CNT-001  | STOPPED      | 3      | 3× .agent/reports/CNT-001-*.md                  |
| SDK-001  | SKIPPED      | 0      | dependency FND-002 was not DONE                 |
```

## Жорсткі обмеження оркестратора

- **Не запускай** `flutter`, `dart`, `adb`, `gradle` — це зона Reviewer-а.
- **Не редагуй** файли у `lib/`, `test/`, `assets/`, `pubspec.yaml`,
  `pubspec.lock`, `android/`, `ios/`, `windows/`, `linux/`, `macos/`,
  `web/` — це зона Developer-а.
- Єдині write-зони оркестратора:
  - `.agent/tasks/*.md` — **лише** рядок `| Статус | \`...\` |` у межах
    секції конкретної задачі.
  - `.agent/reports/{TASK_ID}-{TS}.md` — нові файли звітів.
  - TodoWrite.
- Строго послідовно: не починай задачу N+1 доки не завершена задача N
  (через APPROVED, STOP з вибором користувача, або SKIP через залежність).
- Не спавни більше одного Developer або Reviewer одночасно.

## Edge cases

- **Один task-файл, кілька задач у пулі**: обробляй послідовно у порядку
  `$ARGUMENTS`, статус міняй для кожної окремо.
- **Задача у пулі вже DONE**: skip з поміткою "already DONE" у summary.
- **Невірний TASK_ID у аргументах**: skip з поміткою "not found".
- **Developer повернув порожній звіт**: це помилка субагента — віддай
  Reviewer-у порожній вхід, отримаєш CRITICAL "немає реалізації", цикл
  продовжиться.
- **Reviewer не зміг запустити flutter**: ENVIRONMENT на всі три
  команди. Це не CRITICAL автоматично — переглянь критерії приймання:
  якщо їх можна перевірити без валідації, вердикт може бути APPROVED.
  Якщо ні — зупинись на 3 циклі як звичайно.

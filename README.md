# KrishiMind

An AI farming advisor for farmers in Maharashtra, built with Flutter.

A farmer describes a problem in **Marathi, Hindi or English** and gets an answer
written for them, not for an agronomist: what the problem most likely is, why it
happened, and what to do about it this week.

Built as a final-year college project.

---

## Why it is built this way

Most of the decisions in this app come from one question: *will a farmer with
limited schooling and a weak internet connection actually be able to use it?*

- **No forced login.** Around half the intended users cannot manage an email
  account. Signing in is optional and only exists to carry your past questions to
  a new phone. Every feature works without an account.
- **No GPS.** The farmer picks their district from a list. It needs no
  permission dialog, works with location services off, and is accurate enough for
  weather and crop advice.
- **Language is chosen before anything else.** A farmer in Kolhapur who cannot
  read English should never have to read an English screen to reach the language
  setting.
- **The AI is never allowed to state a pesticide dose.** It may name a chemical
  generically and must then tell the farmer to confirm the quantity at the Krishi
  Seva Kendra. A wrong dose does not mean a wrong answer — it means a dead crop
  and money lost.

---

## What works today

| Feature | Status |
|---|---|
| Splash screen with cycling trilingual tagline | Done |
| Language selection (Marathi / Hindi / English) | Done |
| District selection — all 36 districts, grouped by division | Done |
| Dashboard: greeting, live weather, spraying advice, season | Done |
| Weather via Open-Meteo (no API key needed) | Done |
| Optional email sign-in via Firebase Auth | Done |
| Ask a question by text — AI answer with reasoning and steps | Done |
| Scan crop (image) | Next |
| Ask by voice | Next |
| Saved question history | Planned |
| Offline guide (crops, pests, regional information) | Planned |

---

## Running it on your laptop

### 1. Install Flutter

Follow https://docs.flutter.dev/get-started/install and make sure this prints no
errors:

```bash
flutter doctor
```

You need the Android toolchain — either an Android emulator or a real phone with
USB debugging on.

### 2. Get the code

```bash
git clone https://github.com/<your-username>/krishimind.git
cd krishimind
flutter pub get
```

### 3. Add your own Gemini API key

The project deliberately does **not** include an API key. Keys are tied to a
Google account, so everyone uses their own.

1. Get a free key at https://aistudio.google.com/apikey — choose the free option,
   no billing needed.
2. Copy `lib/secrets_template.dart` to `lib/secrets.dart`.
3. Paste your key into the new file.

`lib/secrets.dart` is listed in `.gitignore`, so your key can never be committed
by accident.

Everything except the AI answers works without a key — splash, language,
district, weather, sign-in.

### 4. Run

```bash
flutter run
```

---

## Built with

- **Flutter** and **Dart** — one codebase, Material 3
- **Google Gemini API** — the AI answers, with a forced JSON response so the app
  can render a structured card instead of a wall of text
- **Open-Meteo** — weather by district coordinates, free and keyless
- **Firebase Auth** — optional email sign-in
- **shared_preferences** — remembers language and district on the phone
- **Noto Sans Devanagari** (SIL Open Font License) — bundled so Marathi and Hindi
  render correctly even offline

---

## Project layout

```
lib/
  main.dart                  app start, theme
  secrets.dart               your API key — never committed
  data/                      languages, districts, strings, weather, AI service
  screens/                   splash, language, district, dashboard shell
  screens/ask/               the question and answer screens
  widgets/                   weather card, ask buttons, answer card
  theme/app_colors.dart      the palette
assets/branding/             emblem and wordmark
fonts/                       Noto Sans Devanagari
```

Every piece of on-screen text lives in `lib/data/strings.dart`, one entry per
phrase in all three languages. No screen contains a hard-coded sentence, which is
why switching language never breaks a layout.

---

## A note on the advice

The answers come from a general-purpose AI model. It can be wrong, and it is told
to say so when it is unsure. Nothing in this app replaces a Taluka Agriculture
Officer or a Krishi Seva Kendra, and it is not a source of pesticide doses.

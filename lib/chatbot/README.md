# `lib/chatbot/` – Offline Knowledge-Base Engine

This folder enables **completely offline** Q&A for situations with no data connectivity.

## Components

| File | Role |
|------|------|
| `chatbot_engine.dart` | Facade called by `chatbot_screen.dart`. Keeps mini KB in memory, matches via TF-IDF cosine similarity, forms a structured reply. |
| `kb.json` *(generated)* | Serialized documents (conditions, medicines, first-aid steps). |
| `tokenizer.dart` | Very lightweight unigram tokenizer (≈200 lines) – no external deps. |

## Algorithm

1. Pre-process KB to term-frequency map (`build_kb.dart` script).  
2. At runtime, tokenize question → TF vector.  
3. Cosine similarity vs. each doc vector, return top-N.  
4. Compose answer template (possible condition, tests, meds).  
5. For unknown, fall back to rule heuristics (e.g., if contains *fever* & *rash* → suggest measles consult).

> 🛈 Accuracy is **not** diagnostic—strictly informational and labeled as such in the UI.

## Updating the KB

1. Edit `source_docs/*.md` then run:

```bash
dart run lib/chatbot/build_kb.dart
```

2. Commit new `kb.json` (≈100 KB).  
3. No app-store update needed; deployed via OTA.

## Extending

* Swap TF-IDF for on-device tflite BERT if size allows.  
* Plug into `UserProfileProvider` to bias answers with personal data (age, conditions).

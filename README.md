## Architecture

The app follows **Clean Architecture** with three strict layers. Dependencies only point inward — the Domain layer has no knowledge of AVFoundation or SwiftUI.

```
Presentation  →  Domain  ←  Data
  (SwiftUI)    (Pure Swift)  (AVFoundation)
```

AVFoundation never crosses the Data boundary. SwiftUI never crosses the Presentation boundary. Use cases and protocols are the only things both sides touch.

---

## Layer

### Domain

Pure Swift. No framework imports beyond Foundation and Combine.


### Data

AVFoundation implementations of Domain protocols.


### Presentation

SwiftUI views and `@Observable` ViewModels. No AVFoundation imports.



## Dependency Injection

`ViewModelFactory` is the single DI root, created once as a `@StateObject` in App. 



## Key Features 

### Feed modes

Toggle between **Card** (default) and **List** via the toolbar icon.

- **Card mode** — full-screen vertical paging. Swiping to a new card auto-plays
- **List mode** — compact scrollable cards with inline seek bars.



### Persistence

All recorded audio survives app restarts and rebuilds :
- `.m4a` files live in `Documents/AudioS3/` — accessible via the Files app.
- `manifest.json` in the same folder stores only filenames (not absolute paths).


## Tradeoffs & Known Limitations

| Decision | Tradeoff |
|---|---|
| `AVAudioPlayer` for playback | Simpler than `AVAudioEngine`; sufficient for local files. Need to replace with `AVAudioEngine` + streaming for network audio. |
| Combine in Domain protocol | Technically an Apple framework, but avoids exposing concrete types. `AsyncStream` is an alternative. |
| `@Observable` ViewModels | iOS 17+ only. Uses `@Environment(Type.self)` at call sites — incompatible with `@StateObject`/`@EnvironmentObject`. |

---

### Demo Video


https://github.com/user-attachments/assets/c2a2731a-66dd-47fc-98a6-4e7d14da7349



# Cocotrack — App Store Marketing Package

Wszystko co potrzebne do wrzucenia do Mac App Store (App Store Connect) pod kontem Cocolab sp. z o.o. Primary language: **English**. Additional: **Polish**.

Znaki liczone bez białych znaków na końcach. Limity są Apple hard-enforced.

---

## 1. App Store Connect — core metadata

| Pole | Wartość |
|---|---|
| **App Name** (30) | `Cocotrack` |
| **Bundle ID** | `com.cocolab.cocotrack` |
| **SKU** | `cocotrack-mas-1` |
| **Primary language** | English (U.S.) |
| **Additional languages** | Polish |
| **Primary category** | Productivity |
| **Secondary category** | Business |
| **Age rating** | 4+ |
| **Pricing** | Free |
| **Availability** | Worldwide |
| **Copyright** | `2026 Cocolab sp. z o.o.` |
| **Content rights** | Does not contain, show, or access third-party content |

---

## 2. EN metadata (primary)

### Subtitle (30 chars)
```
A calm Clockify menu bar timer
```
*(30 chars — pod limitem)*

### Promotional text (170 chars, edytowalny bez review)
```
Clockify right where you work. Start timers from the macOS menu bar, pin favorites, and keep your day focused — native, calm, zero bloat.
```

### Keywords (100 chars total, no spaces after commas)
```
clockify,timer,time tracking,menu bar,productivity,stopwatch,focus,work log,freelance,billable
```
*(94 chars)*

### Description (≤4000 chars)
```
Cocotrack is a small, fast, native macOS time tracker that plugs into your existing Clockify account. It lives in the menu bar, remembers what you usually work on, and stays out of your way.

No browser tab. No Electron. No sign-up. Just your own Clockify API key, a tiny popover, and a focused main window you open only when you need it.

— WHAT COCOTRACK DOES —

• Menu bar timer. See the running description and elapsed time in your macOS menu bar. One click to start or stop.

• Native macOS window. A clean SwiftUI interface designed for macOS 13+. Light and dark mode. Warm, calm palette. No neon, no noise.

• Quick start. Cocotrack learns from your recent entries and offers one-tap templates so you don't re-type "standup", "code review", or "client X — support" every morning.

• Favorites. Pin the timers you use most. They stay one click away.

• Inline editing. Fix a forgotten description or a wrong end time without leaving the app.

• Projects. Pick a project when starting a timer. Create new ones inline if your workspace allows it. Respects workspaces that require a project on every entry.

• Auto-refresh. Entries sync from Clockify every 30 seconds so the app stays truthful even when you change things on another device.

• Localized. Polish and English, follows your system language.

— SETUP —

1. Launch Cocotrack.
2. Open Settings and paste your Clockify API key. You can generate one at clockify.me/user/settings.
3. Optionally set a custom Workspace ID. Otherwise your default workspace is used.
4. Click Save & Connect. Done.

Cocotrack never sees your password. The API key stays in your local macOS keychain-backed preferences and is only sent to api.clockify.me, the Clockify API endpoint.

— PRIVACY —

Cocotrack does not collect analytics, does not phone home, does not ship with third-party SDKs, and does not track you. The only network traffic is the Clockify API itself.

— NOT AFFILIATED —

Cocotrack is an independent application by Cocolab sp. z o.o. It is not affiliated with, endorsed by, sponsored by, or otherwise connected to CAKE.com or Clockify. Clockify is a trademark of CAKE.com. You will need your own Clockify account to use Cocotrack.

— BUILT BY COCOLAB —

Cocolab is a small product studio in Poland. We make focused native tools for people who spend their day in front of a Mac. If you have feedback, write to us at hello@cocolab.pl.
```

### What's New (version 2.2.0 — initial App Store release)
```
First release on the Mac App Store. Native macOS 13+ client for Clockify with menu bar timer, quick start templates, favorites, inline editing, and full localization. Feedback welcome at hello@cocolab.pl.
```

---

## 3. PL metadata (localization)

### Subtitle (30 chars)
```
Timer Clockify w pasku menu
```
*(27 chars)*

### Promotional text (170 chars)
```
Clockify prosto w pasku menu. Startuj timery jednym kliknięciem, przypinaj ulubione i skup się na pracy. Natywnie, spokojnie, bez zbędnych dodatków.
```

### Description (≤4000 chars)
```
Cocotrack to mały, szybki, natywny tracker czasu dla macOS, który współpracuje z Twoim kontem Clockify. Siedzi w pasku menu, pamięta nad czym zwykle pracujesz, i nie wchodzi w drogę.

Bez karty w przeglądarce. Bez Electrona. Bez rejestracji. Tylko Twój klucz API Clockify, mały popover i skupione główne okno, które otwierasz dopiero gdy potrzebujesz.

— CO ROBI COCOTRACK —

• Timer w pasku menu. Widzisz opis aktywnego timera i czas jaki minął — bezpośrednio w menu bar macOS. Jedno kliknięcie żeby wystartować albo zatrzymać.

• Natywne okno macOS. Czysty SwiftUI zaprojektowany pod macOS 13+. Tryb jasny i ciemny. Ciepła, spokojna paleta. Bez neonów, bez szumu.

• Szybki start. Cocotrack uczy się z Twoich ostatnich wpisów i proponuje gotowe szablony, więc nie wpisujesz co rano od nowa „standup", „code review" czy „klient X — support".

• Ulubione. Przypinasz timery, których używasz najczęściej. Są jedno kliknięcie dalej.

• Edycja w miejscu. Poprawiasz zapomniany opis albo zły czas zakończenia bez wychodzenia z aplikacji.

• Projekty. Wybierasz projekt przy starcie timera. Tworzysz nowy w miejscu, jeśli Twój workspace na to pozwala. Wspiera workspace'y, które wymagają projektu na każdym wpisie.

• Auto-odświeżanie. Wpisy synchronizują się z Clockify co 30 sekund, więc aplikacja pokazuje prawdę nawet gdy zmienisz coś na innym urządzeniu.

• Lokalizacja. Polski i angielski, idzie za językiem systemu.

— KONFIGURACJA —

1. Odpal Cocotrack.
2. Otwórz Ustawienia i wklej swój klucz API Clockify. Wygenerujesz go na clockify.me/user/settings.
3. Opcjonalnie ustaw własny Workspace ID. Inaczej używany jest domyślny.
4. Kliknij „Zapisz i połącz". Gotowe.

Cocotrack nigdy nie widzi Twojego hasła. Klucz API zostaje w lokalnych preferencjach macOS i jest wysyłany wyłącznie na api.clockify.me, endpoint Clockify.

— PRYWATNOŚĆ —

Cocotrack nie zbiera analityki, nie łączy się z żadnym naszym serwerem, nie zawiera zewnętrznych SDK i nie śledzi Cię. Jedyny ruch sieciowy to API Clockify.

— NIEZALEŻNA APLIKACJA —

Cocotrack jest niezależną aplikacją tworzoną przez Cocolab sp. z o.o. Nie jest afiliowana, rekomendowana ani sponsorowana przez CAKE.com ani Clockify. Clockify to znak towarowy CAKE.com. Do korzystania z Cocotrack potrzebujesz własnego konta Clockify.

— TWORZONE PRZEZ COCOLAB —

Cocolab to małe studio produktowe w Polsce. Robimy skupione, natywne narzędzia dla ludzi, którzy spędzają dzień przy Macu. Jeśli masz feedback — pisz na hello@cocolab.pl.
```

### What's New PL
```
Pierwsze wydanie w Mac App Store. Natywny klient Clockify dla macOS 13+ z timerem w pasku menu, szybkim startem, ulubionymi, edycją wpisów i pełną lokalizacją. Feedback mile widziany na hello@cocolab.pl.
```

---

## 4. URLs

Wszystkie wymagają hostowania przed submission.

| Typ | URL | Status |
|---|---|---|
| **Support URL** (wymagane) | `https://cocolab.pl/cocotrack/support` | **DO ZROBIENIA** — prosta strona z mailem `hello@cocolab.pl` i FAQ |
| **Marketing URL** (opcjonalne, ale polecane) | `https://cocolab.pl/cocotrack` | **DO ZROBIENIA** — landing z tagline, screenshots, mailem |
| **Privacy Policy URL** (wymagane) | `https://cocolab.pl/cocotrack/privacy` | **DO ZROBIENIA** — treść w sekcji 5 niżej |
| **EULA** (opcjonalne) | domyślny Apple EULA | OK, zostawić domyślny |

---

## 5. Privacy Policy (treść do wrzucenia na stronę)

Tytuł: **Cocotrack Privacy Policy** / **Polityka prywatności Cocotrack**

Minimum required content (EN):

```
Last updated: [DATA SUBMISSIONU]

Cocotrack is a macOS application developed by Cocolab sp. z o.o. This policy describes how Cocotrack handles your data.

1. What Cocotrack collects from you

Nothing. Cocotrack does not collect, store, transmit, or share any personal data with Cocolab or any third party.

2. Data stored on your device

Cocotrack stores the following data locally on your Mac, in standard macOS user preferences:

• Your Clockify API key
• Your Clockify workspace ID (optional)
• Your favorites and recent timer descriptions
• Your app preferences

This data never leaves your device except as described in section 3.

3. Network activity

Cocotrack makes requests only to the Clockify API at https://api.clockify.me. These requests contain:

• Your Clockify API key (as the X-Api-Key header, required for authentication)
• Standard Clockify API request bodies (timer descriptions, project IDs, timestamps)

We do not intercept, proxy, log, or read this traffic. Your data flows directly between your Mac and Clockify's servers (operated by CAKE.com), governed by Clockify's own privacy policy at https://cake.com/privacy.

4. Analytics and tracking

Cocotrack contains no analytics SDKs, no telemetry, no crash reporting services, and no third-party trackers.

5. Children

Cocotrack is not directed at children under 13.

6. Changes

If this policy changes, the update date above will change and the new version will be published at the same URL.

7. Contact

Cocolab sp. z o.o.
Email: hello@cocolab.pl
```

Wersja PL — tłumaczenie 1:1, zachować strukturę i numerację.

---

## 6. Privacy Label (App Store Connect → App Privacy)

Odpowiedzi na questionnaire:

| Pytanie | Odpowiedź |
|---|---|
| **Do you or your third-party partners collect data from this app?** | **No** |
| **Data Types Collected** | None |
| **Tracking** | No — we do not use data collected from this app to track users |

Uzasadnienie dla wewnętrznej dokumentacji: klucz API Clockify jest *user-supplied credential for a third-party service*, przechowywany lokalnie i wysyłany tylko do tego third-party serwisu (api.clockify.me). Nie dociera do serwerów Cocolab. Analogiczne do klientów IMAP/SMTP, SSH, itd.

---

## 7. App Review Information (dla reviewera Apple)

W App Store Connect → App Information → App Review Information:

### Contact Information
- First name: `Paweł`
- Last name: `Orzech`
- Phone: [numer Pawła]
- Email: `pawel@cocolab.pl`

### Sign-in required?
**YES** — Cocotrack requires a Clockify API key to function.

### Demo account credentials
Trzeba utworzyć testowe konto Clockify (free plan wystarczy) dedykowane dla Apple review:

- **Clockify login**: `appreview@cocolab.pl` (utworzyć)
- **Clockify API key**: [wygenerować na clockify.me/user/settings → paste here]
- **Workspace ID**: [default workspace ID tego konta]

Uzupełnić w polu `Demo account` w App Store Connect.

### Notes to reviewer

```
Cocotrack is an independent, third-party macOS client for the Clockify time-tracking service (clockify.me, operated by CAKE.com). Cocotrack is not affiliated with CAKE.com.

The app uses the public Clockify REST API (https://api.clockify.me/api/v1) with a user-supplied API key (X-Api-Key header). Users authenticate against Clockify directly; Cocotrack never sees their password. The API key is entered once in Settings and stored in local macOS user defaults.

We use the "Clockify" brand name in the app description and helper text only as nominative fair use — to tell users which external service Cocotrack connects to. The app name is "Cocotrack", the app icon is original, and no Clockify logos or graphics are used.

For review, please use the demo account credentials supplied above. Paste the API key into Settings → API key, then click "Save & Connect". You should see a connected state and the demo account's recent time entries.

The app is fully sandboxed (com.apple.security.app-sandbox) with only com.apple.security.network.client entitlement for outbound HTTPS.

If you have any questions, please contact pawel@cocolab.pl.
```

### Attachment (opcjonalne)
Screenshot z `codesign -d --entitlements :- Cocotrack.app` pokazujący minimalny sandbox — przyspiesza review jeśli są pytania o entitlements.

---

## 8. Visual assets

### 8.1 App Icon

| Plik | Rozmiar | Notes |
|---|---|---|
| `icon_16x16.png` | 16 × 16 | menu bar, sidebar |
| `icon_16x16@2x.png` | 32 × 32 | |
| `icon_32x32.png` | 32 × 32 | |
| `icon_32x32@2x.png` | 64 × 64 | |
| `icon_128x128.png` | 128 × 128 | |
| `icon_128x128@2x.png` | 256 × 256 | |
| `icon_256x256.png` | 256 × 256 | |
| `icon_256x256@2x.png` | 512 × 512 | |
| `icon_512x512.png` | 512 × 512 | |
| `icon_512x512@2x.png` | 1024 × 1024 | App Store |

Wszystkie PNG, sRGB, bez alpha dla 1024×1024 (Apple dodaje maskę automatycznie), alpha OK dla mniejszych.

Path: `Sources/cocotrack/Resources/cocotrack.xcassets/AppIcon.appiconset/`

### 8.2 App Store Screenshots

**Wymagane**: min 1 screenshot w jednym z wspieranych rozmiarów. Apple preferuje Retina. Wrzucamy **6** screenshotów w rozdzielczości **2880 × 1800** (16:10, MacBook Pro 16" @2x). Obowiązują te same 6 dla EN i PL, ale najlepiej przygotować obie wersje z lokalizowanym UI.

Hero-shot plan (każdy w EN i PL):

| # | Scena | Opis |
|---|---|---|
| 1 | **Running timer + menu bar** | Main window z aktywnym timerem na `code review — Cocotrack iOS`, hero font elapsedTime `01:23:45`, menu bar u góry z tym samym opisem + czasem. Tło warm-neutral jasne. Headline overlay: *"Clockify, now in your menu bar."* |
| 2 | **Quick start** | Recent entries grupowane po dniach, z highlight na "Quick start" sekcji — pokazać, że jedno kliknięcie tworzy nowy timer z dawnym opisem. Headline: *"One click to restart anything."* |
| 3 | **Favorites** | Pinned timery (3–4 capsule chips z ikonkami projektów, kolorowe kropki). Headline: *"Pin what you do every day."* |
| 4 | **Menu bar popover** | Close-up menu bar popovera z compact timerem, przyciskiem Start/Stop, ostatnimi wpisami. Mac desktop częściowo widoczny w tle. Headline: *"Start a timer without switching apps."* |
| 5 | **Dark mode** | Main window w dark mode, pokazać że palette jest ciepła również w dark. Headline: *"Designed for long evenings."* |
| 6 | **Settings / non-affiliation** | Settings sheet z polem API key + widocznym disclaimerem. Headline: *"Your Clockify key, never leaves your Mac."* |

Styling screenshotów:
- Frame: MacBook mockup **opcjonalny**; czysty window preferowany (Apple teraz dopuszcza oba)
- Background: warm neutral gradient spójny z paletą app (`#FBF9F5` → `#F1EEE8`)
- Headline font: duży, sans-serif (SF Pro Display Bold 72pt equiv.)
- Accent color dla highlightów: `#D27B4D` (terracotta, match app accent)
- Pozostawić 10% padding od krawędzi, headline u góry, window na dole

**Nie pokazywać** w screenshotach: logo Clockify, logo CAKE, nazw innych marek, cudzych znaków towarowych.

### 8.3 App Preview video (opcjonalne, 15–30s)

Opcjonalne. Jeśli robimy:
- Rozdzielczość: **2880 × 1800** (musi matchować screenshotom)
- Długość: 15–30 sekund
- Bez audio lub z delikatnym ambient (bez licencjonowanych utworów)
- Story:
  1. (0–3s) Menu bar, user klika ikonę → popover otwiera się
  2. (3–8s) Wpisuje opis → klika Start → timer rusza w menu barze
  3. (8–16s) Alt-tabuje do innej appki, pracuje, wraca po chwili
  4. (16–22s) Otwiera main window → edytuje wpis → zapisuje
  5. (22–28s) End card: logo Cocotrack + tagline "Calm Clockify, native macOS"

### 8.4 Landing page hero + social (dla cocolab.pl/cocotrack)

| Asset | Rozmiar | Użycie |
|---|---|---|
| Hero image | 1920 × 1080 | nagłówek landing page |
| OG image | 1200 × 630 | Facebook / LinkedIn link preview |
| Twitter/X card | 1200 × 675 | X post preview |
| Mastodon card | 1200 × 630 | Mastodon/Fediverse share preview |
| Product Hunt thumbnail | 240 × 240 | opcjonalne, jeśli robimy PH launch |

---

## 9. Launch checklist (przed submission)

- [ ] Nowa ikona wygenerowana i podmieniona w `Sources/cocotrack/Resources/cocotrack.xcassets/AppIcon.appiconset/`
- [ ] 6 screenshotów EN + 6 screenshotów PL przygotowane
- [ ] Privacy Policy hostowana pod `cocolab.pl/cocotrack/privacy`
- [ ] Support page hostowana pod `cocolab.pl/cocotrack/support`
- [ ] Marketing landing hostowana pod `cocolab.pl/cocotrack` (opcjonalne, ale zalecane)
- [ ] `appreview@cocolab.pl` konto Clockify utworzone + API key wygenerowany
- [ ] Cocolab team w Apple Developer ma aktywne Mac App Distribution + Installer certyfikaty
- [ ] Provisioning profile dla `com.cocolab.cocotrack` wygenerowany
- [ ] `scripts/build_mas.sh` odpalony z poprawnymi env vars → `.pkg` gotowy
- [ ] Email do CAKE.com (`legal@cake.com` + `press@cake.com`) wysłany — opcjonalne, ale zalecane
- [ ] Privacy Label w App Store Connect wypełniony (Data Not Collected)
- [ ] Review notes uzupełnione, demo account wklejony
- [ ] Copyright = `2026 Cocolab sp. z o.o.`
- [ ] Keywords = `clockify,timer,time tracking,menu bar,productivity,stopwatch,focus,work log,freelance,billable`
- [ ] Screenshots i opisy w obu językach (EN + PL)

---

## 10. Post-launch — social copy

Gotowe krótkie posty do ogłoszenia launchu.

### X / Mastodon (280 chars)
```
Wrzuciłem do Mac App Store Cocotrack — natywny, spokojny klient Clockify, który siedzi w pasku menu i nie wchodzi w drogę.

Darmowy, open source, zero analityki. macOS 13+.

cocolab.pl/cocotrack
```

### LinkedIn
```
Nowy drobiazg z Cocolab: Cocotrack — natywny macOS klient do Clockify.

Dlaczego powstał? Bo oficjalna apka w App Store (po zmianie polityki Apple) nie ma już idle detection i auto trackera, a webowa wersja to karta w Chromie którą wiecznie gubisz. Chciałem coś małego, co siedzi w menu barze, pamięta moje timery i szanuje mój Mac.

Features:
• Timer w pasku menu z elapsed time
• Quick start z historii
• Ulubione
• Edycja wpisów inline
• Dark mode, light mode, ciepła paleta
• PL + EN
• Zero analityki, zero SDK, zero phoning home

Darmowy, nadal bez IAP. Jeśli używasz Clockify, rzuć okiem.

👉 cocolab.pl/cocotrack
```

### Product Hunt (opcjonalnie)
- Tagline: `A calm, native macOS menu bar timer for Clockify`
- Description: (użyj EN promotional text + EN description first 2 paragraphs)
- First comment: maker story — dlaczego Cocotrack, co wyróżnia od oficjalnego klienta

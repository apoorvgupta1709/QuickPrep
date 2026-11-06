# ⚡ QuickPrep - Technical & Architecture Documentation

> **Flagship Technical Interview & Coding Flashcard Suite**  
> Package Identifiers:
> - **Client App**: `com.apoorv.quickprep`
> - **Admin App**: `com.apoorv.quickprep.admin`  
> Target Platforms: Android, iOS, Web (Admin)  
> Signature Attribution: **Made with ❤️ by Apoorv**

---

## 1. Project Directory Structure

```text
QuickPrep/
├── quickprep_main/                    # Client Application (Play Store & App Store)
│   ├── lib/
│   │   ├── core/                      # Theme, routing, error handling, sound/TTS
│   │   ├── models/                    # Question, Category, Quiz, Leitner, Config
│   │   ├── services/                  # Firestore, Storage, AdMob, Razorpay, PDF
│   │   ├── providers/                 # State management (Pro, Streak, Leitner)
│   │   └── screens/                   # Flashcards, Quizzes, Commute Mode, Cheatsheets, Settings
│   ├── publish/                       # Production store assets & build outputs
│   │   ├── icons/                     # 512x512 Play Store icon, iOS 1024x1024
│   │   ├── graphics/                  # 1024x500 Feature graphic & promo banners
│   │   ├── screenshots/               # High-res store showcase previews
│   │   ├── store_listing/             # Title, short & full descriptions, Privacy Policy
│   │   └── builds/                    # app-release.apk and app-release.aab
│   ├── firestore.rules                # Production hardened security rules
│   └── pubspec.yaml
│
├── quickprep_admin/                   # Dynamic Operator Control Dashboard
│   ├── lib/
│   │   ├── core/                      # Admin theme, auth guard, layout
│   │   ├── models/                    # CMS question & monetization schemas
│   │   ├── services/                  # Bulk importer, Firestore write, Broadcasts
│   │   └── screens/                   # Question CMS, Importer, Ad Control, Razorpay Manager
│   └── pubspec.yaml
│
└── README.md
```

---

## 2. Universal Branding & Attribution

Every screen and about dialog embeds:
- **`v1.0.0 • Made with ❤️ by Apoorv`**
- Permanent presence in Settings/About, Splash screen footer, and Admin dashboard header.

---

## 3. Monetization Engine

### A. AdMob (Dynamic Remote Control)
- **Development**: Official Google Test Ad Unit IDs (Banners, Interstitial, Rewarded).
- **Production**: Synchronized from Firestore `/app_config/monetization`.
- **Kill-Switch**: `ads_enabled: false` immediately pauses all ads app-wide.
- **Frequency Cap**: Configurable interstitial presentation frequency (e.g. after every quiz or N cards).
- **Rewarded Ad Triggers**:
  1. Download 1-page PDF cheat sheet (free users).
  2. Restore broken daily streak.
  3. Reveal deep-dive explanation for advanced questions.

### B. Razorpay Pro Lifetime License
- **Configurable Price**: Default ₹199 (managed dynamically from Admin App).
- **Pro Entitlements**:
  - 100% Ad-Free forever
  - Unlimited PDF downloads without rewarded ads
  - Unlimited Audio Commute Mode
  - Full access to all Company-Specific Question Packs (FAANG, MNCs, FinTech)

---

## 4. Firestore Schema Overview

| Collection | Access | Purpose |
| :--- | :--- | :--- |
| `/app_config/monetization` | Public Read / Admin Write | Real-time AdMob IDs, Razorpay fee, Kill-switch, Banner promo |
| `/categories` | Public Read / Admin Write | Categories (DSA, Flutter, Python, System Design, SQL, etc.) |
| `/questions` | Public Read / Admin Write | Question bank with code snippets, tags, answers, deep dives |
| `/flagged_questions` | Auth Create / Admin Manage | In-app typo and issue submissions |
| `/announcements` | Public Read / Admin Write | Daily Question of the Day & feature broadcasts |
| `/users/{uid}` | User Read/Write / Admin Read | User streak, XP, Pro status, Leitner review progress |

---

## 5. Setup & Running Instructions

### Client Application:
```bash
cd quickprep_main
flutter pub get
flutter run
```

### Admin Application:
```bash
cd quickprep_admin
flutter pub get
flutter run -d chrome # Or run on Android emulator / physical device
```

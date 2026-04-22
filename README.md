<p align="center">
  <img src="assets/png/logo.png" alt="NomAI Logo" width="120" />
</p>

# NomAI – AI Nutrition & Meal Tracking

## ⚡ Overview

NomAI is a powerful AI Agent that brings nutrition and food intelligence to life. Whether you're analyzing meals through images, chatting with an AI nutrition assistant, or generating personalized weekly diet plans — NomAI handles the heavy lifting with a sophisticated multi-step LLM pipeline backed by real-time web research.

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🧠 **AI Nutrition Analysis** | Analyze food from images or text descriptions with a 3-step pipeline: food extraction → web search → LLM synthesis |
| 💬 **Conversational AI Chatbot** | LangChain-powered agent that understands dietary preferences, allergies, and health goals |
| 🍽️ **Weekly Diet Planner** | Generate 7-day personalized meal plans with carb cycling, variety tracking, and macro targets |
| 🔄 **Meal Alternatives** | Get 5 AI-suggested alternative meals respecting your dietary profile |
| 📊 **Nutrition Tracking** | Mark meals as eaten, update plans on the fly, and track diet history |
| 🔗 **Dual LLM Support** | Seamlessly switch between Google Gemini and OpenRouter (Claude) providers |
| 🌐 **Web-Grounded Analysis** | Nutrition data enriched with web search results from Exa or DuckDuckGo |
| 🛢️ **Firestore Persistence** | Chat history and diet plans stored in Google Firestore |

---

### 🚀 Quick Backend Deployment

Get your AI gateway running in seconds:

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/ACNcz0?referralCode=jEIluR&utm_medium=integration&utm_source=template&utm_campaign=generic)

**Backend Repository**: [https://github.com/Pavel401/NomAI](https://github.com/Pavel401/NomAI)

---

## Screenshots

Below is a gallery of the current screenshots in `static/screenshots/`.

<table>
  <tr>
    <td><img src="static/screenshots/Screenshot_1776872036.png" width="230" /></td>
    <td><img src="static/screenshots/Screenshot_1776872042.png" width="230" /></td>
    <td><img src="static/screenshots/Screenshot_1776872044.png" width="230" /></td>
  </tr>
  <tr>
    <td><img src="static/screenshots/Screenshot_1776872048.png" width="230" /></td>
    <td><img src="static/screenshots/Screenshot_1776872052.png" width="230" /></td>
    <td><img src="static/screenshots/Screenshot_1776872059.png" width="230" /></td>
  </tr>
  <tr>
    <td><img src="static/screenshots/Screenshot_1776872068.png" width="230" /></td>
    <td><img src="static/screenshots/Screenshot_1776872072.png" width="230" /></td>
    <td><img src="static/screenshots/Screenshot_1776872093.png" width="230" /></td>
  </tr>
  <tr>
    <td><img src="static/screenshots/Screenshot_1776872095.png" width="230" /></td>
    <td><img src="static/screenshots/Screenshot_1776872097.png" width="230" /></td>
    <td><img src="static/screenshots/Screenshot_1776872106.png" width="230" /></td>
  </tr>
  <tr>
    <td><img src="static/screenshots/Screenshot_1776872109.png" width="230" /></td>
    <td><img src="static/screenshots/Screenshot_1776872113.png" width="230" /></td>
    <td><img src="static/screenshots/Screenshot_1776872181.png" width="230" /></td>
  </tr>
  <tr>
    <td><img src="static/screenshots/Screenshot_1776872183.png" width="230" /></td>
    <td><img src="static/screenshots/Screenshot_1776872191.png" width="230" /></td>
    <td><img src="static/screenshots/Screenshot_1776872201.png" width="230" /></td>
  </tr>
  <tr>
    <td><img src="static/screenshots/Screenshot_1776872204.png" width="230" /></td>
    <td><img src="static/screenshots/Screenshot_1776872211.png" width="230" /></td>
    <td><img src="static/screenshots/Screenshot_1776872216.png" width="230" /></td>
  </tr>
  <tr>
    <td><img src="static/screenshots/Screenshot_1776872221.png" width="230" /></td>
    <td><img src="static/screenshots/Screenshot_1776872224.png" width="230" /></td>
    <td></td>
  </tr>
</table>

---

## 🏗️ System Architecture

NomAI is architected as a high-performance distributed system, separating the cross-platform Flutter client from a sophisticated AI orchestration backend.

### 🗺️ Full-Stack Interaction

The following diagram illustrates the flow from the client through the FastAPI gateway to the AI engines and persistence layers.

```mermaid
graph TD
    Client["📱 Client (Mobile / Web)"]
    Main["main.py — FastAPI App"]
    
    Client --> Main

    Main --> NutritionRouter["/api/v1/nutrition"]
    Main --> ChatRouter["/api/v1/users"]
    Main --> AgentRouter["/api/v1/chat"]
    Main --> DietRouter["/api/v1/diet"]

    NutritionRouter --> NutritionServiceV2
    AgentRouter --> LangChainAgent["🤖 LangChain Agent"]
    LangChainAgent --> AgentTools["Tools: analyse_image\nanalyse_food_description"]
    AgentTools --> NutritionServiceV2
    ChatRouter --> ChatFirestore
    DietRouter --> DietService

    NutritionServiceV2 --> FoodExtractor["FoodExtractorService"]
    NutritionServiceV2 --> SearchService
    NutritionServiceV2 --> LLMProvider["LLM Provider\n(Gemini / OpenRouter)"]
    DietService --> LLMProvider
    DietService --> DietFirestoreDB["DietFirestore"]

    FoodExtractor --> LLMProvider
    SearchService --> ExaAPI["🔍 Exa / DuckDuckGo"]

    ChatFirestore --> Firestore["🔥 Firestore DB"]
    DietFirestoreDB --> Firestore
```

### 🧠 AI Intelligence & Decision Logic

#### 1. ReAct Agent Decision Flow
The backend operates as a **Reasoning + Acting (ReAct)** agent. It doesn't just respond; it evaluates user intent, selects specialized tools, and iterates to find the most accurate facts.

```mermaid
graph TD
    User["👤 User Input\n(Chat/Image)"] --> Context["📋 Context Builder\n(Preferences + Allergies + Goals)"]
    Context --> Brain["🧠 LLM Controller\n(ReAct State Graph)"]
    
    Brain --> Decision{"Is this food-related?"}
    
    Decision -- "No / Simple Q&A" --> Direct["Direct Friendly Answer"]
    Decision -- "Yes / Needs Analysis" --> ToolSelection["🛠️ Tool Selection"]
    
    ToolSelection -- "Image Provided" --> ToolA["📸 analyse_image"]
    ToolSelection -- "Text Description" --> ToolB["📝 analyse_food_description"]
    
    ToolA --> Pipe["🧪 Nutrition Pipeline"]
    ToolB --> Pipe
    
    Pipe --> Observation["🔍 Tool Observation\n(Structured Data)"]
    Observation --> Brain
    
    Brain --> Final["🎁 Final Personalized Response"]
```

#### 2. 🧪 3-Step Nutrition Analysis Pipeline
To ensure "hallucination-free" data, NomAI uses a web-grounded pipeline:
1.  **Identification**: Detection of food items & generation of enriched search queries.
2.  **Web Grounding**: Targeted searches (Exa/DuckDuckGo) for authoritative USDA/FDA or brand data.
3.  **Multimodal Synthesis**: Synthesis of **Actual Image** + **Web Facts** + **User Prompt** into structured nutritional data.

#### 3. 📅 Diet Plan Generation (Carb Cycling)
The system applies metabolic variety patterns rather than static targets.

```mermaid
graph TD
    Input["📥 DietInput Payload"] --> Calc["⚖️ Target Calculator"]
    Calc --> Patterns["🔄 Carb Cycling Logic\n(Cyclical Macro Variation)"]
    Patterns --> Loop["🔁 7-Day Generation Loop"]
    Loop --> DayPrompt["📝 Prompt + Used Foods Tracking"]
    DayPrompt --> LLMCall["🤖 LLM Provider"]
    LLMCall --> Variety["🥗 Update Diversity Score"]
    Variety -- "Next Day" --> Loop
    Variety -- "End" --> Aggregator["📊 Weekly Aggregator"]
```


---

## 🚀 Setup & Deployment

### 1. Backend Configuration
The backend acts as the AI Gateway for the app.
- **Source**: [https://github.com/Pavel401/NomAI](https://github.com/Pavel401/NomAI)  
  [![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/ACNcz0?referralCode=jEIluR&utm_medium=integration&utm_source=template&utm_campaign=generic)
- **Deployment**: We recommend **Railway** or **GCP Cloud Run**.
- **Environment Variables**:
  - `PROVIDER_TYPE`: `gemini` or `openrouter`.
  - `GOOGLE_API_KEY`: For Gemini Vision analysis.
  - `SEARCH_PROVIDER`: `exa` or `duckduckgo` for web grounding.
  - `FIRESTORE_DATABASE_ID`: Set to `mealai`.

### 2. Firebase Core Services
NomAI relies on Firebase for real-time sync and security.
- **Authentication**: Enable Email and Google providers.
- **Firestore**: Initialize in production mode.
- **Remote Config**: Add the `base_url` key pointing to your deployed backend.

### 3. Client Execution (FVM)
NomAI works on **iOS, Android, and Web**.

```bash
# 1. SDK Isolation
fvm use 3.35.0

# 2. Platform Configs
# - Android: google-services.json
# - iOS: GoogleService-Info.plist
# - Web: firebase-config script

# 3. Compile & Run
fvm flutter pub get
fvm flutter run           # Mobile
fvm flutter run -d chrome # Web
```

## 📦 Build & Release

```bash
fvm flutter build apk --release    # Android
fvm flutter build ios --release    # iOS
fvm flutter build web --release    # Web
```

---

## 📂 Folder Structure

```text
lib/
├── app/
│   ├── components/         # Reusable UI components (Buttons, Modals, Inputs)
│   ├── constants/          # Application theme, colors, and API endpoints
│   ├── models/             # Base data models and JSON serialization
│   ├── modules/            # Feature-centric modular architecture
│   │   ├── Analytics/      # Data visualization and dietary metrics
│   │   ├── Auth/           # Firebase Authentication flows
│   │   ├── Chat/           # Conversational AI Assistant
│   │   ├── DashBoard/      # Core metrics and daily logging summary
│   │   ├── Diet/           # Weekly plan generation and alternates
│   │   ├── Onboarding/     # User profiling and goal setting
│   │   └── Scanner/        # Real-time food recognition using Vision AI
│   ├── providers/          # Infrastructure services (RemoteConfig, BLoC)
│   ├── repo/               # Data layer: Firebase SDKs and FastAPI integrations
│   ├── services/           # State monitoring and global domain logic
│   └── utility/            # Helper utilities (Registry, Haptics, Formatting)
├── firebase_options.dart   # Platform-specific Firebase settings
└── main.dart               # App entry point
assets/
├── lottie/                 # High-performance micro-animations
├── png/                    # Branding assets
└── svg/                    # Resolution-independent iconography
```

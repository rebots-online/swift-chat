# Project Index: SwiftChat

**Generated**: 2025-01-31
**Version**: 2.7.0
**Index Size**: ~3.5KB (94% token reduction vs full codebase)

---

## 📁 Project Structure

```text
swift-chat/
├── react-native/          # Cross-platform mobile app (React Native)
│   ├── android/          # Android native code
│   ├── ios/              # iOS/macOS native code (Xcode project)
│   ├── patches/          # npm package patches
│   └── src/              # TypeScript source code
├── server/               # Python FastAPI backend
│   ├── scripts/          # Deployment scripts
│   ├── src/              # Python source code
│   └── template/         # CloudFormation templates
├── assets/               # Images, animations, documentation
└── .github/              # CI/CD workflows, issue templates
```

---

## 🚀 Entry Points

| Location | Purpose |
|----------|---------|
| `react-native/index.js` | React Native entry point |
| `react-native/src/App.tsx` | Main app component with navigation |
| `react-native/src/chat/ChatScreen.tsx` | Primary chat interface |
| `react-native/src/settings/SettingsScreen.tsx` | Configuration management |
| `server/src/main.py` | FastAPI application entry point |
| `server/src/image_nl_processor.py` | Image processing utilities |

---

## 📦 Core Modules

### Chat System (`src/chat/`)

- `ChatScreen.tsx` - Main chat UI with streaming
- `component/CustomMessageComponent.tsx` - Message rendering
- `component/markdown/` - Markdown, code, Mermaid rendering
- `service/VoiceChatService.ts` - Amazon Nova Sonic S2S
- `util/BedrockMessageConvertor.ts` - Message format conversion

### API Layer (`src/api/`)

- `bedrock-api.ts` - Amazon Bedrock client
- `bedrock-api-key.ts` - API Key authentication
- `ollama-api.ts` - Ollama local models
- `open-api.ts` - OpenAI & OpenAI-compatible clients
- `bedrock-api-key-image.ts` - Image generation

### Settings (`src/settings/`)

- `SettingsScreen.tsx` - Multi-provider config UI
- `ModelPrice.ts` - Token pricing calculator
- `OpenAICompatConfigsSection.tsx` - Custom provider management

### Web Search (`src/websearch/`)

- `services/WebSearchOrchestrator.ts` - Search orchestration
- `providers/` - Google, Bing, Baidu, Tavily
- `services/IntentAnalysisService.ts` - Intent detection

### App Creation (`src/app/`)

- `CreateAppScreen.tsx` - AI web app generation
- `AppViewerScreen.tsx` - WebView app viewer
- `AppGalleryScreen.tsx` - App library
- `AIWebView.tsx` - Web bridge

### Storage (`src/storage/`)

- `StorageUtils.ts` - MMKV persistence (10x faster)
- `Constants.ts` - Storage keys

### Theme (`src/theme/`)

- `ThemeContext.tsx` - Dark/light mode
- `colors.ts` - Color definitions

---

## 🔧 Configuration Files

| File | Purpose |
|------|---------|
| `react-native/package.json` | Dependencies (v2.7.0) |
| `react-native/babel.config.js` | Babel transpilation |
| `react-native/metro.config.js` | Metro bundler |
| `server/template/SwiftChatLambda.template` | CloudFormation stack |
| `.github/workflows/build-*.yml` | CI/CD pipelines |

---

## 🔗 Key Dependencies

### Mobile (React Native 0.74.1)

- `@react-navigation/*` 7.x - Navigation
- `react-native-mmkv` 2.12.2 - Fast storage
- `react-native-gifted-chat` 2.4.0 - Chat UI
- `react-native-marked` 6.0.7 - Markdown
- `@mozilla/readability` 0.6.0 - Web content

### Backend (Python FastAPI)

- `fastapi` - Web framework
- `boto3` - AWS SDK
- `uvicorn` - ASGI server
- `httpx` - Async HTTP

---

## 📝 Quick Start

```bash
# Clone & install
git clone https://github.com/aws-samples/swift-chat.git
cd swift-chat/react-native && npm i && npm start

# Run Android
npm run android

# Run iOS
cd ios && pod install && cd .. && npm run ios
```

---

## 🎯 Key Features

- Real-time streaming chat with thinking mode
- Instant web app creation/editing/sharing
- Web search (Google, Bing, Baidu, Tavily)
- Rich markdown (tables, code, LaTeX, Mermaid)
- AI image generation (Nova Canvas, Stable Diffusion)
- Multimodal (text, image, video, document)
- Voice chat with Amazon Nova Sonic
- Cross-platform (Android, iOS, macOS)
- Dark mode

---

## 🏗️ Architecture

- **Backend**: API Gateway + Lambda (Docker) for 15-min streaming
- **Frontend**: React Navigation (Drawer + Stack), MMKV storage
- **Providers**: Bedrock, Ollama, DeepSeek, OpenAI, OpenAI-compatible

---

**Token Efficiency**: Index (~3.5KB) vs Full (~58KB) = **94% savings**

# RustDesk AI - Development Guide

## Project Overview

RustDesk AI is an enhanced version of the RustDesk remote desktop application with integrated AI capabilities for mobile devices. This guide provides comprehensive instructions for setting up and developing the project.

## Project Structure

```
rustdesk-app-package/
├── ai-backend/              # AI backend service (Node.js)
│   ├── src/
│   │   ├── routes/         # API routes (OCR, Chat, Code Review, etc.)
│   │   ├── middleware/     # Auth and error handling
│   │   └── utils/          # Logger and utilities
│   ├── Dockerfile
│   └── package.json
│
├── flutter/                 # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart      # App entry point
│   │   ├── common.dart    # Shared constants and theme
│   │   ├── models/        # Data models
│   │   ├── services/      # Business logic services
│   │   ├── mobile/        # Mobile-specific pages and widgets
│   │   └── widgets/       # Shared UI components
│   ├── android/           # Android-specific configuration
│   ├── ios/               # iOS-specific configuration
│   └── pubspec.yaml       # Flutter dependencies
│
├── rustdesk-server/         # RustDesk server configuration
│   ├── docker-compose.yml  # Server deployment config
│   ├── docker-compose-full.yml  # Full deployment with AI
│   ├── nginx/             # Nginx reverse proxy config
│   └── build_custom.sh     # Server build script
│
└── config/                 # Security and app configuration
    └── security.conf
```

## Development Environment Setup

### Prerequisites

1. **Flutter SDK** (3.24+)
   ```bash
   flutter --version
   ```

2. **Dart SDK** (3.0+)
   ```bash
   dart --version
   ```

3. **Rust** (1.70+) - For native components
   ```bash
   rustc --version
   cargo --version
   ```

4. **Node.js** (18+) - For AI backend
   ```bash
   node --version
   npm --version
   ```

5. **Docker & Docker Compose** - For server deployment
   ```bash
   docker --version
   docker compose version
   ```

### Initial Setup

1. **Clone and navigate to project**
   ```bash
   cd rustdesk-app-package
   ```

2. **Flutter dependencies**
   ```bash
   cd flutter
   flutter pub get
   ```

3. **AI Backend dependencies**
   ```bash
   cd ai-backend
   npm install
   ```

4. **Environment configuration**
   ```bash
   cp ai-backend/.env.example ai-backend/.env
   # Edit .env with your API keys
   ```

## Running the Application

### Mobile App Development

```bash
cd flutter

# Run on connected device/emulator
flutter run

# Run with specific device
flutter run -d <device_id>

# Run debug build
flutter run --debug
```

### AI Backend Development

```bash
cd ai-backend

# Development mode with hot reload
npm run dev

# Production mode
npm start
```

### Server Deployment

```bash
cd rustdesk-server

# Deploy with Docker Compose
docker-compose -f docker-compose-full.yml up -d

# View logs
docker-compose -f docker-compose-full.yml logs -f

# Stop services
docker-compose -f docker-compose-full.yml down
```

## Building for Production

### Android

```bash
cd flutter

# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Build with build script
./build_mobile.sh android
```

### iOS

```bash
cd flutter

# Simulator build (macOS only)
flutter build ios --simulator

# Release build (requires Apple Developer account)
flutter build ios --release
```

### Web

```bash
cd flutter
flutter build web --release
```

## AI Features Integration

### API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/ai/ocr` | POST | Optical character recognition |
| `/api/ai/chat` | POST | AI chat assistant |
| `/api/ai/code-review` | POST | Code analysis and review |
| `/api/ai/summarize` | POST | Screen content summarization |
| `/api/ai/translate` | POST | Text translation |

### Adding New AI Features

1. **Backend** - Add new route in `ai-backend/src/routes/`
2. **Frontend** - Add new service method in `flutter/lib/services/ai_service.dart`
3. **UI** - Add new button in `flutter/lib/widgets/ai_quick_buttons.dart`

## Testing

### Flutter Unit Tests

```bash
cd flutter
flutter test
```

### AI Backend Tests

```bash
cd ai-backend
npm test
```

### Integration Tests

```bash
# Full system test
./test_integration.sh
```

## Troubleshooting

### Common Issues

1. **Flutter build fails**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **AI backend connection refused**
   - Check if service is running: `curl http://localhost:8080/health`
   - Check .env configuration

3. **Docker compose fails**
   - Check Docker is running: `docker ps`
   - Check ports are available: `netstat -an | grep 8080`

## Security Considerations

- Never commit API keys to version control
- Use environment variables for sensitive data
- Enable SSL/TLS in production
- Regular security audits recommended

## License

This project extends RustDesk under AGPL-3.0 license. See RustDesk documentation for details.
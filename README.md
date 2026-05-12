# 🌱 AgroSense — Flutter App

Dashboard agrícola de monitoreo en tiempo real de temperatura, humedad del suelo y lluvia.

---

## 📋 Requisitos previos

Antes de clonar y ejecutar este proyecto asegúrate de tener instalado:

| Herramienta | Versión mínima | Enlace |
|-------------|---------------|--------|
| Flutter SDK | >= 3.10.0 | https://docs.flutter.dev/get-started/install |
| Dart SDK | >= 3.0.0 | (incluido con Flutter) |
| Git | cualquier versión reciente | https://git-scm.com |

> **Nota:** Verifica tu instalación con `flutter doctor`. Todos los checks deben estar en verde (o solo con advertencias no críticas) antes de continuar.

---

## 📥 Instalación y configuración inicial

```bash
# 1. Clonar el repositorio
git clone https://github.com/villegas07/agrosense.git
cd agrosense

# 2. Instalar dependencias
flutter pub get

# 3. (Opcional) Regenerar código generado por build_runner
dart run build_runner build --delete-conflicting-outputs
```

---

## 📱 Plataformas soportadas

| Plataforma | Estado | Notas |
|------------|--------|-------|
| Android | ✅ Soportada | API 21+ (Android 5.0) |
| iOS | ✅ Soportada | Requiere macOS + Xcode |
| Web | ✅ Soportada | `flutter run -d chrome` |
| Linux / Windows / macOS | ✅ Soportada | Desktop embedder habilitado |

### Android
Asegúrate de tener Android Studio con un emulador configurado o un dispositivo físico conectado en modo depuración USB.

```bash
flutter run -d android
```

### iOS (solo macOS)
Requiere Xcode 14+ y CocoaPods instalado (`sudo gem install cocoapods`).

```bash
cd ios && pod install && cd ..
flutter run -d ios
```

---

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                          # Entry point + ProviderScope
├── agrosense.dart                     # Barrel exports
├── core/
│   ├── constants/app_constants.dart   # Espaciado, radios, umbrales
│   ├── errors/failures.dart           # Tipos de error (Failure)
│   └── theme/app_theme.dart           # Colores + ThemeData
└── features/
    └── dashboard/
        ├── data/
        │   ├── datasources/
        │   │   └── dashboard_local_datasource.dart   # Mock data / futura API
        │   ├── models/
        │   │   └── dashboard_models.dart             # DTOs (fromJson)
        │   └── repositories/
        │       └── dashboard_repository_impl.dart    # Implementación concreta
        ├── domain/
        │   ├── entities/
        │   │   └── dashboard_entities.dart           # Entidades puras
        │   ├── repositories/
        │   │   └── dashboard_repository.dart         # Contrato abstracto
        │   └── usecases/
        │       └── dashboard_usecases.dart           # Casos de uso
        └── presentation/
            ├── providers/
            │   └── dashboard_providers.dart          # Riverpod DI + State
            ├── screens/
            │   └── dashboard_screen.dart             # Pantalla principal
            └── widgets/
                ├── section_header.dart
                ├── temperature_card.dart
                ├── soil_humidity_card.dart
                ├── rain_state_card.dart
                ├── last24_hours_card.dart
                └── historical_analysis_card.dart
```

---

## 🏛️ Clean Architecture

```
┌──────────────────────────────────────────┐
│           PRESENTATION LAYER             │
│   Screens · Widgets · Riverpod Providers │
│   Solo conoce Domain (vía use cases)     │
├──────────────────────────────────────────┤
│             DOMAIN LAYER                 │
│   Entities · Repository (abstract)       │
│   Use Cases — cero dependencias externas │
├──────────────────────────────────────────┤
│              DATA LAYER                  │
│   Models · DataSources · Repository Impl │
│   Implementa el contrato de Domain       │
└──────────────────────────────────────────┘
```

**Regla de dependencia:** Las capas internas nunca dependen de las externas.
- Domain no importa Flutter, ni fl_chart, ni Riverpod.
- Data depende de Domain (implementa sus contratos).
- Presentation depende de Domain (consume use cases).

---

## ⚙️ Principios SOLID aplicados

| Principio | Dónde se aplica |
|-----------|-----------------|
| **S** — Single Responsibility | Cada widget hace una sola cosa. Cada use case tiene un único propósito. |
| **O** — Open/Closed | Nuevas fuentes de datos (RemoteDataSource) se agregan sin modificar el repo. |
| **L** — Liskov Substitution | `DashboardRepositoryImpl` sustituye `DashboardRepository` sin alterar comportamiento. |
| **I** — Interface Segregation | `DashboardRepository` expone solo `get` y `watch`. No contamina con métodos no usados. |
| **D** — Dependency Inversion | `Presentation` depende de `DashboardRepository` (abstracción), no de `RepositoryImpl`. |

---

## 🔧 Gestión de Estado — Riverpod

```
dashboardLocalDataSourceProvider   → DashboardLocalDataSource
        ↓
dashboardRepositoryProvider        → DashboardRepository
        ↓
watchDashboardDataUseCaseProvider  → WatchDashboardDataUseCase
        ↓
dashboardDataProvider (StreamProvider.family)   ← Pantalla lo consume
```

---

## 📦 Dependencias principales

| Paquete | Versión | Uso |
|---------|---------|-----|
| `flutter_riverpod` | ^2.5.1 | Gestión de estado + DI |
| `fl_chart` | ^0.68.0 | Gráficas líneas y barras |
| `equatable` | ^2.0.5 | Comparación de entidades |
| `go_router` | ^13.2.0 | Navegación declarativa |
| `freezed_annotation` | ^2.4.1 | Modelos inmutables (opcional) |

---

## 🚀 Cómo ejecutar

```bash
# Ejecutar en el dispositivo/emulador por defecto
flutter run

# Ejecutar en un dispositivo específico
flutter run -d <device_id>

# Listar dispositivos disponibles
flutter devices

# Compilar release APK (Android)
flutter build apk --release

# Compilar release para web
flutter build web
```

---

## 📱 Pantallas implementadas

- ✅ **Dashboard** — Vista principal con todos los módulos del wireframe

### Módulos del Dashboard
| Módulo | Widget | Descripción |
|--------|--------|-------------|
| Header | `_DashboardAppBar` | SectorName, timestamp, badge EN VIVO |
| Temperatura | `TemperatureCard` | Ambiente vs Suelo con delta vs ayer |
| Humedad Suelo | `SoilHumidityCard` | 3 zonas con barra de progreso y estado |
| Lluvia | `RainStateCard` | Estado actual + estadísticas 7/30 días |
| Últimas 24h | `Last24HoursCard` | LineChart doble + alerta de patrón |
| Análisis Histórico | `HistoricalAnalysisCard` | BarChart lluvia + Heatmap temperatura |

---

## 🔌 Conectar API real

Para conectar una API real, solo debes:

1. Crear `DashboardRemoteDataSource` implementando `DashboardLocalDataSource`
2. Reemplazar el provider en `dashboard_providers.dart`:

```dart
final dashboardLocalDataSourceProvider =
    Provider<DashboardLocalDataSource>((ref) {
  return DashboardRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});
```

El resto de la arquitectura no necesita cambios. ✅

---

## 🛠️ Solución de problemas comunes

**`flutter pub get` falla con errores de red**
```bash
# Usa el mirror de pub si estás en una red restringida
export PUB_HOSTED_URL=https://pub.flutter-io.cn
flutter pub get
```

**Error: `Dart SDK version is not compatible`**
Actualiza Flutter a la versión mínima requerida:
```bash
flutter upgrade
flutter --version   # debe mostrar Flutter >= 3.10.0 / Dart >= 3.0.0
```

**`flutter doctor` muestra errores en Android licenses**
```bash
flutter doctor --android-licenses
# Acepta todas las licencias presionando 'y'
```

**Widgets no renderizan gráficas (`fl_chart`)**
Asegúrate de que el widget tenga un tamaño concreto (height/width); `fl_chart` requiere constraints definidos.

---

## 🤝 Contribuir

1. Haz fork del repositorio
2. Crea una rama descriptiva: `git checkout -b feat/nombre-feature`
3. Realiza tus cambios respetando la arquitectura Clean Architecture descrita arriba
4. Ejecuta el análisis estático antes de hacer commit:
   ```bash
   flutter analyze
   flutter test
   ```
5. Abre un Pull Request describiendo los cambios

---

## 📄 Licencia

Este proyecto es de uso académico. Consulta al autor antes de cualquier uso comercial.

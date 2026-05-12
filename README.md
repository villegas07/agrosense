# 🌱 AgroSense — Flutter App

Dashboard agrícola de monitoreo en tiempo real de temperatura, humedad del suelo y lluvia.

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
# 1. Instalar dependencias
flutter pub get

# 2. Ejecutar
flutter run

# 3. (Opcional) Generar código con build_runner
dart run build_runner build --delete-conflicting-outputs
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

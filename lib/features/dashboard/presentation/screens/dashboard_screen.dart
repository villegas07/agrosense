import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/historical_analysis_card.dart';
import '../widgets/last24_hours_card.dart';
import '../widgets/node_temperature_card.dart';
import '../widgets/rain_state_card.dart';
import '../widgets/soil_humidity_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isExporting = false;

  Future<void> _handleExport(String sectorId) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      final ds = ref.read(dashboardRemoteDataSourceProvider);
      await ds.exportAndOpenSectorData(sectorId, hours: 168);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Archivo descargado exitosamente'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSectorId = ref.watch(effectiveSectorIdProvider);

    // Mientras no haya sector disponible (carga inicial o error de API)
    if (effectiveSectorId.isEmpty) {
      return _SectorLoadingOrError(ref: ref);
    }

    final asyncData = ref.watch(dashboardDataProvider(effectiveSectorId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: asyncData.when(
        loading: () => const _LoadingView(),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () =>
              ref.invalidate(dashboardDataProvider(effectiveSectorId)),
        ),
        data: (data) => CustomScrollView(
          slivers: [
            _DashboardAppBar(
              sectorName: data.sectorName,
              lastUpdated: data.lastUpdated,
              isLive: data.isLive,
              ambientTemp: data.temperature.ambientCelsius,
              soilHumidity: data.soilZones.isNotEmpty
                  ? data.soilZones.first.humidityPercent
                  : 0,
              isRaining: data.rainState.isRaining,
              onLogout: () => ref.read(authProvider.notifier).logout(),
              onExport: () => _handleExport(effectiveSectorId),
              isExporting: _isExporting,
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _SectorPicker(effectiveSectorId: effectiveSectorId),
                  NodeTemperatureCard(zones: data.soilZones),
                  const _Divider(),
                  SoilHumidityCard(zones: data.soilZones),
                  const _Divider(),
                  RainStateCard(rainState: data.rainState),
                  const _Divider(),
                  Last24HoursCard(
                    sectorId: effectiveSectorId,
                    alertMessage: data.alertMessage,
                  ),
                  const _Divider(),
                  HistoricalAnalysisCard(
                    weeklyRain: data.weeklyRain,
                    monthlyRain: data.monthlyRain,
                    heatmapData: data.heatmapData,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sector Picker ─────────────────────────────────────────────────────────────
class _SectorPicker extends ConsumerWidget {
  const _SectorPicker({required this.effectiveSectorId});

  final String effectiveSectorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectorsAsync = ref.watch(sectorsProvider);

    return sectorsAsync.maybeWhen(
      data: (sectors) {
        // Only show picker when there are multiple sectors
        if (sectors.length <= 1) return const SizedBox.shrink();
        return SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sectors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final sector = sectors[i];
              final selected = sector.sectorId == effectiveSectorId;
              return ChoiceChip(
                label: Text(sector.name),
                selected: selected,
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? Colors.white
                      : AppColors.textSecondary,
                ),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surfaceVariant,
                side: BorderSide.none,
                onSelected: (_) => ref
                    .read(selectedSectorIdProvider.notifier)
                    .state = sector.sectorId,
              );
            },
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

// ── Sector loading / error (before first sector is known) ─────────────────────
class _SectorLoadingOrError extends ConsumerWidget {
  const _SectorLoadingOrError({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final sectorsAsync = widgetRef.watch(sectorsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: sectorsAsync.when(
        loading: () => const _LoadingView(),
        error: (e, _) => _ErrorView(
          message: 'No se pudieron cargar los sectores.\n${e.toString()}',
          onRetry: () => widgetRef.invalidate(sectorsProvider),
        ),
        // sectors loaded but empty list
        data: (_) => _ErrorView(
          message: 'No hay sectores configurados en el servidor.',
          onRetry: () => widgetRef.invalidate(sectorsProvider),
        ),
      ),
    );
  }
}

// ── AppBar ────────────────────────────────────────────────────────────────────
class _DashboardAppBar extends StatelessWidget {
  const _DashboardAppBar({
    required this.sectorName,
    required this.lastUpdated,
    required this.isLive,
    required this.ambientTemp,
    required this.soilHumidity,
    required this.isRaining,
    required this.onLogout,
    required this.onExport,
    required this.isExporting,
  });

  final String sectorName;
  final String lastUpdated;
  final bool isLive;
  final double ambientTemp;
  final int soilHumidity;
  final bool isRaining;
  final VoidCallback onLogout;
  final VoidCallback onExport;
  final bool isExporting;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final contentTop = kToolbarHeight.toDouble() + statusBarHeight + 4.0;

    return SliverAppBar(
      pinned: true,
      expandedHeight: contentTop + 90,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
        ),
      ),
      title: const Text(
        'AgroSense',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        isExporting
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.download_rounded,
                    size: 20, color: AppColors.textSecondary),
                tooltip: 'Exportar a Excel (últimos 7 días)',
                onPressed: onExport,
              ),
        IconButton(
          icon: const Icon(Icons.logout_rounded,
              size: 20, color: AppColors.textSecondary),
          tooltip: 'Cerrar sesión',
          onPressed: onLogout,
        ),
        if (isLive)
          Container(
            margin: const EdgeInsets.only(right: 16, top: 13, bottom: 13),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.liveRed,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'EN VIVO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppColors.surface,
          padding: EdgeInsets.fromLTRB(16, contentTop, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sectorName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 11, color: AppColors.textTertiary),
                  const SizedBox(width: 3),
                  Text(
                    'Última actualización: $lastUpdated',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textTertiary),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _QuickChip(
                    icon: Icons.thermostat_rounded,
                    label: '${ambientTemp.toStringAsFixed(1)}°C',
                    color: AppColors.tempAmbient,
                  ),
                  const SizedBox(width: 6),
                  _QuickChip(
                    icon: Icons.water_drop_rounded,
                    label: 'Hum. $soilHumidity%',
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  _QuickChip(
                    icon: isRaining
                        ? Icons.grain_rounded
                        : Icons.wb_sunny_rounded,
                    label: isRaining ? 'Lluvia activa' : 'Sin lluvia',
                    color: isRaining
                        ? AppColors.chartBar
                        : AppColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Divider(color: AppColors.divider, height: 1),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
              color: AppColors.primary, strokeWidth: 2.5),
          SizedBox(height: 16),
          Text(
            'Cargando datos del sensor...',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: AppColors.danger, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'Error de conexión',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Reintentar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

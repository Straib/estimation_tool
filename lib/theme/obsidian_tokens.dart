import 'package:flutter/material.dart';

@immutable
class ObsidianTokens extends ThemeExtension<ObsidianTokens> {
  const ObsidianTokens({
    required this.surfacePanel,
    required this.surfacePanelMuted,
    required this.onSurfaceStrong,
    required this.onSurfaceMuted,
    required this.chartBar,
    required this.chartBarTouched,
    required this.accentWarm,
  });

  final Color surfacePanel;
  final Color surfacePanelMuted;
  final Color onSurfaceStrong;
  final Color onSurfaceMuted;
  final Color chartBar;
  final Color chartBarTouched;
  final Color accentWarm;

  static const ObsidianTokens dark = ObsidianTokens(
    surfacePanel: Color(0xFF131B2E),
    surfacePanelMuted: Color(0xFF222A3D),
    onSurfaceStrong: Color(0xFFDAE2FD),
    onSurfaceMuted: Color(0xFFC7C4D7),
    chartBar: Color(0xFF8083FF),
    chartBarTouched: Color(0xFFC0C1FF),
    accentWarm: Color(0xFFFFB783),
  );

  @override
  ObsidianTokens copyWith({
    Color? surfacePanel,
    Color? surfacePanelMuted,
    Color? onSurfaceStrong,
    Color? onSurfaceMuted,
    Color? chartBar,
    Color? chartBarTouched,
    Color? accentWarm,
  }) {
    return ObsidianTokens(
      surfacePanel: surfacePanel ?? this.surfacePanel,
      surfacePanelMuted: surfacePanelMuted ?? this.surfacePanelMuted,
      onSurfaceStrong: onSurfaceStrong ?? this.onSurfaceStrong,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      chartBar: chartBar ?? this.chartBar,
      chartBarTouched: chartBarTouched ?? this.chartBarTouched,
      accentWarm: accentWarm ?? this.accentWarm,
    );
  }

  @override
  ObsidianTokens lerp(ThemeExtension<ObsidianTokens>? other, double t) {
    if (other is! ObsidianTokens) {
      return this;
    }

    return ObsidianTokens(
      surfacePanel: Color.lerp(surfacePanel, other.surfacePanel, t) ?? surfacePanel,
      surfacePanelMuted:
          Color.lerp(surfacePanelMuted, other.surfacePanelMuted, t) ?? surfacePanelMuted,
      onSurfaceStrong:
          Color.lerp(onSurfaceStrong, other.onSurfaceStrong, t) ?? onSurfaceStrong,
      onSurfaceMuted:
          Color.lerp(onSurfaceMuted, other.onSurfaceMuted, t) ?? onSurfaceMuted,
      chartBar: Color.lerp(chartBar, other.chartBar, t) ?? chartBar,
      chartBarTouched: Color.lerp(chartBarTouched, other.chartBarTouched, t) ?? chartBarTouched,
      accentWarm: Color.lerp(accentWarm, other.accentWarm, t) ?? accentWarm,
    );
  }
}

extension ObsidianTokenLookup on BuildContext {
  ObsidianTokens get obsidianTokens {
    final tokens = Theme.of(this).extension<ObsidianTokens>();
    return tokens ?? ObsidianTokens.dark;
  }
}

#language slang 2026

import kitty_custom_shader_types;

// Fraction of the original color retained outside the active window
// (1.0 = unchanged, 0.0 = fully faded into the background).
static const float INACTIVE_OPACITY = 0.6;
// Keep the tab bar outside the effect.
static const bool DIM_CENTRAL_AREA_ONLY = true;
// Treat the active window's padding/margin/border as part of the active window.
static const bool INCLUDE_WINDOW_PADDING = true;

public float4
fragment_main(float4 color, KittyTextures t, KittyCustomShaderData d) {
    if (DIM_CENTRAL_AREA_ONLY) {
        float4 area = d.central_area;
        if (any(t.pos < area.xy) || any(t.pos > area.xy + area.zw)) return color;
    }
    float4 g = d.active_window_geometry;
    if (g.z <= 0.0 || g.w <= 0.0) return color;
    if (INCLUDE_WINDOW_PADDING) {
        g.xy -= d.active_window_padding.xy;
        g.zw += d.active_window_padding.xy + d.active_window_padding.zw;
    }

    float2 winMin = g.xy;
    float2 winMax = g.xy + g.zw;
    if (all(t.pos >= winMin) && all(t.pos <= winMax)) return color;

    // Fade toward the theme's own background, blending in gamma space so the
    // fade looks even on light and dark themes. Inputs are linear RGB.
    float3 bg = d.active_window_background.rgb;
    float3 bg_g = pow(clamp(bg, 0.0, 1.0), float3(1.0 / 2.2));
    float3 fg_g = pow(clamp(color.rgb, 0.0, 1.0), float3(1.0 / 2.2));
    float3 mixed = pow(lerp(bg_g, fg_g, INACTIVE_OPACITY), float3(2.2));
    return float4(
        mixed,
        color.a
    );
}

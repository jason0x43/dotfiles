#language slang 2026

import kitty_custom_shader_types;

static const float3 GLOW_COLOR = float3(0.5, 0.05, 0.5);
static const float GLOW_OPACITY = 0.10;
static const float GLOW_RADIUS_PX = 12.0;

static float
sd_box(float2 p, float2 center, float2 half_extents) {
    float2 d = abs(p - center) - half_extents;
    return length(max(d, float2(0.0))) + min(max(d.x, d.y), 0.0);
}

static float
parametric_blend(float t) {
    float squared = t * t;
    return squared / (2.0 * (squared - t) + 1.0);
}

public float4
fragment_main(float4 color, KittyTextures t, KittyCustomShaderData d) {
    // .x=left, .y=right, .z=top, .w=bottom
    float4 edge = d.cursor_trail_edge;

    // No usable cursor geometry yet.
    if (edge.y <= edge.x || edge.z <= edge.w) return color;

    float2 pixel_dims = float2(d.viewport_size_pixels) * t.viewport.zw;
    float2 pixel_pos = t.pos * pixel_dims;

    float2 cursor_min = float2(
        edge.x * pixel_dims.x,
        edge.w * pixel_dims.y
    );
    float2 cursor_max = float2(
        edge.y * pixel_dims.x,
        edge.z * pixel_dims.y
    );

    float2 cursor_center = (cursor_min + cursor_max) * 0.5;
    float2 cursor_half_size = (cursor_max - cursor_min) * 0.5;

    float distance = sd_box(pixel_pos, cursor_center, cursor_half_size);
    float progress = parametric_blend(
        clamp(t.animation_progress, 0.0, 1.0)
    );

    // Shrink the glow outward toward the cursor over 300 ms.
    float radius = max(GLOW_RADIUS_PX * (1.0 - progress), 0.001);
    float outside_distance = max(distance, 0.0);

    // Glow outside the cursor, leaving the cursor itself untouched.
    float glow =
        (1.0 - smoothstep(0.0, radius, outside_distance))
        * step(0.0, distance);

    float strength = glow * GLOW_OPACITY;

    // Preserve kitty's existing alpha.
    return float4(
        lerp(color.rgb, GLOW_COLOR, strength),
        color.a
    );
}

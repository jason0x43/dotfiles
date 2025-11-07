const vec4 CURSOR_COLOR_ACCENT = vec4(0.5, 0.063, 0.941, 0.3);
const float DURATION = 0.3;

float sdBox(in vec2 p, in vec2 xy, in vec2 b)
{
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

vec2 normalize(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float parametricBlend(float t)
{
    float sqr = t * t;
    return sqr / (2.0 * (sqr - t) + 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    //Normalization for fragCoord to a space of -1 to 1;
    vec2 vu = normalize(fragCoord, 1.);
    vec2 offsetFactor = vec2(-.5, 0.5);

    //Normalization for cursor position and size;
    //cursor xy has the postion in a space of -1 to 1;
    //zw has the width and height
    vec4 currentCursor = vec4(
        normalize(iCurrentCursor.xy, 1.),
        normalize(iCurrentCursor.zw, 0.)
    );

    // How far through the animation we are
    float progress = parametricBlend(
        clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0)
    );

    float cCursorDistance = sdBox(
        vu,
        currentCursor.xy - (currentCursor.zw * offsetFactor),
        currentCursor.zw * 0.5
    );

    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #endif

    vec4 newColor = mix(
        vec4(fragColor),
        CURSOR_COLOR_ACCENT,
        1.0 - smoothstep(cCursorDistance, -0.000, 0.003 * (1. - progress))
    );

    fragColor = mix(fragColor, newColor, 1.);
}

// 精确模拟kitty cursor_trail.c的物理模型

float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b) {
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float seg(in vec2 p, in vec2 a, in vec2 b, inout float s, float d) {
    vec2 e = b - a;
    vec2 w = p - a;
    vec2 proj = a + e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
    float segd = dot(p - proj, p - proj);
    d = min(d, segd);

    float c0 = step(0.0, p.y - a.y);
    float c1 = 1.0 - step(0.0, p.y - b.y);
    float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x);

    float allCond = c0 * c1 * c2;
    float noneCond = (1.0 - c0) * (1.0 - c1) * (1.0 - c2);
    float flip = mix(1.0, -1.0, step(0.5, allCond + noneCond));

    s *= flip;
    return d;
}

float getSdfQuad(in vec2 p, in vec2 v0, in vec2 v1, in vec2 v2, in vec2 v3) {
    float s = 1.0;
    float d = dot(p - v0, p - v0);

    d = seg(p, v0, v1, s, d);
    d = seg(p, v1, v2, s, d);
    d = seg(p, v2, v3, s, d);
    d = seg(p, v3, v0, s, d);

    return s * sqrt(d);
}

vec2 normalize(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float antialising(float distance) {
    return 1.0 - smoothstep(0.0, normalize(vec2(2.0, 2.0), 0.0).x, distance);
}

vec2 getRectangleCenter(vec4 rectangle) {
    return vec2(rectangle.x + (rectangle.z / 2.0), rectangle.y - (rectangle.w / 2.0));
}

// kitty精确参数 - 这些是kitty的默认值
const vec4 TRAIL_COLOR = vec4(1.0, 1.0, 1.0, 1.0);
const float DECAY_FAST = 0.1;  // cursor_trail_decay_fast
const float DECAY_SLOW = 0.3;  // cursor_trail_decay_slow  
const float OPACITY = 1.0;

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
#if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
#endif

    vec2 vu = normalize(fragCoord, 1.0);
    vec2 offsetFactor = vec2(-0.5, 0.5);

    vec4 currentCursor = vec4(normalize(iCurrentCursor.xy, 1.0), normalize(iCurrentCursor.zw, 0.0));
    vec4 previousCursor = vec4(normalize(iPreviousCursor.xy, 1.0), normalize(iPreviousCursor.zw, 0.0));

    // 当前光标的四个角点 (kitty的corner_index逻辑)
    vec2 curr_corners[4];
    curr_corners[0] = vec2(currentCursor.x + currentCursor.z, currentCursor.y); // 右上 [1,0]
    curr_corners[1] = vec2(currentCursor.x + currentCursor.z, currentCursor.y - currentCursor.w); // 右下 [1,1]
    curr_corners[2] = vec2(currentCursor.x, currentCursor.y - currentCursor.w); // 左下 [0,1]
    curr_corners[3] = vec2(currentCursor.x, currentCursor.y); // 左上 [0,0]

    // 计算光标中心和对角线长度（用于dot product计算）
    vec2 curr_center = getRectangleCenter(currentCursor);
    float cursor_diag_2 = length(vec2(currentCursor.z, currentCursor.w)) * 0.5;

    // 实际经过的时间（秒）- 这是关键！
    float dt = iTime - iTimeCursorChange;
    
    // 如果时间太长，直接使用当前光标位置（避免无限拖尾）
    if (dt > 1.0) {
        fragColor = fragColor;
        return;
    }

    // 模拟kitty的四角点物理运动
    vec2 trail_corners[4];
    for (int i = 0; i < 4; i++) {
        vec2 prev_pos = (i == 0) ? vec2(previousCursor.x + previousCursor.z, previousCursor.y) :
                       (i == 1) ? vec2(previousCursor.x + previousCursor.z, previousCursor.y - previousCursor.w) :
                       (i == 2) ? vec2(previousCursor.x, previousCursor.y - previousCursor.w) :
                                  vec2(previousCursor.x, previousCursor.y);

        vec2 dx = curr_corners[i] - prev_pos;
        
        // 如果距离很小，直接使用目标位置
        if (length(dx) < 1e-6) {
            trail_corners[i] = curr_corners[i];
            continue;
        }

        // kitty的dot product计算 - 确定这个角点相对于移动方向的位置
        float dot_product = dot(dx, (curr_corners[i] - curr_center)) / (cursor_diag_2 * length(dx));
        
        // 根据dot product在fast和slow decay之间插值
        float decay = mix(DECAY_SLOW, DECAY_FAST, clamp(dot_product, 0.0, 1.0));
        
        // kitty的核心公式：step = 1.0 - exp2(-10.0 * dt / decay)
        float step = 1.0 - exp2(-10.0 * dt / decay);
        
        // 更新角点位置
        trail_corners[i] = prev_pos + dx * step;
    }

    // 渲染
    float sdfTrail = getSdfQuad(vu, trail_corners[0], trail_corners[1], trail_corners[2], trail_corners[3]);
    float sdfCursor = getSdfRectangle(vu, currentCursor.xy - (currentCursor.zw * offsetFactor), currentCursor.zw * 0.5);

    vec4 newColor = fragColor;
    
    // 简单的透明度计算 - kitty风格的快速衰减
    float opacity_factor = 1.0;
    if (dt > 0.1) {
        opacity_factor = max(0.0, 1.0 - (dt - 0.1) / 0.2); // 0.1秒后开始快速淡出
    }
    
    float trailAlpha = antialising(sdfTrail) * OPACITY * opacity_factor;
    newColor = mix(newColor, TRAIL_COLOR, trailAlpha);
    
    // 确保光标本身不被遮挡
    fragColor = mix(newColor, fragColor, step(sdfCursor, 0.0));
}
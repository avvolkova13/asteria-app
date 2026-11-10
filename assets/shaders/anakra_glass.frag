#include <flutter/runtime_effect.glsl>
precision highp float;
uniform vec2 uSize;
uniform vec2 uScreen;
uniform vec2 uOrigin;
uniform vec4 uTint;
uniform float uRadius;
uniform float uLight;
uniform vec2 uImageSize;
uniform sampler2D uBackground;
out vec4 fragColor;

vec3 backdrop(vec2 p) {
  float scale = max(uScreen.x / uImageSize.x, uScreen.y / uImageSize.y);
  vec2 uv = (p + (uImageSize * scale - uScreen) * 0.5) / (uImageSize * scale);
  vec4 texel = texture(uBackground, clamp(uv, 0.0, 1.0));
  return texel.rgb + vec3(15.0, 10.0, 26.0) / 255.0 * (1.0 - texel.a);
}

void main() {
  vec2 p = FlutterFragCoord().xy;
  float radius = min(uRadius, min(uSize.x, uSize.y) * 0.5);
  vec2 q = abs(p - uSize * 0.5) - (uSize * 0.5 - radius);
  float distance = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;
  vec2 normal = normalize((max(q, 0.0) + 0.001) * sign(p - uSize * 0.5));
  float edge = exp(-abs(distance) / 3.0);
  vec2 samplePoint = uOrigin + p - normal * edge * 16.0;
  // Frost the static page backdrop, leaving text and controls crisp.
  vec3 color = backdrop(samplePoint) * 0.4;
  color += backdrop(samplePoint + vec2(3.5, 0.0)) * 0.15;
  color += backdrop(samplePoint - vec2(3.5, 0.0)) * 0.15;
  color += backdrop(samplePoint + vec2(0.0, 3.5)) * 0.15;
  color += backdrop(samplePoint - vec2(0.0, 3.5)) * 0.15;
  color = mix(color, uTint.rgb, uTint.a);
  float light = max(dot(normal, normalize(vec2(-1.0, -1.0))), 0.0);
  color += vec3(1.0) * light * exp(-abs(distance) * 1.3) * uLight * 0.55;
  fragColor = vec4(color, 1.0);
}

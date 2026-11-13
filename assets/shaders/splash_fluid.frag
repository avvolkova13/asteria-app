#include <flutter/runtime_effect.glsl>
uniform vec2 size;
uniform float time;
out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / size;
  vec2 p = vec2((uv.x - 0.5) * size.x / size.y, uv.y - 0.43);
  float t = time * 0.8;
  // Two lengths of fabric turning across one another; no screen-space texture.
  float x = p.x + 0.048 * sin(p.y * 8.0 - t * 0.75);
  float bend = sin(x * 6.2 + t * 0.75 + 0.70 * sin(p.y * 4.8 - t * 0.47));
  float fold = p.y * 8.9 + 1.15 * bend + 0.85 * sin(x * 9.5 - p.y * 3.0 - t * 0.55) - t * 0.6;
  float wide = 0.5 + 0.5 * cos(fold);
  float silk = smoothstep(0.21, 1.0, wide);
  float light = 0.5 + 0.5 * sin(p.x * 6.0 + p.y * 6.7 + t * 0.65);
  vec3 col = mix(vec3(0.077,0.060,0.125), vec3(0.210,0.147,0.272), silk);
  col += vec3(0.22,0.155,0.205) * pow(wide, 3.8) * (0.32 + 0.68 * light);
  float reveal = smoothstep(0.0, 0.62, time);
  // Fixed spatial dither keeps the dark gradients smooth without temporal noise.
  float grain = fract(52.9829189 * fract(dot(floor(uv * size * 2.0),vec2(0.06711056,0.00583715)))) - 0.5;
  fragColor = vec4(mix(vec3(16.,13.,28.) / 255., col + grain / 255., reveal),1.);
}

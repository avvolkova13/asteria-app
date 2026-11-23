#include <flutter/runtime_effect.glsl>
precision highp float;

uniform vec2 uSize;
uniform float phase;
uniform float isBloom;
uniform sampler2D artwork;
out vec4 fragColor;

vec4 readArt(vec2 p) {
  if (any(lessThan(p, vec2(0.))) || any(greaterThan(p, vec2(1.)))) {
    return vec4(0.);
  }
  return texture(artwork, p);
}

vec2 petal(vec2 at, vec2 center, vec2 radius, vec2 travel, float lag) {
  vec2 delta = (at - center) / radius;
  float influence = 1. - smoothstep(0., 1., dot(delta, delta));
  return travel * influence * (.5 - .5 * cos(phase - lag));
}

vec4 bloom(vec2 at) {
  vec2 source = at;
  source += petal(at, vec2(.19, .60), vec2(.27, .27), vec2(.16, .065), .1);
  source += petal(at, vec2(.82, .56), vec2(.27, .28), vec2(-.15, .052), .38);
  source += petal(at, vec2(.27, .30), vec2(.25, .28), vec2(.09, .06), .52);
  source += petal(at, vec2(.73, .32), vec2(.25, .28), vec2(-.09, .053), .65);
  source += petal(at, vec2(.48, .20), vec2(.22, .27), vec2(.01, .045), .80);
  // Keep the pearl round while the surrounding petals bend.
  float petalWeight = smoothstep(.105, .24, length((at - vec2(.52, .54)) * vec2(1., 1.2)));
  return readArt(mix(at, source, petalWeight));
}

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  vec2 at = (uv - .5) / .88 + .5;
  // The morning scene moves the entire sprite together in PlayerArtwork.
  fragColor = isBloom > .5 ? bloom(at) : readArt(at);
}

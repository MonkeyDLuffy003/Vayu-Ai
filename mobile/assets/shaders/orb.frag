#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform float uEnergy;
uniform vec3 uColor;

out vec4 fragColor;

void main() {
  vec2 uv = (FlutterFragCoord().xy - 0.5 * uResolution) / min(uResolution.x, uResolution.y);
  float dist = length(uv);

  float pulse = 0.5 + 0.5 * sin(uTime * 2.0 + uEnergy * 6.0);
  float core = smoothstep(0.32, 0.0, dist) * (0.6 + 0.4 * pulse);

  float angle = atan(uv.y, uv.x);
  float rim = smoothstep(0.42, 0.38, dist) - smoothstep(0.38, 0.34, dist);
  rim *= 0.5 + 0.5 * sin(angle * 8.0 - uTime * 3.0 * (0.3 + uEnergy));

  float glow = smoothstep(0.5, 0.0, dist) * 0.25;

  float alpha = clamp(core + rim + glow, 0.0, 1.0);
  vec3 color = uColor * (0.7 + 0.3 * uEnergy) * alpha;

  fragColor = vec4(color, alpha);
}

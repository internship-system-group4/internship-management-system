import * as THREE from 'three';
import { RoomEnvironment } from 'three/examples/jsm/environments/RoomEnvironment.js';
import { EffectComposer } from 'three/examples/jsm/postprocessing/EffectComposer.js';
import { RenderPass } from 'three/examples/jsm/postprocessing/RenderPass.js';
import { BokehPass } from 'three/examples/jsm/postprocessing/BokehPass.js';
import { UnrealBloomPass } from 'three/examples/jsm/postprocessing/UnrealBloomPass.js';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';

export type ProceduralModelOptions = {
  wireframe?: boolean;
  castShadow?: boolean;
  receiveShadow?: boolean;
  textureSize?: number;
  textureAnisotropy?: number;
  qualityPriority?: 'reference-fidelity' | 'balanced';
};

export type ProceduralModelRuntime = {
  nodes: Record<string, THREE.Object3D>;
  meshes: Record<string, THREE.Mesh>;
  sockets: Record<string, THREE.Object3D>;
  colliders: Record<string, unknown>;
  destructionGroups: Record<string, THREE.Object3D[]>;
};

type SculptMaterialSpec = Record<string, any>;

function hashString(value: string): number {
  let hash = 2166136261;
  for (let index = 0; index < value.length; index += 1) {
    hash ^= value.charCodeAt(index);
    hash = Math.imul(hash, 16777619);
  }
  return hash >>> 0;
}

function readLayerNumber(value: unknown, keys: string[], fallback: number): number {
  if (typeof value === 'number') return value;
  if (value && typeof value === 'object') {
    const record = value as Record<string, unknown>;
    for (const key of keys) {
      if (typeof record[key] === 'number') return record[key] as number;
    }
  }
  return fallback;
}

function hexToRgb(hex: string): [number, number, number] {
  const normalized = /^#[0-9a-f]{3}$/i.test(hex)
    ? '#' + hex.slice(1).split('').map((part) => part + part).join('')
    : hex;
  const value = /^#[0-9a-f]{6}$/i.test(normalized) ? Number.parseInt(normalized.slice(1), 16) : 0x8a7a5f;
  return [clampAlbedoChannel((value >> 16) & 255), clampAlbedoChannel((value >> 8) & 255), clampAlbedoChannel(value & 255)];
}

function materialPalette(spec: SculptMaterialSpec): string[] {
  const palette = spec.colorVariation?.palette;
  if (Array.isArray(palette) && palette.length > 0) return palette.filter((value) => typeof value === 'string');
  const secondary = spec.albedo?.secondary;
  const colors = [spec.baseColor ?? spec.color ?? spec.albedo?.dominant, ...(Array.isArray(secondary) ? secondary : [])];
  return colors.filter((value): value is string => typeof value === 'string' && value.startsWith('#'));
}

function clamp01(value: number): number {
  return Math.max(0, Math.min(1, value));
}

function clampAlbedoChannel(value: number): number {
  return Math.max(30, Math.min(240, Math.round(value)));
}

function clampPbrF0(value: number): number {
  return Math.max(0.02, Math.min(1, value));
}

function clampPbrIor(value: number): number {
  return Math.max(1, Math.min(2.5, value));
}

function clampPbrMetalness(value: number): number {
  return value >= 0.5 ? 1 : 0;
}

function clampedAlbedoColor(spec: SculptMaterialSpec): THREE.Color {
  const source = typeof spec.baseColor === 'string' ? spec.baseColor : '#8A7A5F';
  // setStyle with an explicit SRGBColorSpace, NOT the numeric constructor.
  //
  // `new THREE.Color(r, g, b)` treats its arguments as LINEAR working-space components,
  // while an authored `baseColor` hex is sRGB. Feeding one to the other skipped the
  // transfer function and lifted every dark albedo: #2e2a28, authored as a near-black
  // vinyl, rendered at roughly sRGB 0.46 — a mid grey. The error is largest exactly where
  // it matters most, because the transfer curve is steepest near black.
  return new THREE.Color().setStyle(source, THREE.SRGBColorSpace);
}

function smoothCurve(value: number): number {
  return value * value * (3 - 2 * value);
}

function periodicHash(x: number, y: number, seed: number, periodX: number, periodY: number): number {
  const wrappedX = ((x % periodX) + periodX) % periodX;
  const wrappedY = ((y % periodY) + periodY) % periodY;
  let value = Math.imul(wrappedX + seed * 17, 374761393) ^ Math.imul(wrappedY + seed * 31, 668265263);
  value = Math.imul(value ^ (value >>> 13), 1274126177);
  return ((value ^ (value >>> 16)) >>> 0) / 4294967295;
}

function periodicValueNoise(u: number, v: number, seed: number, periodX: number, periodY: number): number {
  const x = u * periodX;
  const y = v * periodY;
  const x0 = Math.floor(x);
  const y0 = Math.floor(y);
  const tx = smoothCurve(x - x0);
  const ty = smoothCurve(y - y0);
  const a = periodicHash(x0, y0, seed, periodX, periodY);
  const b = periodicHash(x0 + 1, y0, seed, periodX, periodY);
  const c = periodicHash(x0, y0 + 1, seed, periodX, periodY);
  const d = periodicHash(x0 + 1, y0 + 1, seed, periodX, periodY);
  return THREE.MathUtils.lerp(THREE.MathUtils.lerp(a, b, tx), THREE.MathUtils.lerp(c, d, tx), ty);
}

type SurfaceBand = {
  frequency: number;
  amplitude: number;
  stretchX: number;
  stretchY: number;
  ridge: boolean;
};

function surfaceBands(spec: SculptMaterialSpec): SurfaceBand[] {
  const source = Array.isArray(spec.surfaceFrequencyBands) ? spec.surfaceFrequencyBands : [];
  const parsed = source.flatMap((item: unknown) => {
    if (!item || typeof item !== 'object') return [];
    const band = item as Record<string, unknown>;
    const frequency = typeof band.frequency === 'number' ? band.frequency : 0;
    const amplitude = typeof band.amplitude === 'number' ? band.amplitude : 0;
    if (frequency <= 0 || amplitude <= 0) return [];
    const stretch = Array.isArray(band.stretch) ? band.stretch : [1, 1];
    const description = `${String(band.pattern ?? '')} ${String(band.role ?? '')}`.toLowerCase();
    return [{
      frequency,
      amplitude,
      stretchX: typeof stretch[0] === 'number' ? Math.max(0.1, stretch[0]) : 1,
      stretchY: typeof stretch[1] === 'number' ? Math.max(0.1, stretch[1]) : 1,
      ridge: /(ridge|groove|grain|fiber|striated|crack)/.test(description),
    }];
  });
  return parsed.length > 0 ? parsed : [
    { frequency: 2, amplitude: 0.42, stretchX: 1, stretchY: 1, ridge: false },
    { frequency: 12, amplitude: 0.22, stretchX: 1, stretchY: 1, ridge: false },
    { frequency: 56, amplitude: 0.08, stretchX: 1, stretchY: 1, ridge: false },
  ];
}

function sampleSurface(u: number, v: number, bands: SurfaceBand[], seed: number): number {
  let value = 0;
  let weight = 0;
  for (let index = 0; index < bands.length; index += 1) {
    const band = bands[index];
    const periodX = Math.max(1, Math.round(band.frequency * band.stretchX));
    const periodY = Math.max(1, Math.round(band.frequency * band.stretchY));
    let sample = periodicValueNoise(u, v, seed + index * 1013, periodX, periodY);
    if (band.ridge) sample = 1 - Math.abs(sample * 2 - 1);
    value += sample * band.amplitude;
    weight += band.amplitude;
  }
  return weight > 0 ? clamp01(value / weight) : 0.5;
}

function mixPalette(colors: [number, number, number][], value: number): [number, number, number] {
  if (colors.length === 1) return colors[0];
  const scaled = clamp01(value) * (colors.length - 1);
  const index = Math.min(colors.length - 2, Math.floor(scaled));
  const mix = scaled - index;
  const a = colors[index];
  const b = colors[index + 1];
  return [
    Math.round(THREE.MathUtils.lerp(a[0], b[0], mix)),
    Math.round(THREE.MathUtils.lerp(a[1], b[1], mix)),
    Math.round(THREE.MathUtils.lerp(a[2], b[2], mix)),
  ];
}

type ColorGradientStop = { offset: number; color: string };
type ColorGradientSpec = {
  type: 'linear' | 'radial';
  axis: [number, number];
  stops: ColorGradientStop[];
};

function parseRgba(value: string): [number, number, number] {
  const match = /rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)/.exec(value);
  if (!match) return [138, 122, 95];
  return [clampAlbedoChannel(Number(match[1])), clampAlbedoChannel(Number(match[2])), clampAlbedoChannel(Number(match[3]))];
}

// Analytical per-pixel gradient sample. The extraction schema's colorGradient carries
// exact rgba(...) stop colors (see extract_part_color_recipe.py), so this samples the
// same trend directly in JS math rather than round-tripping through a Canvas 2D
// createLinearGradient/createRadialGradient object — same visual result, and it composes
// directly with the existing noise/height-correlated colorVariation blend below.
function sampleColorGradient(gradient: ColorGradientSpec, u: number, v: number): [number, number, number] {
  const stops = gradient.stops.length >= 2 ? gradient.stops : [{ offset: 0, color: 'rgba(138,122,95,1)' }, { offset: 1, color: 'rgba(138,122,95,1)' }];
  let t: number;
  if (gradient.type === 'radial') {
    const [cx, cy] = gradient.axis;
    const dx = u - cx;
    const dy = v - cy;
    const maxRadius = Math.max(0.001, Math.hypot(Math.max(cx, 1 - cx), Math.max(cy, 1 - cy)));
    t = clamp01(Math.hypot(dx, dy) / maxRadius);
  } else {
    const [ax, ay] = gradient.axis;
    const projection = (u - 0.5) * ax + (v - 0.5) * ay;
    const maxProjection = 0.5 * (Math.abs(ax) + Math.abs(ay)) || 0.5;
    t = clamp01(projection / maxProjection + 0.5);
  }
  const scaled = t * (stops.length - 1);
  const index = Math.min(stops.length - 2, Math.max(0, Math.floor(scaled)));
  const mix = scaled - index;
  const a = parseRgba(stops[index].color);
  const b = parseRgba(stops[index + 1].color);
  return [
    THREE.MathUtils.lerp(a[0], b[0], mix),
    THREE.MathUtils.lerp(a[1], b[1], mix),
    THREE.MathUtils.lerp(a[2], b[2], mix),
  ];
}

function writePixel(data: Uint8ClampedArray, offset: number, red: number, green: number, blue: number): void {
  data[offset] = Math.max(0, Math.min(255, Math.round(red)));
  data[offset + 1] = Math.max(0, Math.min(255, Math.round(green)));
  data[offset + 2] = Math.max(0, Math.min(255, Math.round(blue)));
  data[offset + 3] = 255;
}

function makeCanvas(size: number): HTMLCanvasElement {
  const canvas = document.createElement('canvas');
  canvas.width = size;
  canvas.height = size;
  return canvas;
}

function createMapTexture(
  canvas: HTMLCanvasElement,
  colorSpace: THREE.ColorSpace,
  spec: SculptMaterialSpec,
  options: ProceduralModelOptions,
): THREE.CanvasTexture {
  const texture = new THREE.CanvasTexture(canvas);
  const projection = spec.textureProjection && typeof spec.textureProjection === 'object' ? spec.textureProjection : {};
  const repeat = Array.isArray(projection.repeat) ? projection.repeat : [2, 2];
  texture.colorSpace = colorSpace;
  texture.wrapS = THREE.RepeatWrapping;
  texture.wrapT = THREE.RepeatWrapping;
  texture.repeat.set(
    typeof repeat[0] === 'number' ? repeat[0] : 2,
    typeof repeat[1] === 'number' ? repeat[1] : 2,
  );
  texture.anisotropy = Math.max(1, Math.round(options.textureAnisotropy ?? projection.anisotropy ?? 8));
  texture.needsUpdate = true;
  return texture;
}

type ProceduralTextureSet = {
  albedo: THREE.Texture;
  roughness: THREE.Texture;
  height: THREE.Texture;
  normal: THREE.Texture;
  ao: THREE.Texture;
  source: 'reference-pixel-extraction' | 'procedural';
};

function referenceMapUrl(spec: SculptMaterialSpec, channel: string): string | null {
  const reference = spec.referencePbr;
  if (!reference || typeof reference !== 'object') return null;
  if (reference.usable === false) return null;
  const confidence = typeof reference.confidence === 'number'
    ? reference.confidence
    : (typeof reference.estimatedFidelity === 'number' ? reference.estimatedFidelity : 0);
  const threshold = typeof reference.targetThreshold === 'number' ? reference.targetThreshold : 0.7;
  if (confidence < threshold) return null;
  const maps = reference.maps;
  if (!maps || typeof maps !== 'object') return null;
  const map = (maps as Record<string, unknown>)[channel];
  if (!map || typeof map !== 'object') return null;
  const record = map as Record<string, unknown>;
  const url = typeof record.url === 'string' && record.url.trim() ? record.url : record.path;
  return typeof url === 'string' && url.trim() ? url : null;
}

function createLoadedMapTexture(
  url: string,
  colorSpace: THREE.ColorSpace,
  spec: SculptMaterialSpec,
  options: ProceduralModelOptions,
): THREE.Texture {
  const texture = new THREE.TextureLoader().load(url);
  const projection = spec.textureProjection && typeof spec.textureProjection === 'object' ? spec.textureProjection : {};
  const repeat = Array.isArray(projection.repeat) ? projection.repeat : [1, 1];
  texture.colorSpace = colorSpace;
  texture.wrapS = THREE.RepeatWrapping;
  texture.wrapT = THREE.RepeatWrapping;
  texture.repeat.set(
    typeof repeat[0] === 'number' ? repeat[0] : 1,
    typeof repeat[1] === 'number' ? repeat[1] : 1,
  );
  texture.anisotropy = Math.max(1, Math.round(options.textureAnisotropy ?? projection.anisotropy ?? 8));
  texture.needsUpdate = true;
  return texture;
}

function makeReferenceTextureSet(spec: SculptMaterialSpec, options: ProceduralModelOptions): ProceduralTextureSet | null {
  const albedo = referenceMapUrl(spec, 'albedo');
  const roughness = referenceMapUrl(spec, 'roughness');
  const height = referenceMapUrl(spec, 'height');
  const normal = referenceMapUrl(spec, 'normal');
  const ao = referenceMapUrl(spec, 'ao');
  if (!albedo || !roughness || !height || !normal || !ao) return null;
  return {
    albedo: createLoadedMapTexture(albedo, THREE.SRGBColorSpace, spec, options),
    roughness: createLoadedMapTexture(roughness, THREE.NoColorSpace, spec, options),
    height: createLoadedMapTexture(height, THREE.NoColorSpace, spec, options),
    normal: createLoadedMapTexture(normal, THREE.NoColorSpace, spec, options),
    ao: createLoadedMapTexture(ao, THREE.NoColorSpace, spec, options),
    source: 'reference-pixel-extraction',
  };
}

function makeProceduralTextureSet(
  id: string,
  spec: SculptMaterialSpec,
  options: ProceduralModelOptions,
): ProceduralTextureSet | null {
  if (typeof document === 'undefined') return null;
  const qualityFirst = (options.qualityPriority ?? 'reference-fidelity') === 'reference-fidelity';
  const requested = options.textureSize ?? spec.textureResolution;
  const requestedSize = typeof requested === 'number' && Number.isFinite(requested)
    ? requested
    : (qualityFirst ? 1024 : 512);
  const size = Math.max(256, Math.min(2048, 2 ** Math.round(Math.log2(requestedSize))));
  const canvases = {
    albedo: makeCanvas(size),
    roughness: makeCanvas(size),
    height: makeCanvas(size),
    normal: makeCanvas(size),
    ao: makeCanvas(size),
  };
  const contexts = {
    albedo: canvases.albedo.getContext('2d'),
    roughness: canvases.roughness.getContext('2d'),
    height: canvases.height.getContext('2d'),
    normal: canvases.normal.getContext('2d'),
    ao: canvases.ao.getContext('2d'),
  };
  if (!contexts.albedo || !contexts.roughness || !contexts.height || !contexts.normal || !contexts.ao) return null;
  const images = {
    albedo: contexts.albedo.createImageData(size, size),
    roughness: contexts.roughness.createImageData(size, size),
    height: contexts.height.createImageData(size, size),
    normal: contexts.normal.createImageData(size, size),
    ao: contexts.ao.createImageData(size, size),
  };
  const seed = hashString(id);
  const bands = surfaceBands(spec);
  const heightField = new Float32Array(size * size);
  const roughnessField = new Float32Array(size * size);
  const palette = materialPalette(spec);
  const fallback = typeof spec.baseColor === 'string' ? spec.baseColor : '#8A7A5F';
  const colors = (palette.length >= 2 ? palette : [fallback, '#6E614B', '#A08F70']).map(hexToRgb);
  const baseRoughness = clamp01(readLayerNumber(spec.roughness, ['base'], 0.76));
  const roughnessVariation = clamp01(readLayerNumber(spec.roughness, ['variation'], 0.18));
  const colorAmplitude = clamp01(readLayerNumber(spec.colorVariation, ['amplitude', 'variation'], 0.18));
  const heightCorrelation = clamp01(readLayerNumber(spec.colorVariation, ['heightCorrelation'], 0.3));
  const colorGradient: ColorGradientSpec | undefined = spec.colorGradient;
  for (let y = 0; y < size; y += 1) {
    const v = y / size;
    for (let x = 0; x < size; x += 1) {
      const u = x / size;
      const index = y * size + x;
      const height = sampleSurface(u, v, bands, seed + 101);
      const roughNoise = sampleSurface(u, v, bands, seed + 7001);
      const colorNoise = sampleSurface(u, v, bands, seed + 15013);
      heightField[index] = height;
      roughnessField[index] = clamp01(baseRoughness + (roughNoise - 0.5) * roughnessVariation * 2);
      let color: [number, number, number];
      if (colorGradient) {
        // Evidence-derived spatial gradient (Plan 1.3 Workstream C) takes priority
        // over the noise-based palette blend below — it is a measured trend, not a guess.
        color = sampleColorGradient(colorGradient, u, v);
      } else {
        const paletteValue = clamp01(
          0.5 + (colorNoise - 0.5) * colorAmplitude * 2 + (height - 0.5) * heightCorrelation
        );
        color = mixPalette(colors, paletteValue);
      }
      writePixel(images.albedo.data, index * 4, color[0], color[1], color[2]);
    }
  }
  const normalStrength = Math.max(0.05, readLayerNumber(spec.normal, ['strength', 'amplitude'], 0.35));
  const aoStrength = clamp01(readLayerNumber(spec.ambientOcclusion, ['cavityStrength', 'strength'], 0.35));
  for (let y = 0; y < size; y += 1) {
    const up = ((y - 1 + size) % size) * size;
    const down = ((y + 1) % size) * size;
    for (let x = 0; x < size; x += 1) {
      const left = (x - 1 + size) % size;
      const right = (x + 1) % size;
      const index = y * size + x;
      const center = heightField[index];
      const dx = (heightField[y * size + right] - heightField[y * size + left]) * normalStrength * 6;
      const dy = (heightField[down + x] - heightField[up + x]) * normalStrength * 6;
      const inverseLength = 1 / Math.sqrt(dx * dx + dy * dy + 1);
      const normalX = -dx * inverseLength;
      const normalY = -dy * inverseLength;
      const normalZ = inverseLength;
      const neighborAverage = (
        heightField[y * size + left] + heightField[y * size + right]
        + heightField[up + x] + heightField[down + x]
      ) * 0.25;
      const cavity = Math.max(0, neighborAverage - center);
      const ao = clamp01(1 - aoStrength * (cavity * 12 + (1 - center) * 0.16));
      const offset = index * 4;
      const heightByte = center * 255;
      const roughnessByte = roughnessField[index] * 255;
      writePixel(images.height.data, offset, heightByte, heightByte, heightByte);
      writePixel(images.roughness.data, offset, roughnessByte, roughnessByte, roughnessByte);
      writePixel(
        images.normal.data, offset,
        (normalX * 0.5 + 0.5) * 255,
        (normalY * 0.5 + 0.5) * 255,
        (normalZ * 0.5 + 0.5) * 255,
      );
      writePixel(images.ao.data, offset, ao * 255, ao * 255, ao * 255);
    }
  }
  contexts.albedo.putImageData(images.albedo, 0, 0);
  contexts.roughness.putImageData(images.roughness, 0, 0);
  contexts.height.putImageData(images.height, 0, 0);
  contexts.normal.putImageData(images.normal, 0, 0);
  contexts.ao.putImageData(images.ao, 0, 0);
  return {
    albedo: createMapTexture(canvases.albedo, THREE.SRGBColorSpace, spec, options),
    roughness: createMapTexture(canvases.roughness, THREE.NoColorSpace, spec, options),
    height: createMapTexture(canvases.height, THREE.NoColorSpace, spec, options),
    normal: createMapTexture(canvases.normal, THREE.NoColorSpace, spec, options),
    ao: createMapTexture(canvases.ao, THREE.NoColorSpace, spec, options),
    source: 'procedural',
  };
}

function createSculptMaterial(id: string, spec: SculptMaterialSpec, options: ProceduralModelOptions, denseComponent = false): THREE.MeshPhysicalMaterial {
  // A material that declares -- with evidence -- that its subject carries no texture
  // detail gets NO texture set. Synthesising one anyway is not a harmless default: the
  // branch below then forces color to white and roughness to 1 and reads both from the
  // generated maps, so the authored albedo and the reference-derived roughness are both
  // discarded, and the model gains mottling the reference does not have. Measured on the
  // tuxedo cat, whose black fur rendered as speckled grey-and-white from a palette that
  // only ever described two flat regions.
  const textureless = (spec.textureless as { declared?: boolean } | undefined)?.declared === true;
  const textures = textureless
    ? null
    : makeReferenceTextureSet(spec, options) ?? makeProceduralTextureSet(id, spec, options);
  const material = new THREE.MeshPhysicalMaterial({
    color: textures ? 0xffffff : clampedAlbedoColor(spec),
    roughness: textures ? 1 : clamp01(readLayerNumber(spec.roughness, ['base'], 0.76)),
    metalness: clampPbrMetalness(readLayerNumber(spec.metalness, ['base'], 0.0)),
    clearcoat: clamp01(readLayerNumber(spec.clearcoat, ['base', 'amount'], 0)),
    clearcoatRoughness: clamp01(readLayerNumber(spec.clearcoatRoughness, ['base'], 0.25)),
    transmission: clamp01(readLayerNumber(spec.transmission, ['base', 'amount'], 0)),
    ior: clampPbrIor(readLayerNumber(spec.ior, ['base', 'value'], 1.5)),
    thickness: Math.max(0, readLayerNumber(spec.thickness, ['base', 'amount'], 0)),
    attenuationDistance: Math.max(0.001, readLayerNumber(spec.attenuationDistance, ['base', 'value'], Infinity)),
    attenuationColor: new THREE.Color(typeof spec.attenuationColor === 'string' ? spec.attenuationColor : '#ffffff'),
    sheen: clamp01(readLayerNumber(spec.sheen, ['base', 'amount'], 0)),
    sheenColor: new THREE.Color(typeof spec.sheenColor === 'string' ? spec.sheenColor : '#ffffff'),
    sheenRoughness: clamp01(readLayerNumber(spec.sheenRoughness, ['base'], 1.0)),
    iridescence: clamp01(readLayerNumber(spec.iridescence, ['base', 'amount'], 0)),
    iridescenceIOR: clampPbrIor(readLayerNumber(spec.iridescenceIOR, ['base', 'value'], 1.3)),
    anisotropy: clamp01(readLayerNumber(spec.anisotropy, ['base', 'amount'], 0)),
    anisotropyRotation: readLayerNumber(spec.anisotropy, ['rotation'], 0),
    specularIntensity: clampPbrF0(readLayerNumber(spec.specularF0 ?? spec.f0 ?? spec.specularIntensity, ['base', 'value'], 1.0)),
    specularColor: new THREE.Color(typeof spec.specularColor === 'string' ? spec.specularColor : '#ffffff'),
    emissive: new THREE.Color(typeof spec.emissive === 'string' ? spec.emissive : '#000000'),
    emissiveIntensity: Math.max(0, readLayerNumber(spec.emissiveIntensity, ['base'], 1.0)),
    opacity: clamp01(readLayerNumber(spec.opacity, ['base'], 1)),
    transparent: readLayerNumber(spec.transmission, ['base', 'amount'], 0) > 0 || readLayerNumber(spec.opacity, ['base'], 1) < 1,
    alphaTest: Math.max(0, readLayerNumber(spec.alpha, ['cutoff', 'alphaTest'], 0)),
    wireframe: options.wireframe ?? false,
    side: spec.doubleSided === true ? THREE.DoubleSide : THREE.FrontSide,
    flatShading: spec.flatShading === true,
  });
  if (textures) {
    material.map = textures.albedo;
    material.roughnessMap = textures.roughness;
    material.normalMap = textures.normal;
    material.normalScale.setScalar(Math.max(0.05, readLayerNumber(spec.normal, ['strength', 'amplitude'], 0.35)));
    material.aoMap = textures.ao;
    material.aoMap.channel = 0;
    material.aoMapIntensity = readLayerNumber(spec.ambientOcclusion, ['cavityStrength', 'strength'], 0.35);
    const denseMesh = denseComponent || spec.denseMesh === true || spec.geometryDensity === 'dense' || spec.topologyClass === 'dense';
    const bumpScale = Math.max(0, readLayerNumber(spec.bump, ['amplitude', 'strength'], 0));
    const effectiveBumpScale = denseMesh ? Math.max(0.05, bumpScale) : bumpScale;
    if (effectiveBumpScale > 0) {
      material.bumpMap = textures.height;
      material.bumpScale = effectiveBumpScale;
    }
    const displacementScale = Math.max(0, readLayerNumber(spec.displacement, ['amplitude', 'strength'], 0));
    const effectiveDisplacementScale = denseMesh ? Math.max(0.005, displacementScale) : displacementScale;
    if (effectiveDisplacementScale > 0) {
      material.displacementMap = textures.height;
      material.displacementScale = effectiveDisplacementScale;
      material.displacementBias = -effectiveDisplacementScale * 0.5;
    }
  }
  material.envMapIntensity = readLayerNumber(spec, ['envMapIntensity'], 0.8);
  material.userData.sculptMaterial = spec;
  material.userData.proceduralMapsIndependent = true;
  material.userData.pbrConstraints = { albedoRange: [30, 240], binaryMetalness: true, f0Range: [0.02, 1], iorRange: [1, 2.5] };
  material.userData.pbrTextureSource = textures?.source ?? 'flat-fallback';
  material.userData.referencePbr = spec.referencePbr ?? null;
  material.userData.referenceMaterialId = spec.referenceMaterialId ?? spec.materialReference?.profileId ?? null;
  material.userData.materialEvidence = spec.materialEvidence ?? null;
  material.userData.validationViews = spec.materialReference?.validationViews ?? [];
  material.needsUpdate = true;
  return material;
}

type AttachmentEndpoint = {
  start: THREE.Vector3;
  midpoint: THREE.Vector3;
  quaternion: THREE.Quaternion;
  length: number;
  baseRadius: number;
  endRadius: number;
};

function readVector3(value: unknown, fallback: [number, number, number]): THREE.Vector3 {
  if (Array.isArray(value) && value.length === 3 && value.every((item) => typeof item === 'number')) {
    return new THREE.Vector3(value[0], value[1], value[2]);
  }
  return new THREE.Vector3(fallback[0], fallback[1], fallback[2]);
}

function readNumber(value: unknown, fallback: number): number {
  return typeof value === 'number' && Number.isFinite(value) ? value : fallback;
}

function makeAttachmentEndpoint(attachment: unknown): AttachmentEndpoint | null {
  if (!attachment || typeof attachment !== 'object') return null;
  const record = attachment as Record<string, unknown>;
  const start = readVector3(record.localStart, [0, 0, 0]);
  const end = readVector3(record.localEnd, [0, 1, 0]);
  const delta = end.clone().sub(start);
  const length = delta.length();
  if (length <= 0.0001) return null;
  const direction = delta.clone().normalize();
  const quaternion = new THREE.Quaternion().setFromUnitVectors(new THREE.Vector3(0, 1, 0), direction);
  const baseRadius = Math.max(0.005, readNumber(record.baseRadius, 0.06));
  const endRadius = Math.max(0.003, readNumber(record.endRadius, baseRadius * 0.55));
  return {
    start,
    midpoint: delta.multiplyScalar(0.5),
    quaternion,
    length,
    baseRadius,
    endRadius,
  };
}

// Generated from ObjectSculptSpec target: GJU Courtyard Waterwheel
// Sculpt build pass: blockout
// This factory is intentionally pass-gated. Finish browser screenshot review before unlocking deeper passes.
export function createGJUCourtyardWaterwheelModel(options: ProceduralModelOptions = {}): THREE.Group {
  const root = new THREE.Group();
  root.name = "GJU Courtyard Waterwheel";
  root.userData.reconstructionEvidence = {"itemFamily": null, "subtype": null, "componentAdapter": null, "route": null, "exactnessTier": null, "referenceCamera": {"solved": false, "fovDegrees": 38, "aspect": 1.0, "orientation": {"yaw": 0.0, "pitch": 0.0, "roll": 0.0}, "positionHint": [10, 7.2, 14], "note": "Three-quarter view, wheel face prominent; camera chosen for hero composition rather than exact photograph pose."}, "approximationNotes": []};
  root.userData.materialPipeline = {};
  root.userData.materialReferenceRegistry = null;

  const materialMap: Record<string, THREE.Material> = {};
  materialMap["stone"] = createSculptMaterial(
    "stone",
    {"id": "stone", "name": "stone", "type": "standard", "shaderModel": "MeshStandardMaterial / PBR approximation", "baseColor": "#c9b58f", "color": "#c9b58f", "albedo": {"dominant": "#DCB899", "secondary": ["#E0C1A6", "#D5AE8C", "#E7CDB6"], "samplingNotes": "Reference-derived from foreground pixels; de-lit to reduce baked shadows/highlights.", "map": {"path": "C:\\Users\\user\\Desktop\\Project3\\internship-management-system\\.img2threejs\\pbr-stone\\stone_albedo.png", "url": "stone_albedo.png", "channel": "albedo", "source": "reference-pixel-extraction"}}, "colorVariation": {"palette": ["#DCB899", "#E0C1A6", "#D5AE8C", "#E7CDB6", "#CA9F79"], "pattern": "reference-derived pixel palette", "amplitude": 0.08, "heightCorrelation": 0.42}, "textureResolution": 1024, "textureProjection": {"mode": "uv", "repeat": [2.0, 2.0], "anisotropy": 8, "texelDensityIntent": "Preserve stable world/object-scale detail; do not stretch micro detail with component scale."}, "surfaceFrequencyBands": [{"id": "macro", "frequency": 2.0, "amplitude": 0.339, "role": "reference-derived broad albedo and height breakup"}, {"id": "meso", "frequency": 14.0, "amplitude": 0.35, "role": "reference-derived cracks, ridges, pores, grain, or leaf clusters"}, {"id": "micro", "frequency": 72.0, "amplitude": 0.14, "role": "reference-derived micro highlight breakup under grazing light"}], "roughness": {"base": 0.889, "variation": 0.118, "map": {"path": "C:\\Users\\user\\Desktop\\Project3\\internship-management-system\\.img2threejs\\pbr-stone\\stone_roughness.png", "url": "stone_roughness.png", "channel": "roughness", "source": "reference-pixel-extraction"}, "localResponse": "reference-derived roughness estimate; cavities and textured zones trend rougher, bright highlights trend smoother"}, "metalness": {"base": 0, "variation": 0.0}, "normal": {"pattern": "reference-derived height-gradient normal map", "strength": 0.437, "map": {"path": "C:\\Users\\user\\Desktop\\Project3\\internship-management-system\\.img2threejs\\pbr-stone\\stone_normal.png", "url": "stone_normal.png", "channel": "normal", "source": "reference-pixel-extraction"}, "heightSource": {"path": "C:\\Users\\user\\Desktop\\Project3\\internship-management-system\\.img2threejs\\pbr-stone\\stone_height.png", "url": "stone_height.png", "channel": "height", "source": "reference-pixel-extraction"}, "space": "tangent"}, "bump": {"pattern": "reference-derived height field", "amplitude": 0.08, "map": {"path": "C:\\Users\\user\\Desktop\\Project3\\internship-management-system\\.img2threejs\\pbr-stone\\stone_height.png", "url": "stone_height.png", "channel": "height", "source": "reference-pixel-extraction"}}, "displacement": {"pattern": "none", "amplitude": 0.0, "scale": 1.0, "silhouetteAffects": false}, "ambientOcclusion": {"cavityStrength": 0.38, "contactShadowBias": 0.35, "map": {"path": "C:\\Users\\user\\Desktop\\Project3\\internship-management-system\\.img2threejs\\pbr-stone\\stone_ao.png", "url": "stone_ao.png", "channel": "ao", "source": "reference-pixel-extraction"}, "notes": "Reference-derived cavity estimate from local height minima; verify against grazing-light screenshot."}, "wear": {"edgeWear": 0.0, "scratches": [], "chips": []}, "dirt": {"amount": 0.0, "cavityBias": 0.0, "color": "#2F2A22"}, "localOverrides": [{"id": "stone-wear", "region": "contact edges and lower courses", "roughness": 0.96, "color": "#c9b58f", "evidenceRefs": ["full-object"]}, {"id": "reference-pbr-pixel-evidence", "type": "material-map-evidence", "evidenceRefs": ["full-object"], "channels": ["albedo", "roughness", "height", "normal", "ambient-occlusion"], "notes": "Use generated maps as material evidence, then refine after browser screenshot comparison."}, {"id": "reference-pbr-pixel-evidence", "type": "material-map-evidence", "evidenceRefs": ["full-object"], "channels": ["albedo", "roughness", "height", "normal", "ambient-occlusion"], "notes": "Use generated maps as material evidence, then refine after browser screenshot comparison."}], "shaderNotes": ["Prefer MeshPhysicalMaterial when clearcoat, sheen, transmission, or thin-surface response is observed; otherwise use MeshStandardMaterial-compatible PBR channels.", "Generate albedo, roughness, height/normal, and AO independently; never alias albedo into roughness.", "Use normal/bump/displacement only when they map to observed surface relief.", "Use displacement geometry when the observed relief changes the close-up silhouette; texture-only relief is insufficient there.", "Reference-derived maps are estimates from image pixels; verify with neutral, grazing, and reference-matched renders.", "Do not treat baked image shadows as final albedo; rerun extraction with a tighter material crop if highlights/shadows pollute the maps.", "Reference-derived maps are estimates from image pixels; verify with neutral, grazing, and reference-matched renders.", "Do not treat baked image shadows as final albedo; rerun extraction with a tighter material crop if highlights/shadows pollute the maps."], "notes": "Replace with image-derived color, roughness, noise, and edge-wear notes.", "referencePbr": {"version": "1.0", "sourceImage": "C:\\Users\\user\\Desktop\\Project3\\internship-management-system\\.img2threejs\\stone-crop.png", "extractor": "stage1_intake/extract_pbr_evidence.py", "method": "single-image pixel evidence with de-lighting estimate; not photogrammetry", "usable": true, "verdict": "pass", "confidence": 0.751, "estimatedFidelity": 0.751, "targetThreshold": 0.7, "hardLimit": "A single image cannot uniquely recover true albedo/roughness/normal/AO; maps are reference-derived estimates.", "maps": {"albedo": {"path": "C:\\Users\\user\\Desktop\\Project3\\internship-management-system\\.img2threejs\\pbr-stone\\stone_albedo.png", "url": "stone_albedo.png", "channel": "albedo", "source": "reference-pixel-extraction"}, "roughness": {"path": "C:\\Users\\user\\Desktop\\Project3\\internship-management-system\\.img2threejs\\pbr-stone\\stone_roughness.png", "url": "stone_roughness.png", "channel": "roughness", "source": "reference-pixel-extraction"}, "height": {"path": "C:\\Users\\user\\Desktop\\Project3\\internship-management-system\\.img2threejs\\pbr-stone\\stone_height.png", "url": "stone_height.png", "channel": "height", "source": "reference-pixel-extraction"}, "normal": {"path": "C:\\Users\\user\\Desktop\\Project3\\internship-management-system\\.img2threejs\\pbr-stone\\stone_normal.png", "url": "stone_normal.png", "channel": "normal", "source": "reference-pixel-extraction"}, "ao": {"path": "C:\\Users\\user\\Desktop\\Project3\\internship-management-system\\.img2threejs\\pbr-stone\\stone_ao.png", "url": "stone_ao.png", "channel": "ao", "source": "reference-pixel-extraction"}}, "diagnostics": {"sourceWidth": 75, "sourceHeight": 200, "mapSize": 256, "cropBBoxPixels": {"x": 0, "y": 0, "width": 75, "height": 200}, "mask": {"backgroundColor": "#DFC2AC", "backgroundNoise": 25.08, "transparentPixelFraction": 0.0, "foregroundCoverage": 0.9638}, "mapStats": {"valueRange": 0.1687, "heightP90Gradient": 0.23952, "roughnessBase": 0.889, "roughnessVariation": 0.118, "normalStrength": 0.437, "blurRadius": 5}, "palette": ["#DCB899", "#E0C1A6", "#D5AE8C", "#E7CDB6", "#CA9F79"]}, "warnings": ["image is not clearly isolated from background; using most pixels as material evidence", "object/background separation is weak", "low value range weakens height/roughness inference"]}},
    options
  );
  materialMap["timber"] = createSculptMaterial(
    "timber",
    {"id": "timber", "name": "timber", "type": "standard", "shaderModel": "MeshStandardMaterial / PBR approximation", "baseColor": "#38291f", "color": "#38291f", "albedo": {"dominant": "#231F20", "secondary": ["#332D2C", "#161414", "#4A4942"], "samplingNotes": "Reference-derived from foreground pixels; de-lit to reduce baked shadows/highlights.", "map": {"path": "C:\\Users\\user\\Desktop\\Project3\\internship-management-system\\.img2threejs\\pbr-timber\\timber_albedo.png", "url": "timber_albedo.png", "channel": "albedo", "source": "reference-pixel-extraction"}}, "colorVariation": {"palette": ["#231F20", "#332D2C", "#161414", "#4A4942", "#776C64"], "pattern": "reference-derived pixel palette", "amplitude": 0.144, "heightCorrelation": 0.42}, "textureResolution": 1024, "textureProjection": {"mode": "uv", "repeat": [2.0, 2.0], "anisotropy": 8, "texelDensityIntent": "Preserve stable world/object-scale detail; do not stretch micro detail with component scale."}, "surfaceFrequencyBands": [{"id": "macro", "frequency": 2.0, "amplitude": 0.4, "role": "reference-derived broad albedo and height breakup"}, {"id": "meso", "frequency": 14.0, "amplitude": 0.35, "role": "reference-derived cracks, ridges, pores, grain, or leaf clusters"}, {"id": "micro", "frequency": 72.0, "amplitude": 0.14, "role": "reference-derived micro highlight breakup under grazing light"}], "roughness": {"base": 0.705, "variation": 0.203, "map": {"path": "C:\\Users\\user\\Desktop\\Project3\\internship-management-system\\.img2threejs\\pbr-timber\\timber_roughness.png", "url": "timber_roughness.png", "channel": "roughness", "source": "reference-pixel-extraction"}, "localResponse": "reference-derived roughness estimate; cavities and textured zones trend rougher, bright highlights trend smoother"}, "metalness": {"base": 0, "variation": 0.0}, "normal": {"pattern": "reference-derived height-gradient normal map", "strength": 0.303, "map": {"path": "C:\\Users\\user\\Desktop\\Project3\\internship-management-system\\.img2threejs\\pbr-timber\\timber_normal.png", "url": "timber_normal.png", "channel": "normal", "source": "reference-pixel-extraction"}, "heightSource": {"path": "C:\\Users\\user\\Desktop\\Project3\\internship-management-system\\.img2threejs\\pbr-timber\\timber_height.png", "url": "timber_height.png", "channel": "height", "source": "reference-pixel-extraction"}, "space": "tangent"}, "bump": {"pattern": "reference-derived height field", "amplitude": 0.056, "map": {"path": "C:\\Users\\user\\Desktop\\Project3\\internship-management-system\\.img2threejs\\pbr-timber\\timber_height.png", "url": "timber_height.png", "channel": "height", "source": "reference-pixel-extraction"}}, "displacement": {"pattern": "none", "amplitude": 0.0, "scale": 1.0, "silhouetteAffects": false}, "ambientOcclusion": {"cavityStrength": 0.38, "contactShadowBias": 0.35, "map": {"path": "C:\\Users\\user\\Desktop\\Project3\\internship-management-system\\.img2threejs\\pbr-timber\\timber_ao.png", "url": "timber_ao.png", "channel": "ao", "source": "reference-pixel-extraction"}, "notes": "Reference-derived cavity estimate from local height minima; verify against grazing-light screenshot."}, "wear": {"edgeWear": 0.0, "scratches": [], "chips": []}, "dirt": {"amount": 0.0, "cavityBias": 0.0, "color": "#2F2A22"}, "localOverrides": [{"id": "timber-wear", "region": "contact edges and lower courses", "roughness": 0.86, "color": "#38291f", "evidenceRefs": ["full-object"]}, {"id": "reference-pbr-pixel-evidence", "type": "material-map-evidence", "evidenceRefs": ["full-object"], "channels": ["albedo", "roughness", "height", "normal", "ambient-occlusion"], "notes": "Use generated maps as material evidence, then refine after browser screenshot comparison."}, {"id": "reference-pbr-pixel-evidence", "type": "material-map-evidence", "evidenceRefs": ["full-object"], "channels": ["albedo", "roughness", "height", "normal", "ambient-occlusion"], "notes": "Use generated maps as material evidence, then refine after browser screenshot comparison."}], "shaderNotes": ["Prefer MeshPhysicalMaterial when clearcoat, sheen, transmission, or thin-surface response is observed; otherwise use MeshStandardMaterial-compatible PBR channels.", "Generate albedo, roughness, height/normal, and AO independently; never alias albedo into roughness.", "Use normal/bump/displacement only when they map to observed surface relief.", "Use displacement geometry when the observed relief changes the close-up silhouette; texture-only relief is insufficient there.", "Reference-derived maps are estimates from image pixels; verify with neutral, grazing, and reference-matched renders.", "Do not treat baked image shadows as final albedo; rerun extraction with a tighter material crop if highlights/shadows pollute the maps.", "Reference-derived maps are estimates from image pixels; verify with neutral, grazing, and reference-matched renders.", "Do not treat baked image shadows as final albedo; rerun extraction with a tighter material crop if highlights/shadows pollute the maps."], "notes": "Replace with image-derived color, roughness, noise, and edge-wear notes.", "referencePbr": {"version": "1.0", "sourceImage": "C:\\Users\\user\\Desktop\\Project3\\internship-management-system\\.img2threejs\\timber-crop.png", "extractor": "stage1_intake/extract_pbr_evidence.py", "method": "single-image pixel evidence with de-lighting estimate; not photogrammetry", "usable": true, "verdict": "pass", "confidence": 0.875, "estimatedFidelity": 0.875, "targetThreshold": 0.7, "hardLimit": "A single image cannot uniquely recover true albedo/roughness/normal/AO; maps are reference-derived estimates.", "maps": {"albedo": {"path": "C:\\Users\\user\\Desktop\\Project3\\internship-management-system\\.img2threejs\\pbr-timber\\timber_albedo.png", "url": "timber_albedo.png", "channel": "albedo", "source": "reference-pixel-extraction"}, "roughness": {"path": "C:\\Users\\user\\Desktop\\Project3\\internship-management-system\\.img2threejs\\pbr-timber\\timber_roughness.png", "url": "timber_roughness.png", "channel": "roughness", "source": "reference-pixel-extraction"}, "height": {"path": "C:\\Users\\user\\Desktop\\Project3\\internship-management-system\\.img2threejs\\pbr-timber\\timber_height.png", "url": "timber_height.png", "channel": "height", "source": "reference-pixel-extraction"}, "normal": {"path": "C:\\Users\\user\\Desktop\\Project3\\internship-management-system\\.img2threejs\\pbr-timber\\timber_normal.png", "url": "timber_normal.png", "channel": "normal", "source": "reference-pixel-extraction"}, "ao": {"path": "C:\\Users\\user\\Desktop\\Project3\\internship-management-system\\.img2threejs\\pbr-timber\\timber_ao.png", "url": "timber_ao.png", "channel": "ao", "source": "reference-pixel-extraction"}}, "diagnostics": {"sourceWidth": 30, "sourceHeight": 80, "mapSize": 256, "cropBBoxPixels": {"x": 0, "y": 0, "width": 30, "height": 80}, "mask": {"backgroundColor": "#4E4344", "backgroundNoise": 96.69, "transparentPixelFraction": 0.0, "foregroundCoverage": 0.2558}, "mapStats": {"valueRange": 0.3438, "heightP90Gradient": 0.12492, "roughnessBase": 0.705, "roughnessVariation": 0.203, "normalStrength": 0.303, "blurRadius": 5}, "palette": ["#231F20", "#332D2C", "#161414", "#4A4942", "#776C64"]}, "warnings": []}},
    options
  );
  materialMap["tile"] = createSculptMaterial(
    "tile",
    {"id": "tile", "name": "tile", "type": "standard", "shaderModel": "MeshStandardMaterial / PBR approximation", "baseColor": "#719a9c", "color": "#719a9c", "albedo": {"dominant": "#8A7A5F", "secondary": ["#6E614B", "#A08F70"], "samplingNotes": "Use image-observed local color zones, not a single averaged color."}, "colorVariation": {"palette": ["#8A7A5F", "#6E614B", "#A08F70"], "pattern": "mottled", "amplitude": 0.15, "heightCorrelation": 0.3}, "textureResolution": 1024, "textureProjection": {"mode": "uv", "repeat": [2.0, 2.0], "anisotropy": 8, "texelDensityIntent": "Preserve stable world/object-scale detail; do not stretch micro detail with component scale."}, "surfaceFrequencyBands": [{"id": "macro", "frequency": 2.0, "amplitude": 0.42, "role": "broad color and height breakup"}, {"id": "meso", "frequency": 12.0, "amplitude": 0.22, "role": "ridges, pores, grain, dents, or equivalent visible relief"}, {"id": "micro", "frequency": 56.0, "amplitude": 0.08, "role": "highlight breakup visible under grazing light"}], "roughness": {"base": 0.53, "variation": 0.15, "map": "independent-procedural-field", "localResponse": "higher roughness in cavities, lower roughness on worn edges"}, "metalness": {"base": 0, "variation": 0.0}, "normal": {"pattern": "derived-from-independent-height-field", "strength": 0.35, "scale": 24.0, "space": "tangent"}, "bump": {"pattern": "independent seeded pores / grain", "amplitude": 0.025, "scale": 14}, "displacement": {"pattern": "none", "amplitude": 0.0, "scale": 1.0, "silhouetteAffects": false}, "ambientOcclusion": {"cavityStrength": 0.25, "contactShadowBias": 0.35, "notes": "Darken creases, seams, intersections, and recessed local features."}, "wear": {"edgeWear": 0.0, "scratches": [], "chips": []}, "dirt": {"amount": 0.0, "cavityBias": 0.0, "color": "#2F2A22"}, "localOverrides": [{"id": "tile-wear", "region": "contact edges and lower courses", "roughness": 0.61, "color": "#719a9c", "evidenceRefs": ["full-object"]}], "shaderNotes": ["Prefer MeshPhysicalMaterial when clearcoat, sheen, transmission, or thin-surface response is observed; otherwise use MeshStandardMaterial-compatible PBR channels.", "Generate albedo, roughness, height/normal, and AO independently; never alias albedo into roughness.", "Use normal/bump/displacement only when they map to observed surface relief.", "Use displacement geometry when the observed relief changes the close-up silhouette; texture-only relief is insufficient there."], "notes": "Simplified contextual material, not a reference-exact surface reconstruction.", "qualityTier": "utility"},
    options
  );
  materialMap["water"] = createSculptMaterial(
    "water",
    {"id": "water", "name": "water", "type": "standard", "shaderModel": "MeshStandardMaterial / PBR approximation", "baseColor": "#367d87", "color": "#367d87", "albedo": {"dominant": "#8A7A5F", "secondary": ["#6E614B", "#A08F70"], "samplingNotes": "Use image-observed local color zones, not a single averaged color."}, "colorVariation": {"palette": ["#8A7A5F", "#6E614B", "#A08F70"], "pattern": "mottled", "amplitude": 0.15, "heightCorrelation": 0.3}, "textureResolution": 1024, "textureProjection": {"mode": "uv", "repeat": [2.0, 2.0], "anisotropy": 8, "texelDensityIntent": "Preserve stable world/object-scale detail; do not stretch micro detail with component scale."}, "surfaceFrequencyBands": [{"id": "macro", "frequency": 2.0, "amplitude": 0.42, "role": "broad color and height breakup"}, {"id": "meso", "frequency": 12.0, "amplitude": 0.22, "role": "ridges, pores, grain, dents, or equivalent visible relief"}, {"id": "micro", "frequency": 56.0, "amplitude": 0.08, "role": "highlight breakup visible under grazing light"}], "roughness": {"base": 0.15, "variation": 0.15, "map": "independent-procedural-field", "localResponse": "higher roughness in cavities, lower roughness on worn edges"}, "metalness": {"base": 0, "variation": 0.0}, "normal": {"pattern": "derived-from-independent-height-field", "strength": 0.35, "scale": 24.0, "space": "tangent"}, "bump": {"pattern": "independent seeded pores / grain", "amplitude": 0.025, "scale": 14}, "displacement": {"pattern": "none", "amplitude": 0.0, "scale": 1.0, "silhouetteAffects": false}, "ambientOcclusion": {"cavityStrength": 0.25, "contactShadowBias": 0.35, "notes": "Darken creases, seams, intersections, and recessed local features."}, "wear": {"edgeWear": 0.0, "scratches": [], "chips": []}, "dirt": {"amount": 0.0, "cavityBias": 0.0, "color": "#2F2A22"}, "localOverrides": [{"id": "water-wear", "region": "contact edges and lower courses", "roughness": 0.22999999999999998, "color": "#367d87", "evidenceRefs": ["full-object"]}], "shaderNotes": ["Prefer MeshPhysicalMaterial when clearcoat, sheen, transmission, or thin-surface response is observed; otherwise use MeshStandardMaterial-compatible PBR channels.", "Generate albedo, roughness, height/normal, and AO independently; never alias albedo into roughness.", "Use normal/bump/displacement only when they map to observed surface relief.", "Use displacement geometry when the observed relief changes the close-up silhouette; texture-only relief is insufficient there."], "notes": "Simplified contextual material, not a reference-exact surface reconstruction.", "qualityTier": "utility"},
    options
  );
  materialMap["metal"] = createSculptMaterial(
    "metal",
    {"id": "metal", "name": "metal", "type": "standard", "shaderModel": "MeshStandardMaterial / PBR approximation", "baseColor": "#4d4f49", "color": "#4d4f49", "albedo": {"dominant": "#8A7A5F", "secondary": ["#6E614B", "#A08F70"], "samplingNotes": "Use image-observed local color zones, not a single averaged color."}, "colorVariation": {"palette": ["#8A7A5F", "#6E614B", "#A08F70"], "pattern": "mottled", "amplitude": 0.15, "heightCorrelation": 0.3}, "textureResolution": 1024, "textureProjection": {"mode": "uv", "repeat": [2.0, 2.0], "anisotropy": 8, "texelDensityIntent": "Preserve stable world/object-scale detail; do not stretch micro detail with component scale."}, "surfaceFrequencyBands": [{"id": "macro", "frequency": 2.0, "amplitude": 0.42, "role": "broad color and height breakup"}, {"id": "meso", "frequency": 12.0, "amplitude": 0.22, "role": "ridges, pores, grain, dents, or equivalent visible relief"}, {"id": "micro", "frequency": 56.0, "amplitude": 0.08, "role": "highlight breakup visible under grazing light"}], "roughness": {"base": 0.48, "variation": 0.15, "map": "independent-procedural-field", "localResponse": "higher roughness in cavities, lower roughness on worn edges"}, "metalness": {"base": 0.55, "variation": 0.0}, "normal": {"pattern": "derived-from-independent-height-field", "strength": 0.35, "scale": 24.0, "space": "tangent"}, "bump": {"pattern": "independent seeded pores / grain", "amplitude": 0.025, "scale": 14}, "displacement": {"pattern": "none", "amplitude": 0.0, "scale": 1.0, "silhouetteAffects": false}, "ambientOcclusion": {"cavityStrength": 0.25, "contactShadowBias": 0.35, "notes": "Darken creases, seams, intersections, and recessed local features."}, "wear": {"edgeWear": 0.0, "scratches": [], "chips": []}, "dirt": {"amount": 0.0, "cavityBias": 0.0, "color": "#2F2A22"}, "localOverrides": [{"id": "metal-wear", "region": "contact edges and lower courses", "roughness": 0.5599999999999999, "color": "#4d4f49", "evidenceRefs": ["full-object"]}], "shaderNotes": ["Prefer MeshPhysicalMaterial when clearcoat, sheen, transmission, or thin-surface response is observed; otherwise use MeshStandardMaterial-compatible PBR channels.", "Generate albedo, roughness, height/normal, and AO independently; never alias albedo into roughness.", "Use normal/bump/displacement only when they map to observed surface relief.", "Use displacement geometry when the observed relief changes the close-up silhouette; texture-only relief is insufficient there."], "notes": "Simplified contextual material, not a reference-exact surface reconstruction.", "qualityTier": "utility"},
    options
  );
  materialMap["glass"] = createSculptMaterial(
    "glass",
    {"id": "glass", "name": "glass", "type": "standard", "shaderModel": "MeshStandardMaterial / PBR approximation", "baseColor": "#4c7585", "color": "#4c7585", "albedo": {"dominant": "#8A7A5F", "secondary": ["#6E614B", "#A08F70"], "samplingNotes": "Use image-observed local color zones, not a single averaged color."}, "colorVariation": {"palette": ["#8A7A5F", "#6E614B", "#A08F70"], "pattern": "mottled", "amplitude": 0.15, "heightCorrelation": 0.3}, "textureResolution": 1024, "textureProjection": {"mode": "uv", "repeat": [2.0, 2.0], "anisotropy": 8, "texelDensityIntent": "Preserve stable world/object-scale detail; do not stretch micro detail with component scale."}, "surfaceFrequencyBands": [{"id": "macro", "frequency": 2.0, "amplitude": 0.42, "role": "broad color and height breakup"}, {"id": "meso", "frequency": 12.0, "amplitude": 0.22, "role": "ridges, pores, grain, dents, or equivalent visible relief"}, {"id": "micro", "frequency": 56.0, "amplitude": 0.08, "role": "highlight breakup visible under grazing light"}], "roughness": {"base": 0.26, "variation": 0.15, "map": "independent-procedural-field", "localResponse": "higher roughness in cavities, lower roughness on worn edges"}, "metalness": {"base": 0.15, "variation": 0.0}, "normal": {"pattern": "derived-from-independent-height-field", "strength": 0.35, "scale": 24.0, "space": "tangent"}, "bump": {"pattern": "independent seeded pores / grain", "amplitude": 0.025, "scale": 14}, "displacement": {"pattern": "none", "amplitude": 0.0, "scale": 1.0, "silhouetteAffects": false}, "ambientOcclusion": {"cavityStrength": 0.25, "contactShadowBias": 0.35, "notes": "Darken creases, seams, intersections, and recessed local features."}, "wear": {"edgeWear": 0.0, "scratches": [], "chips": []}, "dirt": {"amount": 0.0, "cavityBias": 0.0, "color": "#2F2A22"}, "localOverrides": [{"id": "glass-wear", "region": "contact edges and lower courses", "roughness": 0.34, "color": "#4c7585", "evidenceRefs": ["full-object"]}], "shaderNotes": ["Prefer MeshPhysicalMaterial when clearcoat, sheen, transmission, or thin-surface response is observed; otherwise use MeshStandardMaterial-compatible PBR channels.", "Generate albedo, roughness, height/normal, and AO independently; never alias albedo into roughness.", "Use normal/bump/displacement only when they map to observed surface relief.", "Use displacement geometry when the observed relief changes the close-up silhouette; texture-only relief is insufficient there."], "notes": "Simplified contextual material, not a reference-exact surface reconstruction.", "qualityTier": "utility"},
    options
  );

  const nodes: Record<string, THREE.Object3D> = { root };
  const meshes: Record<string, THREE.Mesh> = {};
  const sockets: Record<string, THREE.Object3D> = {};
  const colliders: Record<string, unknown> = {};
  const destructionGroups: Record<string, THREE.Object3D[]> = {};

  const endpoint_root_0 = makeAttachmentEndpoint(null);
  const node_root_0 = new THREE.Group();
  node_root_0.name = "root__pivot";
  node_root_0.scale.set(1, 1, 1);
  if (endpoint_root_0) {
    node_root_0.position.copy(endpoint_root_0.start);
    node_root_0.rotation.set(0.0, 0.0, 0.0);
  } else {
    node_root_0.position.set(0.0, 0.0, 0.0);
    node_root_0.rotation.set(0.0, 0.0, 0.0);
  }
  node_root_0.userData.sculptComponent = {"id": "root", "name": "root", "level": "macro", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "box", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": null, "attachment": null, "dimensions": {"width": 0.001, "height": 0.001, "depth": 0.001, "units": "relative", "confidence": 0.5}, "transform": {"position": [0, 0, 0], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "root", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "stone", "materialLayers": ["stone"], "deformations": [], "joints": [], "seams": [], "localFeatures": [], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#c9b58f", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(201, 181, 143, 1)", "secondaryAlbedo": "rgba(186, 166, 128, 1)", "materialClass": "stone", "materialClassConfidence": 0.8}};
  node_root_0.userData.actionProfile = {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "root", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}};
  (nodes["root"] ?? root).add(node_root_0);
  nodes["root"] = node_root_0;
  const mesh_root_0Geometry = endpoint_root_0
    ? new THREE.CylinderGeometry(endpoint_root_0.endRadius, endpoint_root_0.baseRadius, endpoint_root_0.length, 16, 6)
    : new THREE.BoxGeometry(1, 1, 1, 4, 4, 4);
  if (!endpoint_root_0) {
    mesh_root_0Geometry.scale(1.0, 1.0, 1.0);
  }
  const mesh_root_0 = new THREE.Mesh(
    mesh_root_0Geometry,
    materialMap["stone"] ?? new THREE.MeshStandardMaterial({ color: 0x888888 })
  );
  mesh_root_0.name = "root";
  if (endpoint_root_0) {
    mesh_root_0.position.copy(endpoint_root_0.midpoint);
    mesh_root_0.quaternion.copy(endpoint_root_0.quaternion);
  }
  mesh_root_0.castShadow = options.castShadow ?? true;
  mesh_root_0.receiveShadow = options.receiveShadow ?? true;
  mesh_root_0.userData.sculptComponent = {"id": "root", "name": "root", "level": "macro", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "box", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": null, "attachment": null, "dimensions": {"width": 0.001, "height": 0.001, "depth": 0.001, "units": "relative", "confidence": 0.5}, "transform": {"position": [0, 0, 0], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "root", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "stone", "materialLayers": ["stone"], "deformations": [], "joints": [], "seams": [], "localFeatures": [], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#c9b58f", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(201, 181, 143, 1)", "secondaryAlbedo": "rgba(186, 166, 128, 1)", "materialClass": "stone", "materialClassConfidence": 0.8}};
  node_root_0.add(mesh_root_0);
  meshes["root"] = mesh_root_0;
  colliders["root"] = {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."};
  destructionGroups["root"] ??= [];
  destructionGroups["root"].push(node_root_0);

  const endpoint_wheel_1 = makeAttachmentEndpoint(null);
  const node_wheel_1 = new THREE.Group();
  node_wheel_1.name = "wheel__pivot";
  node_wheel_1.scale.set(1, 1, 1);
  if (endpoint_wheel_1) {
    node_wheel_1.position.copy(endpoint_wheel_1.start);
    node_wheel_1.rotation.set(0.0, 0.0, 0.0);
  } else {
    node_wheel_1.position.set(1.35, 3.45, 0.0);
    node_wheel_1.rotation.set(0.0, 0.0, 0.0);
  }
  node_wheel_1.userData.sculptComponent = {"id": "wheel", "name": "wheel", "level": "macro", "role": "rotating assembly", "importance": 1.0, "confidence": 0.8, "primitive": "torus", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "root", "attachment": {"parentSocket": "root-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 6.3, "height": 6.3, "depth": 0.92, "units": "relative", "confidence": 0.5}, "transform": {"position": [1.35, 3.45, 0], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "hinge", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "wheel", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "timber", "materialLayers": ["timber"], "deformations": [], "joints": [], "seams": [], "localFeatures": [], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#38291f", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(56, 41, 31, 1)", "secondaryAlbedo": "rgba(41, 26, 16, 1)", "materialClass": "wood", "materialClassConfidence": 0.8}};
  node_wheel_1.userData.actionProfile = {"animationRole": "hinge", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "wheel", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}};
  (nodes["root"] ?? root).add(node_wheel_1);
  nodes["wheel"] = node_wheel_1;
  const mesh_wheel_1Geometry = endpoint_wheel_1
    ? new THREE.CylinderGeometry(endpoint_wheel_1.endRadius, endpoint_wheel_1.baseRadius, endpoint_wheel_1.length, 16, 6)
    : new THREE.TorusGeometry(0.45, 0.08, 12, 48);
  if (!endpoint_wheel_1) {
    mesh_wheel_1Geometry.scale(1.0, 1.0, 1.0);
  }
  const mesh_wheel_1 = new THREE.Mesh(
    mesh_wheel_1Geometry,
    materialMap["timber"] ?? new THREE.MeshStandardMaterial({ color: 0x888888 })
  );
  mesh_wheel_1.name = "wheel";
  if (endpoint_wheel_1) {
    mesh_wheel_1.position.copy(endpoint_wheel_1.midpoint);
    mesh_wheel_1.quaternion.copy(endpoint_wheel_1.quaternion);
  }
  mesh_wheel_1.castShadow = options.castShadow ?? true;
  mesh_wheel_1.receiveShadow = options.receiveShadow ?? true;
  mesh_wheel_1.userData.sculptComponent = {"id": "wheel", "name": "wheel", "level": "macro", "role": "rotating assembly", "importance": 1.0, "confidence": 0.8, "primitive": "torus", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "root", "attachment": {"parentSocket": "root-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 6.3, "height": 6.3, "depth": 0.92, "units": "relative", "confidence": 0.5}, "transform": {"position": [1.35, 3.45, 0], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "hinge", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "wheel", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "timber", "materialLayers": ["timber"], "deformations": [], "joints": [], "seams": [], "localFeatures": [], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#38291f", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(56, 41, 31, 1)", "secondaryAlbedo": "rgba(41, 26, 16, 1)", "materialClass": "wood", "materialClassConfidence": 0.8}};
  node_wheel_1.add(mesh_wheel_1);
  meshes["wheel"] = mesh_wheel_1;
  colliders["wheel"] = {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."};
  destructionGroups["wheel"] ??= [];
  destructionGroups["wheel"].push(node_wheel_1);

  const endpoint_arcade_2 = makeAttachmentEndpoint(null);
  const node_arcade_2 = new THREE.Group();
  node_arcade_2.name = "arcade__pivot";
  node_arcade_2.scale.set(1, 1, 1);
  if (endpoint_arcade_2) {
    node_arcade_2.position.copy(endpoint_arcade_2.start);
    node_arcade_2.rotation.set(0.0, 0.0, 0.0);
  } else {
    node_arcade_2.position.set(-2.7, 0.0, -0.9);
    node_arcade_2.rotation.set(0.0, 0.0, 0.0);
  }
  node_arcade_2.userData.sculptComponent = {"id": "arcade", "name": "arcade", "level": "macro", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "box", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "root", "attachment": {"parentSocket": "root-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 0.001, "height": 0.001, "depth": 0.001, "units": "relative", "confidence": 0.5}, "transform": {"position": [-2.7, 0, -0.9], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "arcade", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "stone", "materialLayers": ["stone"], "deformations": [], "joints": [], "seams": [], "localFeatures": [], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#c9b58f", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(201, 181, 143, 1)", "secondaryAlbedo": "rgba(186, 166, 128, 1)", "materialClass": "stone", "materialClassConfidence": 0.8}};
  node_arcade_2.userData.actionProfile = {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "arcade", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}};
  (nodes["root"] ?? root).add(node_arcade_2);
  nodes["arcade"] = node_arcade_2;
  const mesh_arcade_2Geometry = endpoint_arcade_2
    ? new THREE.CylinderGeometry(endpoint_arcade_2.endRadius, endpoint_arcade_2.baseRadius, endpoint_arcade_2.length, 16, 6)
    : new THREE.BoxGeometry(1, 1, 1, 4, 4, 4);
  if (!endpoint_arcade_2) {
    mesh_arcade_2Geometry.scale(1.0, 1.0, 1.0);
  }
  const mesh_arcade_2 = new THREE.Mesh(
    mesh_arcade_2Geometry,
    materialMap["stone"] ?? new THREE.MeshStandardMaterial({ color: 0x888888 })
  );
  mesh_arcade_2.name = "arcade";
  if (endpoint_arcade_2) {
    mesh_arcade_2.position.copy(endpoint_arcade_2.midpoint);
    mesh_arcade_2.quaternion.copy(endpoint_arcade_2.quaternion);
  }
  mesh_arcade_2.castShadow = options.castShadow ?? true;
  mesh_arcade_2.receiveShadow = options.receiveShadow ?? true;
  mesh_arcade_2.userData.sculptComponent = {"id": "arcade", "name": "arcade", "level": "macro", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "box", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "root", "attachment": {"parentSocket": "root-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 0.001, "height": 0.001, "depth": 0.001, "units": "relative", "confidence": 0.5}, "transform": {"position": [-2.7, 0, -0.9], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "arcade", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "stone", "materialLayers": ["stone"], "deformations": [], "joints": [], "seams": [], "localFeatures": [], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#c9b58f", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(201, 181, 143, 1)", "secondaryAlbedo": "rgba(186, 166, 128, 1)", "materialClass": "stone", "materialClassConfidence": 0.8}};
  node_arcade_2.add(mesh_arcade_2);
  meshes["arcade"] = mesh_arcade_2;
  colliders["arcade"] = {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."};
  destructionGroups["arcade"] ??= [];
  destructionGroups["arcade"].push(node_arcade_2);

  const endpoint_context_3 = makeAttachmentEndpoint(null);
  const node_context_3 = new THREE.Group();
  node_context_3.name = "context__pivot";
  node_context_3.scale.set(1, 1, 1);
  if (endpoint_context_3) {
    node_context_3.position.copy(endpoint_context_3.start);
    node_context_3.rotation.set(0.0, 0.0, 0.0);
  } else {
    node_context_3.position.set(0.0, 0.0, -4.2);
    node_context_3.rotation.set(0.0, 0.0, 0.0);
  }
  node_context_3.userData.sculptComponent = {"id": "context", "name": "context", "level": "macro", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "box", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "root", "attachment": {"parentSocket": "root-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 0.001, "height": 0.001, "depth": 0.001, "units": "relative", "confidence": 0.5}, "transform": {"position": [0, 0, -4.2], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "context", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "stone", "materialLayers": ["stone"], "deformations": [], "joints": [], "seams": [], "localFeatures": [], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#c9b58f", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(201, 181, 143, 1)", "secondaryAlbedo": "rgba(186, 166, 128, 1)", "materialClass": "stone", "materialClassConfidence": 0.8}};
  node_context_3.userData.actionProfile = {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "context", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}};
  (nodes["root"] ?? root).add(node_context_3);
  nodes["context"] = node_context_3;
  const mesh_context_3Geometry = endpoint_context_3
    ? new THREE.CylinderGeometry(endpoint_context_3.endRadius, endpoint_context_3.baseRadius, endpoint_context_3.length, 16, 6)
    : new THREE.BoxGeometry(1, 1, 1, 4, 4, 4);
  if (!endpoint_context_3) {
    mesh_context_3Geometry.scale(1.0, 1.0, 1.0);
  }
  const mesh_context_3 = new THREE.Mesh(
    mesh_context_3Geometry,
    materialMap["stone"] ?? new THREE.MeshStandardMaterial({ color: 0x888888 })
  );
  mesh_context_3.name = "context";
  if (endpoint_context_3) {
    mesh_context_3.position.copy(endpoint_context_3.midpoint);
    mesh_context_3.quaternion.copy(endpoint_context_3.quaternion);
  }
  mesh_context_3.castShadow = options.castShadow ?? true;
  mesh_context_3.receiveShadow = options.receiveShadow ?? true;
  mesh_context_3.userData.sculptComponent = {"id": "context", "name": "context", "level": "macro", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "box", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "root", "attachment": {"parentSocket": "root-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 0.001, "height": 0.001, "depth": 0.001, "units": "relative", "confidence": 0.5}, "transform": {"position": [0, 0, -4.2], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "context", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "stone", "materialLayers": ["stone"], "deformations": [], "joints": [], "seams": [], "localFeatures": [], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#c9b58f", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(201, 181, 143, 1)", "secondaryAlbedo": "rgba(186, 166, 128, 1)", "materialClass": "stone", "materialClassConfidence": 0.8}};
  node_context_3.add(mesh_context_3);
  meshes["context"] = mesh_context_3;
  colliders["context"] = {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."};
  destructionGroups["context"] ??= [];
  destructionGroups["context"].push(node_context_3);

  const endpoint_rim_front_4 = makeAttachmentEndpoint(null);
  const node_rim_front_4 = new THREE.Group();
  node_rim_front_4.name = "rim-front__pivot";
  node_rim_front_4.scale.set(1, 1, 1);
  if (endpoint_rim_front_4) {
    node_rim_front_4.position.copy(endpoint_rim_front_4.start);
    node_rim_front_4.rotation.set(0.0, 0.0, 0.0);
  } else {
    node_rim_front_4.position.set(0.0, 0.0, 0.46);
    node_rim_front_4.rotation.set(0.0, 0.0, 0.0);
  }
  node_rim_front_4.userData.sculptComponent = {"id": "rim-front", "name": "rim-front", "level": "meso", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "torus", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "wheel", "attachment": {"parentSocket": "wheel-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 6.3, "height": 6.3, "depth": 0.18, "units": "relative", "confidence": 0.5}, "transform": {"position": [0, 0, 0.46], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "rim-front", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "timber", "materialLayers": ["timber"], "deformations": [], "joints": [], "seams": [], "localFeatures": [{"id": "timber-segments", "type": "linework", "placement": "photo-observed component surface", "size": [0.03, 0.03, 0.03], "confidence": 0.75, "geometryEffect": "repeated geometry or independent procedural surface channel", "materialEffect": "localized roughness and value variation", "evidenceRefs": ["full-object"]}], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#38291f", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(56, 41, 31, 1)", "secondaryAlbedo": "rgba(41, 26, 16, 1)", "materialClass": "wood", "materialClassConfidence": 0.8}};
  node_rim_front_4.userData.actionProfile = {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "rim-front", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}};
  (nodes["wheel"] ?? root).add(node_rim_front_4);
  nodes["rim-front"] = node_rim_front_4;
  const mesh_rim_front_4Geometry = endpoint_rim_front_4
    ? new THREE.CylinderGeometry(endpoint_rim_front_4.endRadius, endpoint_rim_front_4.baseRadius, endpoint_rim_front_4.length, 16, 6)
    : new THREE.TorusGeometry(0.45, 0.08, 12, 48);
  if (!endpoint_rim_front_4) {
    mesh_rim_front_4Geometry.scale(1.0, 1.0, 1.0);
  }
  const mesh_rim_front_4 = new THREE.Mesh(
    mesh_rim_front_4Geometry,
    materialMap["timber"] ?? new THREE.MeshStandardMaterial({ color: 0x888888 })
  );
  mesh_rim_front_4.name = "rim-front";
  if (endpoint_rim_front_4) {
    mesh_rim_front_4.position.copy(endpoint_rim_front_4.midpoint);
    mesh_rim_front_4.quaternion.copy(endpoint_rim_front_4.quaternion);
  }
  mesh_rim_front_4.castShadow = options.castShadow ?? true;
  mesh_rim_front_4.receiveShadow = options.receiveShadow ?? true;
  mesh_rim_front_4.userData.sculptComponent = {"id": "rim-front", "name": "rim-front", "level": "meso", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "torus", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "wheel", "attachment": {"parentSocket": "wheel-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 6.3, "height": 6.3, "depth": 0.18, "units": "relative", "confidence": 0.5}, "transform": {"position": [0, 0, 0.46], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "rim-front", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "timber", "materialLayers": ["timber"], "deformations": [], "joints": [], "seams": [], "localFeatures": [{"id": "timber-segments", "type": "linework", "placement": "photo-observed component surface", "size": [0.03, 0.03, 0.03], "confidence": 0.75, "geometryEffect": "repeated geometry or independent procedural surface channel", "materialEffect": "localized roughness and value variation", "evidenceRefs": ["full-object"]}], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#38291f", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(56, 41, 31, 1)", "secondaryAlbedo": "rgba(41, 26, 16, 1)", "materialClass": "wood", "materialClassConfidence": 0.8}};
  node_rim_front_4.add(mesh_rim_front_4);
  meshes["rim-front"] = mesh_rim_front_4;
  colliders["rim-front"] = {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."};
  destructionGroups["rim-front"] ??= [];
  destructionGroups["rim-front"].push(node_rim_front_4);

  const endpoint_rim_back_5 = makeAttachmentEndpoint(null);
  const node_rim_back_5 = new THREE.Group();
  node_rim_back_5.name = "rim-back__pivot";
  node_rim_back_5.scale.set(1, 1, 1);
  if (endpoint_rim_back_5) {
    node_rim_back_5.position.copy(endpoint_rim_back_5.start);
    node_rim_back_5.rotation.set(0.0, 0.0, 0.0);
  } else {
    node_rim_back_5.position.set(0.0, 0.0, -0.46);
    node_rim_back_5.rotation.set(0.0, 0.0, 0.0);
  }
  node_rim_back_5.userData.sculptComponent = {"id": "rim-back", "name": "rim-back", "level": "meso", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "torus", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "wheel", "attachment": {"parentSocket": "wheel-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 6.3, "height": 6.3, "depth": 0.18, "units": "relative", "confidence": 0.5}, "transform": {"position": [0, 0, -0.46], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "rim-back", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "timber", "materialLayers": ["timber"], "deformations": [], "joints": [], "seams": [], "localFeatures": [{"id": "rim-thickness", "type": "bevel", "placement": "photo-observed component surface", "size": [0.03, 0.03, 0.03], "confidence": 0.75, "geometryEffect": "repeated geometry or independent procedural surface channel", "materialEffect": "localized roughness and value variation", "evidenceRefs": ["full-object"]}], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#38291f", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(56, 41, 31, 1)", "secondaryAlbedo": "rgba(41, 26, 16, 1)", "materialClass": "wood", "materialClassConfidence": 0.8}};
  node_rim_back_5.userData.actionProfile = {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "rim-back", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}};
  (nodes["wheel"] ?? root).add(node_rim_back_5);
  nodes["rim-back"] = node_rim_back_5;
  const mesh_rim_back_5Geometry = endpoint_rim_back_5
    ? new THREE.CylinderGeometry(endpoint_rim_back_5.endRadius, endpoint_rim_back_5.baseRadius, endpoint_rim_back_5.length, 16, 6)
    : new THREE.TorusGeometry(0.45, 0.08, 12, 48);
  if (!endpoint_rim_back_5) {
    mesh_rim_back_5Geometry.scale(1.0, 1.0, 1.0);
  }
  const mesh_rim_back_5 = new THREE.Mesh(
    mesh_rim_back_5Geometry,
    materialMap["timber"] ?? new THREE.MeshStandardMaterial({ color: 0x888888 })
  );
  mesh_rim_back_5.name = "rim-back";
  if (endpoint_rim_back_5) {
    mesh_rim_back_5.position.copy(endpoint_rim_back_5.midpoint);
    mesh_rim_back_5.quaternion.copy(endpoint_rim_back_5.quaternion);
  }
  mesh_rim_back_5.castShadow = options.castShadow ?? true;
  mesh_rim_back_5.receiveShadow = options.receiveShadow ?? true;
  mesh_rim_back_5.userData.sculptComponent = {"id": "rim-back", "name": "rim-back", "level": "meso", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "torus", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "wheel", "attachment": {"parentSocket": "wheel-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 6.3, "height": 6.3, "depth": 0.18, "units": "relative", "confidence": 0.5}, "transform": {"position": [0, 0, -0.46], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "rim-back", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "timber", "materialLayers": ["timber"], "deformations": [], "joints": [], "seams": [], "localFeatures": [{"id": "rim-thickness", "type": "bevel", "placement": "photo-observed component surface", "size": [0.03, 0.03, 0.03], "confidence": 0.75, "geometryEffect": "repeated geometry or independent procedural surface channel", "materialEffect": "localized roughness and value variation", "evidenceRefs": ["full-object"]}], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#38291f", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(56, 41, 31, 1)", "secondaryAlbedo": "rgba(41, 26, 16, 1)", "materialClass": "wood", "materialClassConfidence": 0.8}};
  node_rim_back_5.add(mesh_rim_back_5);
  meshes["rim-back"] = mesh_rim_back_5;
  colliders["rim-back"] = {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."};
  destructionGroups["rim-back"] ??= [];
  destructionGroups["rim-back"].push(node_rim_back_5);

  const endpoint_spokes_6 = makeAttachmentEndpoint(null);
  const node_spokes_6 = new THREE.Group();
  node_spokes_6.name = "spokes__pivot";
  node_spokes_6.scale.set(1, 1, 1);
  if (endpoint_spokes_6) {
    node_spokes_6.position.copy(endpoint_spokes_6.start);
    node_spokes_6.rotation.set(0.0, 0.0, 0.0);
  } else {
    node_spokes_6.position.set(0.0, 0.0, 0.0);
    node_spokes_6.rotation.set(0.0, 0.0, 0.0);
  }
  node_spokes_6.userData.sculptComponent = {"id": "spokes", "name": "spokes", "level": "meso", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "box", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "wheel", "attachment": {"parentSocket": "wheel-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 0.001, "height": 0.001, "depth": 0.001, "units": "relative", "confidence": 0.5}, "transform": {"position": [0, 0, 0], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "spokes", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "timber", "materialLayers": ["timber"], "deformations": [], "joints": [], "seams": [], "localFeatures": [{"id": "radial-spokes", "type": "ridge", "placement": "photo-observed component surface", "size": [0.03, 0.03, 0.03], "confidence": 0.75, "geometryEffect": "repeated geometry or independent procedural surface channel", "materialEffect": "localized roughness and value variation", "evidenceRefs": ["full-object"]}], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#38291f", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(56, 41, 31, 1)", "secondaryAlbedo": "rgba(41, 26, 16, 1)", "materialClass": "wood", "materialClassConfidence": 0.8}};
  node_spokes_6.userData.actionProfile = {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "spokes", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}};
  (nodes["wheel"] ?? root).add(node_spokes_6);
  nodes["spokes"] = node_spokes_6;
  const mesh_spokes_6Geometry = endpoint_spokes_6
    ? new THREE.CylinderGeometry(endpoint_spokes_6.endRadius, endpoint_spokes_6.baseRadius, endpoint_spokes_6.length, 16, 6)
    : new THREE.BoxGeometry(1, 1, 1, 4, 4, 4);
  if (!endpoint_spokes_6) {
    mesh_spokes_6Geometry.scale(1.0, 1.0, 1.0);
  }
  const mesh_spokes_6 = new THREE.Mesh(
    mesh_spokes_6Geometry,
    materialMap["timber"] ?? new THREE.MeshStandardMaterial({ color: 0x888888 })
  );
  mesh_spokes_6.name = "spokes";
  if (endpoint_spokes_6) {
    mesh_spokes_6.position.copy(endpoint_spokes_6.midpoint);
    mesh_spokes_6.quaternion.copy(endpoint_spokes_6.quaternion);
  }
  mesh_spokes_6.castShadow = options.castShadow ?? true;
  mesh_spokes_6.receiveShadow = options.receiveShadow ?? true;
  mesh_spokes_6.userData.sculptComponent = {"id": "spokes", "name": "spokes", "level": "meso", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "box", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "wheel", "attachment": {"parentSocket": "wheel-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 0.001, "height": 0.001, "depth": 0.001, "units": "relative", "confidence": 0.5}, "transform": {"position": [0, 0, 0], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "spokes", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "timber", "materialLayers": ["timber"], "deformations": [], "joints": [], "seams": [], "localFeatures": [{"id": "radial-spokes", "type": "ridge", "placement": "photo-observed component surface", "size": [0.03, 0.03, 0.03], "confidence": 0.75, "geometryEffect": "repeated geometry or independent procedural surface channel", "materialEffect": "localized roughness and value variation", "evidenceRefs": ["full-object"]}], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#38291f", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(56, 41, 31, 1)", "secondaryAlbedo": "rgba(41, 26, 16, 1)", "materialClass": "wood", "materialClassConfidence": 0.8}};
  node_spokes_6.add(mesh_spokes_6);
  meshes["spokes"] = mesh_spokes_6;
  colliders["spokes"] = {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."};
  destructionGroups["spokes"] ??= [];
  destructionGroups["spokes"].push(node_spokes_6);

  const endpoint_paddles_7 = makeAttachmentEndpoint(null);
  const node_paddles_7 = new THREE.Group();
  node_paddles_7.name = "paddles__pivot";
  node_paddles_7.scale.set(1, 1, 1);
  if (endpoint_paddles_7) {
    node_paddles_7.position.copy(endpoint_paddles_7.start);
    node_paddles_7.rotation.set(0.0, 0.0, 0.0);
  } else {
    node_paddles_7.position.set(0.0, 0.0, 0.0);
    node_paddles_7.rotation.set(0.0, 0.0, 0.0);
  }
  node_paddles_7.userData.sculptComponent = {"id": "paddles", "name": "paddles", "level": "meso", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "box", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "wheel", "attachment": {"parentSocket": "wheel-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 0.001, "height": 0.001, "depth": 0.001, "units": "relative", "confidence": 0.5}, "transform": {"position": [0, 0, 0], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "paddles", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "timber", "materialLayers": ["timber"], "deformations": [], "joints": [], "seams": [], "localFeatures": [{"id": "paddle-stations", "type": "ridge", "placement": "photo-observed component surface", "size": [0.03, 0.03, 0.03], "confidence": 0.75, "geometryEffect": "repeated geometry or independent procedural surface channel", "materialEffect": "localized roughness and value variation", "evidenceRefs": ["full-object"]}], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#38291f", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(56, 41, 31, 1)", "secondaryAlbedo": "rgba(41, 26, 16, 1)", "materialClass": "wood", "materialClassConfidence": 0.8}};
  node_paddles_7.userData.actionProfile = {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "paddles", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}};
  (nodes["wheel"] ?? root).add(node_paddles_7);
  nodes["paddles"] = node_paddles_7;
  const mesh_paddles_7Geometry = endpoint_paddles_7
    ? new THREE.CylinderGeometry(endpoint_paddles_7.endRadius, endpoint_paddles_7.baseRadius, endpoint_paddles_7.length, 16, 6)
    : new THREE.BoxGeometry(1, 1, 1, 4, 4, 4);
  if (!endpoint_paddles_7) {
    mesh_paddles_7Geometry.scale(1.0, 1.0, 1.0);
  }
  const mesh_paddles_7 = new THREE.Mesh(
    mesh_paddles_7Geometry,
    materialMap["timber"] ?? new THREE.MeshStandardMaterial({ color: 0x888888 })
  );
  mesh_paddles_7.name = "paddles";
  if (endpoint_paddles_7) {
    mesh_paddles_7.position.copy(endpoint_paddles_7.midpoint);
    mesh_paddles_7.quaternion.copy(endpoint_paddles_7.quaternion);
  }
  mesh_paddles_7.castShadow = options.castShadow ?? true;
  mesh_paddles_7.receiveShadow = options.receiveShadow ?? true;
  mesh_paddles_7.userData.sculptComponent = {"id": "paddles", "name": "paddles", "level": "meso", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "box", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "wheel", "attachment": {"parentSocket": "wheel-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 0.001, "height": 0.001, "depth": 0.001, "units": "relative", "confidence": 0.5}, "transform": {"position": [0, 0, 0], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "paddles", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "timber", "materialLayers": ["timber"], "deformations": [], "joints": [], "seams": [], "localFeatures": [{"id": "paddle-stations", "type": "ridge", "placement": "photo-observed component surface", "size": [0.03, 0.03, 0.03], "confidence": 0.75, "geometryEffect": "repeated geometry or independent procedural surface channel", "materialEffect": "localized roughness and value variation", "evidenceRefs": ["full-object"]}], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#38291f", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(56, 41, 31, 1)", "secondaryAlbedo": "rgba(41, 26, 16, 1)", "materialClass": "wood", "materialClassConfidence": 0.8}};
  node_paddles_7.add(mesh_paddles_7);
  meshes["paddles"] = mesh_paddles_7;
  colliders["paddles"] = {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."};
  destructionGroups["paddles"] ??= [];
  destructionGroups["paddles"].push(node_paddles_7);

  const attachment_axle_8 = {"parentSocket": "wheel-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03};
  const endpoint_axle_8 = makeAttachmentEndpoint(attachment_axle_8);
  const node_axle_8 = new THREE.Group();
  node_axle_8.name = "axle__pivot";
  node_axle_8.scale.set(1, 1, 1);
  if (endpoint_axle_8) {
    node_axle_8.position.copy(endpoint_axle_8.start);
    node_axle_8.rotation.set(0.0, 0.0, 0.0);
  } else {
    node_axle_8.position.set(0.0, 0.0, 0.0);
    node_axle_8.rotation.set(0.0, 0.0, 0.0);
  }
  node_axle_8.userData.sculptComponent = {"id": "axle", "name": "axle", "level": "meso", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "cylinder", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "wheel", "attachment": {"parentSocket": "wheel-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 0.22, "height": 1.85, "depth": 0.22, "units": "relative", "confidence": 0.5}, "transform": {"position": [0, 0, 0], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "axle", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "metal", "materialLayers": ["metal"], "deformations": [], "joints": [], "seams": [], "localFeatures": [{"id": "axle-collars", "type": "ridge", "placement": "photo-observed component surface", "size": [0.03, 0.03, 0.03], "confidence": 0.75, "geometryEffect": "repeated geometry or independent procedural surface channel", "materialEffect": "localized roughness and value variation", "evidenceRefs": ["full-object"]}], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#4d4f49", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(77, 79, 73, 1)", "secondaryAlbedo": "rgba(62, 64, 58, 1)", "materialClass": "metal", "materialClassConfidence": 0.8}};
  node_axle_8.userData.actionProfile = {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "axle", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}};
  (nodes["wheel"] ?? root).add(node_axle_8);
  nodes["axle"] = node_axle_8;
  const mesh_axle_8Geometry = endpoint_axle_8
    ? new THREE.CylinderGeometry(endpoint_axle_8.endRadius, endpoint_axle_8.baseRadius, endpoint_axle_8.length, 16, 6)
    : new THREE.CylinderGeometry(0.5, 0.5, 1, 24, 8);
  if (!endpoint_axle_8) {
    mesh_axle_8Geometry.scale(1.0, 1.0, 1.0);
  }
  const mesh_axle_8 = new THREE.Mesh(
    mesh_axle_8Geometry,
    materialMap["metal"] ?? new THREE.MeshStandardMaterial({ color: 0x888888 })
  );
  mesh_axle_8.name = "axle";
  if (endpoint_axle_8) {
    mesh_axle_8.position.copy(endpoint_axle_8.midpoint);
    mesh_axle_8.quaternion.copy(endpoint_axle_8.quaternion);
  }
  mesh_axle_8.castShadow = options.castShadow ?? true;
  mesh_axle_8.receiveShadow = options.receiveShadow ?? true;
  mesh_axle_8.userData.sculptComponent = {"id": "axle", "name": "axle", "level": "meso", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "cylinder", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "wheel", "attachment": {"parentSocket": "wheel-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 0.22, "height": 1.85, "depth": 0.22, "units": "relative", "confidence": 0.5}, "transform": {"position": [0, 0, 0], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "axle", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "metal", "materialLayers": ["metal"], "deformations": [], "joints": [], "seams": [], "localFeatures": [{"id": "axle-collars", "type": "ridge", "placement": "photo-observed component surface", "size": [0.03, 0.03, 0.03], "confidence": 0.75, "geometryEffect": "repeated geometry or independent procedural surface channel", "materialEffect": "localized roughness and value variation", "evidenceRefs": ["full-object"]}], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#4d4f49", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(77, 79, 73, 1)", "secondaryAlbedo": "rgba(62, 64, 58, 1)", "materialClass": "metal", "materialClassConfidence": 0.8}};
  node_axle_8.add(mesh_axle_8);
  meshes["axle"] = mesh_axle_8;
  colliders["axle"] = {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."};
  destructionGroups["axle"] ??= [];
  destructionGroups["axle"].push(node_axle_8);

  const endpoint_bearings_9 = makeAttachmentEndpoint(null);
  const node_bearings_9 = new THREE.Group();
  node_bearings_9.name = "bearings__pivot";
  node_bearings_9.scale.set(1, 1, 1);
  if (endpoint_bearings_9) {
    node_bearings_9.position.copy(endpoint_bearings_9.start);
    node_bearings_9.rotation.set(0.0, 0.0, 0.0);
  } else {
    node_bearings_9.position.set(1.35, 3.45, 0.0);
    node_bearings_9.rotation.set(0.0, 0.0, 0.0);
  }
  node_bearings_9.userData.sculptComponent = {"id": "bearings", "name": "bearings", "level": "meso", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "box", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "root", "attachment": {"parentSocket": "root-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 0.001, "height": 0.001, "depth": 0.001, "units": "relative", "confidence": 0.5}, "transform": {"position": [1.35, 3.45, 0], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "bearings", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "metal", "materialLayers": ["metal"], "deformations": [], "joints": [], "seams": [], "localFeatures": [{"id": "bearing-blocks", "type": "fastener", "placement": "photo-observed component surface", "size": [0.03, 0.03, 0.03], "confidence": 0.75, "geometryEffect": "repeated geometry or independent procedural surface channel", "materialEffect": "localized roughness and value variation", "evidenceRefs": ["full-object"]}], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#4d4f49", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(77, 79, 73, 1)", "secondaryAlbedo": "rgba(62, 64, 58, 1)", "materialClass": "metal", "materialClassConfidence": 0.8}};
  node_bearings_9.userData.actionProfile = {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "bearings", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}};
  (nodes["root"] ?? root).add(node_bearings_9);
  nodes["bearings"] = node_bearings_9;
  const mesh_bearings_9Geometry = endpoint_bearings_9
    ? new THREE.CylinderGeometry(endpoint_bearings_9.endRadius, endpoint_bearings_9.baseRadius, endpoint_bearings_9.length, 16, 6)
    : new THREE.BoxGeometry(1, 1, 1, 4, 4, 4);
  if (!endpoint_bearings_9) {
    mesh_bearings_9Geometry.scale(1.0, 1.0, 1.0);
  }
  const mesh_bearings_9 = new THREE.Mesh(
    mesh_bearings_9Geometry,
    materialMap["metal"] ?? new THREE.MeshStandardMaterial({ color: 0x888888 })
  );
  mesh_bearings_9.name = "bearings";
  if (endpoint_bearings_9) {
    mesh_bearings_9.position.copy(endpoint_bearings_9.midpoint);
    mesh_bearings_9.quaternion.copy(endpoint_bearings_9.quaternion);
  }
  mesh_bearings_9.castShadow = options.castShadow ?? true;
  mesh_bearings_9.receiveShadow = options.receiveShadow ?? true;
  mesh_bearings_9.userData.sculptComponent = {"id": "bearings", "name": "bearings", "level": "meso", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "box", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "root", "attachment": {"parentSocket": "root-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 0.001, "height": 0.001, "depth": 0.001, "units": "relative", "confidence": 0.5}, "transform": {"position": [1.35, 3.45, 0], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "bearings", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "metal", "materialLayers": ["metal"], "deformations": [], "joints": [], "seams": [], "localFeatures": [{"id": "bearing-blocks", "type": "fastener", "placement": "photo-observed component surface", "size": [0.03, 0.03, 0.03], "confidence": 0.75, "geometryEffect": "repeated geometry or independent procedural surface channel", "materialEffect": "localized roughness and value variation", "evidenceRefs": ["full-object"]}], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#4d4f49", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(77, 79, 73, 1)", "secondaryAlbedo": "rgba(62, 64, 58, 1)", "materialClass": "metal", "materialClassConfidence": 0.8}};
  node_bearings_9.add(mesh_bearings_9);
  meshes["bearings"] = mesh_bearings_9;
  colliders["bearings"] = {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."};
  destructionGroups["bearings"] ??= [];
  destructionGroups["bearings"].push(node_bearings_9);

  const endpoint_columns_10 = makeAttachmentEndpoint(null);
  const node_columns_10 = new THREE.Group();
  node_columns_10.name = "columns__pivot";
  node_columns_10.scale.set(1, 1, 1);
  if (endpoint_columns_10) {
    node_columns_10.position.copy(endpoint_columns_10.start);
    node_columns_10.rotation.set(0.0, 0.0, 0.0);
  } else {
    node_columns_10.position.set(0.0, 0.0, 0.0);
    node_columns_10.rotation.set(0.0, 0.0, 0.0);
  }
  node_columns_10.userData.sculptComponent = {"id": "columns", "name": "columns", "level": "meso", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "box", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "arcade", "attachment": {"parentSocket": "arcade-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 0.001, "height": 0.001, "depth": 0.001, "units": "relative", "confidence": 0.5}, "transform": {"position": [0, 0, 0], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "columns", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "stone", "materialLayers": ["stone"], "deformations": [], "joints": [], "seams": [], "localFeatures": [{"id": "stone-courses", "type": "linework", "placement": "photo-observed component surface", "size": [0.03, 0.03, 0.03], "confidence": 0.75, "geometryEffect": "repeated geometry or independent procedural surface channel", "materialEffect": "localized roughness and value variation", "evidenceRefs": ["full-object"]}], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#c9b58f", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(201, 181, 143, 1)", "secondaryAlbedo": "rgba(186, 166, 128, 1)", "materialClass": "stone", "materialClassConfidence": 0.8}};
  node_columns_10.userData.actionProfile = {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "columns", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}};
  (nodes["arcade"] ?? root).add(node_columns_10);
  nodes["columns"] = node_columns_10;
  const mesh_columns_10Geometry = endpoint_columns_10
    ? new THREE.CylinderGeometry(endpoint_columns_10.endRadius, endpoint_columns_10.baseRadius, endpoint_columns_10.length, 16, 6)
    : new THREE.BoxGeometry(1, 1, 1, 4, 4, 4);
  if (!endpoint_columns_10) {
    mesh_columns_10Geometry.scale(1.0, 1.0, 1.0);
  }
  const mesh_columns_10 = new THREE.Mesh(
    mesh_columns_10Geometry,
    materialMap["stone"] ?? new THREE.MeshStandardMaterial({ color: 0x888888 })
  );
  mesh_columns_10.name = "columns";
  if (endpoint_columns_10) {
    mesh_columns_10.position.copy(endpoint_columns_10.midpoint);
    mesh_columns_10.quaternion.copy(endpoint_columns_10.quaternion);
  }
  mesh_columns_10.castShadow = options.castShadow ?? true;
  mesh_columns_10.receiveShadow = options.receiveShadow ?? true;
  mesh_columns_10.userData.sculptComponent = {"id": "columns", "name": "columns", "level": "meso", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "box", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "arcade", "attachment": {"parentSocket": "arcade-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 0.001, "height": 0.001, "depth": 0.001, "units": "relative", "confidence": 0.5}, "transform": {"position": [0, 0, 0], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "columns", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "stone", "materialLayers": ["stone"], "deformations": [], "joints": [], "seams": [], "localFeatures": [{"id": "stone-courses", "type": "linework", "placement": "photo-observed component surface", "size": [0.03, 0.03, 0.03], "confidence": 0.75, "geometryEffect": "repeated geometry or independent procedural surface channel", "materialEffect": "localized roughness and value variation", "evidenceRefs": ["full-object"]}], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#c9b58f", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(201, 181, 143, 1)", "secondaryAlbedo": "rgba(186, 166, 128, 1)", "materialClass": "stone", "materialClassConfidence": 0.8}};
  node_columns_10.add(mesh_columns_10);
  meshes["columns"] = mesh_columns_10;
  colliders["columns"] = {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."};
  destructionGroups["columns"] ??= [];
  destructionGroups["columns"].push(node_columns_10);

  const endpoint_lintel_11 = makeAttachmentEndpoint(null);
  const node_lintel_11 = new THREE.Group();
  node_lintel_11.name = "lintel__pivot";
  node_lintel_11.scale.set(1, 1, 1);
  if (endpoint_lintel_11) {
    node_lintel_11.position.copy(endpoint_lintel_11.start);
    node_lintel_11.rotation.set(0.0, 0.0, 0.0);
  } else {
    node_lintel_11.position.set(0.0, 3.65, 0.0);
    node_lintel_11.rotation.set(0.0, 0.0, 0.0);
  }
  node_lintel_11.userData.sculptComponent = {"id": "lintel", "name": "lintel", "level": "meso", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "box", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "arcade", "attachment": {"parentSocket": "arcade-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 6.7, "height": 0.66, "depth": 0.63, "units": "relative", "confidence": 0.5}, "transform": {"position": [0, 3.65, 0], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "lintel", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "stone", "materialLayers": ["stone"], "deformations": [], "joints": [], "seams": [], "localFeatures": [{"id": "lintel-joints", "type": "linework", "placement": "photo-observed component surface", "size": [0.03, 0.03, 0.03], "confidence": 0.75, "geometryEffect": "repeated geometry or independent procedural surface channel", "materialEffect": "localized roughness and value variation", "evidenceRefs": ["full-object"]}], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#c9b58f", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(201, 181, 143, 1)", "secondaryAlbedo": "rgba(186, 166, 128, 1)", "materialClass": "stone", "materialClassConfidence": 0.8}};
  node_lintel_11.userData.actionProfile = {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "lintel", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}};
  (nodes["arcade"] ?? root).add(node_lintel_11);
  nodes["lintel"] = node_lintel_11;
  const mesh_lintel_11Geometry = endpoint_lintel_11
    ? new THREE.CylinderGeometry(endpoint_lintel_11.endRadius, endpoint_lintel_11.baseRadius, endpoint_lintel_11.length, 16, 6)
    : new THREE.BoxGeometry(1, 1, 1, 4, 4, 4);
  if (!endpoint_lintel_11) {
    mesh_lintel_11Geometry.scale(1.0, 1.0, 1.0);
  }
  const mesh_lintel_11 = new THREE.Mesh(
    mesh_lintel_11Geometry,
    materialMap["stone"] ?? new THREE.MeshStandardMaterial({ color: 0x888888 })
  );
  mesh_lintel_11.name = "lintel";
  if (endpoint_lintel_11) {
    mesh_lintel_11.position.copy(endpoint_lintel_11.midpoint);
    mesh_lintel_11.quaternion.copy(endpoint_lintel_11.quaternion);
  }
  mesh_lintel_11.castShadow = options.castShadow ?? true;
  mesh_lintel_11.receiveShadow = options.receiveShadow ?? true;
  mesh_lintel_11.userData.sculptComponent = {"id": "lintel", "name": "lintel", "level": "meso", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "box", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "arcade", "attachment": {"parentSocket": "arcade-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 6.7, "height": 0.66, "depth": 0.63, "units": "relative", "confidence": 0.5}, "transform": {"position": [0, 3.65, 0], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "lintel", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "stone", "materialLayers": ["stone"], "deformations": [], "joints": [], "seams": [], "localFeatures": [{"id": "lintel-joints", "type": "linework", "placement": "photo-observed component surface", "size": [0.03, 0.03, 0.03], "confidence": 0.75, "geometryEffect": "repeated geometry or independent procedural surface channel", "materialEffect": "localized roughness and value variation", "evidenceRefs": ["full-object"]}], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#c9b58f", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(201, 181, 143, 1)", "secondaryAlbedo": "rgba(186, 166, 128, 1)", "materialClass": "stone", "materialClassConfidence": 0.8}};
  node_lintel_11.add(mesh_lintel_11);
  meshes["lintel"] = mesh_lintel_11;
  colliders["lintel"] = {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."};
  destructionGroups["lintel"] ??= [];
  destructionGroups["lintel"].push(node_lintel_11);

  const endpoint_basin_12 = makeAttachmentEndpoint(null);
  const node_basin_12 = new THREE.Group();
  node_basin_12.name = "basin__pivot";
  node_basin_12.scale.set(1, 1, 1);
  if (endpoint_basin_12) {
    node_basin_12.position.copy(endpoint_basin_12.start);
    node_basin_12.rotation.set(0.0, 0.0, 0.0);
  } else {
    node_basin_12.position.set(-0.5, 0.12, 0.3);
    node_basin_12.rotation.set(0.0, 0.0, 0.0);
  }
  node_basin_12.userData.sculptComponent = {"id": "basin", "name": "basin", "level": "meso", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "box", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "root", "attachment": {"parentSocket": "root-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 9.7, "height": 0.24, "depth": 2.8, "units": "relative", "confidence": 0.5}, "transform": {"position": [-0.5, 0.12, 0.3], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "basin", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "tile", "materialLayers": ["tile"], "deformations": [], "joints": [], "seams": [], "localFeatures": [{"id": "blue-tiles", "type": "linework", "placement": "photo-observed component surface", "size": [0.03, 0.03, 0.03], "confidence": 0.75, "geometryEffect": "repeated geometry or independent procedural surface channel", "materialEffect": "localized roughness and value variation", "evidenceRefs": ["full-object"]}], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#719a9c", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(113, 154, 156, 1)", "secondaryAlbedo": "rgba(98, 139, 141, 1)", "materialClass": "ceramic", "materialClassConfidence": 0.8}};
  node_basin_12.userData.actionProfile = {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "basin", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}};
  (nodes["root"] ?? root).add(node_basin_12);
  nodes["basin"] = node_basin_12;
  const mesh_basin_12Geometry = endpoint_basin_12
    ? new THREE.CylinderGeometry(endpoint_basin_12.endRadius, endpoint_basin_12.baseRadius, endpoint_basin_12.length, 16, 6)
    : new THREE.BoxGeometry(1, 1, 1, 4, 4, 4);
  if (!endpoint_basin_12) {
    mesh_basin_12Geometry.scale(1.0, 1.0, 1.0);
  }
  const mesh_basin_12 = new THREE.Mesh(
    mesh_basin_12Geometry,
    materialMap["tile"] ?? new THREE.MeshStandardMaterial({ color: 0x888888 })
  );
  mesh_basin_12.name = "basin";
  if (endpoint_basin_12) {
    mesh_basin_12.position.copy(endpoint_basin_12.midpoint);
    mesh_basin_12.quaternion.copy(endpoint_basin_12.quaternion);
  }
  mesh_basin_12.castShadow = options.castShadow ?? true;
  mesh_basin_12.receiveShadow = options.receiveShadow ?? true;
  mesh_basin_12.userData.sculptComponent = {"id": "basin", "name": "basin", "level": "meso", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "box", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "root", "attachment": {"parentSocket": "root-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 9.7, "height": 0.24, "depth": 2.8, "units": "relative", "confidence": 0.5}, "transform": {"position": [-0.5, 0.12, 0.3], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "basin", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "tile", "materialLayers": ["tile"], "deformations": [], "joints": [], "seams": [], "localFeatures": [{"id": "blue-tiles", "type": "linework", "placement": "photo-observed component surface", "size": [0.03, 0.03, 0.03], "confidence": 0.75, "geometryEffect": "repeated geometry or independent procedural surface channel", "materialEffect": "localized roughness and value variation", "evidenceRefs": ["full-object"]}], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#719a9c", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(113, 154, 156, 1)", "secondaryAlbedo": "rgba(98, 139, 141, 1)", "materialClass": "ceramic", "materialClassConfidence": 0.8}};
  node_basin_12.add(mesh_basin_12);
  meshes["basin"] = mesh_basin_12;
  colliders["basin"] = {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."};
  destructionGroups["basin"] ??= [];
  destructionGroups["basin"].push(node_basin_12);

  const endpoint_water_13 = makeAttachmentEndpoint(null);
  const node_water_13 = new THREE.Group();
  node_water_13.name = "water__pivot";
  node_water_13.scale.set(1, 1, 1);
  if (endpoint_water_13) {
    node_water_13.position.copy(endpoint_water_13.start);
    node_water_13.rotation.set(0.0, 0.0, 0.0);
  } else {
    node_water_13.position.set(-0.5, 0.27, 0.3);
    node_water_13.rotation.set(0.0, 0.0, 0.0);
  }
  node_water_13.userData.sculptComponent = {"id": "water", "name": "water", "level": "meso", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "box", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "root", "attachment": {"parentSocket": "root-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 9.4, "height": 0.03, "depth": 2.5, "units": "relative", "confidence": 0.5}, "transform": {"position": [-0.5, 0.27, 0.3], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "water", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "water", "materialLayers": ["water"], "deformations": [], "joints": [], "seams": [], "localFeatures": [{"id": "water-highlights", "type": "gloss", "placement": "photo-observed component surface", "size": [0.03, 0.03, 0.03], "confidence": 0.75, "geometryEffect": "repeated geometry or independent procedural surface channel", "materialEffect": "localized roughness and value variation", "evidenceRefs": ["full-object"]}], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#367d87", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(54, 125, 135, 1)", "secondaryAlbedo": "rgba(39, 110, 120, 1)", "materialClass": "glass", "materialClassConfidence": 0.8}};
  node_water_13.userData.actionProfile = {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "water", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}};
  (nodes["root"] ?? root).add(node_water_13);
  nodes["water"] = node_water_13;
  const mesh_water_13Geometry = endpoint_water_13
    ? new THREE.CylinderGeometry(endpoint_water_13.endRadius, endpoint_water_13.baseRadius, endpoint_water_13.length, 16, 6)
    : new THREE.BoxGeometry(1, 1, 1, 4, 4, 4);
  if (!endpoint_water_13) {
    mesh_water_13Geometry.scale(1.0, 1.0, 1.0);
  }
  const mesh_water_13 = new THREE.Mesh(
    mesh_water_13Geometry,
    materialMap["water"] ?? new THREE.MeshStandardMaterial({ color: 0x888888 })
  );
  mesh_water_13.name = "water";
  if (endpoint_water_13) {
    mesh_water_13.position.copy(endpoint_water_13.midpoint);
    mesh_water_13.quaternion.copy(endpoint_water_13.quaternion);
  }
  mesh_water_13.castShadow = options.castShadow ?? true;
  mesh_water_13.receiveShadow = options.receiveShadow ?? true;
  mesh_water_13.userData.sculptComponent = {"id": "water", "name": "water", "level": "meso", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "box", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "root", "attachment": {"parentSocket": "root-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 9.4, "height": 0.03, "depth": 2.5, "units": "relative", "confidence": 0.5}, "transform": {"position": [-0.5, 0.27, 0.3], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "water", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "water", "materialLayers": ["water"], "deformations": [], "joints": [], "seams": [], "localFeatures": [{"id": "water-highlights", "type": "gloss", "placement": "photo-observed component surface", "size": [0.03, 0.03, 0.03], "confidence": 0.75, "geometryEffect": "repeated geometry or independent procedural surface channel", "materialEffect": "localized roughness and value variation", "evidenceRefs": ["full-object"]}], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#367d87", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(54, 125, 135, 1)", "secondaryAlbedo": "rgba(39, 110, 120, 1)", "materialClass": "glass", "materialClassConfidence": 0.8}};
  node_water_13.add(mesh_water_13);
  meshes["water"] = mesh_water_13;
  colliders["water"] = {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."};
  destructionGroups["water"] ??= [];
  destructionGroups["water"].push(node_water_13);

  const endpoint_facade_14 = makeAttachmentEndpoint(null);
  const node_facade_14 = new THREE.Group();
  node_facade_14.name = "facade__pivot";
  node_facade_14.scale.set(1, 1, 1);
  if (endpoint_facade_14) {
    node_facade_14.position.copy(endpoint_facade_14.start);
    node_facade_14.rotation.set(0.0, 0.0, 0.0);
  } else {
    node_facade_14.position.set(0.0, 3.6, 0.0);
    node_facade_14.rotation.set(0.0, 0.0, 0.0);
  }
  node_facade_14.userData.sculptComponent = {"id": "facade", "name": "facade", "level": "meso", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "box", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "context", "attachment": {"parentSocket": "context-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 11, "height": 7.2, "depth": 0.4, "units": "relative", "confidence": 0.5}, "transform": {"position": [0, 3.6, 0], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "facade", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "stone", "materialLayers": ["stone"], "deformations": [], "joints": [], "seams": [], "localFeatures": [{"id": "window-recesses", "type": "linework", "placement": "photo-observed component surface", "size": [0.03, 0.03, 0.03], "confidence": 0.75, "geometryEffect": "repeated geometry or independent procedural surface channel", "materialEffect": "localized roughness and value variation", "evidenceRefs": ["full-object"]}], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#c9b58f", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(201, 181, 143, 1)", "secondaryAlbedo": "rgba(186, 166, 128, 1)", "materialClass": "stone", "materialClassConfidence": 0.8}};
  node_facade_14.userData.actionProfile = {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "facade", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}};
  (nodes["context"] ?? root).add(node_facade_14);
  nodes["facade"] = node_facade_14;
  const mesh_facade_14Geometry = endpoint_facade_14
    ? new THREE.CylinderGeometry(endpoint_facade_14.endRadius, endpoint_facade_14.baseRadius, endpoint_facade_14.length, 16, 6)
    : new THREE.BoxGeometry(1, 1, 1, 4, 4, 4);
  if (!endpoint_facade_14) {
    mesh_facade_14Geometry.scale(1.0, 1.0, 1.0);
  }
  const mesh_facade_14 = new THREE.Mesh(
    mesh_facade_14Geometry,
    materialMap["stone"] ?? new THREE.MeshStandardMaterial({ color: 0x888888 })
  );
  mesh_facade_14.name = "facade";
  if (endpoint_facade_14) {
    mesh_facade_14.position.copy(endpoint_facade_14.midpoint);
    mesh_facade_14.quaternion.copy(endpoint_facade_14.quaternion);
  }
  mesh_facade_14.castShadow = options.castShadow ?? true;
  mesh_facade_14.receiveShadow = options.receiveShadow ?? true;
  mesh_facade_14.userData.sculptComponent = {"id": "facade", "name": "facade", "level": "meso", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "box", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "context", "attachment": {"parentSocket": "context-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 11, "height": 7.2, "depth": 0.4, "units": "relative", "confidence": 0.5}, "transform": {"position": [0, 3.6, 0], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "facade", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "stone", "materialLayers": ["stone"], "deformations": [], "joints": [], "seams": [], "localFeatures": [{"id": "window-recesses", "type": "linework", "placement": "photo-observed component surface", "size": [0.03, 0.03, 0.03], "confidence": 0.75, "geometryEffect": "repeated geometry or independent procedural surface channel", "materialEffect": "localized roughness and value variation", "evidenceRefs": ["full-object"]}], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#c9b58f", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(201, 181, 143, 1)", "secondaryAlbedo": "rgba(186, 166, 128, 1)", "materialClass": "stone", "materialClassConfidence": 0.8}};
  node_facade_14.add(mesh_facade_14);
  meshes["facade"] = mesh_facade_14;
  colliders["facade"] = {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."};
  destructionGroups["facade"] ??= [];
  destructionGroups["facade"].push(node_facade_14);

  const endpoint_glazing_15 = makeAttachmentEndpoint(null);
  const node_glazing_15 = new THREE.Group();
  node_glazing_15.name = "glazing__pivot";
  node_glazing_15.scale.set(1, 1, 1);
  if (endpoint_glazing_15) {
    node_glazing_15.position.copy(endpoint_glazing_15.start);
    node_glazing_15.rotation.set(0.0, 0.0, 0.0);
  } else {
    node_glazing_15.position.set(-4.0, 3.5, 0.3);
    node_glazing_15.rotation.set(0.0, 0.0, 0.0);
  }
  node_glazing_15.userData.sculptComponent = {"id": "glazing", "name": "glazing", "level": "meso", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "box", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "context", "attachment": {"parentSocket": "context-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 3.2, "height": 6.7, "depth": 0.14, "units": "relative", "confidence": 0.5}, "transform": {"position": [-4, 3.5, 0.3], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "glazing", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "glass", "materialLayers": ["glass"], "deformations": [], "joints": [], "seams": [], "localFeatures": [], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#4c7585", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(76, 117, 133, 1)", "secondaryAlbedo": "rgba(61, 102, 118, 1)", "materialClass": "glass", "materialClassConfidence": 0.8}};
  node_glazing_15.userData.actionProfile = {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "glazing", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}};
  (nodes["context"] ?? root).add(node_glazing_15);
  nodes["glazing"] = node_glazing_15;
  const mesh_glazing_15Geometry = endpoint_glazing_15
    ? new THREE.CylinderGeometry(endpoint_glazing_15.endRadius, endpoint_glazing_15.baseRadius, endpoint_glazing_15.length, 16, 6)
    : new THREE.BoxGeometry(1, 1, 1, 4, 4, 4);
  if (!endpoint_glazing_15) {
    mesh_glazing_15Geometry.scale(1.0, 1.0, 1.0);
  }
  const mesh_glazing_15 = new THREE.Mesh(
    mesh_glazing_15Geometry,
    materialMap["glass"] ?? new THREE.MeshStandardMaterial({ color: 0x888888 })
  );
  mesh_glazing_15.name = "glazing";
  if (endpoint_glazing_15) {
    mesh_glazing_15.position.copy(endpoint_glazing_15.midpoint);
    mesh_glazing_15.quaternion.copy(endpoint_glazing_15.quaternion);
  }
  mesh_glazing_15.castShadow = options.castShadow ?? true;
  mesh_glazing_15.receiveShadow = options.receiveShadow ?? true;
  mesh_glazing_15.userData.sculptComponent = {"id": "glazing", "name": "glazing", "level": "meso", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "box", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "context", "attachment": {"parentSocket": "context-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 3.2, "height": 6.7, "depth": 0.14, "units": "relative", "confidence": 0.5}, "transform": {"position": [-4, 3.5, 0.3], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "glazing", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "glass", "materialLayers": ["glass"], "deformations": [], "joints": [], "seams": [], "localFeatures": [], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#4c7585", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(76, 117, 133, 1)", "secondaryAlbedo": "rgba(61, 102, 118, 1)", "materialClass": "glass", "materialClassConfidence": 0.8}};
  node_glazing_15.add(mesh_glazing_15);
  meshes["glazing"] = mesh_glazing_15;
  colliders["glazing"] = {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."};
  destructionGroups["glazing"] ??= [];
  destructionGroups["glazing"].push(node_glazing_15);

  const endpoint_mullions_16 = makeAttachmentEndpoint(null);
  const node_mullions_16 = new THREE.Group();
  node_mullions_16.name = "mullions__pivot";
  node_mullions_16.scale.set(1, 1, 1);
  if (endpoint_mullions_16) {
    node_mullions_16.position.copy(endpoint_mullions_16.start);
    node_mullions_16.rotation.set(0.0, 0.0, 0.0);
  } else {
    node_mullions_16.position.set(-4.0, 3.5, 0.4);
    node_mullions_16.rotation.set(0.0, 0.0, 0.0);
  }
  node_mullions_16.userData.sculptComponent = {"id": "mullions", "name": "mullions", "level": "micro", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "box", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "context", "attachment": {"parentSocket": "context-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 0.001, "height": 0.001, "depth": 0.001, "units": "relative", "confidence": 0.5}, "transform": {"position": [-4, 3.5, 0.4], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "mullions", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "metal", "materialLayers": ["metal"], "deformations": [], "joints": [], "seams": [], "localFeatures": [{"id": "window-grid", "type": "linework", "placement": "photo-observed component surface", "size": [0.03, 0.03, 0.03], "confidence": 0.75, "geometryEffect": "repeated geometry or independent procedural surface channel", "materialEffect": "localized roughness and value variation", "evidenceRefs": ["full-object"]}], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#4d4f49", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(77, 79, 73, 1)", "secondaryAlbedo": "rgba(62, 64, 58, 1)", "materialClass": "metal", "materialClassConfidence": 0.8}};
  node_mullions_16.userData.actionProfile = {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "mullions", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}};
  (nodes["context"] ?? root).add(node_mullions_16);
  nodes["mullions"] = node_mullions_16;
  const mesh_mullions_16Geometry = endpoint_mullions_16
    ? new THREE.CylinderGeometry(endpoint_mullions_16.endRadius, endpoint_mullions_16.baseRadius, endpoint_mullions_16.length, 16, 6)
    : new THREE.BoxGeometry(1, 1, 1, 4, 4, 4);
  if (!endpoint_mullions_16) {
    mesh_mullions_16Geometry.scale(1.0, 1.0, 1.0);
  }
  const mesh_mullions_16 = new THREE.Mesh(
    mesh_mullions_16Geometry,
    materialMap["metal"] ?? new THREE.MeshStandardMaterial({ color: 0x888888 })
  );
  mesh_mullions_16.name = "mullions";
  if (endpoint_mullions_16) {
    mesh_mullions_16.position.copy(endpoint_mullions_16.midpoint);
    mesh_mullions_16.quaternion.copy(endpoint_mullions_16.quaternion);
  }
  mesh_mullions_16.castShadow = options.castShadow ?? true;
  mesh_mullions_16.receiveShadow = options.receiveShadow ?? true;
  mesh_mullions_16.userData.sculptComponent = {"id": "mullions", "name": "mullions", "level": "micro", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "box", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "context", "attachment": {"parentSocket": "context-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 0.001, "height": 0.001, "depth": 0.001, "units": "relative", "confidence": 0.5}, "transform": {"position": [-4, 3.5, 0.4], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "mullions", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "metal", "materialLayers": ["metal"], "deformations": [], "joints": [], "seams": [], "localFeatures": [{"id": "window-grid", "type": "linework", "placement": "photo-observed component surface", "size": [0.03, 0.03, 0.03], "confidence": 0.75, "geometryEffect": "repeated geometry or independent procedural surface channel", "materialEffect": "localized roughness and value variation", "evidenceRefs": ["full-object"]}], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#4d4f49", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(77, 79, 73, 1)", "secondaryAlbedo": "rgba(62, 64, 58, 1)", "materialClass": "metal", "materialClassConfidence": 0.8}};
  node_mullions_16.add(mesh_mullions_16);
  meshes["mullions"] = mesh_mullions_16;
  colliders["mullions"] = {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."};
  destructionGroups["mullions"] ??= [];
  destructionGroups["mullions"].push(node_mullions_16);

  const endpoint_rim_fasteners_17 = makeAttachmentEndpoint(null);
  const node_rim_fasteners_17 = new THREE.Group();
  node_rim_fasteners_17.name = "rim-fasteners__pivot";
  node_rim_fasteners_17.scale.set(1, 1, 1);
  if (endpoint_rim_fasteners_17) {
    node_rim_fasteners_17.position.copy(endpoint_rim_fasteners_17.start);
    node_rim_fasteners_17.rotation.set(0.0, 0.0, 0.0);
  } else {
    node_rim_fasteners_17.position.set(0.0, 0.0, 0.0);
    node_rim_fasteners_17.rotation.set(0.0, 0.0, 0.0);
  }
  node_rim_fasteners_17.userData.sculptComponent = {"id": "rim-fasteners", "name": "rim-fasteners", "level": "micro", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "sphere", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "wheel", "attachment": {"parentSocket": "wheel-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 0.001, "height": 0.001, "depth": 0.001, "units": "relative", "confidence": 0.5}, "transform": {"position": [0, 0, 0], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "rim-fasteners", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "metal", "materialLayers": ["metal"], "deformations": [], "joints": [], "seams": [], "localFeatures": [], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#4d4f49", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(77, 79, 73, 1)", "secondaryAlbedo": "rgba(62, 64, 58, 1)", "materialClass": "metal", "materialClassConfidence": 0.8}};
  node_rim_fasteners_17.userData.actionProfile = {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "rim-fasteners", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}};
  (nodes["wheel"] ?? root).add(node_rim_fasteners_17);
  nodes["rim-fasteners"] = node_rim_fasteners_17;
  const mesh_rim_fasteners_17Geometry = endpoint_rim_fasteners_17
    ? new THREE.CylinderGeometry(endpoint_rim_fasteners_17.endRadius, endpoint_rim_fasteners_17.baseRadius, endpoint_rim_fasteners_17.length, 16, 6)
    : new THREE.SphereGeometry(0.5, 32, 20);
  if (!endpoint_rim_fasteners_17) {
    mesh_rim_fasteners_17Geometry.scale(1.0, 1.0, 1.0);
  }
  const mesh_rim_fasteners_17 = new THREE.Mesh(
    mesh_rim_fasteners_17Geometry,
    materialMap["metal"] ?? new THREE.MeshStandardMaterial({ color: 0x888888 })
  );
  mesh_rim_fasteners_17.name = "rim-fasteners";
  if (endpoint_rim_fasteners_17) {
    mesh_rim_fasteners_17.position.copy(endpoint_rim_fasteners_17.midpoint);
    mesh_rim_fasteners_17.quaternion.copy(endpoint_rim_fasteners_17.quaternion);
  }
  mesh_rim_fasteners_17.castShadow = options.castShadow ?? true;
  mesh_rim_fasteners_17.receiveShadow = options.receiveShadow ?? true;
  mesh_rim_fasteners_17.userData.sculptComponent = {"id": "rim-fasteners", "name": "rim-fasteners", "level": "micro", "role": "architectural part", "importance": 1.0, "confidence": 0.8, "primitive": "sphere", "topologyClass": "assembled-solid", "topologyRationale": "Distinct rigid annular timber sections or planar masonry; continuous liquid surface is simplified.", "geometryDescriptor": {"topologyIntent": "low-poly blockout with bevel-ready edges", "edgeTreatment": {"type": "none", "bevelRadius": 0.0, "segments": 1}, "deformationStack": [], "uvStrategy": "generated procedural coordinates", "normalStrategy": "vertex normals from generated geometry"}, "parent": "wheel", "attachment": {"parentSocket": "wheel-mount", "localStart": [0, 0, 0], "localEnd": [0, 0.1, 0], "contactType": "overlap", "overlap": 0.02, "embedDepth": 0.02, "gapTolerance": 0.03}, "dimensions": {"width": 0.001, "height": 0.001, "depth": 0.001, "units": "relative", "confidence": 0.5}, "transform": {"position": [0, 0, 0], "rotation": [0, 0, 0], "scale": [1, 1, 1]}, "actionProfile": {"animationRole": "static", "pivot": {"mode": "center", "localPosition": [0, 0, 0], "axis": [0, 0, 1], "confidence": 0.5}, "transformChannels": {"translate": true, "rotate": true, "scale": true, "bend": false, "twist": false, "detach": false, "visibility": true, "materialState": true}, "sockets": [], "collider": {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."}, "constraints": [], "destruction": {"breakable": false, "fractureGroup": "rim-fasteners", "seamRefs": [], "detachableFragments": [], "breakImpulse": 0.0, "debrisMaterial": "base"}}, "material": "metal", "materialLayers": ["metal"], "deformations": [], "joints": [], "seams": [], "localFeatures": [], "surfaceDetail": {"macroRoughness": 0.0, "microRoughness": 0.0, "bumpAmplitude": 0.0, "normalPattern": "", "displacementPattern": "", "occlusionPattern": "", "edgeWearPattern": "", "notes": ""}, "evidenceRefs": ["full-object"], "details": [], "fidelityTier": "reference-grounded approximation", "colorMaterialRecipe": {"baseColor": "#4d4f49", "finish": "rough porous limestone / satin weathered timber / reflective water as appropriate", "evidenceRefs": ["full-object"], "dominantAlbedo": "rgba(77, 79, 73, 1)", "secondaryAlbedo": "rgba(62, 64, 58, 1)", "materialClass": "metal", "materialClassConfidence": 0.8}};
  node_rim_fasteners_17.add(mesh_rim_fasteners_17);
  meshes["rim-fasteners"] = mesh_rim_fasteners_17;
  colliders["rim-fasteners"] = {"type": "box", "offset": [0, 0, 0], "scale": [1, 1, 1], "isTrigger": false, "notes": "Replace with sphere/capsule/compound proxy when the object shape demands it."};
  destructionGroups["rim-fasteners"] ??= [];
  destructionGroups["rim-fasteners"].push(node_rim_fasteners_17);

  root.userData.sculptRuntime = { nodes, meshes, sockets, colliders, destructionGroups } satisfies ProceduralModelRuntime;
  root.userData.lookDevTargets = {"qualityPriority": "reference-fidelity", "materialPass": {"albedoPaletteRequired": true, "roughnessVariationRequired": true, "normalOrBumpRequired": true, "localOverridesRequired": true, "minimumTextureResolution": 1024, "preferredTextureResolution": 2048, "independentMapChannels": ["albedo", "roughness", "height", "normal", "ambient-occlusion"], "requiredSurfaceFrequencyBands": ["macro", "meso", "micro"], "geometryReliefRequiredWhenSilhouetteAffected": true, "referencePbrExtraction": {"requiredWhenSourceImagePresent": true, "targetThreshold": 0.7, "stopOnLowConfidence": true, "script": "forge/stage1_intake/extract_pbr_evidence.py", "acceptedLimitation": "single-image extraction is reference-derived inference, not exact photogrammetry"}, "mustAvoid": ["single flat albedo per material", "uniform roughness", "albedo texture reused as roughness/height/normal/AO", "single-frequency random noise", "plastic-looking smooth bark, stone, cloth, foliage, or aged material", "local color/detail described only in prose without material masks", "claiming exact PBR recovery when confidence is below the target threshold"]}, "lightingPass": {"requiredTerms": ["key light", "fill light", "rim or environment light", "exposure", "tone mapping", "background", "contact shadow"], "mustAvoid": ["ambient-only lighting", "flat value range", "missing contact shadow", "reference lighting copied without separating material readability"]}, "screenshotReview": ["Compare albedo palette and local color zones.", "Compare roughness/normal/bump response under light.", "Compare cavity dirt, edge wear, stains, moss, scratches, or other local masks.", "Compare key/fill/rim structure, exposure, tone mapping, background, and contact shadows.", "Capture a neutral-light render to verify material readability without reference lighting.", "Capture a grazing-light close-up to expose flat normals, uniform roughness, tiling, and plastic highlights.", "Capture a reference-matched render from the same camera framing as the source."]};
  root.userData.actionReadiness = {
    note: 'Use root.userData.sculptRuntime.nodes for transforms, sockets for attachments, colliders for physics proxies, and destructionGroups for breakable sets.',
  };
  return root;
}

export function createGJUCourtyardWaterwheelLookDevLights(
  mode: 'neutral' | 'grazing' | 'reference' = 'neutral',
): THREE.Group {
  const lights = new THREE.Group();
  lights.name = "GJU Courtyard Waterwheel look-dev lights";
  const hemi = new THREE.HemisphereLight(
    mode === 'reference' ? 0xfff0d6 : 0xf2f4ff,
    0x363b42,
    mode === 'grazing' ? 0.28 : mode === 'reference' ? 0.72 : 0.85,
  );
  lights.add(hemi);
  const key = new THREE.DirectionalLight(
    mode === 'reference' ? 0xffcf8a : 0xfff4e8,
    mode === 'grazing' ? 4.2 : mode === 'reference' ? 2.6 : 2.15,
  );
  if (mode === 'grazing') key.position.set(7.5, 1.1, 4.0);
  else if (mode === 'reference') key.position.set(-4.5, 7.5, 5.0);
  else key.position.set(-4.0, 6.0, 5.5);
  key.castShadow = true;
  key.shadow.mapSize.set(4096, 4096);
  key.shadow.bias = -0.00025;
  key.shadow.normalBias = 0.018;
  key.shadow.radius = 7;
  key.shadow.blurSamples = 24;
  key.shadow.camera.near = 0.5;
  key.shadow.camera.far = 30;
  key.shadow.camera.left = -2.6;
  key.shadow.camera.right = 2.6;
  key.shadow.camera.top = 2.6;
  key.shadow.camera.bottom = -2.6;
  key.shadow.camera.updateProjectionMatrix();
  lights.add(key);
  const fill = new THREE.DirectionalLight(0xa8c4ff, mode === 'grazing' ? 0.12 : 0.42);
  fill.position.set(4.0, 3.0, 3.5);
  lights.add(fill);
  const rim = new THREE.DirectionalLight(0xfff1c4, mode === 'grazing' ? 0.28 : 0.85);
  rim.position.set(0.5, 4.5, -6.0);
  lights.add(rim);
  lights.userData.reviewMode = mode;
  lights.userData.lightingFromPhoto = ["Key directional warm sunlight (7,11,8), intensity 2.3; shadows 1024 PCF soft contact shadow.", "Sky/ground hemisphere fill .9 with cool sky and muted warm ground.", "Environment pale blue-gray, ACES tone mapping exposure 1.05; no HDR download."];
  lights.userData.lookDevTargets = {"qualityPriority": "reference-fidelity", "materialPass": {"albedoPaletteRequired": true, "roughnessVariationRequired": true, "normalOrBumpRequired": true, "localOverridesRequired": true, "minimumTextureResolution": 1024, "preferredTextureResolution": 2048, "independentMapChannels": ["albedo", "roughness", "height", "normal", "ambient-occlusion"], "requiredSurfaceFrequencyBands": ["macro", "meso", "micro"], "geometryReliefRequiredWhenSilhouetteAffected": true, "referencePbrExtraction": {"requiredWhenSourceImagePresent": true, "targetThreshold": 0.7, "stopOnLowConfidence": true, "script": "forge/stage1_intake/extract_pbr_evidence.py", "acceptedLimitation": "single-image extraction is reference-derived inference, not exact photogrammetry"}, "mustAvoid": ["single flat albedo per material", "uniform roughness", "albedo texture reused as roughness/height/normal/AO", "single-frequency random noise", "plastic-looking smooth bark, stone, cloth, foliage, or aged material", "local color/detail described only in prose without material masks", "claiming exact PBR recovery when confidence is below the target threshold"]}, "lightingPass": {"requiredTerms": ["key light", "fill light", "rim or environment light", "exposure", "tone mapping", "background", "contact shadow"], "mustAvoid": ["ambient-only lighting", "flat value range", "missing contact shadow", "reference lighting copied without separating material readability"]}, "screenshotReview": ["Compare albedo palette and local color zones.", "Compare roughness/normal/bump response under light.", "Compare cavity dirt, edge wear, stains, moss, scratches, or other local masks.", "Compare key/fill/rim structure, exposure, tone mapping, background, and contact shadows.", "Capture a neutral-light render to verify material readability without reference lighting.", "Capture a grazing-light close-up to expose flat normals, uniform roughness, tiling, and plastic highlights.", "Capture a reference-matched render from the same camera framing as the source."]};
  return lights;
}

// PBR materials (clearcoat/iridescence/transmission/anisotropy) need an environment
// map to visually behave as intended — call this once per renderer and assign the
// result to scene.environment before rendering. No external HDR asset required.
export function createGJUCourtyardWaterwheelEnvironment(renderer: THREE.WebGLRenderer): THREE.Texture {
  const pmrem = new THREE.PMREMGenerator(renderer);
  const texture = pmrem.fromScene(new RoomEnvironment(), 0.04).texture;
  pmrem.dispose();
  return texture;
}

// Plan 1.3 §3.2 — auto-framing by bounding box. The Divine Eye can only compare a
// render to the reference if the object is FRAMED consistently (an object framed
// differently scores as wrong even when its shape is right). This positions the camera
// deterministically from the object's bounding box so it fills the frame at a stable
// margin, and sets near/far to the object scale. Call after adding the model to the
// scene, and again on resize (after updating camera.aspect).
export function frameGJUCourtyardWaterwheelCamera(
  camera: THREE.PerspectiveCamera,
  object: THREE.Object3D,
  options: { margin?: number; azimuthDeg?: number; elevationDeg?: number } = {},
): void {
  const box = new THREE.Box3().setFromObject(object);
  if (box.isEmpty()) return;
  const size = box.getSize(new THREE.Vector3());
  const center = box.getCenter(new THREE.Vector3());
  const margin = options.margin ?? 1.15;
  const maxDim = Math.max(size.x, size.y, size.z) * margin;
  const fov = (camera.fov * Math.PI) / 180;
  // distance so the largest object dimension fits vertically in the frame
  const distance = (maxDim / 2) / Math.tan(fov / 2);
  const az = ((options.azimuthDeg ?? 0) * Math.PI) / 180;
  const el = ((options.elevationDeg ?? 0) * Math.PI) / 180;
  const dir = new THREE.Vector3(
    Math.sin(az) * Math.cos(el),
    Math.sin(el),
    Math.cos(az) * Math.cos(el),
  );
  camera.position.copy(center).addScaledVector(dir, distance);
  camera.near = Math.max(0.01, distance - maxDim);
  camera.far = distance + maxDim * 2;
  camera.lookAt(center);
  camera.updateProjectionMatrix();
}

// Plan 1.3 §3.2c — PRESENTATION composer (DOF + bloom). CRITICAL (R-POSTFX): this is
// for the showcase/hero render ONLY. The Divine Eye's EVALUATION render MUST use a
// plain renderer with NO composer — bloom blows highlights and DOF blurs edges, which
// would corrupt the deterministic IoU/DCD/edge/blowout signals. Enable dof/bloom ONLY
// when the reference photo actually exhibits them (detect_reference_effects.py authorizes).
export function createGJUCourtyardWaterwheelPresentationComposer(
  renderer: THREE.WebGLRenderer,
  scene: THREE.Scene,
  camera: THREE.Camera,
  options: { dof?: boolean; bloom?: boolean; bloomStrength?: number; dofFocus?: number; dofAperture?: number } = {},
): EffectComposer {
  const composer = new EffectComposer(renderer);
  composer.addPass(new RenderPass(scene, camera));
  if (options.dof) {
    composer.addPass(new BokehPass(scene, camera, {
      focus: options.dofFocus ?? 10.0,
      aperture: options.dofAperture ?? 0.0002,
      maxblur: 0.01,
    }));
  }
  if (options.bloom) {
    const size = new THREE.Vector2();
    renderer.getSize(size);
    composer.addPass(new UnrealBloomPass(size, options.bloomStrength ?? 0.4, 0.4, 0.85));
  }
  return composer;
}

export function configureGJUCourtyardWaterwheelRenderer(renderer: THREE.WebGLRenderer): void {
  // Load-bearing for view-dependent finishes (anodized / Doppler): without ACES + sRGB
  // the environment reflection reads flat/washed instead of a believable metal response.
  renderer.toneMapping = THREE.ACESFilmicToneMapping;
  renderer.outputColorSpace = THREE.SRGBColorSpace;
}

export function createGJUCourtyardWaterwheelInspectControls(
  camera: THREE.Camera,
  domElement: HTMLElement,
): OrbitControls {
  // View-dependent finishes only read correctly once the user orbits — their color
  // comes from the environment reflection, not albedo, so free rotation matters here.
  const controls = new OrbitControls(camera, domElement);
  controls.enableDamping = true;
  controls.minDistance = 1.0;
  controls.maxDistance = 8.0;
  controls.autoRotate = false;
  return controls;
}

// Campus plan for the Jisr world (metres; +x east, -z north). Artistic, but follows the
// real GJU arrangement: limestone blocks with steel roof pergolas around a courtyard
// with the timber waterwheel, a glazed connector, solar-canopy parking and a long
// cypress-lined approach road through farmland.

export const BUILDINGS = [
 { id: 'west-wing', x: -46, z: -6, w: 30, d: 46, h: 24, facade: 'strip', crown: true, glassBase: true },
 { id: 'north-block', x: 2, z: -50, w: 54, d: 26, h: 27, facade: 'strip', crown: true },
 { id: 'east-tower', x: 46, z: -12, w: 26, d: 32, h: 31, facade: 'strip', crown: true, glassBase: true },
 { id: 'glass-connector', x: 33, z: -44, w: 16, d: 16, h: 19, facade: 'louvre' },
 { id: 'south-west', x: -42, z: 46, w: 34, d: 24, h: 20, facade: 'slots', crown: true },
 { id: 'south-east', x: 42, z: 42, w: 26, d: 30, h: 22, facade: 'strip', crown: true },
 { id: 'library', x: -4, z: 60, w: 26, d: 16, h: 12, facade: 'louvre' },
 { id: 'west-annex', x: -122, z: -42, w: 30, d: 30, h: 18, facade: 'strip', crown: true },
 { id: 'west-hall', x: -118, z: 32, w: 28, d: 42, h: 15, facade: 'slots' },
 { id: 'research-1', x: -12, z: -162, w: 42, d: 26, h: 12, facade: 'slots', solar: true },
 { id: 'research-2', x: 64, z: -150, w: 56, d: 28, h: 10, facade: 'strip', solar: true },
 { id: 'workshops', x: 142, z: -46, w: 34, d: 60, h: 9, facade: 'slots', solar: true }
];

// Barrel-roofed sports hall, top right of the real aerial view.
export const HALL = { x: 150, z: -150, w: 60, d: 44, h: 11 };

export const COURTYARD = { x0: -31, x1: 29, z0: -37, z1: 34 };
export const WATERWHEEL = { x: -10, z: -28 };

// Roads (polylines in metres).
const spine = [];
for (let z = -2600; z <= 2600; z += 40) spine.push({ x: 108 + Math.sin(z / 650) * 34 + Math.sin(z / 1900) * 120 * (Math.abs(z) > 500 ? 1 : Math.abs(z) / 500), z });
export const ROADS = {
 spine,
 access: [{ x: 108, z: 112 }, { x: 72, z: 112 }],
 loop: [{ x: 72, z: 112 }, { x: -82, z: 112 }, { x: -82, z: -98 }, { x: 72, z: -98 }, { x: 72, z: 112 }],
 north: [{ x: -82, z: -98 }, { x: -82, z: -200 }, { x: 108, z: -200 }]
};
export const GATE = { x: 86, z: 112, rotation: Math.PI / 2 };
export const PARKING = { x: -150, z: 120, w: 96, d: 56 };
// Ground-mounted solar rows north of the campus, seen during the student walk.
export const SOLAR_FIELD = { x: -56, z: -77, w: 30, d: 24 };
// Where the student stops and looks up: tall trees and lamps are kept out of this circle so the sky is open.
export const CLIMAX_SPOT = { x: -27, z: -72, clear: 46 };

// Walking routes for students (closed loops inside and around the courtyard).
export const WALKS = [
 [{ x: -1, z: 32 }, { x: -1, z: -24 }, { x: 22, z: -24 }, { x: 22, z: 32 }],
 [{ x: -27, z: 30 }, { x: -27, z: 2 }, { x: -24, z: 2 }, { x: -24, z: 30 }],
 [{ x: -68, z: 82 }, { x: -68, z: -40 }, { x: -60, z: -40 }, { x: -60, z: 82 }],
 [{ x: 24, z: 24 }, { x: 64, z: 4 }, { x: 64, z: -34 }, { x: 22, z: -35 }],
 [{ x: -76, z: 106 }, { x: 66, z: 106 }, { x: 66, z: -92 }, { x: -76, z: -92 }],
 [{ x: 16, z: 34 }, { x: 16, z: 104 }, { x: 40, z: 104 }, { x: 40, z: 64 }, { x: 20, z: 64 }]
];

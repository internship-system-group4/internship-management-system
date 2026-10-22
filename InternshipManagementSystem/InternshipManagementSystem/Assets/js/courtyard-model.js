import * as THREE from './vendor/three.module.min.js';

// Procedural reconstruction, normalized dimensions; see .img2threejs/waterwheel-spec.json.
// Plain-JavaScript adaptation of the skill's staged Group factory (no runtime TS build).
export function createCourtyardModel({ textureSize = 1024 } = {}) {
    const root = new THREE.Group(); root.name = 'root'; root.userData.restPosition = [0, 0, 0];
    const parts = new Map([['root', root]]);
    const materials = {
        stone: new THREE.MeshStandardMaterial({ color: '#c9b58f', roughness: .88 }),
        timber: new THREE.MeshStandardMaterial({ color: '#38291f', roughness: .78 }),
        tile: new THREE.MeshStandardMaterial({ color: '#719a9c', roughness: .53 }),
        water: new THREE.MeshStandardMaterial({ color: '#367d87', roughness: .15, metalness: .12 }),
        metal: new THREE.MeshStandardMaterial({ color: '#4d4f49', roughness: .48, metalness: .55 }),
        glass: new THREE.MeshStandardMaterial({ color: '#4c7585', roughness: .26, metalness: .15 })
    };
    // Independent, seeded channels: surface color is never reused as roughness or height.
    function surface(kind, channel) {
        const size = textureSize, data = new Uint8Array(size * size * 4);
        let seed = kind === 'stone' ? 417 : 823;
        const noise = () => { seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0; return seed / 4294967296; };
        for (let y = 0; y < size; y++) for (let x = 0; x < size; x++) {
            const n = noise(), broad = Math.sin(x * .018) * Math.sin(y * .023);
            const course = y % 128 < 2 || (x + (Math.floor(y / 128) % 2) * 128) % 256 < 2;
            const grain = Math.sin(x * .18 + Math.sin(y * .008) * 6) * .5 + Math.sin(x * .73 + y * .004) * .2;
            let value;
            if (channel === 'albedo') value = kind === 'stone' ? 224 + broad * 7 + n * 12 - (course ? 20 : 0) : 193 + grain * 22 + n * 7;
            else if (channel === 'height') value = kind === 'stone' ? 128 + n * 40 - (course ? 35 : 0) : 128 + grain * 36 + n * 10;
            else value = kind === 'stone' ? 220 + n * 22 : 185 + n * 22 + grain * 14;
            const i = (y * size + x) * 4; data[i] = data[i + 1] = data[i + 2] = value; data[i + 3] = 255;
        }
        const texture = new THREE.DataTexture(data, size, size, THREE.RGBAFormat);
        texture.wrapS = texture.wrapT = THREE.RepeatWrapping; texture.repeat.set(kind === 'stone' ? 2 : 1, kind === 'stone' ? 2 : 1);
        texture.generateMipmaps = true; texture.minFilter = THREE.LinearMipmapLinearFilter; texture.magFilter = THREE.LinearFilter;
        if (channel === 'albedo') texture.colorSpace = THREE.SRGBColorSpace;
        texture.needsUpdate = true; return texture;
    }
    materials.stone.color.set('#e1cfaf');
    for (const kind of ['stone', 'timber']) {
        materials[kind].map = surface(kind, 'albedo'); materials[kind].bumpMap = surface(kind, 'height');
        materials[kind].roughnessMap = surface(kind, 'roughness'); materials[kind].bumpScale = kind === 'stone' ? .035 : .018;
    }
    function part(id, parent = root, position = [0, 0, 0]) {
        const g = new THREE.Group(); g.name = id; g.position.fromArray(position);
        g.userData.restPosition = [...position]; parent.add(g); parts.set(id, g); return g;
    }
    function mesh(parent, name, geometry, material, position = [0, 0, 0]) {
        const m = new THREE.Mesh(geometry, material); m.name = name; m.position.fromArray(position);
        m.castShadow = true; m.receiveShadow = true; parent.add(m); return m;
    }
    const box = (p, name, size, material, pos) => mesh(p, name, new THREE.BoxGeometry(...size), material, pos);
    const wheel = part('wheel', root, [1.35, 3.45, 0]);
    function annulus(id, z) {
        const p = part(id, wheel, [0, 0, z]);
        const shape = new THREE.Shape(); shape.absarc(0, 0, 3.15, 0, Math.PI * 2, false);
        const hole = new THREE.Path(); hole.absarc(0, 0, 2.91, 0, Math.PI * 2, true); shape.holes.push(hole);
        const geometry = new THREE.ExtrudeGeometry(shape, { depth: .16, bevelEnabled: false, curveSegments: 64 });
        geometry.translate(0, 0, -.08); mesh(p, id + '-solid', geometry, materials.timber); return p;
    }
    annulus('rim-front', .46); annulus('rim-back', -.46);
    const spokes = part('spokes', wheel);
    for (const z of [-.46, .46]) for (let i = 0; i < 12; i++) {
        const angle = i * Math.PI / 6;
        const beam = box(spokes, 'spoke-' + z + '-' + i, [2.83, .17, .15], materials.timber, [Math.cos(angle) * 1.45, Math.sin(angle) * 1.45, z]);
        beam.rotation.z = angle;
    }
    const paddles = part('paddles', wheel);
    for (let i = 0; i < 32; i++) {
        const angle = i * Math.PI / 16;
        const paddle = box(paddles, 'paddle-' + i, [.37, .12, 1.18], materials.timber, [Math.cos(angle) * 3.12, Math.sin(angle) * 3.12, 0]);
        paddle.rotation.z = angle;
    }
    const axle = part('axle', wheel);
    const shaft = mesh(axle, 'shaft', new THREE.CylinderGeometry(.105, .105, 1.95, 16), materials.metal);
    shaft.rotation.x = Math.PI / 2;
    for (const z of [-.48, .48]) {
        const hub = mesh(axle, 'hub-' + z, new THREE.CylinderGeometry(.25, .25, .25, 16), materials.timber, [0, 0, z]);
        hub.rotation.x = Math.PI / 2;
    }
    const bearings = part('bearings');
    for (const z of [-.88, .88]) {
        box(bearings, 'bearing-seat-' + z, [.44, .24, .4], materials.metal, [1.35, 3.35, z]);
        box(bearings, 'axle-pier-' + z, [.62, 3.17, .56], materials.stone, [1.35, 1.72, z]);
    }
    const arcade = part('arcade', root, [-2.7, 0, -.9]);
    const columns = part('columns', arcade);
    for (let i = 0; i < 4; i++) box(columns, 'pier-' + i, [.54, 4.5, .64], materials.stone, [-2.8 + i * 1.9, 2.35, 0]);
    const lintel = part('lintel', arcade, [0, 4.65, 0]);
    box(lintel, 'lintel-solid', [6.7, .66, .66], materials.stone, [0, 0, 0]);
    const basin = part('basin'); box(basin, 'basin-floor', [10, .2, 2.9], materials.tile, [-.5, .1, .1]);
    for (const z of [-1.28, 1.48]) box(basin, 'basin-long-edge-' + z, [10.15, .3, .16], materials.stone, [-.5, .2, z]);
    for (const x of [-5.5, 4.5]) box(basin, 'basin-end-' + x, [.16, .3, 2.9], materials.stone, [x, .2, .1]);
    const water = part('water'); box(water, 'water-surface', [9.65, .03, 2.55], materials.water, [-.5, .27, .1]);
    const reflection = new THREE.MeshBasicMaterial({ color: '#8cb8b8', transparent: true, opacity: .22, depthWrite: false });
    // Static glints suggest water without adding another moving surface or costly refraction.
    for (let i = 0; i < 7; i++) {
        const line = box(water, 'water-glint-' + i, [.6 + i % 3 * .15, .002, .012], reflection, [-4.4 + i * 1.2, .289, .6 + Math.sin(i) * .35]);
        line.rotation.y = .14;
    }
    const context = part('context', root, [0, 0, -4.2]);
    const facade = part('facade', context); box(facade, 'facade-solid', [11, 7.2, .4], materials.stone, [0, 3.6, 0]);
    // Narrow interrupted window bands and a gridded glazed connector are visible in the photos.
    for (let row = 0; row < 5; row++) for (let col = 0; col < 5; col++) {
        if ((row + col) % 4 === 0) continue;
        box(facade, 'window-' + row + '-' + col, [1.17, .31, .025], materials.glass, [-1.3 + col * 1.33, 1.15 + row * 1.12, .215]);
    }
    const glazing = part('glazing', context);
    box(glazing, 'glazed-connector', [3.05, 6.6, .14], materials.glass, [-4, 3.35, .28]);
    const mullions = part('mullions', context);
    const silver = new THREE.MeshStandardMaterial({ color: '#b8c3bf', roughness: .52, metalness: .3 });
    for (let i = 0; i < 8; i++) box(mullions, 'vertical-frame-' + i, [.035, 6.6, .08], silver, [-5.5 + i * .43, 3.35, .4]);
    for (let i = 0; i < 9; i++) box(mullions, 'horizontal-frame-' + i, [3.05, .045, .08], silver, [-4, .08 + i * .82, .4]);
    // Shallow static roof louvers are characteristic of the courtyard photographs.
    for (let i = 0; i < 14; i++) box(context, 'roof-louver-' + i, [.045, .06, 1.1], silver, [-5.2 + i * .79, 7.24, .05]);
    const fasteners = part('rim-fasteners', wheel);
    const boltGeometry = new THREE.CylinderGeometry(.035, .035, .025, 6);
    for (let i = 0; i < 32; i++) for (const z of [-.555, .555]) {
        const angle = i * Math.PI / 16;
        const bolt = mesh(fasteners, 'rim-pin-' + i + '-' + z, boltGeometry, materials.metal, [Math.cos(angle) * 3.02, Math.sin(angle) * 3.02, z]);
        bolt.rotation.x = Math.PI / 2;
    }
    box(root, 'courtyard-plinth', [12.4, .22, 7.2], materials.stone, [-.5, -.16, -.8]);
    // Consolidate repeated boxes/bolts within their semantic part; preserve IDs for picking.
    root.traverse(parent => {
        const batches = new Map();
        for (const child of parent.children) if (child.isMesh) {
            const key = child.geometry.type + JSON.stringify(child.geometry.parameters) + child.material.uuid;
            if (!batches.has(key)) batches.set(key, []); batches.get(key).push(child);
        }
        for (const members of batches.values()) if (members.length >= 3) {
            const first = members[0], batch = new THREE.InstancedMesh(first.geometry, first.material, members.length);
            batch.name = parent.name + '-instances'; batch.userData.partIds = members.map(m => m.name);
            const oldGeometries = new Set();
            members.forEach((m, i) => { m.updateMatrix(); batch.setMatrixAt(i, m.matrix); parent.remove(m); if (m.geometry !== first.geometry) oldGeometries.add(m.geometry); });
            oldGeometries.forEach(g => g.dispose()); batch.castShadow = first.castShadow; batch.receiveShadow = true;
            batch.computeBoundingSphere(); parent.add(batch);
        }
    });
    const wheelSocket = new THREE.Object3D(); wheelSocket.name = 'axle-center'; wheel.add(wheelSocket);
    const setExploded = amount => {
        for (const node of parts.values()) node.position.fromArray(node.userData.restPosition).multiplyScalar(1 + Math.max(0, amount));
    };
    const pick = raycaster => {
        const hit = raycaster.intersectObject(root, true)[0];
        return hit ? { id: hit.object.userData.partIds?.[hit.instanceId] || hit.object.name, point: hit.point } : null;
    };
    root.userData.sculptRuntime = { parts, wheel, materials, sockets: { axle: wheelSocket }, collider: { type: 'compound-box', physicsEnabled: false }, destruction: { breakable: false, groups: [...parts.keys()] }, setExploded, pick };
    return { root, wheel, parts };
}

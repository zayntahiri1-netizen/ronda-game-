#!/usr/bin/env node
/**
 * Ronda Asset Generator
 * Generates all required icon and splash screen sizes for Android + iOS
 * Usage: node generate-assets.js
 */

const sharp = require('sharp');
const fs    = require('fs');
const path  = require('path');

const ROOT    = path.resolve(__dirname, '..');
const ASSETS  = path.join(ROOT, 'assets');
const ICON    = path.join(ASSETS, 'icon.svg');
const SPLASH  = path.join(ASSETS, 'splash.svg');

// ═══════════════════════════════════════════════════════
// ANDROID ICON SIZES
// ═══════════════════════════════════════════════════════
const ANDROID_ICONS = [
  { dir: 'mipmap-mdpi',    size: 48  },
  { dir: 'mipmap-hdpi',    size: 72  },
  { dir: 'mipmap-xhdpi',   size: 96  },
  { dir: 'mipmap-xxhdpi',  size: 144 },
  { dir: 'mipmap-xxxhdpi', size: 192 },
];

const ANDROID_ADAPTIVE = [
  // Adaptive icon foreground (1/3 safe zone = 108px at mdpi, 432px canvas)
  { dir: 'mipmap-mdpi',    size: 108  },
  { dir: 'mipmap-hdpi',    size: 162  },
  { dir: 'mipmap-xhdpi',   size: 216  },
  { dir: 'mipmap-xxhdpi',  size: 324  },
  { dir: 'mipmap-xxxhdpi', size: 432  },
];

// ═══════════════════════════════════════════════════════
// iOS ICON SIZES
// ═══════════════════════════════════════════════════════
const IOS_ICONS = [
  // App Store
  { name: 'Icon-1024.png',    size: 1024 },
  // iPhone
  { name: 'Icon-60@2x.png',   size: 120 },
  { name: 'Icon-60@3x.png',   size: 180 },
  // iPad
  { name: 'Icon-76.png',      size: 76  },
  { name: 'Icon-76@2x.png',   size: 152 },
  { name: 'Icon-83.5@2x.png', size: 167 },
  // Settings/Spotlight
  { name: 'Icon-29.png',      size: 29  },
  { name: 'Icon-29@2x.png',   size: 58  },
  { name: 'Icon-29@3x.png',   size: 87  },
  { name: 'Icon-40.png',      size: 40  },
  { name: 'Icon-40@2x.png',   size: 80  },
  { name: 'Icon-40@3x.png',   size: 120 },
  // Notification
  { name: 'Icon-20.png',      size: 20  },
  { name: 'Icon-20@2x.png',   size: 40  },
  { name: 'Icon-20@3x.png',   size: 60  },
];

// ═══════════════════════════════════════════════════════
// SPLASH SCREEN SIZES
// ═══════════════════════════════════════════════════════
const ANDROID_SPLASHES = [
  { dir: 'drawable-port-mdpi',    w: 320,  h: 480  },
  { dir: 'drawable-port-hdpi',    w: 480,  h: 800  },
  { dir: 'drawable-port-xhdpi',   w: 720,  h: 1280 },
  { dir: 'drawable-port-xxhdpi',  w: 960,  h: 1600 },
  { dir: 'drawable-port-xxxhdpi', w: 1280, h: 1920 },
  // Landscape
  { dir: 'drawable-land-mdpi',    w: 480,  h: 320  },
  { dir: 'drawable-land-hdpi',    w: 800,  h: 480  },
  { dir: 'drawable-land-xhdpi',   w: 1280, h: 720  },
  { dir: 'drawable-land-xxhdpi',  w: 1600, h: 960  },
  { dir: 'drawable-land-xxxhdpi', w: 1920, h: 1280 },
];

const IOS_SPLASHES = [
  { name: 'Default@2x~universal~anyany.png',   w: 2732, h: 2732 },
  { name: 'Default@2x~iphone~anyany.png',      w: 1334, h: 1334 },
  { name: 'Default@3x~iphone~anyany.png',      w: 2208, h: 2208 },
  { name: 'Default@2x~ipad~anyany.png',        w: 2048, h: 2048 },
];

// ═══════════════════════════════════════════════════════
// PWA ICONS (www/icons/)
// ═══════════════════════════════════════════════════════
const PWA_ICONS = [72, 96, 128, 144, 152, 192, 384, 512];

// ═══════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════
async function mkdirp(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

async function makeIcon(src, outPath, size, radius = 0) {
  const pipeline = sharp(src).resize(size, size);
  if (radius > 0) {
    // Apply rounded corners mask
    const mask = Buffer.from(
      `<svg><rect x="0" y="0" width="${size}" height="${size}" rx="${radius}" ry="${radius}"/></svg>`
    );
    pipeline.composite([{ input: mask, blend: 'dest-in' }]);
  }
  await pipeline.png().toFile(outPath);
}

async function makeSplash(src, outPath, w, h) {
  await sharp(src)
    .resize(w, h, { fit: 'cover', position: 'centre' })
    .png()
    .toFile(outPath);
}

// ═══════════════════════════════════════════════════════
// MAIN
// ═══════════════════════════════════════════════════════
async function main() {
  console.log('🎴 Ronda Asset Generator Starting...\n');

  // ── Android Icons ───────────────────────────────────
  console.log('📱 Generating Android launcher icons...');
  const androidResDir = path.join(ROOT, 'android', 'app', 'src', 'main', 'res');
  for (const { dir, size } of ANDROID_ICONS) {
    const outDir = path.join(androidResDir, dir);
    await mkdirp(outDir);
    await makeIcon(ICON, path.join(outDir, 'ic_launcher.png'), size);
    await makeIcon(ICON, path.join(outDir, 'ic_launcher_round.png'), size, Math.round(size * 0.5));
    process.stdout.write(`  ✓ ${dir} (${size}px)\n`);
  }

  // Adaptive icon foreground
  console.log('\n📱 Generating Android adaptive icon foregrounds...');
  for (const { dir, size } of ANDROID_ADAPTIVE) {
    const outDir = path.join(androidResDir, dir);
    await mkdirp(outDir);
    await makeIcon(ICON, path.join(outDir, 'ic_launcher_foreground.png'), size);
    process.stdout.write(`  ✓ ${dir} foreground (${size}px)\n`);
  }

  // ── iOS Icons ────────────────────────────────────────
  console.log('\n🍎 Generating iOS app icons...');
  const iosIconDir = path.join(ROOT, 'ios', 'App', 'App', 'Assets.xcassets', 'AppIcon.appiconset');
  await mkdirp(iosIconDir);
  for (const { name, size } of IOS_ICONS) {
    await makeIcon(ICON, path.join(iosIconDir, name), size);
    process.stdout.write(`  ✓ ${name}\n`);
  }

  // ── Android Splashes ─────────────────────────────────
  console.log('\n🌅 Generating Android splash screens...');
  for (const { dir, w, h } of ANDROID_SPLASHES) {
    const outDir = path.join(androidResDir, dir);
    await mkdirp(outDir);
    await makeSplash(SPLASH, path.join(outDir, 'screen.png'), w, h);
    process.stdout.write(`  ✓ ${dir} (${w}×${h})\n`);
  }

  // ── iOS Splashes ──────────────────────────────────────
  console.log('\n🌅 Generating iOS splash screens...');
  const iosSplashDir = path.join(ROOT, 'ios', 'App', 'App', 'Assets.xcassets', 'Splash.imageset');
  await mkdirp(iosSplashDir);
  for (const { name, w, h } of IOS_SPLASHES) {
    await makeSplash(SPLASH, path.join(iosSplashDir, name), w, h);
    process.stdout.write(`  ✓ ${name}\n`);
  }

  // ── PWA Icons ─────────────────────────────────────────
  console.log('\n🌐 Generating PWA icons...');
  const pwaDir = path.join(ROOT, 'www', 'icons');
  await mkdirp(pwaDir);
  for (const size of PWA_ICONS) {
    await makeIcon(ICON, path.join(pwaDir, `icon-${size}.png`), size);
    process.stdout.write(`  ✓ icon-${size}.png\n`);
  }

  // ── Store Assets ──────────────────────────────────────
  console.log('\n🏪 Generating Play Store feature graphic (1024×500)...');
  const storeDir = path.join(ROOT, 'store-assets');
  await mkdirp(storeDir);
  await makeSplash(SPLASH, path.join(storeDir, 'feature-graphic-1024x500.png'), 1024, 500);
  await makeIcon(ICON, path.join(storeDir, 'play-store-icon-512.png'), 512);
  await makeIcon(ICON, path.join(storeDir, 'app-store-icon-1024.png'), 1024);

  console.log('\n✅ All assets generated successfully!');
  console.log(`\n📁 Output locations:`);
  console.log(`   Android: android/app/src/main/res/`);
  console.log(`   iOS:     ios/App/App/Assets.xcassets/`);
  console.log(`   PWA:     www/icons/`);
  console.log(`   Store:   store-assets/`);
}

main().catch(err => {
  console.error('❌ Error:', err.message);
  process.exit(1);
});

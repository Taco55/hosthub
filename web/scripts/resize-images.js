#!/usr/bin/env node
/* eslint-disable @typescript-eslint/no-require-imports */

const fs = require("node:fs/promises");
const path = require("node:path");
const sharp = require("sharp");

const imageSets = [
  {
    directory: path.join("public", "images", "hero"),
    widths: [3840, 1920, 1280, 960, 640],
  },
  {
    directory: path.join("public", "highlights"),
    widths: [1920, 1280, 640],
  },
  {
    directory: path.join("public", "images", "all"),
    widths: [1920, 1280, 960, 640],
  },
];

const allowedExtensions = new Set([".jpg", ".jpeg", ".png", ".webp", ".avif"]);
const generatedPattern = /@\d+w\./;

async function resizeImage(targetDir, fileName, widths) {
  const parsed = path.parse(fileName);
  const source = path.join(targetDir, fileName);

  for (const width of widths) {
    const destinationName = `${parsed.name}@${width}w${parsed.ext}`;
    const destinationPath = path.join(targetDir, destinationName);
    await sharp(source)
      .resize({ width, withoutEnlargement: true })
      .toFile(destinationPath);
  }
}

async function processDirectory(directory, widths) {
  const entries = await fs.readdir(directory, { withFileTypes: true });
  for (const entry of entries) {
    if (entry.isDirectory()) {
      await processDirectory(path.join(directory, entry.name), widths);
      continue;
    }

    if (generatedPattern.test(entry.name)) {
      continue;
    }

    const ext = path.extname(entry.name).toLowerCase();
    if (!allowedExtensions.has(ext)) {
      continue;
    }

    await resizeImage(directory, entry.name, widths);
    console.log(`Resized ${entry.name} to ${widths.length} widths`);
  }
}

async function main() {
  for (const set of imageSets) {
    try {
      await processDirectory(set.directory, set.widths);
    } catch (error) {
      console.error(`Failed to resize images in ${set.directory}`, error);
      process.exitCode = 1;
    }
  }
}

main();

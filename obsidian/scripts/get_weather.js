require('dotenv').config();

const { execSync } = window.require("child_process");

const runShell = (cmd) => {
  try {
    return execSync(cmd, { encoding: "utf-8" }).trim();
  } catch (e) {
    return null;
  }
};

module.exports = async (tp) => {
  const API_KEY = process.env.API_KEY;
  const cachePath = "weather-cache.md";
  const today = new Date().toISOString().slice(0, 10);

  const cacheFile = app.vault.getAbstractFileByPath(cachePath);

  // Use cached weather if it's for today
  if (cacheFile) {
    const fm = app.metadataCache.getCache(cachePath)?.frontmatter;
    if (fm && fm.date === today) {
      return `Weather: ${fm.description}, ${fm.temp}°F in ${fm.city}`;
    }
  }

  const lat = process.env.lat;
  const lon = process.env.lon;
  const fallbackCity = process.env.fallbackCity;

  // Fetch weather data
  const weatherRaw = runShell(`curl -s "https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=${API_KEY}&units=imperial"`);

  if (!weatherRaw) {
    if (cacheFile) {
      const fm = app.metadataCache.getCache(cachePath)?.frontmatter;
      if (fm) {
        return `⚠️ (Offline) Weather: ${fm.description}, ${fm.temp}°F in ${fm.city}`;
      }
    }
    return "⚠️ Failed to fetch weather data and no cache available.";
  }

  let weather;
  try {
    weather = JSON.parse(weatherRaw);
  } catch (e) {
    return "⚠️ Failed to parse weather data.";
  }

  const temp = weather.main?.temp ?? "N/A";
  const description = weather.weather?.[0]?.description ?? "unknown conditions";
  const city = weather.name ?? fallbackCity;

  // Update or create cache file
  const cacheContent = `---
date: ${today}
city: ${city}
description: ${description}
temp: ${temp}
units: imperial
---`;

  try {
    if (cacheFile) {
      await app.vault.modify(cacheFile, cacheContent);
    } else {
      await app.vault.create(cachePath, cacheContent);
    }
  } catch (e) {
    // silently fail if file ops fail
  }

  return `Weather: ${description}, ${temp}°F in ${city}`;
};

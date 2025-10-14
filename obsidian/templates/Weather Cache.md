---
last modified: 10-04-2025, 04:13 am
---
<%*
const cachePath = "weather-cache.md";
const today = tp.date.now("dddd");

const cacheFile = app.vault.getAbstractFileByPath(cachePath);
let fm = app.metadataCache.getCache(cachePath)?.frontmatter;

if (!fm || fm.date !== today) {
  await tp.user.get_weather();
  fm = app.metadataCache.getCache(cachePath)?.frontmatter;
}

const weatherLine = fm
  ? `${fm.description}, ${fm.temp}°F`
  : "Weather data not available";

tR = weatherLine;
%>

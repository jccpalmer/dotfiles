module.exports = async (tp) => {
  const cachePath = "weather-cache.md";
  const today = new Date().toISOString().slice(0, 10);

  try {
    const file = app.vault.getAbstractFileByPath(cachePath);
    if (!file) {
      return `🪹 Cache file "${cachePath}" not found.`;
    }

    const cache = app.metadataCache.getCache(cachePath);
    if (!cache || !cache.frontmatter) {
      return `⚠️ No frontmatter found in "${cachePath}".`;
    }

    const fm = cache.frontmatter;

    if (fm.date !== today) {
      return `📅 Cache is outdated. Cache date: ${fm.date}, Today: ${today}`;
    }

    return `✅ Cached weather: ${fm.description}, ${fm.temp}°F in ${fm.city}`;
  } catch (err) {
    return `🚨 Script error: ${err.message}`;
  }
};

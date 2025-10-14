---
created: <% tp.file.creation_date() %>
day: <% tp.date.now("dddd") %>
city: Centreville
tags:
  - journal
  - daily
last modified: 18-04-2025, 14:31 pm
---
<%*
let fileNameFormat = "DD MMMM YYYY";
let headingFormat = "dddd, MMMM Do";

await tp.file.rename(tp.date.now(fileNameFormat));

let rawWeatherLine = await tp.file.include("[[Weather Cache]]");
let weatherLine = rawWeatherLine.replace(/"/g, '\\"');

let frontmatter = "---\n";
frontmatter += `created: ${tp.file.creation_date()}\n`;
frontmatter += `date: ${tp.date.now("YYYY-MM-DD")}\n`;
frontmatter += `day: ${tp.date.now("dddd")}\n`;
frontmatter += `weather: ${weatherLine}\n`;
frontmatter += "---\n\n";

tR = frontmatter;

tR += "# " + moment(tp.date.now(fileNameFormat), fileNameFormat).format(headingFormat) + "\n\n";

tR += await tp.file.include("[[Navigation]]") + "\n\n";
tR += "---\n";
tR += await tp.file.include("[[Timestamp]]") + "\n\n";
%>

---


{QUOTE HERE}

### Daily Questions

#### {Daily Stoic question}



#### What went well today?

- 

#### What went poorly today?

- 

#### Things I plan to accomplish tomorrow

- [ ] 

---
# Notes

- 

---

<%*
const today = tp.date.now("YYYY-MM-DD");

tR += "### Notes created today\n";
tR += "```dataview\n";
tR += `LIST WHERE file.ctime.day = date("${today}") SORT file.ctime asc\n`;
tR += "```\n\n";

tR += "### Notes last modified today\n";
tR += "```dataview\n";
tR += `LIST WHERE file.mtime.day = date("${today}") SORT file.mtime asc\n`;
tR += "```\n";
%>


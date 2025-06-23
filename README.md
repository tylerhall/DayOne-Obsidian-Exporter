# DayOne-Obsidian-Exporter

I moved away from [Day One](https://dayoneapp.com/) and am now using [Obsidian](https://obsidian.md/) to keep my daily journal. To make that possible, I needed to migrate over a decade's worth of journal entries into an Obsidian-friendly format.

This (very basic) Swift script takes [Day One's JSON export file](https://dayoneapp.com/guides/tips-and-tutorials/exporting-entries/) (and media attachments) and converts your entries into YAML + Markdown files that are friendly to Markdown editors like Obsidian. Entries are sorted into folders based on their date with support for multiple entries per day. Media attachments are saved alongside the Markdown files as inline attachments.

Running the script

```
d1obsidian <path-to-export.json> <some-output-folder>
```

will create a directory structure like this:

```
/export-folder/
  /2023/
  /2024/
  /2025/
    /2024-01 - January/
    /2024-02 - Februrary/
      /2024-02-01/
        2024-02-01 - 001.md
        2024-02-01 - 002.md
        some-image.jpeg
        another-image.jpeg
```

![SS-20250623 130851 Journal@2x](https://github.com/user-attachments/assets/88023a33-3d05-4b0a-9b7b-7a1b557f71e9)

Based on the availabe metadata, each entry's Markdown file will look similar to:

```
---
uuid: AA7A6A77946547449ED0BBC99349537C
creationDate: 2013-02-13T20:38:54Z
timeZone: America/Chicago
location:
  latitude: 37.546
  longitude: -77.439
  localityName: Richmond
  administrativeArea: Virginia
  country: United States
weather:
  conditionsDescription: Cloudy
  weatherCode: cloudy
  temperatureCelsius: 3.5
---
Today I went for a run and ate a sandwhich.

![](991F17490A0F4A919116C5AB428E6F1E.jpeg)
```

It's worth noting that this script does not exhaustively migrate all fields that Day One supports — mostly because I couldn't find a complete listing of all the available fields. It also strips out `dayone-moment:/workout` and `dayone-moment:/location` in-line references from your entires.

And in keeping with open source tradition, there are plenty of other export scripts floating around GitHub and the Obsidian forums, but it was easier to hack this together quickly than try and modify someone else's to match the output I wanted.

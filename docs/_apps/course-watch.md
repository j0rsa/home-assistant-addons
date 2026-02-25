---
name: course-watch
title: Course Watch - Video Course Player
description: Self-hosted video course player with WebDAV support for Home Assistant
category: Media
version: latest
architectures:
  - amd64
  - aarch64
ports:
  - 8099
---

# Course Watch

A self-hosted video course player that reads course structure from a JSON file on
your Home Assistant share and streams videos from WebDAV storage through an
authenticated proxy.

## Features

- Hierarchical course browser (courses → sections → videos)
- Real-time search across all course titles, sections, and video names
- WebDAV proxy with Basic Auth — videos and subtitles load transparently
- Automatic SRT/SUB → WebVTT subtitle conversion in the browser
- Playback speed control via keyboard shortcuts with on-screen toast feedback
- Previous / Next video navigation with position counter
- Home Assistant ingress support

## Installation

1. Add the J0rsa repository to your Home Assistant instance
2. Install the **Course Watch** app
3. Set your WebDAV credentials in the app configuration
4. Create `/share/course-watch/courses.json` (see structure below)
5. Start the app — it is accessible via the sidebar panel or ingress URL

## Configuration

```yaml
webdav_user: "your-username"
webdav_password: "your-password"
media_url: "https://your-webdav-server"
```

| Option | Type | Required | Description |
|---|---|---|---|
| `webdav_user` | string | No | WebDAV username for authenticated storage |
| `webdav_password` | password | No | WebDAV password |
| `media_url` | string | No | Base URL prepended to relative video/subtitle paths in `courses.json` |

If no credentials are set the proxy forwards requests unauthenticated, which works
for open WebDAV servers or locally served files.

When `media_url` is set, relative paths in `courses.json` (e.g. `lectures/01-intro.mp4`)
are resolved against it automatically. Absolute `http://` or `https://` URLs always
pass through as-is regardless of this setting.

## courses.json Structure

Place this file at `/share/course-watch/courses.json`:

```json
{
  "courses": [
    {
      "name": "Course Name",
      "sections": [
        {
          "name": "Section Name",
          "videos": [
            {
              "title": "Video Title",
              "video": "http://your-webdav-server/path/to/video.mp4",
              "sub": "http://your-webdav-server/path/to/subtitles.srt"
            }
          ]
        }
      ]
    }
  ]
}
```

`sub` is optional — omit it or set it to `""` for videos without subtitles.

## Subtitle Support

The app automatically converts SRT files to the WebVTT format required by browsers.
Binary subtitle formats (VobSub `.sub`) are silently skipped. The conversion happens
entirely in the browser — no server-side processing required.

## Keyboard Shortcuts

| Key | Action |
|---|---|
| `<` / `>` | Decrease / increase playback speed |
| `←` / `→` | Seek backward / forward 10 s |
| `Space` or `K` | Play / pause |
| `C` | Toggle captions |
| `F` | Toggle fullscreen |
| `M` | Toggle mute |
| `0`–`9` | Jump to 0–90% of the video |

## Video Streaming

The app proxies all requests to your WebDAV server, injecting the configured
credentials. HTTP Range requests are forwarded so seeking works correctly even
for large video files. For best performance ensure your MP4 files have the
`moov` atom at the start (`ffmpeg -movflags faststart`).

## Troubleshooting

**Video does not load**
- Verify the WebDAV server is reachable from Home Assistant
- Check that `webdav_user` and `webdav_password` are correct
- Look at the add-on log for proxy errors (HTTP 401, 403, 502)

**courses.json not found**
- The file must be at exactly `/share/course-watch/courses.json`
- The `share` volume is mounted read-write by the app

**Subtitles not showing**
- Only text-based SRT format is supported; binary VobSub is skipped
- Check that the subtitle URL is reachable via the WebDAV proxy

## Support

- [GitHub Issues](https://github.com/j0rsa/home-assistant-apps/issues)
- [Home Assistant Community](https://community.home-assistant.io/)

# Changelog

## 1.1.0

- Add loading spinner overlay when switching to a new video
- Fix player pausing current video immediately on selection
- Improve course title readability: remove italic, larger size, primary text colour
- Add Expand all / Collapse all buttons to sidebar
- Hide Expand/Collapse controls while search is active

## 1.0.2

- Fix proxy URL resolution behind HA ingress (use page-relative path)
- Humanise course and section names in the UI (replace _ - . with spaces, title-case)

## 1.0.1

- Fix share volume mapping to read-only
- Fix port conflict by removing host port binding — ingress-only access

## 1.0.0

- Add initial release
- Add hierarchical course browser (courses → sections → videos)
- Add real-time video search with highlighted matches
- Add WebDAV proxy with Basic Auth support
- Add automatic SRT-to-WebVTT subtitle conversion
- Add playback speed keyboard shortcuts with on-screen toast
- Add previous/next video navigation
- Add Home Assistant ingress support
- Add courses.json served from /share/course-watch/

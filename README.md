# ios-build-scripts

A few small command-line tools for building and shipping iOS apps. Nothing
fancy and nothing app-specific — just the stuff that wastes an afternoon the
first time you hit it.

Everything here is generic. Set your own scheme, bundle ID, and paths.

---

## What's in here

| File | What it does |
|---|---|
| `scripts/run-on-sim.sh` | Build and launch your app on the iOS Simulator from the terminal. Picks the sim by UDID so it doesn't break when you have multiple iOS runtimes installed. |
| `scripts/strip-icon-alpha.py` | Flatten a 1024x1024 App Store icon to remove its alpha channel, so the upload doesn't get rejected. |
| `snippets/xcodegen-launch-screen.yml` | The XcodeGen `project.yml` keys that fix the app launching into a tiny window instead of full screen. |

---

## run-on-sim.sh

Builds your app and runs it on a simulator, all from the command line.

```bash
export SCHEME="YourScheme"
export BUNDLE_ID="com.example.app"
export PROJECT="YourApp.xcodeproj"   # optional
./scripts/run-on-sim.sh
```

The one thing worth knowing: it finds the simulator by its UDID, not its
name. If you have more than one iOS runtime installed, matching by name or
by `OS:latest` is unreliable and you get `Unable to find a device
matching...`. A UDID is exact, so the build always lands on the right sim.

To see the UDIDs yourself:

```bash
xcrun simctl list devices available
```

---

## strip-icon-alpha.py

The App Store rejects the 1024x1024 marketing icon if it has transparency.
Most design tools export PNGs as RGBA, so this catches a lot of people at
upload time. This paints the icon onto a solid background and saves a flat
RGB PNG. Looks identical, just no alpha.

```bash
pip install Pillow
python3 scripts/strip-icon-alpha.py icon.png icon-flat.png "#121212"
```

Leave off the color to flatten onto white.

---

## xcodegen-launch-screen.yml

If your app opens into a small ~320x480 window instead of filling the
screen, it's missing a proper launch screen, so the system falls back to an
old screen size. The snippet shows the `project.yml` keys that fix it. Keep
both the build-setting key and the Info.plist key — together they cover both
paths and don't conflict.

---

## License

MIT. Use it however you want.

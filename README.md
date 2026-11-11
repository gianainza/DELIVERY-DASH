# 🛵 Delivery Dash

A top-down delivery game made with **Godot**. Hop on your bike, accept orders on your phone, pick up packages at the shop, and toss them at the right house before the timer runs out. Lose all your stars and you're fired!

---

## 🌐 Play Online

The game is **deployed and ready for live browsing**.

To play it in your browser, open **`index.html`**.

> Tip: if you open `index.html` directly from your computer and it doesn't load, serve the folder through a local web server or use the hosted link, because browsers block some features on `file://` pages.

---

## 🎮 How to Play

1. **Get on the bike.** Ride up to the parked bike to hop on.
2. **Wait for an order.** Your phone buzzes when a new delivery comes in.
3. **Open your phone** and **accept** the order.
4. **Go to the shop** (follow the guide arrow) and **pick up** the package.
5. **Deliver it** to the right house and **toss** the package at the door.
6. **Beat the timer.** Each order has a countdown. Running out of time costs you a star.

You complete **3 orders** per shift. Finish them all to win. Lose all **3 stars** and the game is over.

| Order | Customer | Package | Reward |
|-------|----------|---------|--------|
| 1 | Jiro | Hot Meal | $50 |
| 2 | Mika | Groceries | $70 |
| 3 | Ren | Parcel | $90 |

---

## ⌨️ Controls

| Key | Action |
|-----|--------|
| **W / A / S / D** | Move |
| **Shift** | Boost (bike only, uses the boost bar) |
| **E** | Pick up the package at the shop / toss it at the house |
| **R** | Open / close your phone |
| **F** | Accept the order (while the phone is open) |
| **Esc** | Pause the game |

---

## ✨ Features

- Walking and biking movement with a **boost meter** that drains and recovers
- **Phone system** with order notifications and a vibrating phone
- **Guide arrow** that points you to the shop or the house
- **Bouncing destination arrow** over your target building
- **Per-order countdown timer** and a **3-star** rating system
- **Pickup and toss animations**, with the package flying in an arc
- Coin pop reward effect after each delivery
- Traffic cars, NPCs, and a living town
- Main menu, intro, loading screen, and win / lose end screens

---

## 🛠️ Built With

- **[Godot Engine](https://godotengine.org/)** (project made with Godot 4.x)
- **GDScript**
- Pixel art made for the game

---

## 📁 Project Structure

```
delivery-dash-game/
├── art/          # Sprites, HUD, props, NPCs, traffic, screens
├── audio/        # Audio bus layout
├── scenes/       # Game, player, menus, intro, loading, end screen
├── scripts/      # Game logic (player, delivery manager, HUD, etc.)
└── project.godot # Godot project file
```

### Key scripts

| Script | What it does |
|--------|--------------|
| `scripts/player.gd` | Movement, boost, camera, pickup and toss actions |
| `scripts/delivery_manager.gd` | Orders, timers, stars, pickup / drop-off flow, package animations |
| `scripts/hud.gd` | Phone, timer, hints, messages, and star display |
| `scripts/guide_arrow.gd` | Arrow that points to the current target |
| `scripts/traffic_car.gd` / `npc.gd` / `world_life.gd` | Cars, pedestrians, and town life |

---

## 💻 Run It in Godot

1. Install [Godot 4](https://godotengine.org/download).
2. Open Godot, click **Import**, and select the `project.godot` file.
3. Press **F5** to play.

---

## 🚀 Web Export (for developers)

The online build was exported from Godot using the **Web** preset:

1. In Godot, go to **Project → Export → Add… → Web**.
2. Click **Export Project** and save it as `index.html`.
3. Upload all exported files (`index.html`, `.wasm`, `.pck`, `.js`, etc.) to your hosting service.

---

## 🎨 Customizing

- **Package size:** change `pkg.scale` in `_drop_package` and `_pickup_package` (`scripts/delivery_manager.gd`).
- **Order times and rewards:** edit the `ORDERS` list at the top of `scripts/delivery_manager.gd`.
- **Interaction distance:** change `INTERACT_MARGIN` in `scripts/delivery_manager.gd`.
- **Bike speed and boost:** change the values at the top of `scripts/player.gd`.

---

## 📜 License

Add your license here (for example, MIT) or remove this section.

---

Made with ❤️ using Godot.

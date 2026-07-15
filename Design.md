# Amberfield — UI/UX Design Document

**Genre read from your codebase:** cozy action-RPG / farm-life hybrid. You have combat (FSM-driven player/enemy, click-to-target, skill hotbar, crit/level/stat system) *and* farming tool equipment already defined (Axe, Shovel, Sickle, WateringCan, PickAxe, FishingRod) that isn't hooked to gameplay yet. This puts Amberfield in the same design space as *Rune Factory* / *Fae Farm* / *Stardew + combat* — that's the lens this doc uses.

Art source: Maeve's 16x16 Farm RPG asset pack (32x32 characters at 16px/unit, modular + premade sprites, right-facing only + flip). All UI guidance below assumes this pixel scale.

> **Update note:** this revision folds in the UI implied by the *Amberfield Advanced Systems Architecture Guide* — Relationships, Save/Load, Time & Seasons, Weather, Dialogue branching, Quests, Fishing, and the Tutorial. Where a screen's underlying data model is defined there, this doc only covers layout/interaction — see the architecture guide for the `Resource`/Autoload shape behind it.

---

## 1. Design Pillars

Write these at the top of your design doc and hold every UI decision against them:

1. **Cozy first, combat second.** Combat UI should feel like an extension of the farm-life loop, not a bolt-on. Rarity colors and icon framing should read as "loot from the world," not "MMO gear score."
2. **Two-hand rule.** Left hand (WASD) always drives the character; right hand (mouse) always targets/interacts. No UI should demand the player take a hand off both at once except deliberate menu browsing.
3. **Never block the world for a status check.** HUD elements (health/mana/exp/time-of-day) must be always-visible; full panels (Inventory, Stats, Skills, Quest Log, Relationships) are toggled overlays, not scene changes.
4. **One panel open at a time by default.** Multiple stacked panels (Inventory + Equipment + Stats all open) get messy fast at 16x16 scale on small windows — pick a single-panel-focus model or explicitly design for docking (see §6).
5. **Diegetic over modal, wherever possible.** The tutorial, action prompts, and world-state feedback (season change, weather) should live *in* the world (floating prompts, NPC dialogue, ambient lighting) rather than interrupting with a dialog box — this keeps the cozy pillar intact as the game grows more systems.

---

## 2. Visual Language

| Element | Rule |
|---|---|
| Base grid | 16px. All UI padding/margins should be multiples of 4px (quarter-tile) to stay crisp at pixel-perfect zoom. |
| Panel frames | Use a consistent 9-slice frame across every panel (Inventory, Equipment, Craft, Shop, Stats, Skills, Dialogue, Quest Log, Relationships). Right now each panel likely has its own PanelContainer styling — unify into one theme resource. |
| Rarity colors | You already have Common/Rare/Epic/Legendary/Mythic (seen in Potions). Standardize this palette **once** and reuse it for: slot border color, item name text color, skill lock/unlock icon tint, and Fish rarity (Common/Uncommon/Rare/Legendary — reconcile the two rarity scales into one shared palette rather than a second one for fish). Suggested (colorblind-checked-ish): Common `#B0B0B0`, Rare `#4FA8E0`, Epic `#B15CE0`, Legendary `#E0A63C`, Mythic `#E04C6B`. |
| Icons | 200+ planned icons from the pack — keep a single consistent light source (top-left) and outline weight so Equipment/Inventory/Shop/Craft/Fishing icons don't visually clash. |
| Font | Pick one pixel font for numbers/labels and one (can be the same) for dialogue body text. Avoid anti-aliased default fonts — they'll fight the pixel art. |
| Selection feedback | You already do a `Selector` sprite show/hide on hover for inventory and enemies — good, keep this as the *one* universal "this is interactive/selected" language across all screens (don't introduce a second convention like glow-on-enemy vs. border-on-item). Reuse it again for Quest Log entries and Relationship portraits. |
| Season palette | Each season (Spring/Summer/Fall/Winter) should nudge the UI's ambient accent — not a full re-theme, just a subtle tint shift on panel headers or the HUD corner cluster (§7) — cheap way to make the Time/Season system (architecture guide §3) feel present in the UI, not just the world. |

---

## 3. Screen Inventory (what exists vs. what's missing)

### Exists in your project
- HUD (health/mana/exp bars, panel-toggle buttons, skill hotbar)
- Inventory Panel (grid, drag-via-"grabbed slot", swap/merge/equip/use)
- Equipment Panel (5 slots: Helmet/Armour/Weapon/Legs/Ring)
- Stats Panel (STR/DEX/INT allocation, derived stats)
- Skills Panel (unlock-with-coins, equip to hotbar)
- Craft Panel (stubbed — no logic yet)
- Shop Panel (buy-only, coin display)
- Dialogue Panel (typewriter text, paginated, portrait + emotion)
- Drop Item world pickups, Portal/Transition fade

### Designed in the architecture guide, not yet built (this doc adds the UI layer for these)
- **Quest Log** — tracks `QuestData`/`QuestObjective` progress (architecture guide §6). See §4.9 below.
- **Relationship Panel** — NPC affection, gifting feedback (architecture guide §4). See §4.10 below.
- **Fishing Minigame UI** — triggered by `FishingSpot` + `FishingMinigame` component (architecture guide §7). See §4.11 below.
- **Dialogue Choices** — branching `DialogueChoice` buttons layered onto the existing Dialogue Panel (architecture guide §5). See §4.8 (updated).
- **Time / Season / Weather HUD cluster** — reads `TimeManager`/`WeatherManager` (architecture guide §3, §15). See §8 below.
- **Save/Load screens + Main Menu** — reads `SaveManager` (architecture guide §2). See §9 below.
- **Tutorial hint bubbles** — diegetic `TutorialHint` prompts (architecture guide §14). See §9 below.

### Still missing — no design or architecture yet, worth scoping
- **Pause Menu** (resume / settings / quit to menu) — currently there's no way to pause or exit cleanly.
- **Settings Menu** (key rebinding — you hardcoded WASD/mouse in `project.godot`, so at minimum expose volume + window mode; rebinding is a bigger lift).
- **Death / Game Over screen.** `Player._on_dead_anim_finished()` currently just `queue_free()`s the player — no respawn or game-over flow.
- **Minimap or area label.** With Portals moving the player between zones (Town, presumably a dungeon/wild zone based on `EnemyZone`), players need to know where they are. (The architecture guide's Fast Travel/Map idea in §15 covers the data side once you get here.)
- **Tooltip system.** Hovering an item/skill/quest/NPC currently shows nothing but the selector — no name/description/stats popup. This is one of the highest-value additions for a low cost, and now touches more panels than before (Quest Log objectives, Relationship gift preferences, Fish rarity).
- **Cooking / Housing / Museum panels** — only relevant if you build the corresponding systems from the architecture guide's §15 suggestions; noted here so the panel-pattern table in §6 has a home for them later.

---

## 4. Per-Panel UX Spec

### 4.1 HUD (always visible)
- **Top-left:** stacked Health bar → Mana bar → Exp bar, each with a numeric label overlay (you already do curr/max text — keep it, but consider small icon glyphs instead of "HealthLabel" text so it reads at a glance during combat).
- **Bottom-center:** Skill hotbar, 4 slots, numbered 1–4, matches `Skill_1..4` input actions. Empty slots show a dim placeholder icon (you have `Empty` panel node — good). Add a cooldown sweep overlay per slot now that skills have cooldowns (`GameData.skill_cooldowns`, per the cleanup plan) — a dark fill that recedes from full to empty as `cooldown / skill.cooldown` shrinks.
- **Top-right or bottom-right:** panel toggle icons (Inventory / Equipment / Stats / Skills / Quest Log / Relationships / Map). This row is getting crowded at 7 icons — consider grouping into two rows or a single "Menu" icon that opens a lightweight radial/tab picker once you're past 5 toggles, rather than growing the row indefinitely.
- **Top-center or a HUD corner:** Time/Season/Weather cluster — see §8, its own dedicated section given how much it now needs to communicate.
- **Feedback conventions to standardize:**
  - Floating damage numbers (`Reference.create_damage_text`) — already implemented, keep colors consistent: white for normal hits, yellow/larger for crits (you compute `crit_chance`/`crit_damage` but damage text doesn't currently differentiate crit visually — add that, it's a big "juice" win for very little code).
  - Screen edge vignette flash on player damage (cheap, high impact, doesn't exist yet).
  - Floating "+1 Item" / "+X Affection" / "+X EXP" text should share one visual language (font, rise-and-fade animation) across Inventory pickups, gifting (§4.10), and quest rewards — one component, many callers, same convention discipline as the Selector sprite above.

### 4.2 Inventory Panel
- Grid, 30 slots (matches `Inventory.INVENTORY_SIZE`). Current interaction model: left-click picks up/swaps/merges via a "grabbed slot" that follows the mouse, right-click quick-equips/uses. This is a solid, minimal-click model — **keep it**, just document it (see §5) since it's non-obvious to a new player without a hint.
- Add: item-count sort/stack-consolidate button (single click, common QoL for 30-slot inventories once loot volume grows — and it will, once the 17-mob bestiary and fishing pool both add loot sources).
- Add: hover tooltip (name, rarity color, description, and "Right-click to equip/use" hint) — currently there is zero item-info surface outside of the icon+count.
- Gold display already present (`GoldLabel`) — keep visible at the top of this panel always, since Shop and Craft both consume it.
- **New interaction: gifting.** When an NPC is the player's current interact target (adjacent + facing, same detection your Dialogue trigger already uses), dragging or right-clicking an inventory item onto them should call `Inventory.use_item()` + `RelationshipManager.give_gift()` in one step (architecture guide §4) — reuse the existing right-click-to-use gesture rather than inventing a new one.

### 4.3 Equipment Panel
- 5 fixed slots. Clicking an equipped slot unequips (returns to inventory) — already implemented, good affordance, but there's no icon differentiation between "empty slot silhouette by type" (e.g., a faint helmet outline in the Helmet slot when empty) — add that so empty slots communicate what goes where without a label.
- Show **total derived stats** (bonus damage sum, etc.) somewhere on this panel, not just in the separate Stats Panel — right now a player has to check two different panels to understand "what does my gear give me."
- **Open question worth deciding early:** do farming tools (Axe/Shovel/Sickle/WateringCan/PickAxe/FishingRod) share the Weapon slot with combat weapons, or get a dedicated Tool slot? A dedicated slot means the player never has to swap out their sword to go fishing — recommended, since Fishing (§4.11) and combat (EnemyZones) can plausibly both be relevant in the same session.

### 4.4 Stats Panel
- STR/DEX/INT plus/minus with a points pool — already implemented and reversible (downgrade refunds a point), which is a nice, safe design for player experimentation. Keep that reversibility.
- Add a short one-line description under each stat (what STR/DEX/INT actually do) — right now the mapping (STR→dmg+HP, DEX→speed+crit chance, INT→mana+crit damage) is invisible in the UI and only exists in code.

### 4.5 Skills Panel
- Grid of `SkillButton`s: locked (grey + lock icon) → unlock with coins → click again to equip to first open hotbar slot. This flow is clear but has one silent failure: if all 4 hotbar slots are full, `equip_skill_to_empty_slot` just does nothing with no feedback. Add a "hotbar full" toast/shake.
- Add tooltip on hover: mana cost, base damage, cooldown, short flavor text — `SkillData`/`Item` already has a `description` field that isn't surfaced anywhere in UI yet, and cooldown is a new field per the cleanup plan.

### 4.6 Craft Panel *(currently a stub — design it now before building it)*
Suggested flow, matching your existing `CraftData`/`CraftMaterial` data model:
- Left: grid of `CraftButton`s (recipes), same visual language as Skill/Inventory grids for consistency — and the same `DataGridPanel`/`DataGridButton` base classes from the architecture guide §9, since this panel is the reference case for that refactor.
- Right: selected recipe detail — result icon+name, required materials list (icon, "have X / need Y", greyed out if insufficient), and a Craft button that's disabled until requirements are met.
- Feedback: on craft success, brief flash/pulse on the result icon + the item flies to the inventory grid (or at minimum, the same floating "+1 Item" text used elsewhere).
- If you build the Cooking system from the architecture guide's §15 suggestions later, it's a visually distinct instance of this same panel triggered from a stove/kitchen interact point rather than a generic bench — same layout, different scene and recipe pool.

### 4.7 Shop Panel
- Buy-only grid of `PurchaseButton`s with price — clean, but no sell path currently exists (`Inventory` has no `remove_item`-for-gold flow). If loot volume grows (it will, see §4.2), add a Sell tab/tab-toggle reusing the same grid component.
- Add insufficient-funds feedback (currently `_on_shop_button_pressed` just silently returns if short on coins).
- If NPC schedules (architecture guide §3) gate shop hours, surface that on this panel's entry point — e.g. the shop door's interact prompt reads "Closed until 9am" outside business hours rather than silently doing nothing.

### 4.8 Dialogue Panel — updated for branching
- Typewriter effect with click-to-complete/advance — already well built (page splitting by character count, emotion-driven portrait animation). Genuinely one of the more polished systems in the project. Keep all of this as-is.
- Add: a small "▼" or bounce indicator when a line is done typing and waiting for input, so players don't wonder if the game is frozen.
- **New: choice buttons.** When a `DialogueNode` has `choices` (architecture guide §5), render them as a small vertical button stack anchored above or beside the portrait once typing completes — visually distinct from the "click anywhere to advance" affordance so players don't confuse "pick an option" with "continue reading." Hide choices whose `conditions` aren't met (don't grey them out — an invisible option is less confusing than a visibly-locked one mid-conversation).
- **New: relationship/quest feedback inline.** If a `DialogueEffect` changes affection or starts a quest, a small non-blocking toast ("♥ Lyria +1" or "New Quest: Autumn Festival") in a HUD corner reads better than interrupting dialogue flow with a popup — reuse the same floating-text convention from §4.1.

### 4.9 Quest Log Panel *(new)*
- Two-column layout, same `DataGridPanel` shape as Inventory/Shop: left column lists active quests (title + a small progress ring or fraction), right column shows the selected quest's full objective breakdown with live-updating progress bars per objective (`QuestManager.on_objective_progress`, architecture guide §6).
- A secondary "Completed" tab/filter for finished quests — purely a satisfaction/reference feature, not required for MVP but cheap once the panel exists.
- Objective rows should restate their `description` field in plain language ("Defeat 5 Slimes — 3/5") rather than exposing the internal `target_id`/`type` enum.
- Entry point: add "Quest Log" to the HUD toggle row (§4.1), and auto-flash/highlight it briefly whenever a new quest starts or an objective completes, so players don't have to check it proactively every time.

### 4.10 Relationship Panel *(new)*
- Grid of NPC portraits (reuse the Dialogue Panel's existing portrait art — no new asset work), each with a heart-tier indicator (filled/empty hearts, using the `RelationshipManager.MAX_AFFECTION` scale from the architecture guide §4) beneath it.
- Selecting an NPC shows their loved/liked/disliked gift categories (not exact item lists — that's a "figure it out" mechanic common to the genre and worth preserving as a soft discovery loop) plus their birthday if you're using the `NPCProfile.birthday_day/season` fields.
- Heart-tier-up moments deserve a small celebratory beat (a sparkle/flash on the portrait, or the floating-text toast from §4.1) rather than being silently reflected only when the player happens to open this panel.
- This panel can be lower priority than Quest Log for an initial build — it has no gameplay-blocking function, just a satisfaction/tracking one — but design it now (per §10) so gifting (§4.2) has somewhere to show its effect.

### 4.11 Fishing Minigame UI *(new)*
- Triggered contextually: player has the Fishing Rod tool equipped (see §4.3's open question) and interacts while overlapping a `FishingSpot`. No menu navigation needed to start — this should feel as immediate as the existing Attack input.
- Minigame surface: a simple timing/QTE bar is the lowest-implementation-cost option that still feels good (a moving indicator the player times a button press against, feeding the `FishingMinigame.quality` float from the architecture guide §7) — avoid over-scoping this into a complex minigame on a first pass.
- On success: a brief "catch" reveal card (fish icon, name, rarity-colored border reusing §2's shared rarity palette, size if you're using `FishData.min_size/max_size`) before returning control to the player — mirrors the satisfaction beat other loot-catching genres use, and reuses your existing DropItem/floating-text conventions rather than inventing a new reward-reveal pattern.
- On failure: no punishment beyond time spent — a quick "got away" text and immediate return to normal play, keeping the cozy pillar intact even on a miss.

---

## 5. Input & Navigation Model

Document this once, put it in a "Controls" tab in the Settings menu, and stop guessing:

| Input | Action |
|---|---|
| WASD | Move |
| Left Mouse | Attack / Select enemy or NPC / Confirm UI click |
| Right Mouse (in Inventory) | Quick-equip or quick-use / gift to a targeted NPC (§4.2) |
| 1–4 | Cast equipped skill (requires a selected enemy — currently skills silently no-op with no target, add a "select a target" hint) |
| Interact (new, needs a dedicated key if not already mapped) | Talk to NPC / use farming tool on a tile / start Fishing at a `FishingSpot` — one contextual key rather than three separate ones, matching the "one interact affordance" convention already implied by your NPC dialogue trigger |
| Toggle buttons (HUD icons) | Open/close Inventory, Equipment, Stats, Skills, Quest Log, Relationships |
| (Missing) Esc | Should close the topmost open panel, or open Pause Menu if nothing is open — not implemented yet, very cheap high-value addition |

---

## 6. Panel Layering Strategy

Decide **now** between two models, because your current code (independent `visible` toggles per panel in `HUD.gd`) allows all panels open simultaneously, which will get visually noisy — more so now with Quest Log and Relationships added to the roster:

- **Model A — Single Focus (recommended for cozy-scale UI):** Opening one panel (Inventory) auto-closes any other open panel. Simplest to implement: a small `UIManager` that tracks "current open panel" and hides the previous one before showing the new one.
- **Model B — Docked Multi-panel:** Inventory + Equipment share one combined window (common in ARPGs since gear and inventory are used together constantly), everything else (Stats/Skills/Craft/Quest Log/Relationships) are separate single-focus overlays.

Given Equipment and Inventory already interact directly (right-click-to-equip moves items between them), **Model B for Inventory+Equipment, Model A for everything else** is the best fit for what you've already built. Quest Log and Relationships are pure Model A citizens — nothing else needs to be open alongside them.

---

## 7. Farming Layer UI (ties the asset pack to your tool equipment)

You already have Axe/Shovel/Sickle/WateringCan/PickAxe/FishingRod as `EquipData` items with no gameplay behind them yet. Suggested minimal UI to make that layer real:

- **Selected-tool indicator**: small icon near the hotbar showing the currently equipped tool (see §4.3's open question about a dedicated Tool slot).
- **Action prompt**: contextual "Press [Interact] to [Water/Till/Harvest/Fish]" prompt when standing on a valid tile or `FishingSpot`, same visual weight as your NPC dialogue trigger — one prompt component, reused everywhere, per §5's "one interact affordance" note.
- **Crop state**: no UI needed on the crop itself (sprite frame swap handles it per the asset pack's growth stages and `TimeManager.on_day_changed`, architecture guide §3), but the season clock now lives in the dedicated cluster below (§8) rather than a standalone corner widget.
- **Stamina or tool-durability bar**, if you want a resource-management loop distinct from mana (optional, common in this genre).

---

## 8. Time, Season & Weather HUD Cluster *(new — reads the architecture guide's TimeManager/WeatherManager)*

This grew from a single "season clock" note into its own section because it now needs to communicate three related-but-distinct things without cluttering the HUD:

- **Clock**: a small analog or digital time-of-day readout (`TimeManager.hour`/`minute`), positioned in a fixed HUD corner (top-center works well — it's read glance-style, not stared at).
- **Season icon**: a small badge next to the clock reflecting `TimeManager.season` — reuse the asset pack's existing seasonal crop iconography style (Spring/Summer/Fall are already implied by the pack's crop categories; Winter needs an equivalent visual language if you introduce it) rather than inventing a new icon set.
- **Weather icon**: if you build the Weather system from the architecture guide's §15 suggestions, a third badge (sun/rain/storm/snow) sits alongside season — keep all three (clock, season, weather) visually grouped as one cluster rather than scattered HUD corners, since they're all "world state at a glance" information the player checks together.
- **Day counter**: a small "Day 14, Spring" text label satisfies the planning need (crop timing, NPC schedules, shrine questline pacing from the storyline) without needing a full calendar UI — save a dedicated Calendar screen for a later pass if playtesting shows players want to plan further ahead than "today."
- Interaction model: this cluster is **read-only, always visible, never blocks input** — consistent with pillar 3. No click target needed unless you later add a Calendar screen, in which case clicking the cluster is a reasonable entry point.

---

## 9. Save/Load, Main Menu & Tutorial UI *(new — reads the architecture guide's SaveManager/TutorialHint)*

### Main Menu / Title Screen
- New Game / Continue / Settings / Quit, standard genre layout. "Continue" should be disabled/hidden if no save exists rather than leading to an error state.
- New Game should offer the "Skip Tutorial" toggle mentioned in the architecture guide §14 — a single checkbox or button, not a submenu, since it's a one-time binary choice.

### Save Slot Picker
- If you support multiple save slots (`SaveManager.save_game(slot)`), a simple 3-slot list showing per-slot metadata (character name if any, Day/Season, playtime) is enough — this is a low-frequency screen, don't over-invest in it beyond clarity.
- Since saves are plain JSON (architecture guide §2), no UI is needed for "is this save valid" beyond normal error handling if a file is missing/corrupt — show a simple "couldn't load this save" message rather than crashing silently.

### Tutorial Hint Bubbles
- Visual form: a small floating prompt near the relevant UI element or above the player's head (matches the `TutorialHint` scene from the architecture guide §14) — text should be short imperative phrases ("WASD to move", "Right-click to gift"), not full sentences, consistent with the "show, don't explain" tutorial philosophy.
- Fade in in ~0.3s once triggered, fade out immediately on the matching `GameFlags` flag flipping (action completed) or after the component's own timeout — never require a manual dismiss click, which would break the diegetic feel this pillar (§1.5) is aiming for.
- Stack behavior: only one hint visible at a time — if a second hint's trigger condition becomes true while one is already showing, queue it rather than showing both simultaneously, since two floating prompts competing for attention undercuts the "one thing at a time" teaching principle from the architecture guide's tutorial design.

---

## 10. Accessibility & Polish Checklist

- Rarity colors above are a starting point — verify with a colorblind simulator before locking them in, since red/green pairs (common in "legendary vs rare" palettes) are the most common failure mode. Now applies to Fish rarity too (§2).
- All panel-critical info (equip slot type, rarity, quest objective completion) should not rely on color alone — pair with an icon or label. Quest objectives in particular should show a checkmark, not just a green progress bar, once complete.
- Damage numbers, dialogue text, and tutorial hints should respect a text-scale setting or at least not go below ~8px effective size at default zoom.
- `_input` handlers (e.g., Player skill hotkeys) currently fire even while a panel/dialogue is open — verify combat inputs are suppressed while Inventory/Dialogue/Shop/Quest Log/Relationships are focused, otherwise players will accidentally cast skills while browsing menus. This list of "input-suppressing" panels has grown — worth centralizing as one `UIManager.is_blocking_input()` check rather than scattering per-panel guards.
- Dialogue choice buttons (§4.8) need clear focus/hover states for eventual controller support (architecture guide §15) — don't build choice selection as mouse-only from the start if you can avoid it, since retrofitting is the exact pitfall that section warns about.

---

## 11. Suggested Wireframes (text form)

```
HUD (always on)
┌───────────────────────────────────────────────────┐
│ [HP▓▓▓▓▓▓░░]  [MP▓▓▓▓▓░░░]      🕐 7:40am 🌸 Day 14 │
│ [EXP▓▓░░░░░░░░]                  [Inv][Equip][Stats]│
│                                   [Skills][Quest][♥] │
│                     (gameplay viewport)              │
│                                                       │
│           [1][2][3][4]  ← skill hotbar               │
└───────────────────────────────────────────────────┘

Inventory + Equipment (docked, Model B)
┌───────────────┬─────────────────────────┐
│  Equipment     │   Inventory (30 slots)   │
│  [Helmet]      │   [ ][ ][ ][ ][ ][ ]     │
│  [Armour]      │   [ ][ ][ ][ ][ ][ ]     │
│  [Weapon]      │   [ ][ ][ ][ ][ ][ ]     │
│  [Tool]        │   [ ][ ][ ][ ][ ][ ]     │
│  [Ring]        │   [ ][ ][ ][ ][ ][ ]     │
│                │   Gold: 500              │
└───────────────┴─────────────────────────┘

Craft Panel (to be built)
┌───────────────┬─────────────────────────┐
│ Recipe list    │  Selected: Yakitori      │
│ [🍢][🍡][🍜]   │  Needs: Meat x2 (have 5) │
│ [ ][ ][ ]      │         Skewer x1(have 0)│
│                │  [ Craft ] (disabled)    │
└───────────────┴─────────────────────────┘

Quest Log Panel (new)
┌───────────────┬─────────────────────────┐
│ Active         │  Autumn Festival         │
│ ▸ Autumn Fest. │  Deliver 3 Spiced Cider  │
│   Wolf Den     │  ▓▓░ 2/3                │
│                │                          │
│ Completed ▾    │  Reward: Legendary Rod   │
└───────────────┴─────────────────────────┘

Relationship Panel (new)
┌─────────────────────────────────────────┐
│  [Lyria]   [Finn]   [Old Tam]   [Mira]   │
│  ♥♥♥♡♡     ♥♡♡♡♡     ♥♥♥♥♥      ♥♥♡♡♡     │
│                                           │
│  Selected: Lyria — loves Spring flowers  │
│  Birthday: Day 6, Spring                 │
└─────────────────────────────────────────┘

Fishing Minigame (new)
┌───────────────────────────────────────┐
│              [ ~~~ bar ~~~ ]            │
│         ▲ timing marker sweeping        │
│                                          │
│         Press [Interact] to reel!       │
└───────────────────────────────────────┘

Main Menu (new)
┌───────────────────────────────────────┐
│                AMBERFIELD                │
│                                          │
│              [ Continue ]                │
│              [ New Game ]                │
│              [ Settings ]                │
│              [ Quit ]                    │
└───────────────────────────────────────┘

Dialogue with choices (updated)
┌───────────────────────────────────────┐
│ [Portrait]  Lyria                       │
│  "Would you help me with the festival?" │
│                                          │
│              [ Of course! ]              │
│              [ Maybe later ]             │
└───────────────────────────────────────┘
```

---

## 12. Priority Order (if you want a build sequence)

This now leans on the architecture guide's phased roadmap (its §12) for *when* the underlying data/logic exists — the order below is the UI-specific sequencing on top of that:

1. Tooltip system (cheap, unlocks clarity across every existing panel, and now pays off across Quest Log/Relationships/Fishing too).
2. Pause menu + Esc-to-close-topmost-panel (cheap, fixes a real gap).
3. Finish Craft Panel using the wireframe above (data model already exists, just needs the UI wired up like Shop's — and gets the `DataGridPanel` base class from the architecture guide §9 for free).
4. Death/respawn flow.
5. Main Menu + Save Slot Picker (blocked on `SaveManager` existing per architecture guide Phase 1).
6. Time/Season/Weather HUD cluster (blocked on `TimeManager` per architecture guide Phase 2).
7. Farming HUD + tool interaction prompts (unlocks the whole second gameplay pillar; pairs naturally with #6).
8. Dialogue choice buttons (blocked on the `DialogueNode` rewrite per architecture guide Phase 5).
9. Quest Log Panel (blocked on `QuestManager` per architecture guide Phase 6).
10. Relationship Panel (blocked on `RelationshipManager` per architecture guide Phase 4 — can actually be built before #8/#9 if you want gifting feedback sooner, since it only depends on Relationships, not Dialogue or Quests).
11. Fishing Minigame UI (blocked on `FishingSpot`/`FishingMinigame` per architecture guide Phase 8).
12. Tutorial hint bubbles (last, deliberately — build them once the systems they're teaching actually exist, per architecture guide Phase 9).
13. Main menu polish + Settings (key rebinding, accessibility toggles from §10).

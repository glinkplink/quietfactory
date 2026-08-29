# Quiet Factory — Master Plan
Version: 0.1  
Status: Pre-production / prototype gate  
Product owner: Q  
Last updated: 2026-08-29

---

## 1. Product Thesis

**Quiet Factory is a $1.99 premium iOS puzzle game built around the addictive simplicity of modern tap-away / sorting / conveyor games, without ads, subscriptions, coins, lives, energy systems, or other freemium friction.**

The market gap is not “a brand-new puzzle genre.” The gap is:

> **A polished, one-thumb, low-attention mobile puzzle that people can simply buy once and play forever.**

The product should feel like the satisfying core loop of a modern hypercasual puzzle game, packaged with the restraint and trust of an old-school premium iOS app.

### Core promise

- One-thumb portrait gameplay
- Easy to understand in seconds
- Satisfying tactile feedback
- Enough strategy to avoid becoming a disposable 30-second mechanic
- Works offline
- No account required
- No ads
- No IAP
- No subscriptions
- No lives / energy
- No backend dependency
- $1.99 launch price

---

## 2. Target User

Primary user:

- Plays casual mobile games in short sessions
- Often plays while watching TV, commuting, waiting, or winding down
- Likes sorting, block-clearing, traffic, screw, tap-away, or conveyor puzzles
- Dislikes forced ads and manipulative monetization
- Is willing to spend $0.99–$2.99 to remove that friction permanently

Secondary user:

- Premium iOS-game enthusiast
- Looks for offline games
- Values simple mechanics, polish, and replayability over content spectacle

This is **not** initially optimized for:

- competitive gamers
- multiplayer audiences
- story-first players
- gacha/live-service users
- players expecting deep RPG progression

---

## 3. Core Game Concept

### Working mechanic

The player sees a compact factory / warehouse board filled with colored parcels or crates.

Each movable object has a directional constraint or route.

The player taps an object to release it if its path is clear.

Released objects enter a limited-capacity conveyor / packing buffer.

Matching groups clear from the conveyor.

The puzzle is therefore two-layered:

1. **Spatial:** Can this object leave the board?
2. **Sequencing:** Should I release it now?

The second layer is the key differentiator. It gives the game more depth than a basic tap-away clone without adding control complexity.

### Core interaction

**Tap → slide → conveyor → match → clear → cascade**

The game should be playable with one thumb and understandable without text after the tutorial.

---

## 4. Design Pillars

### 4.1 Immediate comprehension
A new player should understand the basic rule within 30 seconds.

### 4.2 Tactile satisfaction
Movement, snapping, conveyor motion, matching, clearing, and board completion must feel good.

Required:
- precise animation timing
- haptics
- satisfying sound effects
- readable state transitions
- minimal input latency

### 4.3 Low-attention friendly
No timer in standard mode.
No penalty for pausing.
No action-heavy dexterity requirement.

### 4.4 Real puzzle depth
The game cannot rely only on Skinner-box progression.

Depth should come from:
- release sequencing
- limited conveyor capacity
- blockers
- gates
- temporary locks
- hidden information only where fair

### 4.5 Respectful monetization
The business model is part of the product identity.

V1:
- Paid upfront
- No advertising SDK
- No in-app purchases
- No subscriptions
- No consumable currency

### 4.6 Small-system architecture
Avoid systems that create operational burden.

V1 must not require:
- user accounts
- remote database
- multiplayer
- chat
- live events
- server-authored content
- remote economy tuning

---

## 5. V1 Scope

### Required

#### Gameplay
- Portrait orientation
- Tap-to-release crate/block interaction
- Direction/path blocking rules
- Conveyor or holding buffer
- Match/clear logic
- Win condition
- Loss / stuck state where applicable
- Restart
- Undo
- Level progression
- Difficulty progression

#### Content
- 20–30 hand-authored tutorial / mechanic levels
- Procedural or seeded level generator
- Solver / solvability validator
- Curated campaign using validated seeds
- Minimum 100 launch levels
- Daily puzzle generated from deterministic date seed

#### Polish
- Haptics
- Sound effects
- Lightweight particle effects
- Clear completion animation
- Clean visual language
- Dark/light compatibility where practical
- Reduced motion option
- Colorblind-friendly symbols or markings

#### Meta
- Level select
- Progress persistence
- Basic statistics
- Daily streak or completion history without punitive design
- Shareable daily-result card
- Settings

#### App / platform
- iPhone support
- iPad compatibility if low-friction
- Offline-first
- App Store compliant
- Privacy-minimal design

---

## 6. Explicitly Out of Scope for V1

Do not add unless the prototype proves exceptional and the schedule remains intact:

- user accounts
- cloud save
- multiplayer
- friend system
- level editor
- user-generated levels
- cosmetic store
- IAP
- ads
- subscriptions
- social feed
- live ops dashboard
- remote config
- elaborate story
- characters with dialogue
- complex economy
- achievements requiring backend
- Android
- Apple Watch
- macOS-specific version
- localization beyond easy metadata/string-table wins
- large soundtrack

Scope creep is a product risk.

---

## 7. Technical Direction

### Preferred stack

**Swift + SpriteKit + SwiftUI**

SpriteKit:
- gameplay scene
- animation
- particles
- audio
- touch interaction
- board rendering

SwiftUI:
- menus
- settings
- onboarding shell
- level selection
- stats
- result/share screens

### Architectural goals

- deterministic game state
- game rules separated from rendering
- fully testable puzzle model
- seeded RNG
- solver able to operate without SpriteKit
- level definitions serializable
- no network dependency for gameplay

### Suggested modules

- `GameCore`
- `BoardModel`
- `MoveEngine`
- `ConveyorModel`
- `LevelDefinition`
- `LevelGenerator`
- `LevelSolver`
- `DifficultyScorer`
- `GameScene`
- `ProgressStore`
- `DailyPuzzleService`
- `AudioHaptics`
- `ShareCardRenderer`

---

## 8. Procedural Content Strategy

Procedural generation is not optional if it materially reduces content-production burden.

Pipeline:

1. Generate board from seed.
2. Run solver.
3. Reject if unsolvable.
4. Reject trivial boards.
5. Record solution path.
6. Calculate difficulty metrics.
7. Bucket by difficulty.
8. Persist accepted seed.
9. Human-playtest representative samples.
10. Promote curated seeds into campaign.

### Difficulty inputs

Possible metrics:

- minimum solution length
- number of valid opening moves
- branching factor
- number of forced moves
- conveyor occupancy pressure
- blocker count
- dead-end probability
- undo requirement in naïve play
- dependency depth

Difficulty must not rely solely on board size.

---

## 9. Prototype Gate

The project must prove the core interaction before production.

### Prototype contains only

- one board
- basic crate/block sprites
- directional blocking
- conveyor/buffer
- matching
- clearing
- restart
- basic haptics/sound

No progression.
No polished menus.
No achievements.
No elaborate art.

### Kill / continue test

The prototype passes only if:

- rules are understood quickly
- repeated tapping feels good
- conveyor sequencing creates meaningful choices
- multiple testers voluntarily play additional boards
- the game still feels compelling after the novelty of the first minute

If the loop is not compelling, change or kill the mechanic before building meta systems.

---

## 10. Development Plan

### Phase 0 — Product setup
Target: same day

- create repo
- establish documentation
- create Xcode project
- define coding conventions
- create minimal CI/build check if useful

### Phase 1 — Core prototype
Target: days 1–3

- deterministic board model
- tap/release rule
- path collision
- conveyor
- matching
- clear logic
- restart
- provisional juice

**Gate:** Is the toy fun?

### Phase 2 — Game system
Target: days 4–8

- move history
- undo
- failure/stuck detection
- basic blockers
- gates/locks
- level format
- persistence
- tutorial sequence

### Phase 3 — Generator + solver
Target: days 7–12

May overlap Phase 2.

- seeded generator
- solver
- validation
- difficulty scoring
- seed curation tools
- automated tests

**Gate:** Can the game generate reliably good puzzles?

### Phase 4 — Content + progression
Target: days 11–17

- launch campaign
- level select
- daily puzzle
- stats
- share card
- difficulty ramp

### Phase 5 — Polish
Target: days 15–23

- final visual language
- haptic tuning
- sound pass
- animation timing
- accessibility
- onboarding
- performance
- device testing

### Phase 6 — Launch
Target: days 21–28

- TestFlight
- bug triage
- App Store listing
- icon
- screenshots
- preview clips
- privacy labels
- review submission
- launch posts

---

## 11. Visual Direction

Goal:

**Clean industrial toy, not gritty factory and not AI-slop illustration.**

Possible aesthetic:
- simple geometric parcels
- soft 3D / pseudo-3D depth
- clear arrows
- crisp conveyor
- subdued industrial background
- restrained particles
- bold readable state colors

Avoid:
- generic AI characters
- fake mobile-ad visual language
- excessive gradients/effects
- clutter
- asset packs that make the game look interchangeable

The game needs a recognizable icon and board silhouette more than it needs large quantities of art.

---

## 12. Audio / Haptics Direction

Core sound palette should be small but excellent.

Required moments:
- valid tap
- blocked tap
- crate release
- conveyor landing
- match formation
- match clear
- combo
- gate unlock
- board complete
- undo
- failure/stuck cue

Haptics:
- subtle selection
- medium match
- stronger chain/completion
- never vibrate constantly

Audio must remain pleasant in repetitive play.

---

## 13. Daily Puzzle

No backend required.

Daily seed derived deterministically from date plus versioned salt.

Example conceptual input:

`quiet-factory-v1-2026-08-29`

Requirements:
- same puzzle for everyone on that date/version
- solver-valid
- results tracked locally
- share card contains no solution leakage

Potential result format:

`Quiet Factory — Daily #128`
`Solved in 34 moves`
`0 undos`
`★★★`

Avoid creating a Wordle clone aesthetically. Borrow the distribution mechanic, not the product identity.

---

## 14. GTM Positioning

Primary message:

> **The satisfying sorting puzzle without ads, coins, lives, or subscriptions.**

Secondary:
- pay once
- play forever
- works offline
- one thumb
- no timer
- daily puzzle

### App Store metadata direction

Working title:
**Quiet Factory**

Working subtitle:
**Relaxing sorting puzzle — no ads**

Potential keyword themes:
- sorting
- sort
- relaxing
- offline
- block
- tap
- conveyor
- logic
- puzzle
- no ads

Final metadata requires App Store keyword research before submission.

---

## 15. Launch Channels

Priority order:

1. App Store search / paid chart visibility
2. Reddit / iOSGaming developer promotion
3. AppRaven / premium app discovery communities
4. TikTok / Reels / Shorts using satisfying gameplay
5. Indie-game / premium-mobile communities
6. Product Hunt only if launch effort is effectively free

The product should be understandable from an 8–12 second gameplay clip.

Best creative:
- near-stuck board
- one clever release
- chain reaction
- board clears
- overlay: `No ads. No coins. $1.99.`

---

## 16. Pricing

Launch target:

**$1.99 one-time purchase**

V1 has no IAP.

Possible later tests:
- temporary $0.99 launch sale
- permanent $2.99 increase after strong reviews/content expansion

Do not introduce freemium monetization merely because retention is weak. Weak retention means the product needs improvement.

---

## 17. Success Metrics

Do not over-instrument V1.

Useful product metrics during testing:
- tutorial completion
- levels played per session
- voluntary replay
- restart frequency
- undo frequency
- level completion rate
- difficulty drop-off
- daily puzzle repeat usage
- review sentiment

Commercial metrics after launch:
- paid downloads
- conversion from product-page views
- refund rate
- review score
- search ranking
- chart ranking
- organic sales decay
- revenue per launch channel where observable

Because V1 is paid upfront, retention is primarily a product-quality signal rather than an ad-LTV optimization target.

---

## 18. Key Risks

### Risk 1 — mechanic is only fun as a 30-second novelty
Mitigation:
- prototype gate
- conveyor sequencing layer
- multiple puzzle elements
- repeated-play testing before production

### Risk 2 — category is too crowded
Mitigation:
- premium/no-ads positioning
- distinct conveyor mechanic
- strong visual identity
- paid-chart rather than free-chart competition

### Risk 3 — procedural levels feel random
Mitigation:
- solver
- difficulty scorer
- human curation
- hand-authored tutorial/special levels

### Risk 4 — game looks generic
Mitigation:
- narrow visual system
- custom icon
- motion/sound polish
- avoid obvious AI-generated art

### Risk 5 — scope creep breaks 2–4 week target
Mitigation:
- V1 exclusions are binding
- every feature must justify itself against launch date
- runtime docs track scope explicitly

### Risk 6 — no organic discovery
Mitigation:
- metadata research
- clear anti-ad positioning
- shareable daily puzzle
- visually legible short-form gameplay

---

## 19. Expansion Path

Only after launch data justifies it.

Potential V1.x:
- more puzzle mechanics
- additional themes
- alternate daily modes
- Game Center
- iCloud sync
- richer stats
- accessibility improvements

Potential sequel / portfolio strategy:
- reuse shell and tooling for a family of premium casual games
- retain common systems:
  - settings
  - haptics/audio
  - persistence
  - daily-seed framework
  - share renderer
  - App Store pipeline
  - test harness

Long-term opportunity:

> Build a recognizable label for small, tactile, premium mobile games that respect the player's time.

---

## 20. Current Product Decision

Proceed only through the prototype gate.

The next goal is **not** “finish Quiet Factory.”

The next goal is:

> **Prove that tap → release → conveyor → match → clear is fun enough to deserve the rest of the game.**

Everything else is subordinate to that test.

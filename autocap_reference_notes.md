# AutoCap Public Template Reference Notes

## Scope and source

Public gallery reviewed on 26 August 2026: `https://www.autocap.in/templates` and its English collection. The purpose is to learn reusable caption-animation patterns for SubReel, not to copy AutoCap branding, names, proprietary media, or code.

## Observed gallery structure

The public gallery presents 127 templates, with an English collection of 57. Cards are compact, dark, rounded preview surfaces. Each card uses a short sample phrase and small behavior tags such as **Bold**, **Build**, **Glow**, **Box**, **Karaoke**, **Caps**, **Outline**, **Gradient**, **Chip**, and **Typewriter**.

## Reusable animation patterns for SubReel

| Pattern | Public-gallery behavior observed | SubReel adaptation |
|---|---|---|
| Build | Words or short line pieces reveal in sequence. | Add word/line stagger with a short hold, accenting the current word. |
| Karaoke | Current word changes to an accent color while adjacent words remain neutral. | Use existing active-word color with a progressive word-scale or underline option. |
| Glow | High-contrast key words carry a diffuse colored halo. | Add controlled dual shadow/glow preset variants. |
| Box / chip | Words appear inside compact dark/light rounded labels. | Apply per-word pill or compact caption container templates. |
| Outline / hard shadow | Typography remains readable with a dark edge or offset shadow. | Add consistent outline/shadow combinations usable over real video. |
| Gradient / dual tone | Key word uses a second color, frequently warm or neon. | Use two-color double-layer/active-color visual variants rather than copied exact palettes. |
| Multiline / three-line | Caption is arranged vertically as short readable fragments. | Build stacked and ladder layouts with a maximum of a few words per line. |
| One-word / pixel | One dominant word at a time, with pixel or tech typography. | Use the existing word timing engine with optional single-word grouping and a pixel font. |
| Typewriter | Characters or words reveal progressively. | Preserve the existing typewriter option, but preview it as a timed phrase. |

## Implementation direction

SubReel should retain its own dark black-and-white visual identity and English UI labels. The next implementation batch should move Style cards from generic text samples toward explicit short timelines: start phrase, word-by-word build, active-word emphasis, and a brief held finished state. Templates should use distinct combinations of layout, glow, outline, box/chip treatment, and active-color timing rather than relying only on a static card font.

## English gallery visual findings

The English gallery visibly groups many distinct configurations under a small set of reusable primitives. Observed compositions include a dominant yellow single word, red hard-shadow title plus a smaller script line, vertical three-line hierarchy, large serif headline paired with a small sans subline, centered white pill karaoke text, compact black plate with white type, and stacked left-offset words. Its public cards do not expose video files or CSS keyframe names; the previews are static representations of the style. Therefore SubReel should implement original timed demonstrations of the publicly visible behavior categories rather than attempting to reproduce any inaccessible implementation.

The highest-value additions for SubReel are: a per-word chip/box treatment, a hard-shadow offset treatment, a warm-to-cool dual-tone treatment, a three-line hierarchical build, and a one-word focus mode. These map cleanly onto the existing word timing and caption design architecture.

// What the form can hold. Keep it in step with the app: the variants are the ones of SkullPart in
// calaverita_domain and the SVGs of calaverita_presentation.
export const TONES = ["playful", "sarcastic", "dramatic"] as const;
export type Tone = (typeof TONES)[number];

export const NONE = "none";

/** The accessories of the skull, and the looks each comes in (besides "none"). */
export const PARTS = {
  hat: ["sombrero", "tophat", "party", "crown"],
  glasses: ["round", "square", "cateye", "heart"],
  mustache: ["handlebar", "walrus", "pencil"],
  flowers: ["crown", "side", "trio"],
} as const;
export type Part = keyof typeof PARTS;
export const partNames = Object.keys(PARTS) as Part[];

export const DEFAULT_COLOR = "#f6efe0";

/** Festive colors for the skull. Any hex works. */
export const PALETTE: Record<string, string> = {
  "#f6efe0": "bone",
  "#ffffff": "white",
  "#12a5a0": "teal",
  "#1fa567": "green",
  "#f5a524": "marigold",
  "#ff8fb1": "pink",
  "#8fa8ff": "sky",
  "#7048e8": "violet",
};

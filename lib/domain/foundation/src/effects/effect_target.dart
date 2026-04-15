/// Identifies which kind of game entity a [StatusEffect] is applied to.
///
/// Keeping this as a plain enum (no Flutter or app dependencies) lets the
/// effects system be reused in other games without changes.
enum EffectTarget {
  /// The player-controlled hero.
  hero,

  /// An enemy combatant.
  enemy,

  /// An item in the inventory or equipment slots.
  item,

  /// A companion pet.
  pet,

  /// A buff or aura that is itself an effect (e.g. a passive aura from gear).
  buff,
}

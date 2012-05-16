Some information that might come handy:

Items
=====
fileitem structure:
-it contains information that are common for all items of given type
name0-unidentified name
name1-identified name
class,subclass-
  1-weapon (1-dagger,2-sword,3-axe,4-hammer,5-staff)
  2-shield (1-wood,2-steel,3-mithril)
  3-armor   }
  4-helmet  }  (1-leather,2-steel,3-mithril)
  5-boots   }
  6-gloves  }
  7-ring
  8-amulet
  9-cloak (subclass=color)
 10-potion (sub=effect,see potion.pas)
 11-scroll }  (sub=spell,see spell.pas)
 12-wand   }
 13-food (sub=color,bonusX10=nutrition value,spec=permanent bonus to
          given stat,see below)
 14-tunneling tool
 15-projectile }  (sub=type,0-none,1-rock,2-arrow,3-bolt)
 16-launcher   }
 17-miscellaneous (sub=color)
bonus-nonmagical bonus, to what determined by item class
mb-magical bonus, to what determined by spec, you can give a particular
   number (item will always have given bonus) or one of these (results
   in random number):
 -101 always negative, lesser than 0 }
 -100 always negative, may be 0      }  items with negative mb are
   99 random                         }  always cursed
  100 always positive, may be 0
  101 always positive, greater than 0
spec
  1-to hit
  2-damage
  3-defence
  4-speed
  5-sight
  6-searching
  7-carrying capacity
  8-strength
  9-agility
 10-learning
 11-constitution
 12-piety
 13-luck
 14-tunneling
 15-fire resistance
 16-cold res.
 17-lightning res.
 18-resistance
 19-satiation status-don't use on items!
 20-thirst status-don't use on items!
 21-confusion
 22-poison
 23-blindness
 24-missile hit
 25-missile damage
 26-returning projectile
 27-slay race
 28-paralysis
 29-stealth
 30-flaming armor
 31-freezing armor
 (origspc & spc arrays use the same structure)
weight
rarity
 1-common
 2-uncommon
 3-rare
 4-artifact
 5-artifact generated only on demand (e.g. in monster's inventory)

item structure:
num-index for the fitems array (finding out the name etc.)
mb-magical bonus for this item
curse-is cursed?
id-is identified?
flag-flags for minor magic (01-FR,10-CR,11-LR)
q-quantity

Monsters
========
filemonster structure:
name
class-race
  0-orc
  1-undead
  2-humanoid
  3-rat
  4-golem
  5-elemental
  6-nature
  7-mold
  8-demon
  9-shadowling
 10-LoRD
 11-phantom
 12-elf
athit-attack-hit
atdam-attack-damage
def-defence
color
rarity-something between 1 (weak) and 100 (most powerful), affects the
       depth where it will be generated
      -1 is gen.on request only
inv-what will be in the inventory
 -1..-17 something from that item class
 -(ItemClassX10+position) e.g. -123 is third non-artifact wand (see
   item.txt)
   for classes<10 add 300 -> -311 first non-artifact weapon
 the above means "will have this or gold or nothing"
 -999 nothing
 -501..-507 schemes
 -501 common warrior
 -502 uncommon w.
 -503 rare w.
 -504 weapon only
 -505 sling+ammo
 -506 bow+ammo
 -507 crossbow+ammo
speed-speed rating (100=average)
spec-special skills
 bit No.
  0-is caster
  1-element-fire }  both is element-lightning
  2-element-ice  }
  3-spit (elementals only)
  4-drain stats
  5-steal item
  6-steal gold
  7-regenerating
  8-disarming
  9-blink away
 10-uses missile weapon
 11-acidic
 12-generate escorts (next monster in monster.txt)
 13-stealth-minor }  combine to get max stealth
 14-stealth-major }
 15-poisoning
spec2
 bit No.
  0-paralyzing touch (actually never implemented)
  1-bard
  2-if attacked everybody attacks player
  3-don't pass through door when neutral
  4-call for reinforcements (calls monster following caller in
    monster.txt)
  5-become neutral after killing enemy (for police)
  6-is cop (like those in Kloth)
hlt-hitpoints
int-intelligence
mood-defines behavior
 0-enemy
 1..98 confused, slowly drops to 0
 -1..-98 paralysed, slowly drops to 0
 99 neutral, wanders
 -99 neutral, stands still
spell
 bit No.
  0-firebolt
  1-ice
  2-lightning
  3-confusion
  4-blindness
  5-teleport
  6-summon X1 }  sum these to get number of monsters following summoner
  7-summon X2 }  in monster.txt that can be summoned (eg 101 means
  8-summon X4 }  caster will summon any of 5 monsters following his
                 definition in monster.txt)
  9-healing
 10-speed

mon structure:
num-index in fmons array
hlt-actual HP
mood-actual mood
inv-pointer to inventory
speed-speed points left (one move takes 100)
sp-actual spellpoints
flag-state flags
 bit No.
  0-flees
  1-invisible
  2-sleeps (didn't notice player)
  3-speed X1 }
  4-speed X2 }  duration of speed-up spell
  5-speed X4 }
  6-will reset to original mood after killing enemy
align-alignment towards player
  0-enemy
  align_companion-companion
tag-targetting tag
tartag-tag of the current enemy (0-player,otherwise monster)
lx,ly-last position (for "pathfinding")
level-exp.level

Map
===
 0-wall
 1-floor
 2-open door
 3-closed door
 4-secret door
 5-stairs up
 6-stairs down
 7-column
 8-dirt
 9-tree
10-mountain
11-invisible trap
12-visible trap
13-pool of water

Typemap
=======
gives more info about given tile
traps
 1-fire
 2-ice
 3-teleport
 4-confusion
 5-explosion
pools-type div 10 gives number of drinks left
      type mod 10 gives type of the pool
       1-water
       2-mud
       3-poison
      eg. typemap=32 is muddy pool with 3 drinks left

Misc.
=====
"vdata" means "various data", currently contains info about guild
(index [0]), guild reward [1] and the state of farm quest [2].
"patro" means "depth".
Wizard help is pretty outdated.

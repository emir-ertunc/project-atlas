# Anatomy Muscle Ontology

## Contract

The anatomy spike defines 56 stable muscle-region identifiers: one right and
one left identifier for each of the 28 P2-02 reduction groups. The canonical
machine-readable contract is
[`muscle_region_ontology.v1.json`](../tool/anatomy/muscle_region_ontology.v1.json).

Identifiers use lowercase ASCII `snake_case` and end in `_right` or `_left`.
They are independent of source mesh IDs, display text, exercise categories,
and renderer node names.

## Stability Rules

- A published identifier is immutable.
- Editing English or Turkish display text does not change an identifier.
- Moving a region between screens or exercise categories does not change it.
- A true anatomical split or merge creates new identifiers; old identifiers
  move to the deprecation list with explicit replacements.
- Database records, exercise mappings, renderer picking, heatmaps, analytics,
  and exports must use the semantic identifier rather than a display name,
  numeric slot, FMA concept, or FJ mesh name.
- Numeric reduction slots remain pipeline references and are not persisted as
  product identity.

## Canonical Names

| Slot | Group ID | Right region ID | Left region ID | English group name | Turkish group name |
| ---: | --- | --- | --- | --- | --- |
| 01 | `pectoralis_major` | `pectoralis_major_right` | `pectoralis_major_left` | Pectoralis major | Pektoralis majör |
| 02 | `pectoralis_minor` | `pectoralis_minor_right` | `pectoralis_minor_left` | Pectoralis minor | Pektoralis minör |
| 03 | `serratus_anterior` | `serratus_anterior_right` | `serratus_anterior_left` | Serratus anterior | Serratus anterior |
| 04 | `deltoid_anterior` | `deltoid_anterior_right` | `deltoid_anterior_left` | Anterior deltoid | Ön deltoid |
| 05 | `deltoid_lateral` | `deltoid_lateral_right` | `deltoid_lateral_left` | Lateral deltoid | Yan deltoid |
| 06 | `deltoid_posterior` | `deltoid_posterior_right` | `deltoid_posterior_left` | Posterior deltoid | Arka deltoid |
| 07 | `biceps_brachii` | `biceps_brachii_right` | `biceps_brachii_left` | Biceps brachii | Biseps brakii |
| 08 | `brachialis` | `brachialis_right` | `brachialis_left` | Brachialis | Brakialis |
| 09 | `triceps_brachii` | `triceps_brachii_right` | `triceps_brachii_left` | Triceps brachii | Triseps brakii |
| 10 | `forearm_flexors_pronators` | `forearm_flexors_pronators_right` | `forearm_flexors_pronators_left` | Forearm flexors and pronators | Ön kol fleksörleri ve pronatörleri |
| 11 | `forearm_extensors_supinators` | `forearm_extensors_supinators_right` | `forearm_extensors_supinators_left` | Forearm extensors and supinators | Ön kol ekstansörleri ve supinatörleri |
| 12 | `trapezius` | `trapezius_right` | `trapezius_left` | Trapezius | Trapez |
| 13 | `rhomboids` | `rhomboids_right` | `rhomboids_left` | Rhomboids | Romboidler |
| 14 | `rotator_cuff` | `rotator_cuff_right` | `rotator_cuff_left` | Rotator cuff | Rotator manşet |
| 15 | `teres_major` | `teres_major_right` | `teres_major_left` | Teres major | Teres majör |
| 16 | `erector_spinae` | `erector_spinae_right` | `erector_spinae_left` | Erector spinae | Erektör spina |
| 17 | `external_oblique` | `external_oblique_right` | `external_oblique_left` | External oblique | Dış oblik |
| 18 | `gluteus_maximus` | `gluteus_maximus_right` | `gluteus_maximus_left` | Gluteus maximus | Gluteus maksimus |
| 19 | `gluteus_medius_minimus` | `gluteus_medius_minimus_right` | `gluteus_medius_minimus_left` | Gluteus medius and minimus | Gluteus medius ve minimus |
| 20 | `hip_adductors` | `hip_adductors_right` | `hip_adductors_left` | Hip adductors | Kalça addüktörleri |
| 21 | `iliopsoas` | `iliopsoas_right` | `iliopsoas_left` | Iliopsoas | İliopsoas |
| 22 | `quadriceps` | `quadriceps_right` | `quadriceps_left` | Quadriceps | Kuadriseps |
| 23 | `hamstrings` | `hamstrings_right` | `hamstrings_left` | Hamstrings | Hamstringler |
| 24 | `tibialis_anterior` | `tibialis_anterior_right` | `tibialis_anterior_left` | Tibialis anterior | Tibialis anterior |
| 25 | `gastrocnemius` | `gastrocnemius_right` | `gastrocnemius_left` | Gastrocnemius | Gastroknemius |
| 26 | `soleus` | `soleus_right` | `soleus_left` | Soleus | Soleus |
| 27 | `fibularis` | `fibularis_right` | `fibularis_left` | Fibularis muscles | Fibularis kasları |
| 28 | `hip_external_rotators_deep` | `hip_external_rotators_deep_right` | `hip_external_rotators_deep_left` | Deep hip external rotators | Derin kalça dış rotatörleri |

The JSON contract also provides explicit side-qualified English and Turkish
display names for all 56 regions, for example `Right quadriceps`, `Sağ
kuadriseps`, `Left quadriceps`, and `Sol kuadriseps`.

## Versioning

Version 1 has no deprecated identifiers. Future changes must increment the
schema version when they alter structure. Additive display-name corrections may
retain the schema version, but identifier replacement requires a migration and
an explicit deprecated-ID mapping before affected data is written.

The ontology pins the SHA-256 of the P2-02 reduction manifest so the semantic
contract cannot silently drift away from its source-region mapping.

# Anatomy Region Reduction

## Result

The BodyParts3D source is reduced to **56 render regions** formed from **28
bilateral working groups**. The reduction selects 166 non-overlapping source
OBJ elements and keeps left and right geometry independent.

The machine-readable source mapping is
[`bodyparts3d_region_reduction.v1.json`](../tool/anatomy/bodyparts3d_region_reduction.v1.json).
Its numeric slots and English working labels are pipeline references, not
product identifiers or localized user-interface names. P2-03 owns the stable
semantic identifiers and Turkish/English naming contract.

## Selection Rules

- Keep every output region unilateral; never merge left and right geometry.
- Merge source elements only when they form one training-relevant visual group.
- Preserve individual deltoid heads because exercise emphasis differs visibly.
- Keep gastrocnemius and soleus separate because they have distinct training
  and visualization value.
- Group small forearm, rotator-cuff, adductor, and deep-hip muscles where
  separate runtime picking would add cost without useful product detail.
- Assign every selected source element to exactly one output region.
- Retain all FMA concept and FJ element references for provenance.
- Exclude tendons, fascia, vessels, nerves, organs, skin, hair, and other
  non-muscle geometry from the render-region count.

## Working Region Inventory

| Slot | Working group | Source elements per side | Treatment |
| ---: | --- | ---: | --- |
| 01 | Pectoralis major | 3 | Merge clavicular, sternocostal, and abdominal parts |
| 02 | Pectoralis minor | 1 | Preserve as a deep chest region |
| 03 | Serratus anterior | 1 | Preserve |
| 04 | Anterior deltoid | 1 | Preserve deltoid head |
| 05 | Middle deltoid | 1 | Preserve deltoid head |
| 06 | Posterior deltoid | 1 | Preserve deltoid head |
| 07 | Biceps brachii | 2 | Merge long and short heads |
| 08 | Brachialis | 1 | Preserve |
| 09 | Triceps brachii | 3 | Merge long, lateral, and medial heads |
| 10 | Forearm flexor-pronator group | 11 | Merge training-level anterior forearm region |
| 11 | Forearm extensor-supinator group | 12 | Merge training-level posterior forearm region |
| 12 | Trapezius | 3 | Merge ascending, transverse, and descending parts |
| 13 | Rhomboids | 2 | Merge major and minor |
| 14 | Rotator cuff | 4 | Merge supraspinatus, infraspinatus, teres minor, and subscapularis |
| 15 | Teres major | 1 | Preserve separately from the rotator cuff |
| 16 | Erector spinae | 4 | Merge selected thoracic and lumbar columns |
| 17 | External oblique | 1 | Preserve |
| 18 | Gluteus maximus | 1 | Preserve |
| 19 | Gluteus medius-minimus | 2 | Merge lateral/deep gluteal region |
| 20 | Hip adductors | 5 | Merge primary medial-thigh adductors |
| 21 | Iliopsoas | 2 | Merge iliacus and psoas major |
| 22 | Quadriceps | 4 | Merge rectus femoris and three vasti |
| 23 | Hamstrings | 4 | Merge biceps femoris heads, semitendinosus, and semimembranosus |
| 24 | Tibialis anterior | 1 | Preserve |
| 25 | Gastrocnemius | 2 | Merge medial and lateral heads |
| 26 | Soleus | 1 | Preserve separately from gastrocnemius |
| 27 | Fibularis group | 3 | Merge longus, brevis, and tertius |
| 28 | Deep hip external rotators | 6 | Merge piriformis, obturators, gemelli, and quadratus femoris |

Each row produces one right and one left render region. The 28 rows therefore
produce 56 regions, which is inside the P2-02 target of 40-80.

## Source Coverage Gaps

The reviewed BodyParts3D release does not expose selectable meshes for several
training-critical muscles in its pinned IS-A metadata, including latissimus
dorsi, rectus abdominis, internal oblique, and transversus abdominis. These
regions are not substituted with anatomically incorrect nearby geometry.

The 56-region map is sufficient for the renderer and picking spike, but it is
not the final all-muscle product inventory. Before production anatomy content
is declared complete, the missing regions require either a separately licensed
supplemental source or original geometry with its own provenance review.

## Processing Contract

- P2-02 selects and groups source elements; it does not modify geometry.
- P2-03 assigns stable semantic identifiers and localized names to these slots
  through [the anatomy muscle ontology](ANATOMY_MUSCLE_ONTOLOGY.md).
- P2-04 extracts the listed OBJ elements, merges within each unilateral slot,
  performs cleanup and topology normalization, generates LODs, and exports GLB
  files through [the anatomy Blender pipeline](ANATOMY_PIPELINE.md).
- No raw BodyParts3D archive or source OBJ is committed to the repository.
- Processed outputs must keep the BodyParts3D attribution records, source hash,
  modification notice, license metadata, and their own output hashes.

## Acceptance Evidence

- 28 bilateral pairs produce 56 render regions.
- All 162 selected FMA concepts resolve to the pinned source metadata.
- All 166 selected FJ element files exist in the reviewed source archive.
- No FMA concept or FJ element is assigned to more than one output region.
- Every selected right-side FJ element has its matching left-side `M` element.
- Automated manifest tests enforce range, pairing, uniqueness, provenance, and
  separation from the P2-03 semantic naming contract.

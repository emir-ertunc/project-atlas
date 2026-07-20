# Anatomy Source Asset Selection

## Decision

Project Atlas will use the **BodyParts3D 4.0 IS-A Tree OBJ dataset with 99%
polygon reduction** as the source for both skeleton and muscle geometry.

- Asset ID: `anatomy-source-bodyparts3d-v4-isa-obj99`
- Publisher: The Database Center for Life Science, Research Organization of
  Information and Systems
- Database creator: Kousaku Okubo
- Subject: three-dimensional whole-body anatomy of an adult human male
- Runtime status: source only; not bundled in the application or repository
- Review date: 2026-07-08

The selection covers one coordinated anatomical dataset rather than combining
unrelated skeleton and muscle models. This avoids alignment, scale, and naming
conflicts during the P2-02 region-reduction work.

## Selected Source Files

| File | Purpose | SHA-256 |
| --- | --- | --- |
| `isa_BP3D_4.0_obj_99.zip` | 2,234 Wavefront OBJ element meshes | `40665852c49f218326590e204db91064a1ecfc3c6f8cbd7bbbcaac62c7cd409e` |
| `isa_parts_list_e.txt` | FMA, BodyParts3D, and English concept-name mapping | `ab7796deedd49205e77f3609a1cb8c53e2bbee14ecb5c9a6ca05227469780513` |
| `isa_element_parts.txt` | Compound-concept to element-mesh mapping | `a3de74423f943b0d724ae8f59b3a817f87c423a544f8db98113b1980817cbeaf` |
| `isa_inclusion_relation_list.txt` | Anatomical hierarchy relationships | `26e7d818e03a8c909fe09c561f38d0d513423c87681f9450a803bc38f5b07564` |
| `README_e.html` | Dataset description and license record | `f9a90b4d945ad0fe50db45c712e931aa54e52667187b30d7085b6cc394f40107` |
| `release_4.0_e.html` | Release 4.0 notes | `771bd30a47ab11396eb6333e73a946426093c57fa4d4a1db8f718910fea7d985` |

Official locations:

- [Database description](https://dbarchive.biosciencedbc.jp/en/bodyparts3d/desc.html)
- [Download page](https://dbarchive.biosciencedbc.jp/en/bodyparts3d/download.html)
- [License terms](https://dbarchive.biosciencedbc.jp/en/bodyparts3d/lic.html)
- [IS-A OBJ archive](https://dbarchive.biosciencedbc.jp/data/bodyparts3d/LATEST/isa_BP3D_4.0_obj_99.zip)
- [IS-A concept names](https://dbarchive.biosciencedbc.jp/data/bodyparts3d/LATEST/isa_parts_list_e.txt)
- [IS-A element mapping](https://dbarchive.biosciencedbc.jp/data/bodyparts3d/LATEST/isa_element_parts.txt)
- [IS-A hierarchy](https://dbarchive.biosciencedbc.jp/data/bodyparts3d/LATEST/isa_inclusion_relation_list.txt)

## License and Redistribution Requirements

- Current official catalog license: Creative Commons Attribution 4.0
  International (`CC-BY-4.0`)
- Embedded OBJ header notice retained conservatively: Creative Commons
  Attribution-Share Alike 2.1 Japan (`CC-BY-SA-2.1-JP`)
- Redistribution: permitted with attribution, subject to the conservative
  share-alike handling below
- Modification and derivative distribution: permitted with attribution, source
  and output hashes, and modification notice
- Commercial use: permitted by the current catalog license

The current official BodyParts3D catalog page lists `CC-BY-4.0`. Reviewed OBJ
headers in the source archive also contain an older `CC-BY-SA-2.1-JP` notice.
Until the publisher's intended precedence is clarified, every processed
geometry distribution must retain both attribution records and be treated as a
share-alike geometry asset for repository review and distribution planning.

Required attribution records:

> BodyParts3D, © The Database Center for Life Science licensed under CC
> Attribution 4.0 International

> BodyParts3D, (c) The Database Center for Life Science licensed under CC
> Attribution-Share Alike 2.1 Japan

Processed assets must also link to the license record, identify that geometry
was modified, and preserve both source and processed-file hashes. The asset
license applies to anatomy data and derived assets; it does not replace the
repository's Apache-2.0 code license.

## Technical Acceptance Evidence

- The downloaded archive lists successfully and contains 2,234 OBJ files.
- The local archive size, 142,903,898 bytes, matches the official download.
- Metadata contains left/right skeletal concepts, including hip bones and
  individual ribs.
- Metadata contains left/right training-relevant muscle concepts, including
  pectoralis major, deltoid, biceps brachii, triceps brachii, gluteus maximus,
  and soleus structures.
- The source provides stable FMA and BodyParts3D identifiers that can be mapped
  to the product ontology without using display names as identifiers.

## Processing Boundary

- Do not commit the raw source archive or the complete OBJ collection.
- P2-02 selects 166 source elements into 28 bilateral working groups, producing
  56 independent left/right render regions. The exact mapping and known source
  gaps are recorded in [anatomy region reduction](ANATOMY_REGION_REDUCTION.md).
- P2-04 performs cleanup, topology normalization, LOD generation, and GLB
  export through [the anatomy Blender pipeline](ANATOMY_PIPELINE.md).
- Every committed output must be reviewed separately for attribution,
  processed hash, geometry budget, and runtime necessity.
- The model is a visual anatomy reference, not a medical scan or diagnostic
  representation.

## Alternatives

Z-Anatomy was reviewed but not selected as the production source. It may not be
copied into the repository or used to create production derivatives without a
new license review. Because BodyParts3D source OBJ headers also carry an older
share-alike notice, any future source comparison must evaluate both datasets
against the same distribution and attribution standard.

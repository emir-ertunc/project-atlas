# Backup and Encrypted Export Security

## Status

Uncontrolled operating-system backup is disabled for the local data used by the
personal release. This document also defines the encrypted export contract that
P8-10 will implement. No plaintext export or restore path is permitted.

## Threat Model

The controls protect against:

- Automatic cloud backup of health and training records
- Unrequested device-to-device transfer of application data
- Disclosure of an exported file stored in email, cloud storage, or removable
  media
- Offline password guessing within the limits of the chosen passphrase
- Undetected modification, truncation, or corruption of an export
- Partial or unsafe database replacement during restore

They do not protect an unlocked device or an application process already
controlled by an attacker. Device access control, operating-system security,
and careful passphrase handling remain required.

## Platform Backup Policy

### Android

The application sets `android:allowBackup="false"`. Separate XML rules cover
Android 11 and earlier and Android 12 or later. Both cloud backup and
device-to-device transfer exclude the complete credential-protected and
device-protected root, file, database, shared-preference, and external-file
domains.

Both rule formats remain mandatory. `allowBackup` alone is insufficient as the
only control because device manufacturers can treat device-to-device transfer
differently on Android 12 and later.

### iOS

Drift stores the database in the application Documents directory. At every
launch the application marks that directory with
`URLResourceValues.isExcludedFromBackup`. Local database files, WAL files, and
future private files under that directory therefore remain outside automatic
device backup.

An iOS build and restore check is required when iOS development begins. The
source-level policy test does not replace validation on Apple tooling and a
physical device.

## Export Principles

- Export is an explicit user action with a destination chosen through the
  platform document interface.
- Only an authenticated encrypted container may leave application-private
  storage.
- The passphrase and derived key are never persisted, synchronized, logged, or
  placed in repository fixtures.
- Losing the passphrase makes the export unrecoverable. The interface must state
  this before creation.
- Exercise media, anatomy assets, caches, signing material, and bundled catalog
  content are not included.
- Plaintext working files stay in an operating-system no-backup temporary
  location and are removed after success or failure.

## Measurement History Report Copy

P6-09 adds a measurement-history CSV/JSON report copy on the Progress screen.
This is not a backup or restore path and does not write a plaintext file. It is
an explicit clipboard action with a personal-data warning, omits `profile_id`,
and remains separate from the restore-capable encrypted container required for
P8-10.

## Container Version 1

The file extension is `.atlasbackup`. Multi-byte integers use big-endian byte
order.

```text
8 bytes   magic: ATLASBK1
4 bytes   authenticated header length
N bytes   UTF-8 canonical JSON header (AES-GCM additional data)
M bytes   ciphertext
16 bytes  AES-GCM authentication tag
```

The header contains only format and cryptographic metadata:

- Container format version
- Payload schema version
- KDF identifier and Argon2 version
- Argon2id memory, iteration, and parallelism parameters
- 16-byte random salt
- Cipher identifier
- 12-byte random nonce
- Authentication-tag length

It must not contain names, measurements, workout dates, goals, locale, or other
user data. Unknown required fields, algorithms, or versions cause restore to
stop before decryption.

## Cryptographic Profile

- Key derivation: Argon2id version 1.3
- Baseline parameters: 64 MiB memory, three iterations, four lanes
- Salt: 16 bytes from the operating-system cryptographic random source, unique
  for every export
- Derived key: 32 bytes
- Authenticated encryption: AES-256-GCM
- Nonce: 12 random bytes, unique for the per-export key
- Authentication tag: 16 bytes
- Additional authenticated data: magic, header length, and the exact header
  bytes
- Passphrase encoding: Unicode NFC normalization followed by UTF-8, with no
  trimming; creation requires confirmation and at least 12 Unicode characters

The Argon2id baseline follows the memory-constrained recommendation in
[RFC 9106](https://www.rfc-editor.org/rfc/rfc9106). AES-GCM usage follows
[NIST SP 800-38D](https://csrc.nist.gov/pubs/sp/800/38/d/final). The
implementation must use maintained cryptographic libraries and must not
implement either primitive directly.

Devices must be benchmarked before P8-10 is accepted. A stronger configuration
may be stored per export, but the implementation must not silently fall below
the baseline. Restore applies documented upper bounds before running a KDF so a
hostile header cannot request unbounded memory or CPU time.

## Payload

The encrypted payload is a deterministic archive containing:

- `manifest.json` with payload format, database schema version, entry sizes,
  and SHA-256 hashes used for post-decryption diagnostics
- `project_atlas.sqlite`, a consistent SQLite snapshot

The snapshot is created with SQLite's backup mechanism or `VACUUM INTO` while
the live database is coordinated by the application. Copying only the live
SQLite file is forbidden because committed data may still be represented by a
WAL file.

Archive entry count, individual size, total expanded size, path depth, and
compression ratio have strict limits. Absolute paths, parent traversal,
symlinks, and duplicate entry names are rejected.

## Restore Flow

1. Read and bounds-check the fixed prefix and header.
2. Accept only supported container, KDF, cipher, and parameter values.
3. Derive the key from the supplied passphrase.
4. Authenticate the complete ciphertext before parsing any payload entry.
5. Extract into a fresh private no-backup temporary directory.
6. Validate the manifest, hashes, archive limits, and expected file names.
7. Open the candidate database separately and run schema migration, SQLite
   integrity checking, and foreign key checking.
8. Show the user a non-sensitive summary and require confirmation before
   replacement.
9. Close the active database, preserve a local rollback copy, remove stale WAL
   sidecars, atomically replace it, and reopen it.
10. Delete temporary plaintext and the rollback copy after verified success.

Authentication failure, a wrong passphrase, and corrupted ciphertext produce
one generic error and expose no partially decrypted data. Restore never merges
records in container version 1; it replaces the local dataset only after
validation and confirmation.

## P8-10 Acceptance Requirements

- Independent known-answer tests for KDF and AEAD library integration
- Round-trip tests across Android and iOS implementations
- Wrong-passphrase, modified-header, modified-ciphertext, truncated-file, and
  nonce-uniqueness tests
- Archive traversal, decompression-limit, KDF-limit, and unsupported-version
  tests
- Database migration, integrity, rollback, cancellation, low-storage, and
  interrupted-restore tests
- Verification that no plaintext export remains after success or failure

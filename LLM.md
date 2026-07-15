# kms — AI Assistant Context

Zoo runs the sovereign image `ghcr.io/zooai/kms:<ver>` (thin pin over `luxfi/kms` + Zoo
branding). Live: `do-sfo3-zoo-k8s` ns `zoo-kms`, statefulset `kms` (1 node), PVC
`data-kms-0` on `do-block-storage-retain`.

## 2026-07-15 — KMS↔MPC wire fix (v1.12.3) PROVEN; live upgrade STAGED

- **`zooai/kms:1.12.3`** (pin `luxfi/kms:1.12.3`, wire-fix commit `7105376`) is BUILT. The fix
  realigns the KMS↔MPC ZAP signing wire to the mpcd contract: `SignRequest{vault_id,
  wallet_id,payload}`, snake_case `KeygenResult`, and `ZapClient.call()` surfaces a daemon
  `{"error":…}` frame as a REAL error — killing the false-green empty-signature path.
- **End-to-end wire fix PROVEN** against the fixed zoo ring via an ephemeral no-master-key
  KMS v1.12.3 pod (`mpc ready=true peers=4/4`): `POST /v1/kms/keys/generate` created a genuine
  degree-2 wallet (`713f5c2d…`, pub `0360ac6b…`) on the ring; `POST /v1/kms/keys/{id}/sign
  key_type=bls` returned a real ECDSA sig (R,S) that VERIFIES against the wallet pubkey.
  (`SignResponse.signature` concat field is empty while R/S are populated — informational
  follow-up: mpcd KMS-ZAP should populate the concatenated signature.) Corona/ed25519 over the
  KMS-ZAP keygen is still single-curve (secp256k1 only) — a known follow-up.
- **LIVE zoo-kms upgrade to 1.12.3 is STAGED, NOT rolled.** Current zoo-kms is `1.11.8`,
  secrets-only (`MPC_VAULT_ID` empty, `ZAP_PORT=0`) with a legacy `KMS_MASTER_KEY_B64` REK, so
  it does NOT MPC-sign → NOT exposed to the false-green bug. **Blocker:** v1.12.3's `/v1/sdk`
  plane fires a MANDATORY consensus authorizer (`buildConsensusAuthorizer`, "refuses to boot
  fail-open") whenever a REK/master key is loaded — independent of `ZAP_PORT`. So a live
  upgrade that keeps the master key MUST also set `KMS_CONSENSUS_VALIDATORS`+`KMS_CONSENSUS_
  OPERATORS` (or `KMS_CONSENSUS_FILE`), else crashloop. Enabling MPC-backing itself only needs
  `MPC_VAULT_ID=zoo` + `MPC_ADDR=mpc-node-{0..4}.mpc-node-headless.zoo-mpc.svc:9653` (no
  authority needed) — the wire fix is braided with the authorizer in one release; that coupling
  is what blocks the live roll.

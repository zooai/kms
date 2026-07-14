# Zoo KMS — runs upstream luxfi/kms (pure-Go Hanzo/Lux KMS) with Zoo branding.
# Sovereign version tag MIRRORS the wrapped upstream: zooai/kms:v1.11.8 ==
# luxfi/kms:1.11.8 — EXACT parity with the proven live lux-kms-go/kms-0 (the
# task's Lux reference), which boots secrets-only (ZAP_PORT=0, MPC_VAULT_ID="")
# with a KMS_MASTER_KEY_B64 REK. Patch-pin only — never :latest.
#   NOTE: luxfi/kms 1.11.10 introduced a MANDATORY consensus-authorizer that
#   fail-closes without KMS_CONSENSUS_VALIDATORS/OPERATORS whenever a master key
#   is set — neither Lux (v1.11.8) nor Hanzo (1.11.9, no master key) satisfy it
#   today. Moving Zoo + the fleet to 1.11.10 with real consensus authority is a
#   coordinated upgrade owned by the KMS-issuer/consensus workstream; the Zoo
#   zoo-mpc ring (proven DKG + threshold sign) is ready to back it.
FROM ghcr.io/luxfi/kms:1.11.8
ENV KMS_ORG=zoo
ENV KMS_KEY_PREFIX=zoo/
ENV KMS_BRAND_NAME=Zoo

# Zoo KMS — runs upstream luxfi/kms (pure-Go Hanzo/Lux KMS) with Zoo branding.
# Sovereign version tag MIRRORS the wrapped upstream: zooai/kms:1.12.3 ==
# luxfi/kms:1.12.3. This release carries the KMS↔MPC ZAP signing-wire fix
# (luxfi/kms 7105376): SignRequest is {vault_id, wallet_id, payload}, KeygenResult
# tags are snake_case, and ZapClient.call() surfaces a daemon {"error":…} frame as
# a real error — killing the false-green empty-signature path. Patch-pin only,
# never :latest.
#   MPC-backing (threshold signing) is enabled purely by MPC_VAULT_ID + MPC_ADDR;
#   it does NOT require consensus authority and is what the zoo-mpc ring (proven
#   genuine 3-of-5 DKG + threshold sign) backs.
#   SEPARATE CONCERN: 1.12.3 also carries the native /v1/sdk enveloped-secrets +
#   threshold-sign plane, whose consensus authorizer fail-CLOSES (refuses to boot)
#   without KMS_CONSENSUS_VALIDATORS/OPERATORS *whenever a REK/master key is loaded*
#   (KMS_MASTER_KEY_B64 or MPC_REK_ENDPOINT). So a LIVE zoo-kms upgrade that keeps
#   its master key MUST also set the consensus authority; a boot with no master key
#   (proof / stateless signer) skips the authorizer entirely.
FROM ghcr.io/luxfi/kms:1.12.3
ENV KMS_ORG=zoo
ENV KMS_KEY_PREFIX=zoo/
ENV KMS_BRAND_NAME=Zoo

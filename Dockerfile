# Zoo KMS — runs upstream luxfi/kms (pure-Go Hanzo/Lux KMS) with Zoo branding.
# Sovereign version tag MIRRORS the wrapped upstream: zooai/kms:1.12.8 ==
# luxfi/kms:1.12.8. Patch-pin only, never :latest.
#
# 1.12.8 adds the JSON-only listener (luxfi/kms f7fc4d7). Before it, the binary
# embedded a console SPA under a root catch-all, so any path the server did NOT
# have came back 200 with an HTML page. A caller pointed at a wrong URL read that
# as success. kms.zoo.network still shows this today: GET /v1/kms/status returns
# 200 text/html from 1.11.8, and the route does not exist. Every response is JSON
# now, and an unmatched path is a JSON 404 that names the path.
#
# 1.12.3 carried the KMS↔MPC ZAP signing-wire fix (luxfi/kms 7105376):
# SignRequest is {vault_id, wallet_id, payload}, KeygenResult tags are snake_case,
# and ZapClient.call() surfaces a daemon {"error":…} frame as a real error —
# killing the false-green empty-signature path.
#   MPC-backing (threshold signing) is enabled purely by MPC_VAULT_ID + MPC_ADDR;
#   it does NOT require consensus authority and is what the zoo-mpc ring (proven
#   genuine 3-of-5 DKG + threshold sign) backs.
#
# ── BLOCKER on rolling the LIVE zoo-kms (read before deploying this image) ──
# 1.12.3+ carries the native /v1/sdk enveloped-secrets + threshold-sign plane,
# whose consensus authorizer fail-CLOSES (refuses to boot) without
# KMS_CONSENSUS_VALIDATORS/OPERATORS *whenever a REK/master key is loaded*.
# The live zoo-kms StatefulSet (ctx do-sfo3-zoo-k8s, ns zoo-kms) is still on
# 1.11.8 and its env has KMS_MASTER_KEY_B64 set with NO KMS_CONSENSUS_VALIDATORS,
# NO KMS_CONSENSUS_OPERATORS and NO KMS_CONSENSUS_FILE. Rolling it onto this
# image AS-IS will crashloop. Pick one first, then roll:
#   (a) set the consensus authority (validators/operators, or KMS_CONSENSUS_FILE), or
#   (b) migrate the REK to MPC_REK_ENDPOINT against the zoo-mpc ring.
# That is a key-custody decision, which is why this image is staged and the
# StatefulSet is deliberately left on 1.11.8.
FROM ghcr.io/luxfi/kms:1.12.8
ENV KMS_ORG=zoo
ENV KMS_KEY_PREFIX=zoo/
ENV KMS_BRAND_NAME=Zoo

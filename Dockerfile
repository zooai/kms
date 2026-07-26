# Zoo KMS — runs upstream luxfi/kms (pure-Go Hanzo/Lux KMS) with Zoo branding.
# Sovereign version tag MIRRORS the wrapped upstream: zooai/kms:1.12.9 ==
# luxfi/kms:1.12.9. Patch-pin only, never :latest.
#
# 1.12.8 added the JSON-only listener (luxfi/kms f7fc4d7). Before it, the binary
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
# 1.12.9 adds GET /v1/kms/orgs/{org}/secrets?path=&env= — the HTTP secret-list
# route, giving the HTTP surface parity with the ZAP wire OpSecretList.
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
# There is a THIRD route, strictly safer than either:
#   (c) DROP KMS_MASTER_KEY_B64 from the StatefulSet.
# In 1.12.9 the REK has exactly ONE consumer: zapserver.Config{MasterKey}. The
# HTTP secrets plane never touches it — putSecretHandler assigns
# Ciphertext: []byte(req.Value) and GET returns string(sec.Ciphertext), calling
# neither store.Seal nor store.Open. zoo-kms runs ZAP_PORT=0 and MPC_VAULT_ID="",
# so that HTTP plane is ALL it serves. With no REK: masterKey is nil, /v1/sdk is
# never mounted, buildConsensusAuthorizer never runs, and nothing zoo-kms serves
# changes. Leave kms-secrets/master-key-b64 in place and it is one line to revert.
#
# Route (b) is not merely unprovisioned, it is UNIMPLEMENTED: mpcrek.Bootstrap
# calls OpDecrypt 0x0031 and the deployed zooai/mpc:1.17.12 dispatch map holds
# only 0x0001/0x0010/0x0011/0x0012/0x0020. The daemon answers "unknown opcode",
# the KMS aborts on boot — a deterministic crashloop.
#
# Data risk HERE is nil: the live store is empty (Badger logs "Set nextTxnTs to
# 0", no .sst files, ~48K on disk). That does NOT generalise — crypto.go wraps a
# per-secret DEK under the REK and there is no rek-rotate tool in the tree, so on
# a POPULATED store a changed REK is unrecoverable loss of anything ZAP sealed.
FROM ghcr.io/luxfi/kms:1.12.9
ENV KMS_ORG=zoo
ENV KMS_KEY_PREFIX=zoo/
ENV KMS_BRAND_NAME=Zoo

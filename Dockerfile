# Zoo KMS — runs upstream luxfi/kms (pure-Go Hanzo/Lux KMS) with Zoo branding.
# Sovereign version tag MIRRORS the wrapped upstream: zooai/kms:v1.11.10 ==
# luxfi/kms:1.11.10 (latest patch line; Hanzo prod runs 1.11.9). Patch-pin only —
# never :latest, never a lazy major bump. Inherits the upstream kmsd ENTRYPOINT;
# full operational env (IAM, ZAP, MPC vault, at-rest keys) is set by the
# zoo-kms StatefulSet, white-labelled to the Zoo brand by domain.
FROM ghcr.io/luxfi/kms:1.11.10
ENV KMS_ORG=zoo
ENV KMS_KEY_PREFIX=zoo/
ENV KMS_BRAND_NAME=Zoo

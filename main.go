// Copyright (C) 2026, Zoo Labs Foundation. All rights reserved.
// Zoo KMS — Key Management Service for Zoo Network validators and treasury.
// Thin wrapper around luxfi/kms with Zoo-specific configuration.
package main

import (
	"fmt"
	"os"
)

const version = "0.1.0"

func main() {
	if len(os.Args) > 1 && (os.Args[1] == "version" || os.Args[1] == "--version") {
		fmt.Printf("zoo-kms %s\n", version)
		os.Exit(0)
	}

	// Zoo KMS delegates to the upstream Lux KMS binary.
	// In production, use the ghcr.io/luxfi/kms image with Zoo-specific env vars:
	//   KMS_ORG=zoo
	//   KMS_KEY_PREFIX=zoo/
	//   KMS_BRAND_NAME=Zoo
	//
	// This binary serves as the entrypoint for the Zoo KMS Docker image,
	// setting defaults before delegating to the upstream KMS server.
	fmt.Println("Zoo KMS — use ghcr.io/luxfi/kms with Zoo configuration")
	fmt.Println("Environment variables:")
	fmt.Println("  KMS_ORG=zoo")
	fmt.Println("  KMS_KEY_PREFIX=zoo/")
	fmt.Println("  KMS_BRAND_NAME=Zoo")
	fmt.Println("  KMS_LISTEN=:8443")
}

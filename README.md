# Multus + kind quick lab

This setup creates a kind cluster with one control-plane and one worker, attaches an extra Docker network to the kind nodes, installs Multus, and attaches a second pod interface with a `NetworkAttachmentDefinition`.

## Files

- `kind-config.yaml`
- `manifests/network-attachment-definition.yaml`
- `scripts/01-create-kind.sh`
- `scripts/02-setup-secondary-network.sh`
- `scripts/03-run-nginx-secondary.sh`
- `scripts/04-install-multus.sh`
- `scripts/05-apply-nad.sh`
- `scripts/06-test-curl-nginx.sh`
- `scripts/99-cleanup.sh`

## Run

```bash
./scripts/01-create-kind.sh
./scripts/02-setup-secondary-network.sh
./scripts/03-run-nginx-secondary.sh
./scripts/04-install-multus.sh
./scripts/05-apply-nad.sh
./scripts/06-test-curl-nginx.sh
```

Expected test output includes `200` from curl.

## Clean up

```bash
./scripts/99-cleanup.sh
```


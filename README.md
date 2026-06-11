# Multus + kind quick lab

This setup creates a kind cluster with one control-plane and two workers, attaches an extra Docker network to the kind nodes, installs Multus and Whereabouts, and attaches a second pod interface with a `NetworkAttachmentDefinition`.

The secondary network uses only two pod IPs, and the test verifies that a third pod cannot get one.

## Files

- `kind-config.yaml`
- `manifests/network-attachment-definition.yaml`
- `scripts/01-create-kind.sh`
- `scripts/02-setup-secondary-network.sh`
- `scripts/03-run-nginx-secondary.sh`
- `scripts/04-install-multus.sh`
- `scripts/05-install-whereabouts.sh`
- `scripts/06-apply-nad.sh`
- `scripts/07-test-curl-nginx.sh`
- `scripts/99-cleanup.sh`
- `scripts/run-all.sh`

## Run

```bash
./scripts/01-create-kind.sh
./scripts/02-setup-secondary-network.sh
./scripts/03-run-nginx-secondary.sh
./scripts/04-install-multus.sh
./scripts/05-install-whereabouts.sh
./scripts/06-apply-nad.sh
./scripts/07-test-curl-nginx.sh
```

Expected test output includes:
- two distinct secondary IPs printed
- two `200` curl responses
- a non-running status for the third pod

## Clean up

```bash
./scripts/99-cleanup.sh
```

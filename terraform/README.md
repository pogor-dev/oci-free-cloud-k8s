# Terraform project

Run commands from this directory. Authentication uses the provider variables in
`production.tfvars`.

## Initialize the OCI backend

Use Terraform >= 1.12.0 with the `oracle/oci` provider. Run commands from this
`terraform/` directory. Backend settings are literal values in `versions.tf` because
Terraform backend blocks cannot reference variables. Backend authentication uses
the `DEFAULT` profile in `~/.oci/config`. Provider authentication continues to use
`production.tfvars`. Ensure both credentials refer to the intended tenancy.

All existing backups and `.tfvars` were preserved. The active local state uses
`registry.terraform.io/oracle/oci`; `terraform.tfstate.before-terraform.backup`
preserves the exact pre-conversion state. Remote migration has not been performed.

With no concurrent runs, migrate the local state to the existing OCI bucket:

```sh
terraform init -migrate-state
terraform state list
terraform plan -var-file=production.tfvars
```

Confirm the prompt to copy existing state. Keep local backups until the remote
state and plan are verified. Use `-migrate-state`, not `-reconfigure`. For other
environments update the backend settings or supply `-backend-config` overrides: `-var-file` does not set
backend values. The native OCI backend supports locking and API signing-key
authentication; no S3 Customer Secret Key is needed.

## Current subnet configuration

The active subnet and security-list files follow the OKE reference network:

| Purpose | CIDR | Routing | DNS label |
| --- | --- | --- | --- |
| Private API endpoint | `10.0.0.0/28` | NAT and service gateway | `api` |
| Private workers | `10.0.10.0/24` | NAT and service gateway | `workers` |
| Public load balancers | `10.0.20.0/24` | Internet gateway | `loadbalancers` |

API and worker security lists mirror the reference rules. The public
load-balancer security list starts empty. OCI service CIDRs are discovered for
the configured region. Each subnet uses its own security list.

Cluster and node-pool definitions are active in `oke.tf`. Files ending in
`.tf_`, if present, are inactive.
The configuration changes do not deploy resources until `terraform apply` is run.

## Historical private VCN-native API endpoint migration

The following notes describe the earlier shared-subnet deployment, not the
current subnet configuration above.

The cluster is created with its Kubernetes API endpoint sharing the existing
regional private worker subnet (`10.0.1.0/24`), with no public IP. The subnet uses the existing NAT
and service gateway routes. Security rules allow API access from the VCN and
control-plane/worker and inter-node pod communication within the shared subnet.
Public IP assignment is disabled for the subnet. This is VCN-native API networking; it does
not change the cluster's pod networking CNI.

The existing cluster was migrated to this private endpoint. OCI keeps the old
public endpoint available until it is explicitly decommissioned. Keep it enabled
until the new endpoint has been verified from a host with access to the VCN.
The kubeconfig at `~/.kube/oke-private` targets the private endpoint; this
workstation currently has no route to `10.0.1.213`.

The migration was started through the OCI CLI, so refresh Terraform's local state
and inspect the plan before the next apply. Do not apply a plan that replaces
the cluster.

```sh
terraform plan -var-file=production.tfvars -out=create.tfplan
terraform apply create.tfplan
```

To destroy the existing managed stack and recreate it:

```sh
terraform plan -destroy -var-file=production.tfvars -out=destroy.tfplan
terraform apply destroy.tfplan
terraform plan -var-file=production.tfvars -out=create.tfplan
terraform apply create.tfplan
```

Destroying the stack removes the managed cluster and nodes. Recreating Always
Free compute depends on available capacity. Preserve any workload data you need
before destroying the stack.

## Access the private API

API access is allowed from the VCN CIDR. Clients can run inside the VCN or use an
OCI Bastion tunnel. Access from other networks requires both private connectivity
and additional security rules.

Generate a kubeconfig using an OCI CLI profile authorized for this cluster. The
CLI does not automatically use Terraform provider credentials.

```sh
oci ce cluster create-kubeconfig \
  --cluster-id "$(terraform output -raw oke_cluster_id)" \
  --region "$(terraform output -raw oke_region)" \
  --file "$HOME/.kube/oke-private" \
  --token-version 2.0.0 \
  --kube-endpoint PRIVATE_ENDPOINT
kubectl --kubeconfig "$HOME/.kube/oke-private" get nodes
```

Run the connectivity check from a host with private network access. A bastion
tunnel also requires configuring the kubeconfig to use that tunnel.
`terraform output oke_endpoints` shows the assigned endpoint addresses.

See Oracle's [network configuration guide](https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengnetworkconfig.htm).

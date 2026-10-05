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

## Access the private API through Bastion

The Bastion configuration uses a dedicated private subnet (`10.0.30.0/28`),
with stateful egress to the API subnet on TCP/6443. The existing API security
list already allows TCP/6443 from `0.0.0.0/0`, which includes the Bastion subnet;
no additional ingress rule is required. The API endpoint remains private.

`bastion_client_cidrs` in the ignored `production.tfvars` allows the workstation's
public IPv4 address (`123.243.57.69/32` when detected). Update this value and apply
if your public IP changes. Bastion sessions last at most three hours and are
created on demand, outside Terraform state.

### Deploy when ready

From this directory, review a fresh plan and apply it:

```sh
terraform plan -var-file=production.tfvars -out=bastion.tfplan
terraform apply bastion.tfplan
```

Your OCI CLI identity must have permission to use the cluster and Bastion and
manage Bastion sessions. This configuration does not create IAM grants. It uses
the existing administrator access; other users need suitable policies.

### Create a session

Use an SSH authentication key pair (not the OCI API signing key). Generate a
dedicated key if needed, choosing a new filename to avoid replacing an existing key:

```sh
ssh-keygen -t rsa -b 3072 -f "$HOME/.ssh/oke-bastion"
```

Set the connection values and request a session:

```sh
oke_region=$(terraform output -raw oke_region)
oke_cluster_id=$(terraform output -raw oke_cluster_id)
oke_bastion_id=$(terraform output -raw bastion_id)
oke_endpoint=$(terraform output -raw oke_private_endpoint)
oke_api_ip=${oke_endpoint%:*}
oke_key="$HOME/.ssh/oke-bastion"

oke_session_id=$(oci bastion session create-port-forwarding \
  --region "$oke_region" \
  --bastion-id "$oke_bastion_id" \
  --ssh-public-key-file "$oke_key.pub" \
  --target-private-ip "$oke_api_ip" \
  --target-port 6443 \
  --session-ttl 10800 \
  --query 'data.id' --raw-output)

oci bastion session get --region "$oke_region" --session-id "$oke_session_id" \
  --query 'data."lifecycle-state"' --raw-output
```

Repeat the last command until the session is `ACTIVE`. Obtain its SSH command:

```sh
oci bastion session get --region "$oke_region" --session-id "$oke_session_id" \
  --query 'data."ssh-metadata".command' --raw-output
```

In the returned command, replace the private-key placeholder with the path to
`oke-bastion`, and replace the local-port placeholder with `127.0.0.1:16443`.
Keep the returned session host and target address. Add
`-o ExitOnForwardFailure=yes -o ServerAliveInterval=30` to `ssh` and run it in a
separate terminal. Keep the tunnel in the foreground; Ctrl-C closes it.

### Configure kubectl

Use a dedicated kubeconfig, preserving your default configuration. The following
refuses to overwrite an existing file; choose another filename if needed:

```sh
oke_kubeconfig="$HOME/.kube/oke-bastion"
if [ -e "$oke_kubeconfig" ]; then
  echo "Choose a new kubeconfig filename; this one already exists."
else
  oci ce cluster create-kubeconfig \
    --cluster-id "$oke_cluster_id" \
    --region "$oke_region" \
    --file "$oke_kubeconfig" \
    --token-version 2.0.0 \
    --kube-endpoint PRIVATE_ENDPOINT

  oke_context_cluster=$(kubectl --kubeconfig "$oke_kubeconfig" config view \
    --minify -o jsonpath='{.contexts[0].context.cluster}')
  kubectl --kubeconfig "$oke_kubeconfig" config set-cluster "$oke_context_cluster" \
    --server=https://127.0.0.1:16443 \
    --tls-server-name="$oke_api_ip"
fi
```

TLS verification still uses the cluster CA and original API IP. Do not disable
certificate verification. With the tunnel running:

```sh
kubectl --kubeconfig "$oke_kubeconfig" get nodes
```

When finished, close the tunnel and optionally delete the session:

```sh
oci bastion session delete --region "$oke_region" --session-id "$oke_session_id"
```

For subsequent connections, create a new session and open its tunnel. Existing
kubeconfig settings remain usable while the cluster endpoint is unchanged.

Reference: [Oracle: Setting Up a Bastion for Cluster Access](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengsettingupbastion.htm).

resource "oci_core_security_list" "api-security-list" {
  compartment_id = oci_identity_compartment.infra-compartment.id
  vcn_id         = module.vcn.vcn_id
  display_name   = "api-security-list-${var.org}-${var.project}-${var.env}"

  egress_security_rules {
    description      = "Allow Kubernetes Control Plane to communicate with OKE"
    stateless        = false
    destination      = data.oci_core_services.all-oci-services.services[0].cidr_block
    destination_type = "SERVICE_CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"

    tcp_options {
      min = 443
      max = 443
    }
  }

  egress_security_rules {
    description      = "All traffic to worker nodes"
    stateless        = false
    destination      = local.private_subnet_cidr
    destination_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"
  }

  egress_security_rules {
    description      = "Path discovery"
    stateless        = false
    destination      = local.private_subnet_cidr
    destination_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1
    protocol = "1"

    # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    description = "External access to Kubernetes API endpoint"
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    description = "Kubernetes worker to Kubernetes API endpoint communication"
    stateless   = false
    source      = local.private_subnet_cidr
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    description = "Kubernetes worker to control plane communication"
    stateless   = false
    source      = local.private_subnet_cidr
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"

    tcp_options {
      min = 12250
      max = 12250
    }
  }

  ingress_security_rules {
    description = "Path discovery"
    stateless   = false
    source      = local.private_subnet_cidr
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1
    protocol = "1"

    # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
    icmp_options {
      type = 3
      code = 4
    }
  }
}

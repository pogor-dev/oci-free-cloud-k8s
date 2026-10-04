data "oci_core_services" "all-oci-services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_security_list" "private-security-list" {
  compartment_id = oci_identity_compartment.infra-compartment.id
  vcn_id         = module.vcn.vcn_id
  display_name   = "private-security-list-${var.org}-${var.project}-${var.env}"

  egress_security_rules {
    description      = "Allow pods on one worker node to communicate with pods on other worker nodes"
    stateless        = false
    destination      = local.private_subnet_cidr
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  egress_security_rules {
    description      = "Access to Kubernetes API Endpoint"
    stateless        = false
    destination      = local.api_subnet_cidr
    destination_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  egress_security_rules {
    description      = "Kubernetes worker to control plane communication"
    stateless        = false
    destination      = local.api_subnet_cidr
    destination_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"

    tcp_options {
      min = 12250
      max = 12250
    }
  }

  egress_security_rules {
    description      = "Path discovery"
    stateless        = false
    destination      = local.api_subnet_cidr
    destination_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1
    protocol = "1"

    # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    description      = "Allow nodes to communicate with OKE to ensure correct start-up and continued functioning"
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
    description      = "ICMP Access from Kubernetes Control Plane"
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1
    protocol = "1"

    # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    description      = "Worker Nodes access to Internet"
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  ingress_security_rules {
    description = "Allow pods on one worker node to communicate with pods on other worker nodes"
    stateless   = false
    source      = local.private_subnet_cidr
    source_type = "CIDR_BLOCK"
    protocol    = "all"
  }

  ingress_security_rules {
    description = "Path discovery"
    stateless   = false
    source      = local.api_subnet_cidr
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1
    protocol = "1"

    # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    description = "TCP access from Kubernetes Control Plane"
    stateless   = false
    source      = local.api_subnet_cidr
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"
  }

  ingress_security_rules {
    description = "Inbound SSH traffic to worker nodes"
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"

    tcp_options {
      min = 22
      max = 22
    }
  }
}

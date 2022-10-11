MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash

# userdata for EKS worker nodes to properly configure Kubernetes applications on EC2 instances
# https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
# https://aws.amazon.com/blogs/opensource/improvements-eks-worker-node-provisioning/
# https://github.com/awslabs/amazon-eks-ami/blob/master/files/bootstrap.sh

set -ex

/etc/eks/bootstrap.sh \
    --kubelet-extra-args '--max-pods=110 --node-labels=eks.amazonaws.com/nodegroup-image=${ami_id},eks.amazonaws.com/capacityType=${capacity_type},eks.amazonaws.com/nodegroup=${node_group_name}' \
    --b64-cluster-ca '${certificate_authority_data}' \
    --apiserver-endpoint '${cluster_endpoint}' \
    ${bootstrap_extra_args} \
    '${cluster_name}'

--//--
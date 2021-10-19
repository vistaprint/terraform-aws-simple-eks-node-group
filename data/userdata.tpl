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
    --kubelet-extra-args '--node-labels=eks.amazonaws.com/nodegroup-image=${ami_id},eks.amazonaws.com/capacityType=${capacity_type},eks.amazonaws.com/nodegroup=${node_group_name}' \
    --b64-cluster-ca '${certificate_authority_data}' \
    --apiserver-endpoint '${cluster_endpoint}' \
    ${bootstrap_extra_args} \
    '${cluster_name}'

if ${disable_source_dest_checks}
then
    # Disable source/dest checks
    # (see https://docs.projectcalico.org/reference/public-cloud/aws#routing-traffic-within-a-single-vpc-subnet)

    export TOKEN=$(
        curl -s -X PUT -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" \
        "http://169.254.169.254/latest/api/token"
    )
    export INSTANCE_ID=$(
        curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
        http://169.254.169.254/latest/meta-data/instance-id
    )
    export REGION=$(
        curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
        http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}'
    )

    aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --no-source-dest-check --region $REGION
fi

--//--
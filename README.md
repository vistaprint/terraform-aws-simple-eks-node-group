# Simple EKS Node Group Module

## Selecting an Instance Type for EKS Clusters

Several factors need to be considered when choosing an instance type for an EKS cluster:

- Number of vCPUs
- Amount of memory
- Networking capacity
- Cost

Another important criteria is the maximum number of pods the cluster can concurrently run. In a cluster using [native VPC networking](https://docs.aws.amazon.com/eks/latest/userguide/pod-networking.html) the maximum number of pods is limited by the [number of network interfaces in an instance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html#AvailableIpPerENI). [Here](https://github.com/awslabs/amazon-eks-ami/blob/master/files/eni-max-pods.txt) you can find a list of pod count limits per instance type.

This module supports enabling [high pod density](https://aws.amazon.com/blogs/containers/amazon-vpc-cni-increases-pods-per-node-limits/) to overcome this limitation. See variable `enable_high_pod_density`.

## Development

### Testing

We use [Terratest](https://github.com/gruntwork-io/terratest) to run integration tests.

Before running the tests the following environment variables must be set:

- AWS_PROFILE: the AWS profile to use for the test
- AWS_DEFAULT_REGION: region where the test cluster will be created
- SIMPLE_EKS_TEST_VPC_NAME: VPC to be used by the test cluster

Then, go into `test` folder and run:

```shell
go test -v -timeout 30m
```

## References

- [Launch templates](https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html)
- [Launch templates and custom AMI support](https://aws.amazon.com/blogs/containers/introducing-launch-template-and-custom-ami-support-in-amazon-eks-managed-node-groups/)

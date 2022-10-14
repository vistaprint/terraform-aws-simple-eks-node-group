package test

import (
	"context"
	"log"
	"os"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/eks"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestTerraformBasicExample(t *testing.T) {
	t.Parallel()

	awsProfile := os.Getenv("AWS_PROFILE")
	require.NotEmpty(t, awsProfile)

	awsRegion := os.Getenv("AWS_DEFAULT_REGION")
	require.NotEmpty(t, awsRegion)

	vpcName := os.Getenv("SIMPLE_EKS_TEST_VPC_NAME")
	require.NotEmpty(t, vpcName)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/basic",
		Vars: map[string]interface{}{
			"aws_profile": awsProfile,
			"aws_region":  awsRegion,
			"vpc_name":    vpcName,
		},
		NoColor: true,
		Upgrade: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	checkNodeGroupExists(t, "basic")
	checkNodeGroupExists(t, "calico")
	checkNodeGroupExists(t, "encrypt-ebs")
}

func checkNodeGroupExists(t *testing.T, nodeGroupName string) {
	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion("eu-west-1"))
	if err != nil {
		log.Fatal(err)
	}

	client := eks.NewFromConfig(cfg)

	output, err := client.ListNodegroups(
		context.TODO(),
		&eks.ListNodegroupsInput{
			ClusterName: aws.String("simple-eks-integration-test-for-eks-node-group"),
		},
	)

	if err != nil {
		log.Fatal(err)
	}

	assert.GreaterOrEqual(t, len(output.Nodegroups), 1)
	assert.Contains(t, output.Nodegroups, nodeGroupName)
}

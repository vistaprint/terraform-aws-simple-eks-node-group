package test

import (
	"os"
	"testing"

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
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	assert.Equal(t,
		"simple-eks-integration-test-for-eks-node-group:spot",
		terraform.Output(t, terraformOptions, "node_group_id"),
	)

	assert.Regexp(t,
		`^eks-[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$`,
		terraform.Output(t, terraformOptions, "node_group_autoscaling_group_name"),
	)
}

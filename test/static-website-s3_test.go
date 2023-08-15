package test

import (
	"fmt"
	"io"
	"net/http"
	"strings"
	"testing"

	terraform "github.com/gruntwork-io/terratest/modules/terraform"
)

func TestStaticWebsite(t *testing.T) {

	terraformOptions := &terraform.Options{
		// You should update this relative path to your test deployment
		TerraformDir: "../test_deployment/static-website",
		Vars: map[string]interface{}{
			"region":              "us-east-1",
			"static-website-name": fmt.Sprintf("test-static-website-01"),
		},
	}

	// Clean up everything at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Deploy the resources
	terraform.InitAndApply(t, terraformOptions)

	// Get the URL of the static website
	url := terraform.OutputRequired(t, terraformOptions, "staic-website-url")

	// Make an HTTP request to the resource
	urlResponse, err := http.Get(url)
	if err != nil {
		t.Fatalf("Failed to make HTTP request: %v", err)
	}
	defer urlResponse.Body.Close()

	// Read the response body
	var bodyBuilder strings.Builder
	_, err = io.Copy(&bodyBuilder, urlResponse.Body)
	if err != nil {
		t.Fatalf("Failed to read response body: %v", err)
	}
	body := bodyBuilder.String()

	// Define the expected string in the response body
	expectedString := "Code: NoSuchKey"

	// Check if the expected string exists in the response body
	if !strings.Contains(body, expectedString) {
		t.Errorf("Expected string '%s' not found in response body", expectedString)
	}

	// Print the response body (for debugging purposes)
	fmt.Println("Response Body:", body)
}

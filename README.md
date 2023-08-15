
# AWS S3 Static Website Setup [Terraform + Terragrunt + Terratest]

This example entails the establishment of an Amazon Web Services (AWS) Simple Storage Service (S3) static website through the integrated utilization of Terraform and Terragrunt. Additionally, it includes the integration of Terratest for the execution of pre-deployment testing procedures.

### Prerequistes
- [AWS Access Key ID and Secret Access key](https://docs.aws.amazon.com/powershell/latest/userguide/pstools-appendix-sign-up.html)
- [Terraform Installation](https://developer.hashicorp.com/terraform/downloads)
- [Terragrunt Installation](https://terragrunt.gruntwork.io/docs/getting-started/install)
- [Go programming Langugage Installation](https://go.dev/doc/install)

### What is Terragrunt and why we use.
Terragrunt is a powerful tool that acts as a wrapper around Terraform and provides additional features and benefits to streamline and enhance your infrastructure provisioning workflow. Here are some benefits of using Terragrunt alongside Terraform:
1. **DRY (Don't Repeat Yourself) Configurations**:
Terragrunt promotes the DRY principle by allowing you to define common configurations, such as backend configurations, remote state settings, and variables, in a single place and then reuse them across multiple Terraform modules and configurations. This reduces duplication and maintenance effort.

2. **Simplified Remote State Management**:
Terragrunt helps manage remote state more effectively by centralizing the configuration in a "terragrunt.hcl" file. This avoids duplicating remote state settings across different Terraform configurations, ensuring consistency and reducing the risk of misconfiguration.
### Directory Structure

#### Folder [live]
Benefits of using separate environments folder
1. **Isolation and Security**:
- By keeping environments separate, you minimize the risk of changes made in one environment affecting another. This helps prevent accidental misconfigurations in production due to changes made in a staging environment.
- Security-sensitive configurations and secrets specific to each environment can be managed more effectively when environments are isolated.
2. **Reduced Human Errors**:
- Clear separation reduces the chances of mistakes that can occur when managing similar but distinct resources in different environments.
- It helps avoid accidentally applying or modifying production infrastructure when working on staging or development setups.
#### Folder [modules]
Benefits of using separate verioning modules
 1. **Modularity**: Breaking down your infrastructure provisioning into smaller, focused modules allows for better organization and easier maintenance. Each module can represent a specific component or resource in your infrastructure.

2. **Reusability**: By creating modules that encapsulate specific functionality or resources, you can reuse them across multiple projects or environments. This reduces duplication of code and effort, promoting consistency.

3. **Collaboration**: Teams can work more efficiently by focusing on developing and maintaining specific modules. This promotes collaboration as different teams can contribute to different modules concurrently.

4. **Testing**: Smaller modules are easier to test and validate independently, reducing the risk of errors or bugs in your infrastructure.

5. **Versioning**: Versioning your Terraform modules is crucial for maintaining a stable and predictable infrastructure. When you use versioned modules, you ensure that changes to one module don't inadvertently break other parts of your infrastructure.
#### Folder [test_deployment] 
- Terraform deployment for testing
#### Folder [test] 
- To test that deployment meets that we expected.

### Why should we engage in testing prior to deployment?
- **Avoid errors and failures** in our infrastructure deployments. A small mistake or typo can cause unexpected consequences in many places. Testing can catch these errors before they cause damage.
- **Ensure compliance and security** of our infrastructure resources. Testing can check that our Terraform configuration meets the desired policies, standards, and best practices.
- **Verify functionality and reliability** of our infrastructure code. Testing can validate that our Terraform code does what we expect it to do, and that it can handle different scenarios and environments.

### How can we conduct testing for the deployment of this S3 static website using Terraform?
Upon deploying the static S3 website, it will be observed that upon accessing the URL, a default "400 Not Found, Code: NoSuchKey" response will be encountered. This response arises due to the absence of the required web pages such as "index.html" not being updated in S3.
________________________________________
<img title="Expected S3 Static Website reponse" alt="Alt text" src="/s3-static-website-expected-response.png">
________________________________________
- If we see this expected response, it indicates the successful deployment of our S3 resource.
- Let us now examine the go program provided below for testing purposes.
    ````go
    func TestStaticWebsite(t *testing.T) {

	terraformOptions := &terraform.Options{
		// You should update this relative path to your test deployment
		TerraformDir: "../test_deployment/static-website/v1.0.0",
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
    ````

- This test will carry out a sequence of actions: firstly, it will execute the commands "terraform init," "terraform plan," and "terraform apply" in that specific order. 
- Once these actions are completed, the testing program will obtain a static website URL. Following this, the test will access the obtained URL and examine whether our expected string "Code: NoSuchKey" is present within the response body of the HTTP request made to the static website URL.
- If the specific string we expected to find in the URL response is present, the test will be considered successful. However, if this string is not found, the test will be marked as failed.
- At the end of the test, the resource created for testing will be automatically deleted.
### Test Run Steps
Under test folder, 
- Run command: **go mod init <your test name>** 
- Run command: **go mod tidy**
- Run command: **go test -v static-website-s3_test.go**
### Deployment Steps
1. Set AWS credentials to deploymet in AWS.
   ```bash
   export AWS_ACCESS_KEY_ID=(your aws access key id)
   export AWS_SECRET_ACCESS_KEY=(your aws secret access key)
   ```
2. Go to the folder live > stage and change your aws region, s3 bucket name to store state file and dynamodb table for terraform locking in terragrunt.hcl file. If you have not created S3 Bucket and dynamodb table, terragrunt will automatically create for you.
   ```terragrunt
   ---
    provider "aws" {
        region = "<your aws region>"
    }
    ---
    config = {
        bucket         = "<your aws s3 bucket name>"
        key            = "${path_relative_to_include()}/terraform.tfstate"
        region         = "<your aws region>"
        encrypt        = true
        dynamodb_table = "<your aws dynamodb table name>"
    }
    ---
   ```
3. Then go to folder live > stage > static-website and change your aws region and static website name in terragrunt.hcl file
    ```terragrunt
    terraform {
        source = "../../../modules//s3-static-website/v1.0.0"
    }
    ---
    inputs = {
        region = "<your aws region>"
        static-website-name = "<your static website name>"
    }
    ```
    
4. Run terragrunt plan and apply under live > stage > static website.
    ````terragrunt
    terragrunt plan
    terragrunt apply
    ````
5. After deployment, you will see your static website url.
    ````bash
    ----
    Apply complete! Resources: 6 added, 0 changed, 0 destroyed.
    
    Outputs:

    staic-website-url = "<your-static-website-url>"
    ````

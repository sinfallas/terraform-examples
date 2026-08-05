# Terraform Examples

Welcome to the **Terraform Examples** repository! This repository serves as a collection of Infrastructure as Code (IaC) templates, modules, and best practices using [HashiCorp Terraform](https://www.terraform.io/). It is designed to help developers and DevOps engineers quickly deploy and manage cloud infrastructure.

## 📖 Table of Contents
- [About The Project](#about-the-project)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Best Practices](#best-practices)
- [Contributing](#contributing)
- [License](#license)

## 🚀 About The Project
This repository contains a variety of Terraform configurations ranging from basic setups to more advanced architectures. Whether you are looking to provision a simple virtual machine, set up a managed Kubernetes cluster, or design a highly available multi-tier network, you'll find reference code here.

**Goals:**
* Provide ready-to-use infrastructure templates.
* Demonstrate Terraform best practices (state management, modules, variables).
* Serve as a learning resource for infrastructure automation.

## 🏁 Getting Started
1. **Clone the repository:**
   ```bash
   git clone [https://github.com/sinfallas/terraform-examples.git](https://github.com/sinfallas/terraform-examples.git)
   cd terraform-examples
   ```

2. **Navigate to your desired example:**
   ```bash
   cd aws/ec2-instance
   ```

3. **Configure Variables:**
   Most examples include a `variables.tf` file. Create a `terraform.tfvars` file to pass your specific values (e.g., region, instance types):
   ```hcl
   aws_region = "us-east-1"
   instance_type = "t3.micro"
   ```

## 💻 Usage
Standard Terraform workflow applies to all examples:

1. **Initialize the working directory** (downloads providers and modules):
   ```bash
   terraform init
   ```
2. **Review the execution plan** (shows what will be created/modified):
   ```bash
   terraform plan
   ```
3. **Apply the configuration** (provisions the infrastructure):
   ```bash
   terraform apply
   ```
   *(Type `yes` when prompted to confirm)*
4. **Destroy the infrastructure** (cleans up resources to avoid unexpected charges):
   ```bash
   terraform destroy
   ```

## 🌟 Best Practices
When using or adapting these examples for production, please consider the following:
* **Remote State:** Always configure a remote backend (like AWS S3 + DynamoDB, Azure Storage, or Terraform Cloud) to store your `.tfstate` files securely.
* **Least Privilege:** Ensure the credentials used to run Terraform only have the permissions necessary to create the required resources.
* **Version Pinning:** Pin your Terraform provider versions to avoid breaking changes in future updates.

## 🤝 Contributing
Contributions, issues, and feature requests are welcome!
1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License
Distributed under the MIT License. See `LICENSE` for more information.

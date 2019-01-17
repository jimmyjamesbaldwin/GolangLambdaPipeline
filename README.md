# Golang AWS Lambda Jenkins CI/CD Pipeline
A simple golang HelloWorld app with an accompanying Jenkins pipeline to build, test and deploy to AWS Lambda automatically on pull requests/branching, as well as Terraform templates to setup infrastructure.

<img src="https://wiki.jenkins.io/download/attachments/2916393/logo.png" width="100"><img src="https://camo.githubusercontent.com/a6074cc3e448110a02c3947a69f41a5acfd8d217/68747470733a2f2f7777772e7465727261666f726d2e696f2f6173736574732f696d616765732f6f672d696d6167652d66356262633938632e706e67" width="125"><img src="https://i.imgur.com/YurNxnI.png" width="125"><img src="https://cdn-images-1.medium.com/max/1200/1*ERojGMB35dNDZJtgdC-iFw.png" width="250">

## Setup
Before we begin, you will need:
* An AWS account
* A Jenkins server. 
    * This guide can help set one up: https://d1.awsstatic.com/Projects/P5505030/aws-project_Jenkins-build-server.pdf. Remember to set security groups accordingly so you can access the machine; also setup a reasonable password and install any patches.
    * (you can also spin up a docker container with: `docker run -d -p 8080:8080 -p 50000:50000 jenkins/jenkins`, if you prefer)

### Configure Jenkins
* You'll need to install the golang plugin so you have all the necessary build tools for go
    * Manage Jenkins > Manage Plugins > Available > Go
* You'll need AWS keys, I set mine as environment variables
    * Manage Jenkins > Configure System > Global Properties > Environment Variables > add _AWS_ACCESS_KEY_ID/AWS_DEFAULT_REGION/AWS_SECRET_ACCESS_KEY_
* The pipeline is set to run on Jenkins slave, but if you're lazy like me and don't want to setup Jenkins slaves, on your master head to Jenkins > Configure System > Labels > add 'slaves'

### Create Jenkins project
Now we've configured Jenkins, we can setup our project and point to our repo.

* Jenkins > New Item > Multibranch Pipeline
    * Branch Sources > GitHub
        * Credentials > Add > Username/PAT token
        * Owner > jimmyjamesbaldwin
        * Repository > lambda_test
        * Behaviours
            * Discover branches
                * Strategy: _Exclude branches that are also filed as PRs_
    * Build Configuration
        * Mode: by Jenkinsfile
            * Script Path > Jenkinsfile

### Add GitHub webhooks
To make Jenkins build automatically when code is pushed to the repo, head to GitHub > Settings > Webhooks > Payload Url: _http://jenkins_user:password@<dns_alias_of_jenkins_ec2_host>_ (in the real world don't authenticate like this...). 

Afterwards you'll see any development branches appear and attempt to build:
![dev branch in jenkins](https://i.imgur.com/qOHqcJO.png)

### Build the go binaries locally (one time only)
Terraform needs some source to create the Lambda function, so run these commands to build the Go app:
```
git clone <repo>
cd repo/src
GOOS=linux go build -o main main.go
zip lambda.zip main && mv lambda.zip ../terraform/
```

### Set your S3 bucket name
Under repo/vars.tf, set your preferred s3 bucket name, and put the same at the top of your Jenkinsfile:

_vars.tf_
```
variable "bucket" {
  default = "my_awesome_bucket"
}
```
_Jenkinsfile_
```
def bucket = 'my_awesome_bucket'
```


### Run the Terraform templates
Under terraform/vars.tf, set your preferred s3 bucket name and put the same at the top of your Jenkinsfile.

_A note on the terraform templates: I'm using a access/secret key attached to an IAM user that has the AdministratorAccess policy attached to it. Not great for security but useful for testing. Ideally IAM should roles should be configured properly but this is just a POC._
```
# download terraform binary...
cd repo/terraform
./terraform init
./terraform apply
```

### Raise a PR
When merging PR's, you should see a build kick off and update the lambda function:
![jenkins pipeline](https://i.imgur.com/yZxNA9O.png)

If merging to master, you can see the _production_ version alias on the lambda gets updated:
![updated lambda alias](https://i.imgur.com/dyyiU4m.png)

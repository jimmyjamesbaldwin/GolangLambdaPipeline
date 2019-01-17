def bucket = 'lambda-grave-shirley'
def functionName = 'HelloWorld'
def region = 'us-east-1'

node('slaves'){
    stage('Checkout'){
        checkout scm
    }

    stage('Test'){
        sh 'go fmt src/*'
        sh 'go vet src/*'        
        sh 'go test src/*'
    }

    stage('Build'){
        sh 'GOOS=linux go build -o main src/main.go'
        sh "zip ${commitID()}.zip main"
    }

    stage('Push'){
        sh "aws s3 cp ${commitID()}.zip s3://${bucket}"
    }

    stage('Deploy'){
        sh "aws lambda update-function-code --function-name ${functionName} \
                --s3-bucket ${bucket} \
                --s3-key ${commitID()}.zip \
                --region ${region}"
    }

    if (env.BRANCH_NAME == 'master') {
        stage('Publish') {
            def lambdaResponse = sh(
                script: "aws lambda publish-version --function-name ${functionName} --region ${region}",
                returnStdout: true
            )
            def lambdaJSON = readJSON text: lambdaResponse
            def lambdaVersion = lambdaJSON.Version
            sh "aws lambda update-alias --function-name ${functionName} --name production --region ${region} --function-version ${lambdaVersion}"
        }
    }
}

def commitID() {
    sh 'git rev-parse HEAD > .git/commitID'
    def commitID = readFile('.git/commitID').trim()
    sh 'rm .git/commitID'
    commitID
}
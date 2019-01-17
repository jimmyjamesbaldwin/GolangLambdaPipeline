package main

import (
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
)

func helloworld() string {
	return ("hello world")
}

func mynewfeature() string {
	return ("new feature!!!")
}


func handler() {
	fmt.Println(helloworld())
}

func main() {
	lambda.Start(handler)
}

package main

import (
	"github.com/stretchr/testify/assert"
	"testing"
)

func TestHelloWorld(t *testing.T) {
	assert.Equal(t, "hello world", helloworld())
}

// a broken test to check we break the build with fails
/*func TestFail(t *testing.T) {
	assert.Equal(t, "not hello world", helloworld())
}*/

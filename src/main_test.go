package main

import (
	"github.com/stretchr/testify/assert"
	"testing"
)

func TestHelloWorld(t *testing.T) {
	assert.Equal(t, "hello world", helloworld())
}

func TestFail(t *testing.T) {
	assert.Equal(t, "new feature!!!", mynewfeature())
}

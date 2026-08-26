package helper

import "log"

func Logger(cause string, path string, err error) {
	log.Printf("Error [%s] [%s]: %v\n", cause, path, err.Error())
}

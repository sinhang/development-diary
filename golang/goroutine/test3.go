package main

import (
	"fmt"
	"io"
	"net/http"
)

func main() {
	h := &http.Client{}
	for j := 0; j < 1; j++ {
		for i := 1; i <= 1030; i++ {
			resp, err := h.Get(fmt.Sprintf("http://localhost:8080/track?id=%d", i))
			if err != nil {
				fmt.Println(j, i, err)
			}
			defer resp.Body.Close()
			ret, err := io.ReadAll(resp.Body)
			if err != nil {
				fmt.Println("read", j, i, err)
			}
			fmt.Println(j, i, resp.StatusCode, string(ret))
		}
	}
}

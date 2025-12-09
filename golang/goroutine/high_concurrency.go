package main

import (
	"fmt"
	"log"
	"net/http"
	"time"
)

// 全局统计缓存
var stats = make(map[string]int)

func main() {
	http.HandleFunc("/track", func(w http.ResponseWriter, r *http.Request) {
		deviceID := r.URL.Query().Get("id")
		fmt.Println(deviceID)
		// 模拟异步处理埋点逻辑
		go func() {
			// [隐患点?]
			stats[deviceID]++

			// 模拟耗时较长的分析操作
			// [隐患点?] 这里的 Context 使用是否正确？
			ctx := r.Context()
			select {
			case <-time.After(2 * time.Second):
				fmt.Printf("Device %s processed. Total: %d\n", deviceID, stats[deviceID])
			case <-ctx.Done():
				// 假设主要为了处理客户端断开连接的逻辑
				fmt.Println("Client disconnected")
			}
		}()

		w.Write([]byte("Tracking started"))
	})

	fmt.Println("started serve")
	// [隐患点?]
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal(err)
	}
}

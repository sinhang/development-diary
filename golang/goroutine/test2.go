package main

import (
	"fmt"
	"time"
)

// 有缓冲chan
func main() {
	ch := make(chan string, 1)

	go func() {
		who := "外卖小哥我."
		fmt.Println(who, "送餐中...2s")
		time.Sleep(time.Second * 2)
		fmt.Println("已经送餐到门口，外卖挂载门把上面了(缓冲区)")
		food := "小炒肉"
		ch <- food
		fmt.Println("订单已经送达，开始送其他订单")
	}()

	// go func() {
	// 	who := "11111111外卖小哥我."
	// 	fmt.Println(who, "11111111送餐中...2s")
	// 	time.Sleep(time.Second * 2)
	// 	fmt.Println("11111111已经送到门口，等待买家取餐")
	// 	food := "11111111烤牛排"
	// 	ch <- food
	// 	fmt.Println("11111111订单已经送达，开始送其他订单")
	// }()

	go func() {
		who := "张三"
		fmt.Println(who, "等待外卖...3s")
		time.Sleep(time.Second * 3)
		fmt.Println("已经送到门口，等待买家取餐")
		food := <-ch
		fmt.Println("已经取到", food)
	}()

	time.Sleep(time.Second * 10)
}

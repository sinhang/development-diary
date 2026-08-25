package test

import (
	"context"

	"github.com/cloudwego/eino/compose"
)

func BuildslideGenerate(ctx context.Context) (r compose.Runnable[any, any], err error) {
	const (
		ChatModel1 = "ChatModel1"
		Lambda1    = "Lambda1"
		ChatModel2 = "ChatModel2"
		Lambda2    = "Lambda2"
	)
	g := compose.NewGraph[any, any](compose.WithGenLocalState(func(ctx context.Context) (state any) {
		panic("implement me")
	}))
	chatModel1KeyOfChatModel, err := newChatModel(ctx)
	if err != nil {
		return nil, err
	}
	_ = g.AddChatModelNode(ChatModel1, chatModel1KeyOfChatModel)
	_ = g.AddLambdaNode(Lambda1, compose.InvokableLambda(newLambda))
	chatModel2KeyOfChatModel, err := newChatModel1(ctx)
	if err != nil {
		return nil, err
	}
	_ = g.AddChatModelNode(ChatModel2, chatModel2KeyOfChatModel)
	_ = g.AddLambdaNode(Lambda2, compose.InvokableLambda(newLambda1))
	_ = g.AddEdge(compose.START, ChatModel1)
	_ = g.AddEdge(Lambda2, compose.END)
	_ = g.AddEdge(ChatModel1, Lambda1)
	_ = g.AddEdge(Lambda1, ChatModel2)
	_ = g.AddEdge(ChatModel2, Lambda2)
	r, err = g.Compile(ctx, compose.WithGraphName("slideGenerate"), compose.WithNodeTriggerMode(compose.AnyPredecessor))
	if err != nil {
		return nil, err
	}
	return r, err
}

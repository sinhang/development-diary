package test

import (
	"context"

	"github.com/cloudwego/eino-ext/components/model/qwen"
	"github.com/cloudwego/eino/components/model"
)

// newChatModel component initialization function of node 'ChatModel1' in graph 'slideGenerate'
func newChatModel(ctx context.Context) (cm model.ChatModel, err error) {
	// TODO Modify component configuration here.
	config := &qwen.ChatModelConfig{}
	cm, err = qwen.NewChatModel(ctx, config)
	if err != nil {
		return nil, err
	}
	return cm, nil
}

// newChatModel1 component initialization function of node 'ChatModel2' in graph 'slideGenerate'
func newChatModel1(ctx context.Context) (cm model.ChatModel, err error) {
	// TODO Modify component configuration here.
	config := &qwen.ChatModelConfig{}
	cm, err = qwen.NewChatModel(ctx, config)
	if err != nil {
		return nil, err
	}
	return cm, nil
}

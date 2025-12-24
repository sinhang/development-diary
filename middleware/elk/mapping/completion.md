### 创建索引
```bash
PUT completion_v1
{
  "settings": {
    "index": {
      "number_of_shards": "3",
      "number_of_replicas": "1"
    },
    "analysis": {
      "analyzer": {
        "by_smart": {
          "type": "custom",
          "tokenizer": "ik_smart"
        },
        "by_words": {
          "type": "custom",
          "tokenizer": "ik_max_word"
        },
        "pinyin_analyzer" : {
          "tokenizer" : "pinyin"
        }
      },
      "tokenizer" : {
        "pinyin" : {
          "type" : "pinyin",
          "keep_separate_first_letter" : true,
          "keep_full_pinyin" : true,
          "keep_original" : true,
          "limit_first_letter_length" : 16,
          "lowercase" : true,
          "remove_duplicated_term" : true
        }
      },
      "filter": {
        "by_tfr": {
          "type": "stop",
          "stopwords": [" "]
        }
      },
      "char_filter": {
        "by_cfr": {
          "type": "mapping",
          "mappings": ["| => |"]
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "keyword":{
        "type": "text",
        "fields": {
          "pinyin" : {
              "type" : "completion",
              "analyzer" : "pinyin_analyzer",
              "search_analyzer" : "pinyin_analyzer"
          },
          "hans" : {
              "type" : "completion",
              "analyzer" : "by_words",
              "search_analyzer" : "ik_smart"
          }
        }
      },
      "is_goods": {
        "type": "integer",
        "index": true
      },
      "is_video": {
        "type": "integer",
        "index": true
      },
      "is_category": {
        "type": "integer",
        "index": true
      },
      "is_talk": {
        "type": "integer",
        "index": true
      },
      "is_brand": {
        "type": "integer",
        "index": true
      },
      "is_user": {
        "type": "integer",
        "index": true
      },
      "is_company": {
        "type": "integer",
        "index": true
      },
      "is_shop": {
        "type": "integer",
        "index": true
      },
      "is_maker": {
        "type": "integer",
        "index": true
      },
      "is_delete": {
        "type": "integer",
        "index": true
      },
      "is_video_category": {
        "type": "integer",
        "index": true
      },
      "is_designer": {
        "type": "integer",
        "index": true
      },
      "is_dict": {
        "type": "integer",
        "index": true
      }
    }
  }
}
```

### 设置别名
```bash
PUT /completion_v1/_alias/a_completion
{
  "acknowledged" : true
}
```
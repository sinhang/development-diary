### 创建索引
```bash
PUT post_index_v1
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
                    "tokenizer": "ik_smart",
                    "filter": ["remote_synonym", "local_stop"]
                },
                "by_words": {
                    "type": "custom",
                    "tokenizer": "ik_max_word",
                    "filter": ["remote_synonym", "local_stop"]
                },
                "pinyin_analyzer" : {
                    "tokenizer" : "pinyin"
                },
                "ngram_tokenizer" : {
                    "tokenizer" : "ngram_tokenizer"
                }
            },
            "tokenizer": {    
                "pinyin": {    
                    "type" : "pinyin",
                    "keep_separate_first_letter" : true,
                    "keep_full_pinyin" : true,
                    "keep_original" : true,
                    "limit_first_letter_length" : 16,
                    "lowercase" : true,
                    "remove_duplicated_term" : true
                },
                "ngram_tokenizer": {
                  "type": "ngram",
                  "min_gram": 1,
                  "max_gram": 2,
                  "token_chars": ["letter", "digit", "whitespace"]
                }
            },
            "filter": {    
                "local_stop": {    
                    "type": "stop",
                    "stopwords": [" "]
                },
                "remote_synonym" : {
                    "type" : "dynamic_synonym",
                    "synonyms_path" : "http://192.168.1.100:9080/api/keyword/synonym?type=post&key=gwey5yqrgerg245724234sdfqw4rklsj9212",
                    "interval": 3600
                }
            },
            "char_filter": {
                "&2and": {
                    "type": "mapping",
                    "mappings": ["& => and"]
                }
            }
        }
    },
    "mappings": {
        "properties": {
            "id": {
                "type": "integer",
                "index": true
            },
            "created_at": {
                "type": "date",
                "index": true,
                "format": "yyyy-MM-dd HH:mm:ss||date_optional_time"
            },
            "updated_at": {
                "type": "date",
                "index": true,
                "format": "yyyy-MM-dd HH:mm:ss||date_optional_time"
            },
            "deleted_at": {
                "type": "date",
                "index": true,
                "format": "yyyy-MM-dd HH:mm:ss||date_optional_time"
            },
            "state": {
                "type": "integer",
                "index": true
            },
            "type": {
                "type": "integer",
                "index": true
            },
            "user_id": {
                "type": "integer",
                "index": true
            },
            "category_id": {
                "type": "integer",
                "index": true
            },
            "category_idx": {
                "type": "keyword"
            },
            "category_text": {
                "type" : "keyword",
                "fields" : {
                    "pinyin" : {
                        "type" : "text",
                        "store": false,
                        "term_vector": "with_offsets",
                        "analyzer" : "pinyin_analyzer"
                    }
                }
            },
            "subject": {
                "type" : "text",
                "analyzer" : "by_words",
                "search_analyzer" : "ik_smart",
                "fields" : {
                    "pinyin" : {
                        "type" : "text",
                        "store": false,
                        "term_vector": "with_offsets",
                        "analyzer" : "pinyin_analyzer"
                    },
                    "ngram" : {
                        "type" : "text",
                        "analyzer" : "ngram_tokenizer"
                    }
                }
            },
            "content_before": {
                "type" : "keyword"
            },
            "content": {
                "type" : "keyword"
            },
            "poster": {
                "type": "keyword"
            },
            "data": {
                "type": "keyword"
            },
            "is_album": {
                "type": "integer",
                "index": true
            },
            "is_open": {
                "type": "integer",
                "index": true
            },
            "is_hot": {
                "type": "integer",
                "index": true
            },
            "is_home": {
                "type": "integer",
                "index": true
            },
            "is_search": {
                "type": "integer",
                "index": true
            },
            "can_creation": {
                "type": "integer",
                "index": true
            },
            "is_top": {
                "type": "integer",
                "index": true
            },
            "love": {
                "type": "integer",
                "index": true
            },
            "hit": {
                "type": "integer",
                "index": true
            },
            "fav": {
                "type": "integer",
                "index": true
            },
            "comment": {
                "type": "integer",
                "index": true
            },
            "goods_id": {
                "type": "integer",
                "index": true
            },
            "clothes_id": {
                "type": "integer",
                "index": true
            },
            "video_id": {
                "type": "integer",
                "index": true
            },
            "sale_num": {
                "type": "integer",
                "index": true
            },
            "queue_type": {
                "type": "integer",
                "index": true
            },
            "special_type": {
                "type": "integer",
                "index": true
            },
            "extend": {
                "type": "keyword"
            },
            "pr": {
                "type": "float",
                "index": true
            },
            "same_num": {
                "type": "integer",
                "index": true
            },
            "bg_music": {
                "type": "keyword"
            },
            "tags": {
                "type": "keyword"
            },
            "talk": {
                "type": "keyword"
            },
            "dict": {
                "type": "keyword"
            },
            "filter_gender": {
                "type": "keyword"
            },
            "filter_style": {
                "type": "keyword"
            },
            "filter_color": {
                "type": "keyword"
            },
            "filter_season": {
                "type": "keyword"
            },
            "filter_material": {
                "type": "keyword"
            },
            "filter_pattern": {
                "type": "keyword"
            },
            "filter_collar": {
                "type": "keyword"
            },
            "filter_sleeve": {
                "type": "keyword"
            },
            "filter_fit": {
                "type": "keyword"
            },
            "filter_thickness": {
                "type": "keyword"
            },
            "filter_length": {
                "type": "keyword"
            },
            "filter_occasion": {
                "type": "keyword"
            },
            "filter_function": {
                "type": "keyword"
            },
            "filter_brand": {
                "type": "keyword"
            },
            "filter_region": {
                "type": "keyword"
            },
            "filter_category": {
                "type": "keyword"
            }
        }
    }
}
```

### 设置别名
```bash
PUT /post_index_v1/_alias/a_post
{
  "acknowledged" : true
}
```
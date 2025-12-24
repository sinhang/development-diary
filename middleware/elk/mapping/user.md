### 创建索引
```bash
PUT designer_index_v1
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
                    "synonyms_path" : "http://192.168.1.100:9080/api/keyword/synonym?type=user&key=gwey5yqrgerg245724234sdfqw4rklsj9212",
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
            "birthday": {
                "type": "date",
                "index": true,
                "format": "yyyy-MM-dd||date_optional_time"
            },
            "state": {
                "type": "integer",
                "index": true
            },
            "level_id": {
                "type": "integer",
                "index": true
            },
            "user_id": {
                "type": "integer",
                "index": true
            },
            "cats_id": {
                "type": "keyword"
            },
            "name": {
                "type" : "text",
                "analyzer" : "by_words",
                "search_analyzer" : "ik_smart",
                "fields" : {
                    "pinyin" : {
                        "type" : "text",
                        "store": false,
                        "term_vector": "with_offsets",
                        "analyzer" : "pinyin_analyzer"
                    }
                }
            },
            "nickname": {
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
            "work": {
                "type" : "keyword"
            },
            "street": {
                "type" : "keyword"
            },
            "desc": {
                "type" : "keyword"
            },
            "photo": {
                "type": "keyword"
            },
            "skill_cert": {
                "type": "keyword"
            },
            "cert": {
                "type": "keyword"
            },
            "school": {
                "type": "keyword"
            },
            "major": {
                "type": "keyword"
            },
            "age": {
                "type": "integer",
                "index": true
            },
            "sex": {
                "type": "integer",
                "index": true
            },
            "exp": {
                "type": "integer",
                "index": true
            },
            "exp_id": {
                "type": "integer",
                "index": true
            },
            "edu": {
                "type": "integer",
                "index": true
            },
            "rate_num": {
                "type": "integer",
                "index": true
            },
            "city_id": {
                "type": "integer",
                "index": true
            },
            "rate": {
                "type": "float",
                "index": true
            },
            "rate_sco": {
                "type": "float",
                "index": true
            },
            "pr": {
                "type": "float",
                "index": true
            },
            "audit_state": {
                "type": "integer",
                "index": true
            },
            "is_hot": {
                "type": "integer",
                "index": true
            },
            "is_new": {
                "type": "integer",
                "index": true
            }
        }
    }
}
```

### 设置别名
```bash
PUT /designer_index_v1/_alias/a_designer
{
  "acknowledged" : true
}
```
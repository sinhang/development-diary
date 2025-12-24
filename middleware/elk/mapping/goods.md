### 创建索引
```bash
PUT goods_index_v1
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
                    "synonyms_path" : "http://192.168.1.100:9080/api/keyword/synonym?type=goods&key=gwey5yqrgerg245724234sdfqw4rklsj9212",
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
            "order_type": {
                "type": "integer",
                "index": true
            },
            "user_id": {
                "type": "integer",
                "index": true
            },
            "shop_id": {
                "type": "integer",
                "index": true
            },
            "shop_name": {
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
            "goods_name": {
                "type": "text",
                "analyzer": "by_words",
                "search_analyzer": "ik_smart",
                "fields": {
                    "pinyin": {
                        "type" : "text",
                        "store": false,
                        "term_vector": "with_offsets",
                        "analyzer" : "pinyin_analyzer"
                    },
                    "ngram": {
                        "type": "text",
                        "analyzer": "ngram_tokenizer",
                        "search_analyzer": "standard"
                    }
                }
            },
            "goods_code": {
                "type": "keyword"
            },
            "desc": {
                "type" : "keyword"
            },
            "dict": {
                "type" : "keyword"
            },
            "category_text": {
                "type": "keyword",
                "fields" : {
                    "pinyin" : {
                        "type" : "text",
                        "store": false,
                        "term_vector": "with_offsets",
                        "analyzer" : "pinyin_analyzer"
                    }
                }
            },
            "category_idx": {
                "type": "keyword"
            },
            "image": {
                "type": "keyword"
            },
            "album": {
                "type": "keyword"
            },
            "clothes": {
                "type": "keyword"
            },
            "video": {
                "type": "keyword"
            },
            "video_poster": {
                "type": "keyword"
            },
            "images": {
                "type": "keyword"
            },
            "price": {
                "type": "float",
                "index": true
            },
            "price_max": {
                "type": "float",
                "index": true
            },
            "price_market": {
                "type": "float",
                "index": true
            },
            "price_cost": {
                "type": "float",
                "index": true
            },
            "pack_price": {
                "type": "float",
                "index": true
            },
            "express_price": {
                "type": "float",
                "index": true
            },
            "express_mode": {
                "type": "integer",
                "index": true
            },
            "express_tpl_id": {
                "type": "integer",
                "index": true
            },
            "params": {
                "type": "keyword",
                "index": true
            },
            "attrs": {
                "type": "keyword",
                "index": true
            },
            "content": {
                "type" : "keyword"
            },
            "inventory_num": {
                "type": "integer",
                "index": true
            },
            "inventory_remind": {
                "type": "integer",
                "index": true
            },
            "sale_num": {
                "type": "integer",
                "index": true
            },
            "sale_num_virtual": {
                "type": "integer",
                "index": true
            },
            "hit": {
                "type": "integer",
                "index": true
            },
            "hit_virtual": {
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
            },
            "rate_num": {
                "type": "integer",
                "index": true
            },
            "fav": {
                "type": "integer",
                "index": true
            },
            "rate": {
                "type": "float",
                "index": true
            },
            "pr": {
                "type": "float",
                "index": true
            },
            "tags": {
                "type": "keyword"
            }
        }
    }
}
```

### 设置别名
```basg
PUT /goods_index_v1/_alias/a_goods
{
  "acknowledged" : true
}
```
### analysis-pinyin

1. [github](https://github.com/infinilabs/analysis-pinyin)

### 查看版本号
```bash
curl -XGET 'http://elastic:changeme@192.168.1.100:9200/'
# 输出
{
  "name" : "elasticsearch",
  "cluster_name" : "docker-cluster",
  "cluster_uuid" : "HKTrf-nERpa_n99at70aOA",
  "version" : {
    "number" : "9.2.2",
    "build_flavor" : "default",
    "build_type" : "docker",
    "build_hash" : "ed771e6976fac1a085affabd45433234a4babeaf",
    "build_date" : "2025-11-27T08:06:51.614397514Z",
    "build_snapshot" : false,
    "lucene_version" : "10.3.2",
    "minimum_wire_compatibility_version" : "8.19.0",
    "minimum_index_compatibility_version" : "8.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

### install
```bash
sudo docker exec -it docker-elk-elasticsearch-1 /bin/bash

# 对应上面获取的 number
bin/elasticsearch-plugin install https://get.infini.cloud/elasticsearch/analysis-pinyin/9.2.2
```

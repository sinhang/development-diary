### analysis-dynamic-synonym

1. [github](https://github.com/sinhang/analysis-dynamic-synonym)
2. [elasticsearch-cluster-runner](https://github.com/codelibs/elasticsearch-cluster-runner)
3. [elasticsearch-module](https://github.com/codelibs/elasticsearch-module)

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

### build
```bash
# 编译 analysis-common-9.2.2.jar
git clone https://github.com/codelibs/elasticsearch-module.git
cd elasticsearch-module
./build.sh 9.2.2
# 编译完成后
ll ./target/elasticsearch-9.2.2/modules/analysis-common/analysis-common-9.2.2.jar
mvn install:install-file -Dfile=./modules/analysis-common/target/elasticsearch-analysis-common-9.2.2.jar -DgroupId=org.codelibs -DartifactId=elasticsearch-analysis-common -Dversion=9.2.2 -Dpackaging=jar


mvn install:install-file -Dfile=path/to/preallocate-9.2.2.jar -DgroupId=org.codelibs.elasticsearch.lib -DartifactId=preallocate -Dversion=9.2.2 -Dpackaging=jar

mvn install:install-file -Dfile=path/to/plugin-classloader-9.2.2.jar -DgroupId=org.codelibs.elasticsearch.lib -DartifactId=plugin-classloader -Dversion=9.2.2 -Dpackaging=jar


# https://mvnrepository.com/artifact/org.elasticsearch/elasticsearch-plugin-classloader
# https://mvnrepository.com/artifact/org.elasticsearch/elasticsearch-preallocate
git clone https://github.com/codelibs/elasticsearch-cluster-runner.git

git clone https://github.com/sinhang/analysis-dynamic-synonym.git

# https://mvnrepository.com/artifact/org.elasticsearch/elasticsearch-grok
sudo apt install maven -y
```

### install
```bash
unzip dynamic-synonym-8.7.1.zip -d ./dynamic-synonym
docker cp ./dynamic-synonym docker-elk-elasticsearch-1:/usr/share/elasticsearch/plugins/
```
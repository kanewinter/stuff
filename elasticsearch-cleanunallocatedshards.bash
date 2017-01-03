HOST=bcv-srv-db-dev.b.comcast.net
PORT=9200
TO_NODE=bcv-srv-db-dev-02

curl "http://$HOST:$PORT/_cat/shards" | grep UNAS | awk '{print $1,$2}' | while read var_index var_shard; do 
  curl -XPOST "http://$HOST:$PORT/_cluster/reroute" -d "
    { 
      \"commands\" : [ 
        { 
          \"allocate\" : 
            { 
              \"index\" : \"$var_index\", 
              \"shard\" : $var_shard, 
              \"node\" : \"$TO_NODE\", 
              \"allow_primary\" : true 
            } 
        } 
      ]
    }" ; 
    sleep 5; 
done

{
"listener": [{
"tcp": {
"address" : "${address}:8200",
"tls_disable" : 1
}
}],
"api_addr": "http://${address}:8201",

"storage": {
    "file": {
    "path" : "/opt/vault-data"
    }
 },
 "backend": {
    "inmem": {
    }
  },
"max_lease_ttl": "10h",
"default_lease_ttl": "10h",
"ui":true
}

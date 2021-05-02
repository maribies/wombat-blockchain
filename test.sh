#!/bin/bash

=============() {
  echo "$@" | tr 'a-z' 'A-Z'
}

============= APP 1: MAKE SOME TRANSACTIONS
curl -s localhost:5000/transactions/new -H 'Content-Type: application/json' --data-raw $'{
 "sender": "josh",
 "recipient": "marissa",
 "amount": 5
}' | jq

curl -s localhost:5000/transactions/new -H 'Content-Type: application/json' --data-raw $'{
 "sender": "josh",
 "recipient": "marissa",
 "amount": 3
}' | jq

curl -s localhost:5000/transactions/new -H 'Content-Type: application/json' --data-raw $'{
 "sender": "marissa",
 "recipient": "dave",
 "amount": 4
}' | jq


============= APP 1: MINE THE BLOCK
curl -s 'localhost:5000/mine' | jq

============= APP 1: VIEW THE BLOCKCHAIN
curl -s 'localhost:5000/chain' | jq


============= APP 2: REGISTER APP 1
curl -s localhost:5001/nodes -H 'Content-Type: application/json' --data-raw $'{
  "nodes": ["http://localhost:5000/chain"]
}' | jq


============= APP 2: RESOLVE THE NEW CHAIN '(should get chain from app 1)'
curl -s localhost:5001/nodes/resolve -H 'Content-Type: application/json' | jq .

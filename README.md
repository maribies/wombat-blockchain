Getting to know blockchain w/ [@JoshCheek](https://github.com/JoshCheek)

Inspo:
- @dvf's article: https://hackernoon.com/learn-blockchains-by-building-one-117428612f46
- crypto & coffee meetup

### To run server:

```sh
rackup -I lib -p 5000
```

### To run tests:
```sh
rspec
```

### To interact with server:

```sh
# NOTE: for pretty printing the JSON, we are using `jq`,
# which can be installed via package manager. Eg `brew install jq`

# Post a transaction
curl -s localhost:5000/transactions/new -H 'Content-Type: application/json' --data-raw $'{
 "sender": "my address",
 "recipient": "someone else\'s address",
 "amount": 5
}' | jq

# Mine the next block
curl -s 'localhost:5000/mine' | jq

# View the blockchain
curl -s 'localhost:5000/chain' | jq
```

#### Exploring the differences between posting via API and HTML
```sh
curl localhost:5000/transactions/new \
  -i -H 'Content-Type: application/json' -H 'accept: application/json' --data-raw $'{
 "sender": "my address",
 "recipient": "someone else\'s address",
 "amount": 5
}'

# It's not about the method, but the structure and data sent. :)
curl localhost:5000/transactions/new \
  -i \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'accept: text/html' \
  --data-raw $'transaction%5Bsender%5D=my+address&transaction%5Brecipient%5D=your+address&transaction%5Bamount%5D=8'
```

//If this ends up in our GitHub, I'm blaming myself -dsfounis

Web3 = require('web3')
let web3 = new Web3(Web3.givenProvider || "ws://localhost:7545")

function add(a, b) {
    var final_hash = web3.utils.soliditySha3("21f3a9de43f07d855f49b946a10c30df432e8af95311435f77daf894216dcd41")
    console.log(final_hash)
    
    return a+b 
} 

console.log(add(4, 6)) 


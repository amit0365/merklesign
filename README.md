Simple group-sign with members public key stored in a merkle tree. 

client-server arch: 
1) server sends root, siblings and indices of the tree to client
2) client prooves with his secret key that he is one of the members and signs the transaction, without revealing his identity aka public key


Note: The private key is used to commit to a message not sign it 



Compilation

compile circuit: circom circuit.circom --r1cs --wasm --sym
This generates an r1cs file - rank 1 constraint system i.e. === operators
wasm file (containing <--  assignment and input signals)

generate withness: node generate_witness.js circuit.wasm ./input.json ./witness.wtns
Witness file "wtns" which takes wasm file and input.json, contains the computational trace as a result of running the circuit

genearate zkey from ptau: snarkjs groth16 setup circuit.r1cs pot12_final.ptau merklesign_0000.zkey

Export the verification key: snarkjs zkey export verificationkey merklesign_0000.zkey verification_key.json

generate proof: snarkjs groth16 prove merklesign_0000.zkey witness.wtns proof.json public.json

mimsc hash function is repeated multiplication and addtion to have less computation overhead, because keccak256 is compute heavy





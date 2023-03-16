pragma circom 2.1.4;

include "/Users/ak36/node_modules/circomlib/circuits/poseidon.circom";
// include "https://github.com/0xPARC/circom-secp256k1/blob/master/circuits/bigint.circom";

template SecretToPublic () {
    signal input sk;
    signal output pk;
    
    
    component poseidon = Poseidon(1);
    poseidon.inputs[0] <== sk;
    pk <== poseidon.out;

}

template Sign () {

    signal input m;
    signal input sk; //private
    signal input pk;

    
    
    component checker = SecretToPublic();
    checker.sk <== sk;
    pk===checker.pk;

    //dummy constraint
    signal msq;
    msq<== m * m ;

}



// if index == 0, out = [in[0],in[1]]
// if index == 1, out = [in[0],in[1]] 

template DualMux(){

    signal input s; //index
    signal input in[2];
    signal output out[2];


    // make sure only one quadratic term in eq
    s * (1 - s) === 0;
    out[0] <== (in[1] - in[0])*s + in[0];
    out[1] <== (in[0] - in[1])*s + in[1];

}

// checking if a sk is part of the merkle leaves

template MerkleTreeMembership(nLevels){

   // signal input sk; //private
    signal input root;
    signal input siblings[nLevels];
    signal input pathIndices[nLevels]; // 0 if left sibling 1 if right sibling

    signal input leaf;
    signal intermidiateHash[nLevels+1];
    component poseidons[nLevels];
    component muxes[nLevels];

    intermidiateHash[0] <== leaf;

    for(var i=0;i<nLevels;i++){

        muxes[i]=DualMux();
        muxes[i].in[0] <== intermidiateHash[i];
        muxes[i].in[1] <== siblings[i];
        muxes[i].s <== pathIndices[i];


        poseidons[i]=Poseidon(2);

        poseidons[i].inputs[0] <== muxes[i].out[0];
        poseidons[i].inputs[1] <== muxes[i].out[1]; 

        intermidiateHash[i+1] <== poseidons[i].out;

    }

    root===intermidiateHash[nLevels];


}


// sign message with sk which must be present in the merkle tree
template MerkleGroupSign(nLevels) {

    signal input m;
    signal input sk; //private
    signal input root;
    signal input siblings[nLevels]; // private
    signal input pathIndices[nLevels]; //private
    
    
    component computePk = SecretToPublic();
    computePk.sk <== sk;
    // checker.pk is your public key
    // checker.pk === pk[i] for some i 

    //we know a secret key corresponding to a public key inside this merkle tree
    component merkle = MerkleTreeMembership(15);
    merkle.root <== root;
    merkle.leaf <== computePk.pk;


    for(var i=0;i<nLevels;i++){
        merkle.siblings[i] <== siblings[i];
        merkle.pathIndices[i] <== pathIndices[i];
    }


    //dummy constraint
    signal msq;
    msq<== m * m ;

}

component main { public [ root ] } = MerkleGroupSign(15);


/* INPUT = {
    "m":"1",
    "sk": "5",
    "root": "12526504943074866943285022220877919486581928733179543616540415535435246153044",
    "siblings": [
        "1",
        "217234377348884654691879377518794323857294947151490278790710809376325639809",
        "18624361856574916496058203820366795950790078780687078257641649903530959943449",
        "19831903348221211061287449275113949495274937755341117892716020320428427983768",
        "5101361658164783800162950277964947086522384365207151283079909745362546177817",
        "11552819453851113656956689238827707323483753486799384854128595967739676085386",
        "10483540708739576660440356112223782712680507694971046950485797346645134034053",
        "7389929564247907165221817742923803467566552273918071630442219344496852141897",
        "6373467404037422198696850591961270197948259393735756505350173302460761391561",
        "14340012938942512497418634250250812329499499250184704496617019030530171289909",
        "10566235887680695760439252521824446945750533956882759130656396012316506290852",
        "14058207238811178801861080665931986752520779251556785412233046706263822020051",
        "1841804857146338876502603211473795482567574429038948082406470282797710112230",
        "6068974671277751946941356330314625335924522973707504316217201913831393258319",
        "10344803844228993379415834281058662700959138333457605334309913075063427817480"
    ],
    "pathIndices": [
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0"
    ]
} */
pragma circom 2.1.6;

include "../../node_modules/circomlib/circuits/poseidon.circom";
include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/multiplexer.circom";
// include "https://github.com/0xPARC/circom-secp256k1/blob/master/circuits/bigint.circom";

template OneBitVector(n){
    signal input index;
    signal output out[n];

    component X=Decoder(n);
    X.inp <== index;

    X.success === 1;

    out <== X.out;
}

template LTBitVector(n){

    signal input index;
    signal output out[n];

    signal eq[n] <== OneBitVector(n)(index-1);
    out[n-1] <== eq[n-1];
    
    for(var i=n-2;i>=0;i--){
        out[i] <== eq[i] + out[i+1];
    }
}
 

template ZeroIfEqualAndEnabled() {
    signal input enabled;
    signal input in[2];
    signal output out;
    component isz = IsZero();

    in[1] - in[0] ==> isz.in;

    out <== 1-(isz.out)*enabled;
}


template HideCard (maxCardsCount) {
    signal input cards[maxCardsCount];
    signal input card_count;
    signal input current_card;
    signal input salt;


    component count_check = GreaterThan(4);
    count_check.in[0]<==card_count;
    count_check.in[1]<==1;

    count_check.out === 1;

    signal output hidden_card;
    
    signal active_cards[maxCardsCount] <== LTBitVector(maxCardsCount)(card_count);

    //signal result <== cards[0] - current_card;
    //signal output result_vec[maxCardsCount];
     
    component eq[maxCardsCount];
    var total=0;    
    for (var i=0;i<maxCardsCount;i++){
        // var diff=cards[i]-current_card;
        eq[i]=ZeroIfEqualAndEnabled();
        // log("diff",diff);
        // result_vec[i]<== (diff-1)*active_cards[i];
        eq[i].in[0] <== cards[i];
        eq[i].in[1] <== current_card;
        eq[i].enabled<== active_cards[i];
        //result_vec[i] <== eq[i].out;
        total = total +  eq[i].out;
        // log("eq", eq[i].out);
        
        
    }
    // log("total", total);
        
    // component total=CalculateTotal(maxCardsCount);
    // total.in<==result_vec;

    component check = IsEqual();
    check.in[0] <== total  ;
    check.in[1] <== maxCardsCount;
    check.out === 0;

    component hash = Poseidon(2);
    hash.inputs[0] <== current_card;
    hash.inputs[1] <== salt;

    hidden_card <== hash.out;
    // log("hash", hash.out);
}

component main { public [ cards,card_count ] } = HideCard(10);

/* INPUT = {
    "cards": ["31","26","41","50","35","23","0","0","0","0"],
    "card_count": "6",
    "current_card": "41",
    "salt": "1234"
} */
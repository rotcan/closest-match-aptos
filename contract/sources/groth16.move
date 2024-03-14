module closest_match::groth16_prove{
    friend closest_match::game;
    use aptos_std::crypto_algebra::{Element,  scalar_mul,deserialize, eq, multi_pairing,  pairing,  add, zero};
    use aptos_std::bls12381_algebra::{G1,G2,Gt, Fr, FormatFrLsb, FormatG1Compr, FormatG2Compr};
    use std::vector ; 
    
    // let HIDE_CARD_VK_ALPHA_G1: vector<u8> =x"0x";
    // let HIDE_CARD_VK_BETA_G2: vector<u8> =x"0x";
    // let HIDE_CARD_VK_GAMMA_G2: vector<u8> =x"0x";
    // let HIDE_CARD_VK_DELTA_G2: vector<u8> =x"0x";
    // let HIDE_CARD_VK_IC_1: vector<u8> =x"0x";
    // let HIDE_CARD_VK_IC_2: vector<u8> =x"0x";

    
    const HIDE_CARD_ALPHA_G1:  vector<u8> =x"b9e24ac2633a7669dab68a1f72a630289c8f9ad84c111f6131c8f17383cb4f00367d62c9a019c1dd910e6a107391dea1";
    const HIDE_CARD_BETA_G2:  vector<u8> =x"a525e15de1ea6426867d2450dc7a20c40f3a2d8523fdbf35b282f671a9d784224ecdf66e7c683361956b08cae9814f2f18798a261ae8f599f65c6a61a96cefc796fd68535843c163ca6561ecb365d8eebb0a4a863743b78a114f2967b87bed96";
    const HIDE_CARD_GAMMA_G2:  vector<u8> =x"93e02b6052719f607dacd3a088274f65596bd0d09920b61ab5da61bbdc7f5049334cf11213945d57e5ac7d055d042b7e024aa2b2f08f0a91260805272dc51051c6e47ad4fa403b02b4510b647ae3d1770bac0326a805bbefd48056c8c121bdb8";
    const HIDE_CARD_DELTA_G2:  vector<u8> =x"92977569f8d18674ff07553e3c7ed89711816f54866b22e94014e513f371fe2c7ce03c8fcd128e25aeb2c12e90e0826a09089a77e298f37c81961c7ac3d48a1182bcf97c5a24f7e96ab09ea910a2d8f2b517179652d566d61d878354e9a8f2ce";
    const HIDE_CARD_IC_1: vector<u8> =x"a031aea7b651908cba02ac6c2411ccd46d966dda302de65ed301d396d2d986a97109fb91df4c82b39af00eb497bec1fe";
    const HIDE_CARD_IC_2: vector<u8> =x"80a05e6fca141ae45ba0f329e4af32e75eb90cfaf33a8e85a3a84bea469b1b4b8d7b581e902c5e8befb7d5574aab4bd9";
    const HIDE_CARD_IC_3: vector<u8> =x"84186b2b1b8c11851e14557dbbf41baa84377f7a4d1b59e2dede652c7400bdc45ce703e948ce78242769e3bb44747a09";
    const HIDE_CARD_IC_4: vector<u8> =x"89fcfd3f98064d184e56ce50e33f1126ef2ec71e6cd995daaaab7f6655917c5d89655c8c78587507c04f67464db3d7be";
    const HIDE_CARD_IC_5: vector<u8> =x"94c648d21a4532fb9dd0b6f7d6aeaca703201e5a2f8dac107b61f60fa8e8dbd5e476289a8f59f3e0e1968334685d4a7b";
    const HIDE_CARD_IC_6: vector<u8> =x"80c1a81f52fabbfd4083ee5c6158ac6ac51b3004f6d9e82d9e5e8d0fbecdbf369b94c02413cd2e583957085ee38ca55e";
    const HIDE_CARD_IC_7: vector<u8> =x"af7fa4cc1fe645be0ea1756368848f51f835609310463a0e5eb5c2ecbfcd86c0e690686ca8c4b3793caa8c606ac0db77"; 
    const HIDE_CARD_IC_8: vector<u8> =x"88d66724ec1012928b9c425b340beb61b5fa64168b5117194e638d293dbfbe4acb4d8946d67db1bc0d4ac3e804a59451"; 
    const HIDE_CARD_IC_9: vector<u8> =x"96ca60aa9aa04bdd159d6f9230c21ad2e44a84edde281c232a4444eeeae496f1bf5f74c2fe1fb74507f4cb4c71b0d68c"; 
    const HIDE_CARD_IC_10: vector<u8> =x"a7c8096779afcb458456588934b36c41b3d7e1c8f53431351b28d69991de46000759425935bbbc15cfe2df264afe0b2b"; 
    const HIDE_CARD_IC_11: vector<u8> =x"a038b33506b3192bb159520ebf0aca4bffa038a1de120d29a69667a48d530d8b5c394de525b055c55e4946875f62778f"; 
    const HIDE_CARD_IC_12: vector<u8> =x"98b9f72fd9f38eeed5cede1c67dbacfef3d90487abb5bf706f12e2ab2c362c7cef9dbf5cc8ea07e494f39ab847fd2384"; 
    const HIDE_CARD_IC_13: vector<u8> =x"9593e845fad8ed980e806cc05edf0d3428996f6c3da42c01ee147eee632fb7264af75891dca1bc6e814a3c24d4575c10"; 

    const SHOW_CARD_ALPHA_G1:  vector<u8> =x"a53d6c852bc254299b98d297d58b2218cba2ba1f04a01ee34b3a4131daac23bee4ea2853403debd68ae737ad28100412";
    const SHOW_CARD_BETA_G2:  vector<u8> =x"b53fa9b1d894feed0a3ac4026c9bd3a8a1b8f8a596a5100e527f88a468ef87b23e0202141fd064abd107de12825cd4ed1502db33a6e35869414d9f25ec42a0584b6793bb2644da6d8dec93bab1e3c440c15fd56fc338c5a5fa6636ca3d56dd1e";
    const SHOW_CARD_GAMMA_G2:  vector<u8> =x"93e02b6052719f607dacd3a088274f65596bd0d09920b61ab5da61bbdc7f5049334cf11213945d57e5ac7d055d042b7e024aa2b2f08f0a91260805272dc51051c6e47ad4fa403b02b4510b647ae3d1770bac0326a805bbefd48056c8c121bdb8";
    const SHOW_CARD_DELTA_G2:  vector<u8> =x"ad546cbced1ccfcd1ddbe164e6b668ce771494e23f3a2395395b05cdac9ae7497b13d1ce38eedf5720f124b78fb262800fce75e0b721821368e8523757d3b67e6d3a18376077d6823cfe89156665b0bad7c911235d04ba1237e2c441e9ff7614";
    const SHOW_CARD_IC_1: vector<u8> =x"88806c055b2dd078d32fa14ebdcf61a9336b725a0cc96514fbe67bceda4e58d11489cfe7e0a5e3fec463ad071146b5e5";
    const SHOW_CARD_IC_2: vector<u8> =x"a79f6198773eda9f523934fe96343552131b9e5f9a259b93da1368f334aac3007438cfaa21e07982df3580aba8a07e9c";
    const SHOW_CARD_IC_3: vector<u8> =x"a6764641fc0efa6e648f7edc9ad5626b7f04dd5ccddfb1f278a63da036329273b8df3f3510acbeed4ce055bc64100472";
    const SHOW_CARD_IC_4: vector<u8> =x"a159e3b54bd5d9837c88066f33520e0347981e88f26a1816761af19c35391972a54358bbc32ff84ba8ecd6ccfde62cd8";
    const SHOW_CARD_IC_5: vector<u8> =x"95c56ff7b0965bc8c1ba46d2bcf05b7e222f881bdc2f250a94777bb306bd9938548f87431ddf996d5c335ea2d485aa68";
    const SHOW_CARD_IC_6: vector<u8> =x"a7ba4c2437457c5137f3507c421f42ec26dad6f9327eec6afe708bc831bfd03eaf91012ab48ea26c4256a47925d1bcbe";
    const SHOW_CARD_IC_7: vector<u8> =x"939f6b1bd6d88f5f6fa260bac3394a248f355c6dedcd0ebf792bf6bf65b03cd9a30b395fe9a505d06084feb0dbfc49df"; 
    const SHOW_CARD_IC_8: vector<u8> =x"89140678e2f93386fcd250a6984bcad8187b3da50f9f2ff79f91e2706886fa50765084e3bf34fc651bcbaea9920fcb7a"; 
    const SHOW_CARD_IC_9: vector<u8> =x"836e3f6d27a2b6e80d6694aecfea923e8876137e0073cebbe7047cae87353ea4e87ef1b78ed85475e43fce7e88071617"; 
    const SHOW_CARD_IC_10: vector<u8> =x"a33a66c5bbaa69cc2c400df0c2fd3701b5e548e3517d307852555b0bbeed98a9e094df0ad54e48c56819c6d418fb5cc9"; 
    const SHOW_CARD_IC_11: vector<u8> =x"b64c80d892128378ff1b996ab59d6c20b423a3198939578ba7989300eae69f4ff4156f8ff038b20c43e6219bb08bb1d7"; 
    const SHOW_CARD_IC_12: vector<u8> =x"8d7245176bdd32e09797abdafe7496064ad472847af124fea4aededaed29d448d5d9deedc9e475168886fec762550d40"; 
    const SHOW_CARD_IC_13: vector<u8> =x"b8c3a7147dbea753e0457f903359a7c8b3306e2b1a890039b414176be918aa3b93199333ff22ceda3d9cbe43f51c4b1a"; 
    const SHOW_CARD_IC_14: vector<u8> =x"b01675560789d8bb05029099b510c299060ce5d84251572bec11ad0b32e9d572fe1f8f970071c8eb87255c3a94b2cabf"; 


    public(friend) fun verify_hide_card_proof(public_inputs:  vector<vector<u8>>,
    proof_a: vector<u8>,
    proof_b: vector<u8>,
    proof_c: vector<u8>):bool{
        verify_game_proof(HIDE_CARD_ALPHA_G1,HIDE_CARD_BETA_G2,
        HIDE_CARD_GAMMA_G2, HIDE_CARD_DELTA_G2,
        vector[HIDE_CARD_IC_1,HIDE_CARD_IC_2,HIDE_CARD_IC_3,HIDE_CARD_IC_4,HIDE_CARD_IC_5,
        HIDE_CARD_IC_6,HIDE_CARD_IC_7,HIDE_CARD_IC_8,HIDE_CARD_IC_9,HIDE_CARD_IC_10,HIDE_CARD_IC_11,HIDE_CARD_IC_12,HIDE_CARD_IC_13],
        public_inputs,
        proof_a,
        proof_b,
        proof_c
        )
    }

    public(friend) fun verify_show_card_proof(public_inputs:  vector<vector<u8>>,
    proof_a: vector<u8>,
    proof_b: vector<u8>,
    proof_c: vector<u8>):bool{
        verify_game_proof(SHOW_CARD_ALPHA_G1,SHOW_CARD_BETA_G2,
        SHOW_CARD_GAMMA_G2, SHOW_CARD_DELTA_G2,
        vector[SHOW_CARD_IC_1,SHOW_CARD_IC_2,SHOW_CARD_IC_3,SHOW_CARD_IC_4,SHOW_CARD_IC_5,
        SHOW_CARD_IC_6,SHOW_CARD_IC_7,SHOW_CARD_IC_8,SHOW_CARD_IC_9,SHOW_CARD_IC_10,SHOW_CARD_IC_11,SHOW_CARD_IC_12,SHOW_CARD_IC_13,SHOW_CARD_IC_14],
        public_inputs,
        proof_a,
        proof_b,
        proof_c
        )
    }

    inline fun verify_game_proof(vk_alpha_g1:  vector<u8>,
    vk_beta_g2: vector<u8>,
    vk_gamma_g2: vector<u8>,
    vk_delta_g2:  vector<u8>,
    vk_uvw_gamma_g1:  vector<vector<u8>>,
    public_inputs:  vector<vector<u8>>,
    proof_a: vector<u8>,
    proof_b: vector<u8>,
    proof_c: vector<u8>,): bool {
        
        let vk_alpha_g1 = std::option::extract(&mut deserialize<G1, FormatG1Compr>(&vk_alpha_g1));
        let vk_beta_g2 = std::option::extract(&mut deserialize<G2, FormatG2Compr>(&vk_beta_g2));
        let vk_gamma_g2 = std::option::extract(&mut deserialize<G2, FormatG2Compr>(&vk_gamma_g2));
        let vk_delta_g2 = std::option::extract(&mut deserialize<G2, FormatG2Compr>(&vk_delta_g2));
        let vk_gamma_abc_g1: vector<Element<G1>> =vector::map_ref(&vk_uvw_gamma_g1, |e1| std::option::extract(&mut deserialize<G1, FormatG1Compr>(e1)) );
        let public_inputs_arr: vector<Element<Fr>> = vector::map_ref(&public_inputs,|e| std::option::extract(&mut deserialize<Fr, FormatFrLsb>(e)));
        let proof_a = std::option::extract(&mut deserialize<G1, FormatG1Compr>(&proof_a));
        let proof_b = std::option::extract(&mut deserialize<G2, FormatG2Compr>(&proof_b));
        let proof_c = std::option::extract(&mut deserialize<G1, FormatG1Compr>(&proof_c));


        verify_proof<G1,G2,Gt,Fr>(&vk_alpha_g1,&vk_beta_g2,&vk_gamma_g2,&vk_delta_g2,&vk_gamma_abc_g1,&public_inputs_arr,
        &proof_a,&proof_b,&proof_c)
     
    }

    inline fun verify_proof<G1,G2,Gt,S>(
        vk_alpha_g1: &Element<G1>,
        vk_beta_g2: &Element<G2>,
        vk_gamma_g2: &Element<G2>,
        vk_delta_g2: &Element<G2>,
        //vk_uvw_gamma_g1: &vector<Element<G1>>,
        ic: &vector<Element<G1>>,
        public_inputs: &vector<Element<S>>,
        proof_a: &Element<G1>,
        proof_b: &Element<G2>,
        proof_c: &Element<G1>,
    ): bool {
        let vk_x=zero<G1>();
        vk_x=add(&vk_x,vector::borrow(ic,0));
        let l=vector::length(public_inputs);
        
        for (i in 0..l) {
            vk_x = add(&vk_x, &scalar_mul(vector::borrow(ic,i+1), vector::borrow(public_inputs,i)));
        };
        
        let left= pairing<G1,G2,Gt>(proof_a, proof_b);
        let right=multi_pairing<G1,G2,Gt>(&vector[
              // vk.alfa1,
            *vk_alpha_g1,
            // vk_x,
            vk_x,
            // _proof.C,
            *proof_c,
        ],&vector[
             //  vk.beta2,
            *vk_beta_g2,
            //  vk.gamma2,
            *vk_gamma_g2,
            //  vk.delta2
            *vk_delta_g2,
        ]);
        // let res_bytes= serialize<Gt, FormatGt>(&res);
        // let b_val: u8=*vector::borrow(&res_bytes,31);
        // assert!(b_val==1,INVALID_PROOF);
        // true 
        eq(&left, &right)
    }
}
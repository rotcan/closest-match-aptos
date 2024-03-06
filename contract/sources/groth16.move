module closest_match::groth16_prove{
    
    use aptos_std::crypto_algebra::{Element, from_u64, multi_scalar_mul,scalar_mul,deserialize, eq, multi_pairing, upcast, pairing,  add, zero};
    use aptos_std::bls12381_algebra::{G1,G2,Gt,Fr, FormatFrLsb, FormatG1Compr, FormatG2Compr};
    use std::vector ;
    use std::signer;

    
    public(friend) fun verify_game_proof(vk_alpha_g1:  vector<u8>,
    vk_beta_g2: vector<u8>,
    vk_gamma_g2: vector<u8>,
    vk_delta_g2:  vector<u8>,
    vk_uvw_gamma_g1:  vector<vector<u8>>,
    public_inputs:  vector<vector<u8>>,
    proof_a: vector<u8>,
    proof_b: vector<u8>,
    proof_c: vector<u8>,): bool {
        verify_proof(vk_alpha_g1,vk_beta_g2,vk_gamma_g2,vk_delta_g2,vk_uvw_gamma_g1,public_inputs,
        proof_a,proof_b,proof_c);
     
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
module closest_match::game_tests{
    #[test_only]
    use std::signer;

    const PLAYER1_R1_HC_PROOF_A : vector<u8> = x"86a7ff24bc2f89e9d4429c83900cc32859cb34ae3116c1dd5d87945ceb76d50ca8e177eb2436d4e820f1bc56857981c1";
    const PLAYER1_R1_HC_PROOF_B : vector<u8> = x"813a5f942bf42a36ca7bd6c0eb7650f10c1a0a1e06501b943585e3f7b8e00e3e4d00221490663f987c1a398f99d146740a18a4543d66f5a496596cdd3a04fa2ca1ccfaaf13f3e6605c8310493c21f2c42ced797c22a06c6ca264f9078a7649ea";
    const PLAYER1_R1_HC_PROOF_C : vector<u8> = x"a88066ec1364278f800c03788a969c13f1a082d1009daa7e18dee7511de79fd294e67684db33e61f472c98f4325e5d89";
    const PLAYER1_R1_HC_PUBLIC_INPUT_1 : vector<u8> = x"06ed427cd23fb1a0f63881e1d2e2f7af9fcb9add7efefbac870c405b20f9ed12";
    const PLAYER1_R1_HC_PUBLIC_INPUT_2_CARD1 : vector<u8> = x"1f00000000000000000000000000000000000000000000000000000000000000";
    const PLAYER1_R1_HC_PUBLIC_INPUT_3_CARD2 : vector<u8> = x"1a00000000000000000000000000000000000000000000000000000000000000";
    const PLAYER1_R1_HC_PUBLIC_INPUT_4_CARD3 : vector<u8> = x"2900000000000000000000000000000000000000000000000000000000000000";
    const PLAYER1_R1_HC_PUBLIC_INPUT_5_CARD4 : vector<u8> = x"3200000000000000000000000000000000000000000000000000000000000000";
    const PLAYER1_R1_HC_PUBLIC_INPUT_6_CARD5 : vector<u8> = x"2300000000000000000000000000000000000000000000000000000000000000";
    const PLAYER1_R1_HC_PUBLIC_INPUT_7_CARD6 : vector<u8> = x"1700000000000000000000000000000000000000000000000000000000000000";
    const PUBLIC_INPUT_ZERO_VAL : vector<u8> = x"0000000000000000000000000000000000000000000000000000000000000000";
    const PUBLIC_INPUT_ZERO_CARD_COUNT : vector<u8> = x"0600000000000000000000000000000000000000000000000000000000000000";

    const PLAYER1_R1_SC_PROOF_A : vector<u8> = x"9256a7e0daa045800b15f9b221ddc92f27e0f6fdcd43d07598fc281bc366418b3089a9cc69d80c0e5e13a2c42500885f";
    const PLAYER1_R1_SC_PROOF_B : vector<u8> = x"895bdce0aec7ec22ad0a49bd6e680cb8a789f4ded371033bbd95805c273569a719c8a68577119eb92a238df4dbebf4fd12d48570777535a54c871a5bb9a187b5c6e752c0d9c9d021127978b373ab3b9b432692e0b8a22bae7536ef0165f7444c";
    const PLAYER1_R1_SC_PROOF_C : vector<u8> = x"8744e687bd8df7638513a9afb3a55f362d8fd38fb557aa63f55f6727ace568171b7052ef131bfc66af7231a179a23516";
    const PLAYER1_R1_SC_PUBLIC_INPUT_12 : vector<u8> = x"1f00000000000000000000000000000000000000000000000000000000000000";
    const PLAYER1_R1_SC_PUBLIC_INPUT_13 : vector<u8> = x"06ed427cd23fb1a0f63881e1d2e2f7af9fcb9add7efefbac870c405b20f9ed12";
    

    const PLAYER2_R1_HC_PROOF_A : vector<u8> = x"888ed908b28832d8dcf8792ea58f545e786c70e0551d14e4feadb6aef7be26937eed7dba319d1d8682c294860f9c192a";
    const PLAYER2_R1_HC_PROOF_B : vector<u8> = x"b756ca668163630c6b61f72abb62d21ded3045a4f0354729165f613a696785cbaa264932703fc18921704afcfac84f860a0555e39ff87a9ccb9bd33c42a3739b07bb87651d36d9e34e9affbb58e80140fec9d155f01c40a8f27e73c93d27801d";
    const PLAYER2_R1_HC_PROOF_C : vector<u8> = x"af5f7faf11300df4c291eb7a7e69714ab43ee8e7df129fcd807298829b7e6b9685083a46deeed235d9db8d2245abdb25";
    const PLAYER2_R1_HC_PUBLIC_INPUT_1 : vector<u8> = x"2941414fd3984b593403be868225c9a44120a6a95025116f46b36f43a4755e35";
    const PLAYER2_R1_HC_PUBLIC_INPUT_2_CARD1 : vector<u8> = x"0300000000000000000000000000000000000000000000000000000000000000";
    const PLAYER2_R1_HC_PUBLIC_INPUT_3_CARD2 : vector<u8> = x"0000000000000000000000000000000000000000000000000000000000000000";
    const PLAYER2_R1_HC_PUBLIC_INPUT_4_CARD3 : vector<u8> = x"1800000000000000000000000000000000000000000000000000000000000000";
    const PLAYER2_R1_HC_PUBLIC_INPUT_5_CARD4 : vector<u8> = x"0100000000000000000000000000000000000000000000000000000000000000";
    const PLAYER2_R1_HC_PUBLIC_INPUT_6_CARD5 : vector<u8> = x"2e00000000000000000000000000000000000000000000000000000000000000";
    const PLAYER2_R1_HC_PUBLIC_INPUT_7_CARD6 : vector<u8> = x"1d00000000000000000000000000000000000000000000000000000000000000";

    const PLAYER2_R1_SC_PROOF_A : vector<u8> = x"996339e84ce9c466abe2bb14a52ec2d8050ea343d890af298f4f743026c943df2a5636b02f14920acc4b2d9e00e5f0b1";
    const PLAYER2_R1_SC_PROOF_B : vector<u8> = x"a5d0be980fded316ca2130d052f93165ade31287c543c73d6605bc7d2acc2951f069aad5303e4031f8b10cf036e3ccda0825bf3a85bea26160631cda893ac2d619bfffa1c2f84d45e4180e72497f961cd6d76cbdd3ca713c1b7c5f78cc6329f4";
    const PLAYER2_R1_SC_PROOF_C : vector<u8> = x"82d48054d1f716e53d66c99766ebab61179ef3e3d26fd929c273ea767a708f6260f5113d34ba387307ff0a211a9fe1c0";
    const PLAYER2_R1_SC_PUBLIC_INPUT_12 : vector<u8> = x"1800000000000000000000000000000000000000000000000000000000000000";
    const PLAYER2_R1_SC_PUBLIC_INPUT_13 : vector<u8> = x"2941414fd3984b593403be868225c9a44120a6a95025116f46b36f43a4755e35";
    

    const PLAYER3_R1_HC_PROOF_A : vector<u8> = x"97fc5c96a438c695ad868447aca9843315d389057f98c8a93b4b9f63ad50de3e5246c89f01622338481089e4de303fb1";
    const PLAYER3_R1_HC_PROOF_B : vector<u8> = x"a050d9bf3929f93ff8ea80e7fa9e5bec3807fea8fda3e8c540602b700312ad3c0f4f8bcef1d772ee0df15da346ed4f7a078edf75b3c912320038a1ef1ef8d18b09f998acfbf3c4abd8dc65d6d9e1cd43407fc28cb04ff7b55735100cb92a02cf";
    const PLAYER3_R1_HC_PROOF_C : vector<u8> = x"95672617804ddf29872cfb0460c439eaf6cb193190c02cec7a08a4083040911d956b04c431d5a1ad07b1855741396d10";
    const PLAYER3_R1_HC_PUBLIC_INPUT_1 : vector<u8> = x"9185ca5ac0c1255dea97b52e3c9ae616cfb4bf3edb14a698976aa51a48253b44";
    const PLAYER3_R1_HC_PUBLIC_INPUT_2_CARD1 : vector<u8> = x"2c00000000000000000000000000000000000000000000000000000000000000";
    const PLAYER3_R1_HC_PUBLIC_INPUT_3_CARD2 : vector<u8> = x"0400000000000000000000000000000000000000000000000000000000000000";
    const PLAYER3_R1_HC_PUBLIC_INPUT_4_CARD3 : vector<u8> = x"2100000000000000000000000000000000000000000000000000000000000000";
    const PLAYER3_R1_HC_PUBLIC_INPUT_5_CARD4 : vector<u8> = x"1b00000000000000000000000000000000000000000000000000000000000000";
    const PLAYER3_R1_HC_PUBLIC_INPUT_6_CARD5 : vector<u8> = x"1300000000000000000000000000000000000000000000000000000000000000";
    const PLAYER3_R1_HC_PUBLIC_INPUT_7_CARD6 : vector<u8> = x"0f00000000000000000000000000000000000000000000000000000000000000";

    const PLAYER3_R1_SC_PROOF_A : vector<u8> = x"b34edd67d1d3ee8e46952497b5847e4523cfa150c758608037ec2d48747e2f9bcb710072fca38476bd894c52a3fd4f91";
    const PLAYER3_R1_SC_PROOF_B : vector<u8> = x"8649821dca038945d374aea31805090ab4b631ae98711aa9c783587eb44ba0ea755bf3afaca484b210f1e8e78b4285540cb0fa2c4829c672be35df8b92b6af0e592845492b9eefc483dd6ba3b3d66164fc09d1b548eaeaa106ecd468069fe09c";
    const PLAYER3_R1_SC_PROOF_C : vector<u8> = x"8431a7ee1aedf49fa12912bde8feb6da0ec421cfbc1e497c500288fc4db69eb81509649a27320ca74e26477d3c656cde";
    const PLAYER3_R1_SC_PUBLIC_INPUT_12 : vector<u8> = x"1300000000000000000000000000000000000000000000000000000000000000";
    const PLAYER3_R1_SC_PUBLIC_INPUT_13 : vector<u8> = x"9185ca5ac0c1255dea97b52e3c9ae616cfb4bf3edb14a698976aa51a48253b44";
  

    #[test_only]
    use aptos_framework::account::create_account_for_test;

    #[test_only]
    use aptos_framework::crypto_algebra::enable_cryptography_algebra_natives;
    
    #[test_only]
    use closest_match::game;

    #[test_only]
    use closest_match::mtc_coin;

    #[test_only]
    use closest_match::game_randomness;

    #[test_only]
    use aptos_framework::timestamp;

    #[test_only]
    fun setup_game_for_test(
        admin: &signer,
        fx: &signer
    ){
        game::init_module_for_testing(admin);
        mtc_coin::setup_test(admin);
        game_randomness::init_randomness(fx)
    }

    const POT_VALUE: u64=1000;
    const MATCH_ID: u64=0;
    const PLAYER_COUNT: u8 = 3;
    const MOVE_TIME: u64 = 60;

    // #[test_only]
    // fun setup_match(admin: &signer,player1: &signer, player2: &signer, player3: &signer,fx: &signer){
       
    // }
    
    #[test(admin=@admin_addr, player1=@0xabc, player2=@0xbcd,player3=@0xcde, fx=@aptos_framework)]
    fun test_match(admin: signer,player1: signer, player2: signer, player3: signer,fx: signer){
        
        // let admin_address=signer::address_of(&admin);
        // let player1_address=signer::address_of(&player1);
        // let player2_address=signer::address_of(&player2);
        // let player3_address=signer::address_of(&player3);
        // let pot_value=POT_VALUE;
        // let match_id=MATCH_ID;
        // let player_count=PLAYER_COUNT;
        //seconds
        // let move_time=MOVE_TIME;
        
        
        // setup_match(&admin,&player1,&player2,&player3,&fx);
         let admin_address=signer::address_of(&admin);
        let player1_address=signer::address_of(&player1);
        let player2_address=signer::address_of(&player2);
        let player3_address=signer::address_of(&player3);
        create_account_for_test(admin_address);
        create_account_for_test(player1_address);
        create_account_for_test(player2_address);
        create_account_for_test(player3_address);
        //init game
        setup_game_for_test(&admin,&fx);
        enable_cryptography_algebra_natives(&fx);
        timestamp::set_time_has_started_for_testing(&fx);

        //mint coins
        let pot_value=1000;
        let match_id=0;
        mtc_coin::mint_coins(&admin,admin_address,pot_value);

        assert!(mtc_coin::get_balance(admin_address,admin_address) == pot_value,1);
        mtc_coin::mint_coins(&admin,player1_address,pot_value);
        mtc_coin::mint_coins(&admin,player2_address,pot_value);
        mtc_coin::mint_coins(&admin,player3_address,pot_value);

        let player_count=3;
        //seconds
        let move_time=60;
        game::setup_match_test(&player1,player_count,move_time,pot_value); 

        game::join_match_test(&player2,player1_address,match_id); 
        game::join_match_test(&player3,player1_address,match_id); 
    
        //draw cards for all players
        game::draw_cards_test(player1_address,match_id);
        //timestamp::fast_forward_seconds(610);

        //Start move

        //player 1
        game::play_hidden_card_test(&player1,player1_address,match_id,vector[PLAYER1_R1_HC_PUBLIC_INPUT_1,PLAYER1_R1_HC_PUBLIC_INPUT_2_CARD1,
        PLAYER1_R1_HC_PUBLIC_INPUT_3_CARD2,
        PLAYER1_R1_HC_PUBLIC_INPUT_4_CARD3,PLAYER1_R1_HC_PUBLIC_INPUT_5_CARD4,PLAYER1_R1_HC_PUBLIC_INPUT_6_CARD5,PLAYER1_R1_HC_PUBLIC_INPUT_7_CARD6,
        PUBLIC_INPUT_ZERO_VAL,PUBLIC_INPUT_ZERO_VAL,PUBLIC_INPUT_ZERO_VAL,PUBLIC_INPUT_ZERO_VAL,
        PUBLIC_INPUT_ZERO_CARD_COUNT],PLAYER1_R1_HC_PROOF_A,PLAYER1_R1_HC_PROOF_B,PLAYER1_R1_HC_PROOF_C,);
        //player 2
        game::play_hidden_card_test(&player2,player1_address,match_id,vector[PLAYER2_R1_HC_PUBLIC_INPUT_1,PLAYER2_R1_HC_PUBLIC_INPUT_2_CARD1,
        PLAYER2_R1_HC_PUBLIC_INPUT_3_CARD2,
        PLAYER2_R1_HC_PUBLIC_INPUT_4_CARD3,PLAYER2_R1_HC_PUBLIC_INPUT_5_CARD4,PLAYER2_R1_HC_PUBLIC_INPUT_6_CARD5,PLAYER2_R1_HC_PUBLIC_INPUT_7_CARD6,
        PUBLIC_INPUT_ZERO_VAL,PUBLIC_INPUT_ZERO_VAL,PUBLIC_INPUT_ZERO_VAL,PUBLIC_INPUT_ZERO_VAL,
        PUBLIC_INPUT_ZERO_CARD_COUNT],PLAYER2_R1_HC_PROOF_A,PLAYER2_R1_HC_PROOF_B,PLAYER2_R1_HC_PROOF_C,);

        
        //player 3
        game::play_hidden_card_test(&player3,player1_address,match_id,vector[PLAYER3_R1_HC_PUBLIC_INPUT_1,PLAYER3_R1_HC_PUBLIC_INPUT_2_CARD1,
        PLAYER3_R1_HC_PUBLIC_INPUT_3_CARD2,
        PLAYER3_R1_HC_PUBLIC_INPUT_4_CARD3,PLAYER3_R1_HC_PUBLIC_INPUT_5_CARD4,PLAYER3_R1_HC_PUBLIC_INPUT_6_CARD5,PLAYER3_R1_HC_PUBLIC_INPUT_7_CARD6,
        PUBLIC_INPUT_ZERO_VAL,PUBLIC_INPUT_ZERO_VAL,PUBLIC_INPUT_ZERO_VAL,PUBLIC_INPUT_ZERO_VAL,
        PUBLIC_INPUT_ZERO_CARD_COUNT],PLAYER3_R1_HC_PROOF_A,PLAYER3_R1_HC_PROOF_B,PLAYER3_R1_HC_PROOF_C,);
        
        //Reveal Move
        game::reveal_hidden_card_test(&player1,player1_address,match_id,vector[PLAYER1_R1_HC_PUBLIC_INPUT_2_CARD1,
        PLAYER1_R1_HC_PUBLIC_INPUT_3_CARD2,
        PLAYER1_R1_HC_PUBLIC_INPUT_4_CARD3,PLAYER1_R1_HC_PUBLIC_INPUT_5_CARD4,PLAYER1_R1_HC_PUBLIC_INPUT_6_CARD5,PLAYER1_R1_HC_PUBLIC_INPUT_7_CARD6,
         PUBLIC_INPUT_ZERO_VAL,PUBLIC_INPUT_ZERO_VAL,
        PUBLIC_INPUT_ZERO_VAL,PUBLIC_INPUT_ZERO_VAL,PUBLIC_INPUT_ZERO_CARD_COUNT,
        PLAYER1_R1_SC_PUBLIC_INPUT_12,PLAYER1_R1_SC_PUBLIC_INPUT_13],PLAYER1_R1_SC_PROOF_A,PLAYER1_R1_SC_PROOF_B,PLAYER1_R1_SC_PROOF_C,);

         game::reveal_hidden_card_test(&player2,player1_address,match_id,vector[PLAYER2_R1_HC_PUBLIC_INPUT_2_CARD1,
        PLAYER2_R1_HC_PUBLIC_INPUT_3_CARD2,
        PLAYER2_R1_HC_PUBLIC_INPUT_4_CARD3,PLAYER2_R1_HC_PUBLIC_INPUT_5_CARD4,PLAYER2_R1_HC_PUBLIC_INPUT_6_CARD5,PLAYER2_R1_HC_PUBLIC_INPUT_7_CARD6,
         PUBLIC_INPUT_ZERO_VAL,PUBLIC_INPUT_ZERO_VAL,
        PUBLIC_INPUT_ZERO_VAL,PUBLIC_INPUT_ZERO_VAL,PUBLIC_INPUT_ZERO_CARD_COUNT,
        PLAYER2_R1_SC_PUBLIC_INPUT_12,PLAYER2_R1_SC_PUBLIC_INPUT_13],PLAYER2_R1_SC_PROOF_A,PLAYER2_R1_SC_PROOF_B,PLAYER2_R1_SC_PROOF_C,);

         game::reveal_hidden_card_test(&player3,player1_address,match_id,vector[PLAYER3_R1_HC_PUBLIC_INPUT_2_CARD1,
        PLAYER3_R1_HC_PUBLIC_INPUT_3_CARD2,
        PLAYER3_R1_HC_PUBLIC_INPUT_4_CARD3,PLAYER3_R1_HC_PUBLIC_INPUT_5_CARD4,PLAYER3_R1_HC_PUBLIC_INPUT_6_CARD5,PLAYER3_R1_HC_PUBLIC_INPUT_7_CARD6,
         PUBLIC_INPUT_ZERO_VAL,PUBLIC_INPUT_ZERO_VAL,
        PUBLIC_INPUT_ZERO_VAL,PUBLIC_INPUT_ZERO_VAL,PUBLIC_INPUT_ZERO_CARD_COUNT,
        PLAYER3_R1_SC_PUBLIC_INPUT_12,PLAYER3_R1_SC_PUBLIC_INPUT_13],PLAYER3_R1_SC_PROOF_A,PLAYER3_R1_SC_PROOF_B,PLAYER3_R1_SC_PROOF_C,);

        //Scoring

    }
}
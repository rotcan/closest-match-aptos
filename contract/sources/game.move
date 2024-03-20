module closest_match::game {
 
    use std::option;
    use aptos_std::simple_map;
    use std::error;
    use std::bcs;
    use std::vector;
    use std::account;
    use std::signer;
    use aptos_std::comparator;
    use aptos_framework::timestamp;
    use aptos_framework::randomness;

    //Errors
    const E_MATCH_ALREADY_RUNNING: u64=1;
    const E_MATCH_DOES_NOT_EXIST: u64=2;
    const E_MATCH_ALREADY_STARTED: u64=3;
    const E_ALREADY_JOINED: u64=4;
    const E_ADMIN_ADDRESS_MISMATCH: u64=5;
    const E_RESOURCE_ALREADY_EXISTS: u64=6;
    const E_PROOF_FAILED: u64=7;
    const E_CARDS_MISMATCH: u64=8;
    const E_CANNOT_PLAY_MULTIPLE_CARDS_IN_SAME_ROUND: u64=9;
    const E_REVEAL_CARD_MISMATCH: u64=10;
    const E_REVEAL_CARD_NOT_PRESENT: u64=11;
    const E_REVEAL_CARD_PLAYED_AGAIN: u64=12;
    const E_MATCH_ALREADY_ENDED: u64=13;
    const E_WAITING_FOR_OTHER_PLAYERS: u64=14;
    const E_MATCH_NOT_IN_PROGRESS: u64 =15;
    const E_ALREADY_PLAYED: u64=16;
    const E_ALREADY_SCORED: u64 = 17;
    const E_ROUND_NOT_FINISHED: u64 = 18;
    const E_CANNOT_FINISH_MATCH: u64 = 19;
    const E_LAST_ROUND_CANNOT_CALL: u64=20;
    const E_ROUNDS_NOT_IN_RANGE: u64=21;

    //Play state enum
    const MATCH_SETUP: u8 = 1; //match setup
    // const MATCH_PLAYER_JOIN: u8 = MATCH_SETUP+1;
    const MATCH_START: u8= 2 ;
    const MATCH_IN_PROGRESS: u8= 3 ;
    const MATCH_END: u8= 4 ;
    const MATCH_FORFEIT: u8= 5 ;

    const GAME_INIT: u8=10; //draw cards
    const GAME_PLAYER_HIDDEN_MOVE: u8= 11; //Player move
    const GAME_PLAYER_REVEAL: u8=12;
    const GAME_END: u8=13;

    const RESOURCE_ADDRESS_SEED_GLOBAL:vector<u8> = b"closest_match_global";
    const RESOURCE_ADDRESS_SEED:vector<u8> = b"closest_match";
    const RESOURCE_POOL_SEED:vector<u8> = b"closest_match_pool";
    const RESOURCE_ADDRESS_SEED_PLAYERS:vector<u8> = b"closest_match_players";
    
    const MIN_PLAYERS: u8=2;
    const MAX_PLAYERS: u8=4;

    const CARDS_PER_PLAYER: u8=6;
    const ROUNDS: u8=6;

    use closest_match::mtc_coin;
    use closest_match::utils; 
    use closest_match::game_randomness;
    use closest_match::groth16_prove;
    //Groth16 input values
    const HC_HIDDEN_CARD_INDEX: u64=0;
    const HC_CARDS_START_INDEX: u64=1;
    const HC_CARDS_END_INDEX: u64=10;
    const HC_CARDS_COUNT_INDEX: u64=11;

    const SC_CARDS_START_INDEX: u64=0;
    const SC_CARDS_END_INDEX: u64=9;
    const SC_CARDS_COUNT_INDEX: u64=10;
    const SC_CARD_INDEX: u64=11;
    const SC_HIDDEN_CARD_INDEX: u64=12;
    
    const DUMMY_CARD_VALUE: u8 = 52;

    const FEE_BASIS_POINTS: u64=20; //0.2pct
    //Events
    //Setup match
    //Start Match
     #[event]
    struct MatchStartEvent has drop, store {
        match_id: u64,
        owner: address,
        match_address: address,
    }
    //Match finish
    //Match forfeit
    //Round Finish
    #[event]
    struct MatchEvent has drop, store {
        match_id: u64,
        owner: address,
        match_address: address,
        match_state: u8,
        game_state: u8,
    }
    //Player Join
    #[event]
    struct PlayerJoinEvent has drop, store {
        match_id: u64,
        owner: address,
        match_address: address,
        player_address: address,
    }
    //Play Card
    //Reveal Card
    #[event]
    struct CardEvent has drop, store {
        owner: address,
        match_address: address,
        player_address: address,
        round: u8,
        value: option::Option<u8>,
    }
    

    struct MatchId has key,store{
        match_id: u64,
    }
    //only one current match per player as of now
    //create resource account to store this struct using seed as sender's address
    // struct Matches has key,store{
    //     //so current match is last in vector
    //     current_match: u64,
    //     match_states: simple_map::SimpleMap<u64,MatchState>,
    // }

    //Resource account, anyone can update this
    struct MatchState has key,store{
        match_id: u64,
        owner: address,
        player_count: u8,
        max_time_between_moves: u64, //forfeit if player leaves before match finishes
        deck_cards: vector<u8>,
        table_cards: vector<u8>,
        //active_player: option::Option<address>,
        players: vector<address>,
        pot_value: u64,
        player_points: simple_map::SimpleMap<address, u8>,
        match_state: u8,
        total_rounds: u8,
        //player_state: simple_map::SimpleMap<address, PlayerState>, //could use map
        game_state: GameState,
        winners: vector<address>,
        //signer cap
        pool_cap: account::SignerCapability,
        pool_address: address,
    }

    //Resource account, anyone can update this
    struct GameState has store,drop{
        game_state: u8,
        current_player: u8,
        current_round: u8,
        cards_played: u8,
        current_round_moves: simple_map::SimpleMap<address,u8>,
        //current round timestamp
        round_timestamp: u64,
        //player_state: vector<PlayerState>,
        round_scored: u8,
    }


    //Only player can update this
    struct PlayerState has key,store{
        //addr: address,
        player_moves: vector<PlayerMove>,
        player_cards: vector<u8>,
    }

    struct PlayerMove has store,drop{
        secret: vector<u8>,
        value:  option::Option<u8>,   
    }

    struct RoundScoring has store,drop{
        player: address,
        diff: u8,
    }

    struct MatchScoring has store,drop{
        player:address,
        points: u8,
    }

    

    inline fun get_coin_address(): address{
        mtc_coin::get_coin_address()
    }


    #[view]
    public fun get_match_id_address( ):address{
        let seed=get_resource_seed(@admin_addr,0,RESOURCE_ADDRESS_SEED_GLOBAL);
        let resource_address= account::create_resource_address(&@admin_addr, seed);
        resource_address
    }

 
    #[view]
    public fun get_match_state_address(owner_address: address, match_id: u64):address{
        let seed=get_resource_seed(owner_address,match_id,RESOURCE_ADDRESS_SEED);
        let resource_address= account::create_resource_address(&owner_address, seed);
        resource_address
    }

    #[view]
    public fun get_player_state_address(player_address: address, match_id: u64,):address{
        let seed=get_resource_seed(player_address,match_id,RESOURCE_ADDRESS_SEED_PLAYERS);
        let resource_address=account::create_resource_address(&player_address,seed);
        resource_address
    }
     
    inline fun get_empty_state(creator: &signer, player_count: u8, move_time: u64,pot_value: u64,rounds: u8, match_id : u64): MatchState{
        
        //let deck_cards=vector[35, 4,30,20,45,21,17,18,47,49, 6,34,33, 8, 7, 0,31,24, 5,13,15,36,16, 9,46,29,50,44,37,14,10,42,25,12,43,48,11, 1,39,41,51, 2,22,27,19, 3,28,26,23,32,38,40];      
        //todo: uncomment this;
        let deck_cards=vector::empty();
        for (i in 0..52){
            vector::push_back(&mut deck_cards,i);
        };
        let creator_address=signer::address_of(creator);
        let pool_seed=get_resource_seed(creator_address,match_id,RESOURCE_POOL_SEED);

        let (resource,signer_cap)=account::create_resource_account(creator,pool_seed);
        let pool_address=signer::address_of(&resource);
        
        MatchState {
            match_id,
            owner: creator_address,
            player_count,
            max_time_between_moves: move_time, //forfeit if player leaves before match finishes
            deck_cards,
            table_cards: vector::empty(),
            //active_player: option::none(),
            players: vector::singleton<address>(creator_address),
            player_points: simple_map::new_from<address,u8>(vector[creator_address],vector[0]),
            match_state: MATCH_SETUP,
            pot_value,
            total_rounds: rounds,
            winners: vector::empty(),
            //player_state: simple_map::SimpleMap<address, PlayerState>, //could use map
            game_state: GameState {
                game_state: GAME_INIT,
                current_player: 0,
                current_round: 0,
                cards_played: 0,
                current_round_moves: simple_map::create<address,u8>(),
                round_timestamp: 0,
                round_scored:0,
                // player_state: vector::empty(),
            },
            pool_cap: signer_cap,
            pool_address: pool_address,
        }
    } 

    inline fun get_resource_seed(player_address:address, match_id: u64,salt: vector<u8>):vector<u8>{
        let seed=bcs::to_bytes(&player_address);
        vector::append(&mut seed,bcs::to_bytes(&@closest_match));
        vector::append(&mut seed,salt);
        vector::append(&mut seed,bcs::to_bytes(&match_id));
        seed
    }


    fun init_module(admin: &signer){
        let admin_address=signer::address_of(admin);
        assert!(@admin_addr==admin_address, error::permission_denied(E_ADMIN_ADDRESS_MISMATCH));

        let seed=get_resource_seed(admin_address,0,RESOURCE_ADDRESS_SEED_GLOBAL);
        let (_resource_signer, signer_cap) = account::create_resource_account(admin,seed);
        let resource_signer_from_cap=account::create_signer_with_capability(&signer_cap);

        move_to(&resource_signer_from_cap, MatchId{
            match_id:0
        });
    }


    //Setup match : num of players, pot size, 
    //Use fungible asset for tokens
    //At one time only one match will be active per player
    public entry fun setup_match(sender: &signer, player_count: u8, move_time: u64, rounds: u8, pot_value: u64) acquires MatchId{
        //Create resource account
        assert!(rounds >=3 && rounds <=ROUNDS, E_ROUNDS_NOT_IN_RANGE);
        let sender_address=signer::address_of(sender);

        let seed=get_resource_seed(@admin_addr,0,RESOURCE_ADDRESS_SEED_GLOBAL);
        let match_id=borrow_global_mut<MatchId>(account::create_resource_address(&@admin_addr,seed));
        
        //Add new resource
        //move to resource
        let seed=get_resource_seed(sender_address,match_id.match_id,RESOURCE_ADDRESS_SEED);
        let check_resource_address= account::create_resource_address(&sender_address, seed);

        assert!(!account::exists_at(check_resource_address), error::permission_denied(E_RESOURCE_ALREADY_EXISTS));

        //create resource account
        let (_resource,signer_cap)=account::create_resource_account(sender,seed);
        //let resource_address=signer::address_of(&resource);
        let signer_from_cap=account::create_signer_with_capability(&signer_cap);

        let match=get_empty_state(sender,player_count,move_time,pot_value,rounds,match_id.match_id);
        let pool_address=match.pool_address;
        // let match_state=match.match_state;
        // let game_state=match.game_state.game_state;
        let current_match_id=match.match_id;
        move_to(&signer_from_cap,match);  
        
        
        //Create game pot
        if(pot_value > 0 ){
            
            let coin_address=get_coin_address();
            // std::debug::print<u64>(&190);
            // std::debug::print<address>(&coin_address);
            mtc_coin::transfer_to(sender, coin_address, pool_address, pot_value);
        };

        let seed=get_resource_seed(sender_address,match_id.match_id,RESOURCE_ADDRESS_SEED_PLAYERS);
        let (_resource_signer, signer_cap) = account::create_resource_account(sender,seed);
        let resource_signer_from_cap=account::create_signer_with_capability(&signer_cap);
        
        move_to(&resource_signer_from_cap, PlayerState{
            player_moves: vector::empty(),
            player_cards: vector::empty(),
        });
        
        match_id.match_id =match_id.match_id + 1;
        let event = MatchStartEvent {
            match_id: current_match_id,
            owner: sender_address,
            match_address: check_resource_address,
            // match_state: match_state,
            // game_state: game_state,
        };
        0x1::event::emit(event);
    }

    //Join match: all players join , change state to start match
        //On start match -> Deal cards and draw card on table
    public entry fun join_match(sender: &signer, owner: address, match_id: u64,) acquires MatchState{
        let sender_address=signer::address_of(sender);

        let match_seed=get_resource_seed(owner, match_id,RESOURCE_ADDRESS_SEED);
        let check_resource_address= account::create_resource_address(&owner, match_seed);
        assert!(account::exists_at(check_resource_address), error::permission_denied(E_MATCH_DOES_NOT_EXIST));
        
        let match_state=borrow_global_mut<MatchState>(check_resource_address);
        assert!(match_state.match_state == MATCH_SETUP, error::permission_denied(E_MATCH_ALREADY_STARTED));
        
        //update state
        assert!(!simple_map::contains_key(&match_state.player_points,&sender_address), error::permission_denied(E_ALREADY_JOINED));
        vector::push_back(&mut match_state.players,sender_address);
        simple_map::add(&mut match_state.player_points, sender_address ,0 );
        
        //transfer to pot if exists
        let pot_value=match_state.pot_value;
        if(pot_value > 0 ){
            let coin_address=get_coin_address();
            let pool_seed=get_resource_seed(owner,match_state.match_id,RESOURCE_POOL_SEED);
            let pool_address=account::create_resource_address(&owner,pool_seed);
            mtc_coin::transfer_to(sender, coin_address, pool_address, pot_value);
        };

        let seed=get_resource_seed(sender_address,match_state.match_id,RESOURCE_ADDRESS_SEED_PLAYERS);
        let (_resource_signer, signer_cap) = account::create_resource_account(sender,seed);
        let resource_signer_from_cap=account::create_signer_with_capability(&signer_cap);
        move_to(&resource_signer_from_cap, PlayerState{
            player_moves: vector::empty(),
            player_cards: vector::empty(),
        });

        //Check if match can start
        if (vector::length(&match_state.players) == (match_state.player_count as u64) ){
            //match can start
            match_state.match_state=MATCH_START;
            let event = MatchEvent {
                match_id: match_state.match_id,
                owner: owner,
                match_address: check_resource_address,
                match_state: match_state.match_state,
                game_state: match_state.game_state.game_state,
            };
            0x1::event::emit(event);
        };
        let join_event = PlayerJoinEvent {
            match_id: match_state.match_id,
            owner: owner,
            match_address: check_resource_address,
            player_address: sender_address,
        };
        0x1::event::emit(join_event);
    }

    public entry fun draw_cards(owner: address, match_id: u64,) 
    acquires PlayerState,MatchState
    {
        draw_cards_internal(owner,match_id);
    }

    #[randomness]
    entry fun draw_cards_internal(owner: address, match_id: u64,) 
    acquires PlayerState,MatchState
    {
        let match_seed=get_resource_seed(owner, match_id,RESOURCE_ADDRESS_SEED);
        let check_resource_address= account::create_resource_address(&owner, match_seed);
        assert!(account::exists_at(check_resource_address), error::permission_denied(E_MATCH_DOES_NOT_EXIST));
        
        let match_state=borrow_global_mut<MatchState>(check_resource_address);
        //Get cards from deck for each player
        //Draw one card on table
        let player_count=(match_state.player_count as u64);
        for (i in 0..player_count){
            let player_address=vector::borrow(&match_state.players,i);
            let seed=get_resource_seed(*player_address,match_state.match_id,RESOURCE_ADDRESS_SEED_PLAYERS);
            let resource_address=account::create_resource_address(player_address,seed);
            let player_state=borrow_global_mut<PlayerState>(resource_address);
            
            //todo: check CARDS_PER_PLAYER
            player_state.player_cards=game_randomness::draw_cards(&mut match_state.deck_cards,match_state.total_rounds);
            // for (i in 0..CARDS_PER_PLAYER){
            //     let size= vector::length(&match_state.deck_cards) ;
            //     let card=randomness::u64_range(0, size);
            //     vector::push_back(&mut player_state.player_cards, vector::remove(&mut match_state.deck_cards,card));
            // };
            //std::debug::print<u16>(&272);
            // for (j in 0..vector::length(&player_state.player_cards)){
            //     std::debug::print<u8>(vector::borrow(&player_state.player_cards,j));
            // };
        };
        //draw card on table
        //let table_card: vector<u8> =vector::empty<u8>();
        //let table_card=randomness::u64_range(0, vector::length(&match_state.deck_cards) );
        let table_card=game_randomness::draw_cards(&mut match_state.deck_cards,1);
        //vector::push_back(&mut match_state.table_cards,(table_card as u8));
        vector::append(&mut match_state.table_cards,table_card );
        // std::debug::print<u8>(vector::borrow(&match_state.table_cards,0));
        //Update match state
        match_state.game_state.game_state=GAME_PLAYER_HIDDEN_MOVE;
        //match_state.game_state.current_round=1;
        match_state.game_state.cards_played=0;
        match_state.game_state.round_timestamp=timestamp::now_seconds();
        match_state.match_state=MATCH_IN_PROGRESS;
    }

    public entry fun play_hidden_card(sender: &signer,owner: address, match_id: u64, public_inputs:  vector<vector<u8>>,
    proof_a: vector<u8>,
    proof_b: vector<u8>,
    proof_c: vector<u8>) acquires MatchState, PlayerState{
        let match_seed=get_resource_seed(owner, match_id,RESOURCE_ADDRESS_SEED);
        let check_resource_address= account::create_resource_address(&owner, match_seed);
        assert!(account::exists_at(check_resource_address), error::permission_denied(E_MATCH_DOES_NOT_EXIST));
        let match_state=borrow_global_mut<MatchState>(check_resource_address);

        let player_address=signer::address_of(sender);
        let seed=get_resource_seed(player_address,match_id,RESOURCE_ADDRESS_SEED_PLAYERS);
        let resource_address=account::create_resource_address(&player_address,seed);
        let player_state=borrow_global_mut<PlayerState>(resource_address);
            

        play_hidden_card_internal(public_inputs,proof_a,proof_b,proof_c,check_resource_address,player_address, match_state, player_state);
    }
    
    fun play_hidden_card_internal(  public_inputs:  vector<vector<u8>>,
    proof_a: vector<u8>,
    proof_b: vector<u8>,
    proof_c: vector<u8>,match_address: address, player_address: address, match_state: &mut MatchState, player_state: &mut PlayerState )  {
        
        assert!(match_state.game_state.current_round < match_state.total_rounds-1, E_LAST_ROUND_CANNOT_CALL);

        assert!(match_state.match_state == MATCH_IN_PROGRESS, E_MATCH_NOT_IN_PROGRESS);

        //check timestamp
        let time_diff=timestamp::now_seconds() - match_state.game_state.round_timestamp ;
        if (time_diff > match_state.max_time_between_moves) {
            //forfeit 
            forfeit_match(match_address,match_state);
            return
        };

        assert!(!simple_map::contains_key(&match_state.game_state.current_round_moves, &player_address),E_ALREADY_PLAYED);
        
        //check for same card again
        let secret_array=vector::map_ref(&player_state.player_moves, |e| {
            let e: &PlayerMove=e;
            e.secret
        });

        let hidden_value_vec=vector::borrow(&public_inputs,HC_HIDDEN_CARD_INDEX);
        assert!(!vector::contains(&secret_array,hidden_value_vec), E_ALREADY_PLAYED);
        //verify proof
        //todo: uncomment this
        assert!(groth16_prove::verify_hide_card_proof(public_inputs,proof_a,proof_b,proof_c)==true,E_PROOF_FAILED);   
        assert!(match_state.game_state.game_state==GAME_PLAYER_HIDDEN_MOVE,E_WAITING_FOR_OTHER_PLAYERS);
        //get public inputs
        //0 = hidden value
        //1-11 = cards
        //12 = card num
        //let hidden_value=utils::get_u64_from_vec_le(hidden_value_vec,32);
        let card_count_vec=vector::borrow(&public_inputs,HC_CARDS_COUNT_INDEX);
        let card_count=utils::get_u64_from_vec_le(card_count_vec,1);
         
        let card_scalars=utils::slice(&public_inputs,HC_CARDS_START_INDEX,HC_CARDS_START_INDEX+card_count);
        let cards: vector<u8> =vector::map_ref(&card_scalars, |e| (utils::get_u64_from_vec_le(e,1) as u8) );
        //match cards are same
        let player_cards=player_state.player_cards;
        // std::debug::print<u64>(&512);
        // std::debug::print<vector<u8>>(&cards);
        // std::debug::print<vector<u8>>(&player_cards);
        assert!(comparator::is_equal(&comparator::compare_u8_vector(cards,player_cards)),E_CARDS_MISMATCH);
        //verify same card is not played in show cards
        
        //check rounds match
        assert!(vector::length(&player_state.player_moves)==(match_state.game_state.current_round as u64), E_CANNOT_PLAY_MULTIPLE_CARDS_IN_SAME_ROUND);

        let player_move=PlayerMove{secret: *hidden_value_vec, value: option::none()};
        vector::push_back(&mut player_state.player_moves,player_move);
        //Check if  all players have played cards then update match to show cards
        match_state.game_state.cards_played=match_state.game_state.cards_played+1;
        simple_map::add<address,u8>(&mut match_state.game_state.current_round_moves, player_address, DUMMY_CARD_VALUE);

        if(match_state.game_state.cards_played==match_state.player_count){
            //update state to show cards
            match_state.game_state.game_state=GAME_PLAYER_REVEAL;
            match_state.game_state.cards_played=0;
            match_state.game_state.round_timestamp=timestamp::now_seconds();
            //simple_map::destroy(match_state.game_state.current_round_moves, |_e| {},|_e2| {});
            for (i in 0..vector::length(&match_state.players)){
                let addr=vector::borrow(&match_state.players,i);
                //clear round moves
                let (_a,_val)=simple_map::remove<address,u8>(&mut match_state.game_state.current_round_moves, addr);
            };
        };

        let event =   CardEvent {
            owner: match_state.owner,
            match_address: match_address,
            player_address: player_address,
            round: match_state.game_state.current_round,
            value: option::none(),
        };
         0x1::event::emit(event);
    }

    public entry fun reveal_hidden_card(sender: &signer,owner: address, match_id: u64, public_inputs:  vector<vector<u8>>,
    proof_a: vector<u8>,
    proof_b: vector<u8>,
    proof_c: vector<u8>) acquires MatchState, PlayerState{
        let match_seed=get_resource_seed(owner, match_id,RESOURCE_ADDRESS_SEED);
        let check_resource_address= account::create_resource_address(&owner, match_seed);
        assert!(account::exists_at(check_resource_address), error::permission_denied(E_MATCH_DOES_NOT_EXIST));
        let match_state=borrow_global_mut<MatchState>(check_resource_address);

        let player_address=signer::address_of(sender);
        let seed=get_resource_seed(player_address,match_id,RESOURCE_ADDRESS_SEED_PLAYERS);
        let resource_address=account::create_resource_address(&player_address,seed);
        let player_state=borrow_global_mut<PlayerState>(resource_address);
            

        reveal_card_internal(player_address, public_inputs,proof_a,proof_b,proof_c,check_resource_address, match_state, player_state);
    }

    fun reveal_card_internal(player_address: address, public_inputs:  vector<vector<u8>>,
    proof_a: vector<u8>,
    proof_b: vector<u8>,
    proof_c: vector<u8>, match_address: address,  match_state: &mut MatchState, player_state: &mut PlayerState ){
        //verify proof
        //todo: uncomment this
        assert!(groth16_prove::verify_show_card_proof(public_inputs,proof_a,proof_b,proof_c)==true,E_PROOF_FAILED);   
        assert!(match_state.match_state == MATCH_IN_PROGRESS, E_MATCH_NOT_IN_PROGRESS);
        assert!(match_state.game_state.current_round < match_state.total_rounds-1, E_LAST_ROUND_CANNOT_CALL);

        //check timestamp
        let time_diff=timestamp::now_seconds() - match_state.game_state.round_timestamp ;
        if (time_diff > match_state.max_time_between_moves) {
            //forfeit 
            forfeit_match(match_address,match_state);
            return
        };

        assert!(!simple_map::contains_key(&match_state.game_state.current_round_moves, &player_address),E_ALREADY_PLAYED);
        

        
        assert!(match_state.game_state.game_state==GAME_PLAYER_REVEAL,E_WAITING_FOR_OTHER_PLAYERS);
        //get public inputs
        //verify public inputs
        let hidden_value_vec=vector::borrow(&public_inputs,SC_HIDDEN_CARD_INDEX);
        
        let player_cards=player_state.player_cards;
        let player_move=vector::pop_back(&mut player_state.player_moves);
        assert!(comparator::is_equal(&comparator::compare_u8_vector(*hidden_value_vec,player_move.secret)), E_REVEAL_CARD_MISMATCH);
        
        let card_count_vec=vector::borrow(&public_inputs,SC_CARDS_COUNT_INDEX);
        let card_count=utils::get_u64_from_vec_le(card_count_vec,1);

        let card_value_vec=vector::borrow(&public_inputs,SC_CARD_INDEX );
        let card_value=(utils::get_u64_from_vec_le(card_value_vec,1) as u8);

        let card_scalars=utils::slice(&public_inputs,SC_CARDS_START_INDEX,SC_CARDS_START_INDEX+card_count);
        let cards: vector<u8> =vector::map_ref(&card_scalars, |e| (utils::get_u64_from_vec_le(e,1) as u8) );
        //match cards are same
        assert!(comparator::is_equal(&comparator::compare_u8_vector(cards,player_cards)),E_CARDS_MISMATCH);

        //verify card is in players hand
        assert!(vector::contains(&player_cards,&card_value ), E_REVEAL_CARD_NOT_PRESENT);
        //verify card is not played before
        let played_cards: vector<u8> =vector::map_ref(&player_state.player_moves, |e| {
            let e: &PlayerMove = e;
            *option::borrow(&e.value)
        });
        // std::debug::print<u64>(&609);
        // std::debug::print<vector<u8>>(&played_cards);
        assert!(!vector::contains(&played_cards,&card_value ), E_REVEAL_CARD_PLAYED_AGAIN);
        
        player_move.value=option::some<u8>(card_value);
        vector::push_back(&mut player_state.player_moves, player_move);

       
        match_state.game_state.cards_played=match_state.game_state.cards_played+1;
        simple_map::add<address,u8>(&mut match_state.game_state.current_round_moves, player_address, card_value);

        let round=match_state.game_state.current_round;

        //round_finish_internal(match_address,match_state);

        let event =   CardEvent {
            owner: match_state.owner,
            match_address: match_address,
            player_address: player_address,
            round: round,
            value: option::some(card_value),
        };
         0x1::event::emit(event);
    }

    public entry fun round_finish(owner: address, match_id: u64,) acquires MatchState{
        let match_seed=get_resource_seed(owner, match_id,RESOURCE_ADDRESS_SEED);
        let check_resource_address= account::create_resource_address(&owner, match_seed);
        assert!(account::exists_at(check_resource_address), error::permission_denied(E_MATCH_DOES_NOT_EXIST));
        
        round_finish_internal(check_resource_address);
    }

    public entry fun last_round(owner: address, match_id: u64, player_cards: vector<u8>) acquires MatchState,PlayerState{
        let match_seed=get_resource_seed(owner, match_id,RESOURCE_ADDRESS_SEED);
        let check_resource_address= account::create_resource_address(&owner, match_seed);
        assert!(account::exists_at(check_resource_address), error::permission_denied(E_MATCH_DOES_NOT_EXIST));
        let match_state=borrow_global_mut<MatchState>(check_resource_address);

        last_round_internal(check_resource_address,match_state,player_cards);
    }

    fun last_round_internal(match_address: address, match_state: &mut MatchState,  player_cards: vector<u8>) acquires PlayerState{
        
        assert!(match_state.game_state.current_round==match_state.total_rounds-1, E_CANNOT_FINISH_MATCH);
        
        for (i in 0..vector::length(&match_state.players)) {
            let player_address=vector::borrow(&match_state.players,i);
            let seed=get_resource_seed(*player_address,match_state.match_id,RESOURCE_ADDRESS_SEED_PLAYERS);
            let resource_address=account::create_resource_address(player_address,seed);
            let player_state=borrow_global_mut<PlayerState>(resource_address);
            let card_value=vector::borrow(&player_cards,i);

             //verify card is in players hand
            assert!(vector::contains(&player_state.player_cards,card_value ), E_REVEAL_CARD_NOT_PRESENT);
            //Not already played
            let played_cards: vector<u8> =vector::map_ref(&player_state.player_moves, |e| {
                let e: &PlayerMove = e;
                *option::borrow(&e.value)
            });
            // std::debug::print<u64>(&676);
            // std::debug::print<u8>(card_value);
            // std::debug::print<vector<u8>>(&played_cards);
            assert!(!vector::contains(&played_cards,card_value ), E_REVEAL_CARD_PLAYED_AGAIN);
            //Not add to player moves
            let player_move=PlayerMove{secret: vector[], value: option::some<u8>(*card_value)};
            vector::push_back(&mut player_state.player_moves, player_move);

            match_state.game_state.cards_played=match_state.game_state.cards_played+1;
            simple_map::add<address,u8>(&mut match_state.game_state.current_round_moves, *player_address, *card_value);

        };
      
         //update round
        round_finish_update_internal(match_state);

        //finish match
        match_finish( match_address, match_state);
    }


    #[randomness]
    entry fun round_finish_internal(match_address: address)  acquires MatchState{
        //update match if all players revealed the card
        let match_state=borrow_global_mut<MatchState>(match_address);
        assert!(match_state.game_state.current_round<match_state.total_rounds, E_LAST_ROUND_CANNOT_CALL);
        // assert!(match_state.game_state.cards_played==match_state.player_count, E_ROUND_NOT_FINISHED );

        // let current_round=match_state.game_state.current_round;
        // //update state to hide cards
        // match_state.game_state.game_state=GAME_PLAYER_HIDDEN_MOVE;
        // match_state.game_state.cards_played=0;
        // match_state.game_state.current_round=current_round+1;
        // match_state.game_state.round_timestamp=timestamp::now_seconds();
    
        // //score round
        // let table_card=vector::borrow(&match_state.table_cards,vector::length(&match_state.table_cards)-1);
        // //get players round cards
        // let player_moves:vector<u8> = vector::empty();
        // for (i in 0..vector::length(&match_state.players)){
        //     let addr=vector::borrow(&match_state.players,i);
        //     //clear round moves
        //     let (_a,val)=simple_map::remove<address,u8>(&mut match_state.game_state.current_round_moves, addr);
        //     vector::push_back(&mut player_moves, val);
        // };
        // //score 
        // score_round(match_state, *table_card,player_moves );
        round_finish_update_internal(match_state);
        
        //check match finish
        // if (match_state.game_state.current_round==ROUNDS+1) {
        //     match_finish( match_address, match_state);
        // }else{
        let new_table_card=game_randomness::draw_cards(&mut match_state.deck_cards,1);
        //vector::push_back(&mut match_state.table_cards,(table_card as u8));
        vector::append(&mut match_state.table_cards,new_table_card );
        // };
       
    }

    
    fun round_finish_update_internal(match_state: &mut MatchState){
        assert!(match_state.game_state.cards_played==match_state.player_count, E_ROUND_NOT_FINISHED );
        
        let current_round=match_state.game_state.current_round;
        //update state to hide cards
        match_state.game_state.game_state=GAME_PLAYER_HIDDEN_MOVE;
        match_state.game_state.cards_played=0;
        match_state.game_state.current_round=current_round+1;
        match_state.game_state.round_timestamp=timestamp::now_seconds();
    
        //score round
        let table_card=vector::borrow(&match_state.table_cards,vector::length(&match_state.table_cards)-1);
        //get players round cards
        let player_moves:vector<u8> = vector::empty();
        for (i in 0..vector::length(&match_state.players)){
            let addr=vector::borrow(&match_state.players,i);
            //clear round moves
            let (_a,val)=simple_map::remove<address,u8>(&mut match_state.game_state.current_round_moves, addr);
            vector::push_back(&mut player_moves, val);
        };
        //score 
        // std::debug::print<u64>(&707);
        // std::debug::print<u8>(&match_state.game_state.current_round);
        // std::debug::print<u8>(&match_state.game_state.round_scored);
        score_round(match_state, *table_card,player_moves );
 
    }

    fun score_round(match_state: &mut MatchState, table_card: u8, player_cards: vector<u8>){
        let players=match_state.players;
        let winners=vector::empty<RoundScoring>();
        let first_addr=vector::borrow(&players,0);
        let first_pc=vector::borrow(&player_cards,0);
        vector::push_back(&mut winners,RoundScoring{player: *first_addr, diff: utils::get_card_difference(table_card, *first_pc)});
        assert!(match_state.game_state.round_scored == match_state.game_state.current_round-1, E_ALREADY_SCORED);
        //std::debug::print<u64>(&10000);
        //std::debug::print<u8>(&utils::get_card_difference(table_card, *first_pc));
        for (i in 1..vector::length(&players)){
            let second_addr=vector::borrow(&players,i);
            let second_pc=vector::borrow(&player_cards,i);

            let winner =vector::borrow_mut(&mut winners, 0);
            let diff=utils::get_card_difference(table_card, *second_pc);
        
            if (diff < winner.diff){
                //new array
                winners=vector::singleton(RoundScoring{player: *second_addr,diff});
            }else  if (diff == winner.diff){
                //append
                vector::push_back(&mut winners,RoundScoring{player: *second_addr, diff: diff});
            };
            
        };

        let winner_point = if (vector::length(&winners) == 1){
            3
        }else{
            1
        };

        for (i in 0..vector::length(&winners)){
            let points=simple_map::borrow_mut(&mut match_state.player_points, &vector::borrow(&winners,i).player);
            *points=*points + winner_point;
        };
        match_state.game_state.round_scored=match_state.game_state.current_round;
    }
 
    
    fun match_finish(match_address:address, match_state: &mut MatchState) {
        assert!(match_state.match_state != MATCH_END, E_MATCH_ALREADY_ENDED);

        match_state.game_state.game_state=GAME_END;
        match_state.match_state=MATCH_END;

        //calculate winner(s)
        let first_addr=vector::borrow(&match_state.players,0);
        let first_points=simple_map::borrow(&match_state.player_points, first_addr);
        
        let winners: vector<MatchScoring> =vector::empty();
        vector::push_back(&mut winners,MatchScoring{player: *first_addr, points: *first_points});
        for (i in 1..vector::length(&match_state.players)){
            let addr=vector::borrow(&match_state.players,i);
            let points=simple_map::borrow(&match_state.player_points, addr);

            let winner =vector::borrow_mut(&mut winners, 0);
            //Add to array if points are same
            //New array is points are more
            if (*points > winner.points){
                //new array
                winners=vector::singleton(MatchScoring{player: *addr,points: *points});
            }else if (*points == winner.points){
                //append
                vector::push_back(&mut winners,MatchScoring{player: *addr, points: *points});
            };
        };

        match_state.winners=vector::map_ref(&winners, |e| {
            let e: &MatchScoring=e;
            e.player
        });

        // std::debug::print<vector<address>>(&match_state.winners);
        disburse_money(match_state);

        let event = MatchEvent {
            match_id: match_state.match_id,
            owner: match_state.owner,
            match_address: match_address,
            match_state: match_state.match_state,
            game_state: match_state.game_state.game_state,
        };
        0x1::event::emit(event);
    }

    fun disburse_money( match_state: &mut MatchState){
        let coin_address=get_coin_address();
        let pot_value=mtc_coin::balance(match_state.pool_address,coin_address);
        //disburse money
        if(pot_value > 0 ){
            let fees=FEE_BASIS_POINTS * pot_value/ 10000;

            let winner_count=vector::length(&match_state.winners);
            let winner_pot_value=(pot_value-fees) / winner_count;
            let signer_cap=account::create_signer_with_capability(&match_state.pool_cap);
            for (i in 0..winner_count){
                let addr=vector::borrow(&match_state.winners,i);
                //sender is resrouce signer
                mtc_coin::transfer_to(&signer_cap, coin_address, *addr, winner_pot_value);
            };
            //Transfer fees to treasury
            mtc_coin::transfer_to(&signer_cap, coin_address, @treasury_addr, fees);
        };
    }

     
    
    fun forfeit_match(match_address: address, match_state: &mut MatchState){
        match_state.match_state=MATCH_FORFEIT;

        //std::debug::print<u64>(&simple_map::length(&match_state.game_state.current_round_moves));
        if(simple_map::length(&match_state.game_state.current_round_moves) != 0){
            let winners: vector<address> = vector::empty();
            for (i in 0..vector::length(&match_state.players)){
                let addr=vector::borrow(&match_state.players,i);
                if(simple_map::contains_key<address,u8>(&match_state.game_state.current_round_moves, addr)){
                    vector::push_back(&mut winners, *addr);
                };
            };

            match_state.winners=winners;
        }else{
            match_state.winners=match_state.players;
        };

        disburse_money(match_state);

        let event = MatchEvent {
            match_id: match_state.match_id,
            owner: match_state.owner,
            match_address: match_address,
            match_state: match_state.match_state,
            game_state: match_state.game_state.game_state,
        };
        0x1::event::emit(event);
    }

    //Player 1 plays card
    //Player 2 plays card
    //Player 1 reveals card
    //Player 2 reveals card. Round finishes
        //Update scoring
    //Finish match and distribute winnings if any
    #[test_only]
    friend closest_match::game_tests;
 
    #[test_only]
    public fun init_module_for_testing(admin: &signer) {
        init_module(admin)
    }

    #[test_only]
    public fun setup_match_test(player1: &signer, player_count: u8,move_time: u64,rounds: u8,pot_value: u64, ) acquires MatchId{
        setup_match(player1,player_count,move_time,rounds,pot_value);
    }

    #[test_only]
    public fun join_match_test(player1: &signer, owner: address, match_id: u64) acquires MatchState{
        join_match(player1,owner,match_id);
    }

    #[test_only]
    public fun draw_cards_test(  owner: address, match_id: u64) 
    acquires MatchState,PlayerState
    {
        //let match_seed=get_resource_seed(owner, match_id,RESOURCE_ADDRESS_SEED);
        //let check_resource_address= account::create_resource_address(&owner, match_seed);

        draw_cards_internal(owner,match_id);
        
    }

    #[test_only]
    public fun round_finish_test(  owner: address, match_id: u64) 
    acquires MatchState
    {
        //let match_seed=get_resource_seed(owner, match_id,RESOURCE_ADDRESS_SEED);
        //let check_resource_address= account::create_resource_address(&owner, match_seed);

        round_finish(owner,match_id);
        
    }

     #[test_only]
    public fun score_round_test(  owner: address, match_id: u64) 
    acquires MatchState
    {
        let match_seed=get_resource_seed(owner, match_id,RESOURCE_ADDRESS_SEED);
        let match_address= account::create_resource_address(&owner, match_seed);
        let match_state=borrow_global_mut<MatchState>(match_address);
        score_round(match_state,30,vector[22,41,19]);
        
    }

     #[test_only]
    public fun last_round_test(  owner: address, match_id: u64, cards: vector<u8>) 
    acquires MatchState, PlayerState
    {
        //let match_seed=get_resource_seed(owner, match_id,RESOURCE_ADDRESS_SEED);
        //let check_resource_address= account::create_resource_address(&owner, match_seed);

        last_round(owner,match_id,vector[]);
        
    }

    #[test_only]
    public fun play_hidden_card_test(sender: &signer, owner: address, match_id: u64, public_inputs:  vector<vector<u8>>,
    proof_a: vector<u8>,
    proof_b: vector<u8>,
    proof_c: vector<u8>) acquires MatchState, PlayerState{
        play_hidden_card(sender,owner,match_id,public_inputs,proof_a,proof_b,proof_c);
    }

    #[test_only]
    public fun reveal_hidden_card_test(sender: &signer, owner: address, match_id: u64, public_inputs:  vector<vector<u8>>,
    proof_a: vector<u8>,
    proof_b: vector<u8>,
    proof_c: vector<u8>) acquires MatchState, PlayerState{
        reveal_hidden_card(sender,owner,match_id,public_inputs,proof_a,proof_b,proof_c);
    }
    
    // #[test_only]
    // public fun debug_match_state(owner: address,match_id: u64) acquires MatchState{

    // }
    
    #[test_only]
    fun setup_game_for_test(
        admin: &signer
    ){
        init_module_for_testing(admin);
        mtc_coin::setup_test(admin);
    }
 
       
}
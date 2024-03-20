import { InputTransactionData } from "@aptos-labs/wallet-adapter-react";
import { AptosClient } from "./sdk"
import {Buffer} from 'buffer';
import { GrothProofOutput } from "../zk/groth";
import { CommittedTransactionResponse, PendingTransactionResponse } from "@aptos-labs/ts-sdk";
import { DUMMY_CARD_VALUE } from "../utils";
export const MATCH_SETUP = 1; //match setup
// const MATCH_PLAYER_JOIN: u8 = MATCH_SETUP+1;
export const MATCH_START= 2 ;
export const MATCH_IN_PROGRESS= 3 ;
export const MATCH_END= 4 ;
export const MATCH_FORFEIT= 5 ;

export const GAME_INIT=10; //draw cards
export const GAME_PLAYER_HIDDEN_MOVE= 11; //Player move
export const GAME_PLAYER_REVEAL=12;
export const GAME_END=13;

export const CARD_COUNT=6;

export enum MenuOption{
    Home,
    Start,
    Join,
    List,
    Game,
}

export interface AllPlayerStates{
    OtherPlayerState: PlayerState[],
    LoggedInPlayerState: PlayerState | undefined,
}

export interface TempGameState{
    menuOption: MenuOption,
    matchId: string | undefined,
    ownerAddress: string | undefined,
    askToJoin: boolean,
}


export interface AptosMatchState {
    match_id: string,
    owner: string,
    player_count: number,
    max_time_between_moves: string, //forfeit if player leaves before match finishes
    deck_cards: string,
    table_cards: string,
    //active_player: string[],
    players: string,
    pot_value: string,
    player_points: Map<string,string>,
    match_state: number,
    total_rounds: number,
    //player_state: simple_map::SimpleMap<address, PlayerState>, //could use map
    game_state: GameState,
    winners: string[],
    //signer cap
    //pool_cap:string,
    pool_address: string,
} 

export interface MatchState {
    match_id: string,
    owner: string,
    player_count: number,
    max_time_between_moves: string, //forfeit if player leaves before match finishes
    deck_cards: number[],
    table_cards: number[],
    //active_player: string[],
    players: string,
    pot_value: string,
    player_points: Map<string,string>,
    match_state: number,
    total_rounds: number,
    //player_state: simple_map::SimpleMap<address, PlayerState>, //could use map
    game_state: GameState,
    winners: string[],
    //signer cap
    //pool_cap:string,
    pool_address: string,
} 

export interface GameState{
    game_state: number,
    current_player: number,
    current_round: number,
    cards_played: number,
    current_round_moves: Map<string,number>,
    //current round timestamp
    round_timestamp: string,
}


export interface AptosPlayerState{
    player_address: string,
    player_moves: PlayerMove[],
    player_cards: string,
}

export interface PlayerState{
    player_address: string,
    player_moves: PlayerMove[],
    player_cards: number[],
}

export interface PlayerMove{
    secret: string,
    value:  {
        vec: string,
    },   
}



export const getMatchDataByAddress=async({address, aptosClient}:{address: string, aptosClient: AptosClient}):Promise<MatchState | undefined>=>{
    return await aptosClient.getResourceData({address,resourceName:"MatchState"});
}

export const getMatchDataById=async({owner, matchId, aptosClient}:{matchId: string, owner: string, aptosClient: AptosClient}):Promise<MatchState | undefined>=>{
    const address=await aptosClient.getGameAddress({gameOwner: owner,matchId });
    // console.log("address",address);
    if(address)
    {
        const d=await aptosClient.getResourceData<AptosMatchState>({address,resourceName:"MatchState"});
        if(d){
           
            const newState= {
                deck_cards: Array.from(new Uint8Array(Buffer.from(d.table_cards.substring(2),"hex"))),
                game_state: {
                    cards_played: d.game_state.cards_played,
                    current_player: d.game_state.current_player,
                    current_round: d.game_state.current_round,
                    //@ts-ignore
                    current_round_moves: new Map(d.game_state.current_round_moves.data.map(m=>[m.key,m.value])),
                    game_state: d.game_state.game_state,
                    round_timestamp: d.game_state.round_timestamp,
                } as GameState,
                match_id: d.match_id,match_state: d.match_state,
                max_time_between_moves: d.max_time_between_moves,owner: d.owner,
                player_count: d.player_count,
                //@ts-ignore
                player_points: new Map(d.player_points.data.map(m=>[m.key,m.value])),
                players:d.players,
                pool_address: d.pool_address,
                pot_value: d.pot_value,
                total_rounds: d.total_rounds,
                table_cards: Array.from(new Uint8Array(Buffer.from(d.table_cards.substring(2),"hex"))),
                winners: d.winners
            } as MatchState;
            return newState;
        }
    } 
    return undefined;
}

export const getCoinBalance=async({address,aptosClient,coinAddress}:{coinAddress: string, aptosClient: AptosClient, address: string}):Promise<number>=>{
    const balance=await aptosClient.getCoinBalance({coinAddress: coinAddress,userAddress: address});
         
    return balance
}


export const getPlayerStateData=async({matchId,playerAddress, aptosClient}:
    {playerAddress: string, matchId: string, aptosClient: AptosClient}): Promise<PlayerState | undefined>=>{
        // aptosClient.getGameAddress
    const address=await aptosClient.getPlayerStateAddress({playerAddress: playerAddress,matchId});
    console.log("addr",playerAddress,address);
    if(address)
    {
        const d=await aptosClient.getResourceData<AptosPlayerState>({address,resourceName:"PlayerState"});
        if(d){
            return {player_address: d.player_address, 
                player_moves: d.player_moves,
                 player_cards: Array.from(new Uint8Array(Buffer.from(d.player_cards.substring(2),"hex")))
                 } as PlayerState
        }
    } 
    return undefined
}

export const loadAllPlayerStatesByMatchState=async({aptosClient,matchState,playerAddress}:{playerAddress?: string, matchState: MatchState, aptosClient: AptosClient}):Promise<PlayerState[]>=>{
    const allPlayers: PlayerState[]=[];
    
    for(const a of matchState.players){
        const data=await getPlayerStateData({matchId: matchState.match_id,aptosClient, playerAddress: a});
        if(data!==undefined){
            allPlayers.push({...data, player_address:a} as PlayerState);
        }
    }
    // const playerData=playerAddress ? allPlayers.filter((m)=> m.player_address===playerAddress).length > 0 ? 
    //allPlayers.filter((m)=> m.player_address===playerAddress)[0] : undefined : undefined;
    // return {LoggedInPlayerState: playerData ,
    //      OtherPlayerState: allPlayers.filter((m)=> m.player_address===playerAddress).filter(m=> m.player_address !==playerAddress)
    //     } as AllPlayerStates;
    return allPlayers;
}

//Txns
//Airdrop
export const submitAirdropTxn=async({aptosClient,amount,toAddress,signAndSubmitTransaction,
    initCallBack,failureCallback}:{aptosClient: AptosClient, 
    amount: string,
    toAddress: string,
    signAndSubmitTransaction:(transaction: InputTransactionData) => Promise<any>,
    initCallBack: ()=>void,
    failureCallback: ()=>void,
}):Promise<CommittedTransactionResponse | undefined>=>{
    const fnc="airdrop";
    const payload={ data:{
        function: aptosClient.getCoinModule()+"::"+fnc,
        functionArguments:[toAddress,  amount]
    }} as InputTransactionData;
    return await aptosClient.signAndSubmitTxn({payload, signAndSubmitTransaction,initCallBack,failureCallback});
    
}


//   player_count: u8, move_time: u64, pot_value: u64
export const submitGameStartTxn=async({moveTime,playerCount,rounds,aptosClient,potValue, initCallBack,failureCallback, signAndSubmitTransaction}:{
    aptosClient: AptosClient, 
    playerCount: string,
    moveTime: string,
    rounds: string,
    potValue: string,
    initCallBack: ()=>void,
    failureCallback: ()=>void,
    signAndSubmitTransaction:(transaction: InputTransactionData) => Promise<any>
}):Promise<CommittedTransactionResponse | undefined>=>{
    const fnc="setup_match";
    return await aptosClient.signAndSubmitTxn({payload:{
        data:{
            function: aptosClient.getGameModule()+"::"+fnc,
            functionArguments:[playerCount, moveTime,rounds, potValue]
        }
    } as InputTransactionData,initCallBack,failureCallback, signAndSubmitTransaction});
    
}

//join_match( owner: address, match_id: u64,) 
export const submitJoinMatchTxn=async({owner,matchId,aptosClient,initCallBack,failureCallback, signAndSubmitTransaction}:{
    aptosClient: AptosClient, 
    matchId: string,
    owner: string,
    initCallBack: ()=>void,
    failureCallback: ()=>void,
    signAndSubmitTransaction:(transaction: InputTransactionData) => Promise<any>
}):Promise<CommittedTransactionResponse | undefined>=>{
    const fnc="join_match";
    return await aptosClient.signAndSubmitTxn({payload:{
        data:{
            function: aptosClient.getGameModule()+"::"+fnc,
            functionArguments:[owner,matchId ]
        }
    } as InputTransactionData,initCallBack,failureCallback, signAndSubmitTransaction});
    
}

export const drawCardsTxn=async({owner,matchId,aptosClient,initCallBack,failureCallback, signAndSubmitTransaction}:{
    aptosClient: AptosClient, 
    matchId: string,
    owner: string,
    initCallBack: ()=>void,
    failureCallback: ()=>void,
    signAndSubmitTransaction:(transaction: InputTransactionData) => Promise<any>
}):Promise<CommittedTransactionResponse | undefined>=>{
    const fnc="draw_cards";
    return await aptosClient.signAndSubmitTxn({payload:{
        data:{
            function: aptosClient.getGameModule()+"::"+fnc,
            functionArguments:[owner,matchId ]
        }
    } as InputTransactionData,initCallBack,failureCallback, signAndSubmitTransaction});
    
}

export const roundFinishTxn=async({owner,matchId,aptosClient,initCallBack,failureCallback, signAndSubmitTransaction}:{
    aptosClient: AptosClient, 
    matchId: string,
    owner: string,
    initCallBack: ()=>void,
    failureCallback: ()=>void,
    signAndSubmitTransaction:(transaction: InputTransactionData) => Promise<any>
}):Promise<CommittedTransactionResponse | undefined>=>{
    const fnc="round_finish";
    return await aptosClient.signAndSubmitTxn({payload:{
        data:{
            function: aptosClient.getGameModule()+"::"+fnc,
            functionArguments:[owner,matchId ]
        }
    } as InputTransactionData,initCallBack,failureCallback, signAndSubmitTransaction});
    
}


export const lastRoundTxn=async({owner,cards, matchId,aptosClient,initCallBack,failureCallback, signAndSubmitTransaction}:{
    aptosClient: AptosClient, 
    matchId: string,
    owner: string,
    cards: number[],
    initCallBack: ()=>void,
    failureCallback: ()=>void,
    signAndSubmitTransaction:(transaction: InputTransactionData) => Promise<any>
}):Promise<CommittedTransactionResponse | undefined>=>{
    const fnc="last_round";
    return await aptosClient.signAndSubmitTxn({payload:{
        data:{
            function: aptosClient.getGameModule()+"::"+fnc,
            functionArguments:[owner,matchId,cards ]
        }
    } as InputTransactionData,initCallBack,failureCallback, signAndSubmitTransaction});
    
}
// owner: address, match_id: u64, public_inputs:  vector<vector<u8>>,
//     proof_a: vector<u8>,
//     proof_b: vector<u8>,
//     proof_c: vector<u8>)
export const submitPlayCardTxn=async({initCallBack,failureCallback,signAndSubmitTransaction,aptosClient,matchId,owner,secretInput,}:{
    aptosClient: AptosClient, 
    owner: string,
    matchId: string,
    secretInput : GrothProofOutput,
    initCallBack: ()=>void,
    failureCallback: ()=>void,
    signAndSubmitTransaction:(transaction: InputTransactionData) => Promise<any>}):Promise<CommittedTransactionResponse | undefined>=>{
    const fnc="play_hidden_card";
    return await aptosClient.signAndSubmitTxn({payload: {
        data:{
            function: aptosClient.getGameModule()+"::"+fnc,
            functionArguments:[owner, matchId,secretInput.signals,secretInput.proof[0],secretInput.proof[1],secretInput.proof[2],]
        }
    } as InputTransactionData,initCallBack,failureCallback, signAndSubmitTransaction});
     
}

export const submitRevealCardTxn=async({initCallBack,failureCallback,signAndSubmitTransaction,aptosClient,matchId,owner,secretInput,}:{
    aptosClient: AptosClient, 
    owner: string,
    matchId: string,
    secretInput : GrothProofOutput,
    initCallBack: ()=>void,
    failureCallback: ()=>void,
    signAndSubmitTransaction:(transaction: InputTransactionData) => Promise<any>}):Promise<CommittedTransactionResponse | undefined>=>{
    const fnc="reveal_hidden_card";
    return await aptosClient.signAndSubmitTxn({payload: {
        data:{
            function: aptosClient.getGameModule()+"::"+fnc,
            functionArguments:[owner, matchId,secretInput.signals,secretInput.proof[0],secretInput.proof[1],secretInput.proof[2],]
        }
    } as InputTransactionData,initCallBack,failureCallback, signAndSubmitTransaction});
     
}
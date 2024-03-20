import { GAME_PLAYER_HIDDEN_MOVE, GAME_PLAYER_REVEAL, MATCH_END, MATCH_IN_PROGRESS, MATCH_SETUP, MATCH_START, MatchState, PlayerState } from "./aptos/data";
import {Buffer} from 'buffer';
export const PLAYER_NOT_PART_OF_GAME_MSG="Game has already started!";
export const DEFAULT_AMOUNT = 1_000_000_000;
export const DUMMY_CARD_VALUE=52;

export const getSalt=(address: string):string=>{
    return getStorageValue(address, getRandValue());
}


export const getStorageValue=(key:string,defValue: string): string=>{
    if(localStorage.getItem(key))
        return localStorage.getItem(key)!;
    setStorageValue(key,defValue)
    return defValue;
}

export const setStorageValue=(key: string, value: string)=>{
    localStorage.setItem(key,value);
}

const getRandValue=():string=>{
    const array = new Uint8Array(32);
    crypto.getRandomValues(array);
    let finalVal= 0n;
    let inc=1n;
    for(const a of array){
        finalVal=finalVal+BigInt(a)*inc;
         inc=inc<<8n;
    }
    return finalVal.toString();
}

export const IsPlayerPartOfGame=({loggedInAccount,matchState}:{matchState : MatchState,loggedInAccount : string}):boolean=>{
    for(const a of matchState.players)
            if(a===loggedInAccount)
                return true;
    return false;
}

export const IsMatchJoinPending=({matchState}:{matchState: MatchState}):boolean=>{
    return matchState.match_state === MATCH_SETUP;
}

export const IsMatchInProgress=({matchState}:{matchState: MatchState}):boolean=>{
    return matchState.match_state === MATCH_IN_PROGRESS;
}

export const IsMatchEnd=({matchState}:{matchState: MatchState}):boolean =>{
    return matchState.match_state === MATCH_END;
}

export const getCurrentDeckCard=({matchState}:{matchState : MatchState}):number=>{
    return matchState.table_cards[matchState.table_cards.length-1];
}

export const getPastDeckCard=({matchState}:{matchState : MatchState}):number[]=>{
    if(matchState.match_state === MATCH_IN_PROGRESS)
    return matchState.table_cards.slice(0,matchState.table_cards.length-1);
    return  matchState.table_cards;
}

export const IsRoundFinished=({matchState}:{matchState : MatchState}):boolean=>{
    if(matchState.game_state.game_state===GAME_PLAYER_REVEAL && matchState.game_state.current_round_moves.size ===
        matchState.player_count){
            return true;
        }
    return false;
}

export const getMatchStatus=({matchState}:{matchState : MatchState}):string=>{
    // console.log("getmatchstatus",matchState.match_state);
    if(matchState.match_state === MATCH_SETUP){
        return "Waiting for players to join";
    }
    if(matchState.match_state === MATCH_START){
        return "Waiting to draw cards";
    }
    if(matchState.match_state === MATCH_IN_PROGRESS){
        return "In Progress";
    }
    if(matchState.match_state === MATCH_END){
        return "Winners declared";
    }
    return "Match Forfeited";
    
}

export const getAvailableCards=({playerStates,playerAddress}:{playerStates: PlayerState[], playerAddress: string}):string[]=>{
    const playerState=playerStates.filter(p=>p.player_address===playerAddress);
    if(playerState.length>0){
        const playedCards=playerState[0].player_moves.map(m=>""+getPlayerMoveCard(m.value.vec));
        const availableCards=playerState[0].player_cards.filter(m=>playedCards.indexOf(""+m)<0).map(v=>""+v);
        return availableCards;
    }
    return [];
}

export const getPlayerPlayedCard=({playerStates,currentRound,matchState, playerAddress,currentPlayerAddress}:
    {playerStates:PlayerState[],matchState: MatchState, currentRound: number,playerAddress: string,currentPlayerAddress: string}): string | undefined=>{
    for(const p of playerStates){
        if(p.player_address === playerAddress && p.player_moves.length>currentRound){
            if(p.player_moves[currentRound]){
                const v= getPlayerMoveCard(p.player_moves[currentRound].value.vec);
                if(v===DUMMY_CARD_VALUE ){
                    if( currentPlayerAddress === playerAddress)
                        return getPlayedCard({address: currentPlayerAddress, matchState, round: currentRound})
                    return ""+DUMMY_CARD_VALUE;
                }else{
                    return ""+v;
                }
            }
        }
    }
    return undefined;
}

const getPlayerMoveCard=(val : string): number=>{
    if(val.substring(2).length>0)
        return Array.from(new Uint8Array(Buffer.from(val.substring(2),"hex")))[0]
    return DUMMY_CARD_VALUE;
}

export const storePlayedCard=({address,matchState,playedCard,round}:{matchState: MatchState, playedCard: string,address :string,round: number})=>{
    const key=matchState.match_id+"_"+address+"_"+round;
    setStorageValue(key,playedCard);
}

export const getPlayedCard=({address,matchState,round}:{matchState: MatchState,round: number, address :string}):string=>{
    const key=matchState.match_id+"_"+address+"_"+round;
    return getStorageValue(key,"52");
}

export const IsPlayCardAvailable=({playerAddress,matchState}:{playerAddress: string, matchState: MatchState}):boolean=>{
    return matchState.game_state.game_state===GAME_PLAYER_HIDDEN_MOVE && !matchState.game_state.current_round_moves.has(playerAddress)
}

export const IsRevealCardAvailable=({playerAddress,matchState}:{playerAddress: string, matchState: MatchState}):boolean=>{
    return matchState.game_state.game_state===GAME_PLAYER_REVEAL && !matchState.game_state.current_round_moves.has(playerAddress)
}

export const wrapString=(str: string, len: number=6) : string=>{
    return str.length>len*2 ? str.substring(0,len)+".."+str.substring(str.length-len, str.length) : str;
}

export const getPlayerPoints=({matchState,playerAddress}:{matchState: MatchState, playerAddress: string}):number=>{
    for( const  a of matchState.player_points.keys()){
        if(playerAddress===a)
            return +matchState.player_points.get(a)!;
    }
    return 0;
}


export const IsLastRound=({matchState}:{matchState: MatchState}):boolean=>{
    if(matchState.match_state===MATCH_IN_PROGRESS &&  matchState.game_state.current_round === matchState.total_rounds-1)
    return true;
 return false;
}

export const getMatchUrl=({matchId,ownerAddress}:{matchId: string, ownerAddress: string})=>{
    //@ts-ignore
    const baseUrl=window.PUBLIC_URL;
    const gameUrl = window.location.origin +
    "" +
    baseUrl +
    `?matchId=${matchId}`
    +
    `&owner=${ownerAddress}`;
    return gameUrl;
}

export const IsWinner=({address,matchState}:{matchState: MatchState, address: string}): boolean=>{
    if(matchState.match_state > MATCH_IN_PROGRESS){
        return matchState.winners.filter(m=>m===address).length>0 ? true :false;
    }
    return false;
}

export const getBaseUrl=()=>{
    //@ts-ignore
    return window.PUBLIC_URL;
}
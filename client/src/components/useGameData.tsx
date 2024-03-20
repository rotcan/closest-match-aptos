import React, { Dispatch, SetStateAction, createContext, useContext, useEffect, useState } from "react"
import { MATCH_IN_PROGRESS, MatchState, MenuOption, PlayerState, TempGameState, getMatchDataById, getPlayerStateData, loadAllPlayerStatesByMatchState } from "../aptos/data"
import { AptosClient } from "../aptos/sdk";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import useLoading from "../helper/loading/useLoading";
const objectHash = require('object-hash');

type GameDataContextType={
    matchState : MatchState | undefined,
    setMatchState : Dispatch<SetStateAction<MatchState  | undefined>>,
    tempGameState: TempGameState ,
    setTempGameState: Dispatch<SetStateAction<TempGameState >>,
    aptosClient: AptosClient | undefined,
    // loggedInPlayerState: PlayerState | undefined,
    // setLoggedInPlayerState: Dispatch<SetStateAction<PlayerState | undefined>>,
    coinAddress: string | undefined,
    allPlayerStates: PlayerState[],
    moveEndTime: Date |undefined,
    setAllPlayerStates: Dispatch<SetStateAction<PlayerState[]>>,
    lastTxnVersion: string | undefined,
    matchAddress: string | undefined,
}

const getDefaultTempState=(): TempGameState=>{
    return {menuOption: MenuOption.Home, matchId : undefined, ownerAddress: undefined,askToJoin:false}
}

const GameDataContext=createContext({
    matchState: undefined,
    setMatchState : ()=>{},
    tempGameState: getDefaultTempState(),
    setTempGameState: ()=>{},
    // loggedInPlayerState: undefined,
    allPlayerStates: [],
    // setLoggedInPlayerState: ()=>{},
    setAllPlayerStates: ()=>{},
    aptosClient: undefined,
    coinAddress: undefined,
    moveEndTime: undefined,
    lastTxnVersion: undefined,
    matchAddress: undefined,
} as GameDataContextType);

interface Props{
    children: React.ReactNode
}

export const GameDataProvider: React.FC<Props>=({children})=>{
    const [matchState,setMatchState]=useState<MatchState | undefined>();
    const [tempGameState,setTempGameState]=useState<TempGameState>(getDefaultTempState());
    // const [loggedInPlayerState,setLoggedInPlayerState]=useState<PlayerState | undefined>();
    const [allPlayerStates,setAllPlayerStates]=useState<PlayerState[]>([]);
    const [coinAddress,setCoinAddress]=useState<string| undefined>();
    const {account}=useWallet();
    const [aptosClient,setAptosClient]=useState<AptosClient>();
    const [moveEndTime,setMoveEndTime]=useState<Date | undefined>();
    const [count,setCount]=useState<number>(0);
    const [lastTxnVersion,setLastTxnVersion]=useState<string | undefined>();
    const [matchAddress,setMatchAddress]=useState<string|undefined>();
    const {setLoading}=useLoading();
    useEffect(()=>{
         if(process.env.REACT_APP_MODULE_ADDRESS && process.env.REACT_APP_NETWORK &&
            process.env.REACT_APP_GRAPHQL_INDEXER){
             setAptosClient(new AptosClient({moduleAddress: process.env.REACT_APP_MODULE_ADDRESS, network: process.env.REACT_APP_NETWORK,
            indexerUrl: process.env.REACT_APP_GRAPHQL_INDEXER}));
          }

       
    
    },[process.env.REACT_APP_MODULE_ADDRESS,process.env.REACT_APP_NETWORK])

    const loadGameData=async()=>{
       if(tempGameState && tempGameState.matchId!==undefined && tempGameState.ownerAddress && aptosClient){
            const matchData=await getMatchDataById({aptosClient,matchId: tempGameState.matchId,owner: tempGameState?.ownerAddress})
            console.log("loadGameData tempGameState",tempGameState);
            if(matchData){
                const matchAddr=matchAddress ?? await aptosClient.getGameAddress({gameOwner : tempGameState?.ownerAddress,matchId: tempGameState.matchId});
                if(!matchAddress || matchAddress!==matchAddr)
                    setMatchAddress(matchAddr)
                
                //update version
                try{
                    //const latestVersion=await aptosClient.getLatestMatchTxn({matchAddress: matchAddr!});
                    const hash=objectHash(matchData);
                    if(hash && (!lastTxnVersion || lastTxnVersion!==hash)){
                        console.log("lastTxnVersion",lastTxnVersion,"latestVersion",hash)
                        setLastTxnVersion(hash)
                        //Wait 1 sec to remove loading
                        setTimeout(()=>{setLoading(false)},1e3);
                    }
                }catch(e){

                }

                const allPlayersData=await loadAllPlayerStatesByMatchState({aptosClient,matchState:matchData,playerAddress:account?.address})
                // setLoggedInPlayerState(allPlayersData.LoggedInPlayerState);
                setAllPlayerStates(allPlayersData);
                //console.log("allPlayerStates",allPlayersData);
                if(matchData){
                    // console.log("matchData",matchData);
                    if(matchData.match_state === MATCH_IN_PROGRESS){
                        const startTime=matchData.game_state.round_timestamp;
                        const diff=matchData.max_time_between_moves;
                        const endTime=(BigInt(startTime) + BigInt(diff) )*1000n;
                        // console.log("endTime",+endTime.toString(),new Date(+endTime.toString()));
                        setMoveEndTime(new Date(+endTime.toString()))
                    }
                    setMatchState(matchData);
                }
                
            }
           
        }

    }

    const loadCoinAddress=async()=>{
        if(aptosClient && !coinAddress){
            const coinAddress=await aptosClient.getCoinAddress();
            setCoinAddress(coinAddress);
        }
    }

    useEffect(()=>{
        const timer = setTimeout(() => {
            // console.log("useEffect useGameData")
            if(tempGameState && aptosClient)
                loadGameData();
            setCount(count+1)
        }, 10e3)
        return () => clearTimeout(timer) 
    },[count, ])

    useEffect(()=>{
        loadCoinAddress();
        loadGameData();
          
            //load states
        
    },[tempGameState,account,aptosClient])

    const value={matchState,setMatchState,lastTxnVersion,matchAddress,coinAddress, moveEndTime, tempGameState,setTempGameState,aptosClient, allPlayerStates, setAllPlayerStates};
    return (
        <GameDataContext.Provider  value={value}>{children}</GameDataContext.Provider>
    )
}

const useGameData=()=>{
    const context=useContext(GameDataContext);
    if(!context){
        throw new Error("useGameData must be called within game data provider");
    }
    return context;
}

export default useGameData;
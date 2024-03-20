import { Col, Row, Image, Button } from "antd";
import useGameData from "./useGameData";
import { DUMMY_CARD_VALUE, IsLastRound, IsRoundFinished, getAvailableCards, getCurrentDeckCard, getPastDeckCard, getPlayerPlayedCard } from "../utils";
import { MATCH_IN_PROGRESS, MATCH_SETUP, MATCH_START, drawCardsTxn, lastRoundTxn, roundFinishTxn } from "../aptos/data";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import useLoading from "../helper/loading/useLoading";
import { useEffect } from "react";

const images = require.context('../cards', true);  /* This is the key line 1 */

interface Props{
  
}
const Deck = (props: Props) => {

    const {allPlayerStates,aptosClient,matchState}=useGameData();
    const { signAndSubmitTransaction,account } = useWallet();
    const {setLoading}=useLoading();
    
    const isMatchStarted=():boolean=>{
        return matchState && matchState.match_state === MATCH_IN_PROGRESS ? true: false;
    }

    const canDrawCards=():boolean=>{
        
        return matchState && matchState.match_state === MATCH_START ? true : false;
    }

    const drawCards=async()=>{
        if(aptosClient && matchState)  {
            const response = await drawCardsTxn({
                aptosClient, matchId: matchState?.match_id, owner: matchState?.owner,
                signAndSubmitTransaction,failureCallback: ()=>{setLoading(false)},
                initCallBack: ()=>{setLoading(true)}
            });
            // console.log("draw cards response", response);
        }
         
    }
    
    const submitRoundFinish=async()=>{
        if(aptosClient && matchState){
            const response=await roundFinishTxn({
                aptosClient,matchId: matchState.match_id, owner: matchState.owner,
                signAndSubmitTransaction,failureCallback: ()=>{setLoading(false)},
                initCallBack: ()=>{setLoading(true)},
            })

            // console.log("round finish response",response);
        }
    }

    
    const submitLastRound=async()=>{
        if(aptosClient && matchState){
            const allAvailableCards:number[]=[];
            for(const p of allPlayerStates){
                const c=getAvailableCards({
                    playerAddress: p.player_address,
                    playerStates: allPlayerStates
                })
                allAvailableCards.push(...c.map(m=>+m));
            }
            const response=await lastRoundTxn({
                aptosClient,matchId: matchState.match_id, owner: matchState.owner,
                cards: allAvailableCards,
                signAndSubmitTransaction,failureCallback: ()=>{setLoading(false)},
                initCallBack: ()=>{setLoading(true)}
            })

            // console.log("round finish response",response);
        }
    }


    const getCard=(index : number)=>{
        if(account && matchState && allPlayerStates){
            const card=getPlayerPlayedCard({
                currentPlayerAddress: account.address,
                currentRound: matchState.game_state.current_round,
                //currentRound: matchState.game_state.current_round,
                matchState: matchState,
                playerAddress: matchState.players[index],
                playerStates: allPlayerStates
            })
            if (card===""+ DUMMY_CARD_VALUE)
                return "back.jpg";
            // console.log("card",card)
            if(card!==undefined)
            return card+".png";
        }
        return undefined;
    }



    const jsx=()=>{
        if(!matchState)
            return <></>
        if(!account)
        return <></>
        if(!allPlayerStates)
        return <></>
        return (
             <>
            <div className="deck">
                <Row style={{height: 80, marginTop: 5}} >
                    <Col span={4} offset={2}>
                    {
                         matchState.player_count>0 && getCard(0) &&
                         <Image alt={""+getCard(0)} src={images(`./${""+getCard(0)}`)} width={50} preview={false} />
                         
                    }
                    </Col>
                    <Col span={7} offset={1}>
                        {IsRoundFinished({matchState}) && !IsLastRound({matchState}) &&
                            <Button className="menu-button" onClick={()=>{submitRoundFinish()}}>Next Round</Button>
                        }
                        {
                            IsLastRound({matchState})
                            && 
                            <Button className="menu-button" onClick={()=>{submitLastRound()}}>End Match</Button>
                        }
                        {
                        canDrawCards() && <Button className="menu-button" onClick={()=>{drawCards()}}>Draw Cards</Button>
                         }
                    </Col>
                    <Col span={4} offset={4}>
                    {
                    matchState.player_count>1 && getCard(1) &&
                    <Image alt={""+getCard(1)} src={images(`./${""+getCard(1)}`)} width={50} preview={false} />
                    
                    }
                    </Col>
                </Row>
                <Row style={{height: 80}} justify="end" align={"middle"}>
                    <Col span={6} offset={10}>
                    {
                      isMatchStarted() &&  
                        <Image alt={""+getCurrentDeckCard({matchState})} src={images(`./${""+getCurrentDeckCard({matchState})}.png`)} width={50} preview={false} />
                    }
                   
                    </Col>
                    <Col span={6} offset={2} >
                    <Image alt={"back"} src={images(`./back.jpg`)} width={50} preview={false} />
                    </Col>
                </Row>
                <Row style={{height: 80, marginTop: 5}} >
                    <Col span={4} offset={2}>
                    {
                         matchState.player_count>2 && getCard(2) &&
                         <Image alt={""+getCard(2)} src={images(`./${""+getCard(2)}`)} width={50} preview={false} />
                         
                    }
                    </Col>
                    <Col span={6} offset={3}>
                        
                    </Col>
                    <Col span={4} offset={4}>
                    {
                    matchState.player_count>3 && getCard(3) &&
                    <Image alt={""+getCard(3)} src={images(`./${""+getCard(3)}`)} width={50} preview={false} />
                    
                    }
                    </Col>
                </Row>
                
            </div> 
            <div  className="deck-history">
                <Row style={{height: 50}}>
                    <Col span={20} offset={2}>
                        {getPastDeckCard({matchState}).map(m=>{
                            return (
                                <Image style={{paddingLeft:2}} key={"old_deck_"+m} alt={""+m} src={images(`./${""+m}.png`)} width={50} preview={false} />
                            )
                        })    
                        }
                    </Col>
                    
                </Row>
            </div>
            </>
        )
    }
    return (
        <>
        {jsx()}
        </>
       
    )
}

export default Deck;
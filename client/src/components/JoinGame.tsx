import { Button, Col, Input, Row } from "antd";
import { useEffect, useState } from "react";
import { MenuOption, getMatchDataById, getPlayerStateData, submitJoinMatchTxn } from "../aptos/data";
import useGameData from "./useGameData";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import useLoading from "../helper/loading/useLoading";

const JoinGame = () => {
    const { aptosClient, setTempGameState, tempGameState, matchState } = useGameData();
    const [owner, setOwner] = useState<string | undefined>(tempGameState.ownerAddress);
    const [matchId, setMatchId] = useState<string | undefined>(undefined);
    const { account, signAndSubmitTransaction } = useWallet();
    const {setLoading}=useLoading();

    const joinGame = async () => {
        //Check if already joined then open join screen
        //else submit txn and join
        // console.log("owner", owner, matchId, aptosClient);
        if(!account){
            alert("Please connect wallet!");
        }
        if (owner && matchId !== undefined && aptosClient && account) {
            const matchData = matchState ?? await getMatchDataById({ aptosClient, matchId, owner })
            if (matchData) {
                //Check if already joined
                const playerData = await getPlayerStateData({ aptosClient, matchId, playerAddress: account?.address });
                if (playerData) {
                    setTempGameState(current => ({ ...current!, matchId: matchId, ownerAddress: owner, menuOption: MenuOption.Game }));
                } else {
                    //Join game
                    const response = await submitJoinMatchTxn({ aptosClient, matchId, owner, signAndSubmitTransaction,failureCallback: ()=>{setLoading(false)},
                initCallBack: ()=>{setLoading(true)} });
                    // console.log("joinGame response", response)
                    if (response && response.success && response.version) {
                        const timer = setTimeout(async () => {
                            const playerData = await getPlayerStateData({ aptosClient, matchId, playerAddress: account?.address });
                            if (playerData) {
                                setTempGameState(current => ({ ...current!, matchId: matchId, ownerAddress: owner, menuOption: MenuOption.Game }));
                                clearTimeout(timer);
                            }
                        }, 2e3)

                    }
                }

            }

            // const matchData=await getMatchDataById({aptosClient,matchId,owner})
            // if(account)
            // {
            //     const playerData=await getPlayerStateData({aptosClient,matchId,playerAddress: account?.address});
            //     setLoggedInPlayerState(playerData);
            // }
            // if(matchData){
            //     console.log(matchData);
            //     setMatchState(matchData);
            // }

        }
    }


    useEffect(() => {
        if (tempGameState.ownerAddress && tempGameState.matchId && tempGameState.menuOption === MenuOption.Join) {
            setOwner(tempGameState.ownerAddress);
            setMatchId(tempGameState.matchId);
        }
        // console.log("joingame useeffect", owner, matchId, tempGameState, owner && matchId !== undefined && tempGameState.askToJoin)
        if (owner && matchId !== undefined && tempGameState.askToJoin) {
            joinGame();
        }
    }, [tempGameState, owner, matchId, matchState?.match_id])

    return (
        <div className="game-form">
            <Row className="full-width row">
                <Col span={4} className="title">Owner: </Col>
                <Col span={20}><Input onChange={(e) => { setOwner(e.target.value) }}
                    value={owner}
                /></Col>
            </Row>
            <Row className="full-width row">
                <Col span={4}  className="title">Match Id: </Col>
                <Col span={20}><Input onChange={(e) => { setMatchId(e.target.value) }} value={matchId} /></Col>
            </Row>
            <Row className="full-width row">
                <Col span={8} offset={16}><Button className="menu-button full-width" onClick={() => { joinGame(); }}>Join Game</Button></Col>
            </Row>
        </div>
    )
}

export default JoinGame;
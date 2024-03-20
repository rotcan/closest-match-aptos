import { Col, Row } from "antd";
import Player from "./Player";
import Deck from "./Deck";
import { CARD_COUNT, MatchState, PlayerState } from "../aptos/data";
import { useEffect, useState } from "react";
import { IsMatchInProgress, IsRoundFinished, IsWinner, getAvailableCards, getMatchStatus, getMatchUrl, getPlayerPoints, getSalt } from "../utils";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import useGameData from "./useGameData";
import CountdownTimer from "../helper/CountdownTimer";
import { ClockCircleOutlined } from "@ant-design/icons";
import Copy from "../helper/Copy";
import Loading from "../helper/loading/Index";
import useLoading from "../helper/loading/useLoading";

const Game = () => {

    //Listen Events
    //Fetch Data
    const { account } = useWallet();
    const { matchState, allPlayerStates, moveEndTime,lastTxnVersion } = useGameData();
    const {setLoading}=useLoading();
    const [salt, setSalt] = useState("");

    const showGame = (): boolean => {
        // console.log("showgame tempGameState",tempGameState);
        return matchState !== undefined;
    }

    const isLoggedInPlayer = (address: string): boolean => {
        return account && address === account.address ? true : false;
    }

    const getPlayerSalt = (address: string): string => {
        if (isLoggedInPlayer(address))
            return salt;
        return "";
    }

    const getViewMode = (address: string): boolean => {
        if (isLoggedInPlayer(address))
            return false;
        return true;
    }

    useEffect(() => {
        if (account) {
            setSalt(getSalt(account.address));
        }
    }, [account]);

    useEffect(()=>{
        if(matchState){
            console.log("Game loading",false);
            setLoading(false);
        }
    },[lastTxnVersion,])

    const gameJSX = () => {
        if (!showGame()) {
            return (<div style={{ width: "100%", textAlign: "center" }}><Loading /></div>)
        }
        if (!matchState)
            return (<div style={{ width: "100%", textAlign: "center" }}>Waiting to download match state...</div>)
        return (<div className="full-width game-screen">
           
            <Row className="game-status-row padding-row">
                <Col span={8} offset={8} className="score-title">
                    {matchState &&
                        <Row>
                            <Col span={16} offset={8} className="title"> 
                                <span>Status: {getMatchStatus({ matchState })}
                                    <span style={{ paddingLeft: 20 }}>
                                        <Copy title="Copy Match Url" str={getMatchUrl({ matchId: matchState.match_id, ownerAddress: matchState.owner })} />
                                    </span>
                                    {/* <span style={{paddingLeft: 20}}>
                                        <Loading/>
                                    </span> */}
                                </span>
                            </Col>

                        </Row>}
                </Col>
                <Col span={4} offset={2}>
                    {moveEndTime && matchState && !IsRoundFinished({ matchState }) && IsMatchInProgress({ matchState }) &&
                        <Row  >
                            <Col className="title" span={2}>
                                <ClockCircleOutlined />
                            </Col>
                            <Col span={22}>
                                <CountdownTimer targetDate={moveEndTime} />
                            </Col>
                        </Row>}
                </Col>

            </Row>
            <Row className="padding-row">
                <Col span={9}>
                    {allPlayerStates.length > 0
                        && (
                            <Player address={allPlayerStates[0].player_address}
                                cards={allPlayerStates[0].player_cards.map(m => m.toString())}
                                cardCount={matchState.total_rounds}
                                salt={getPlayerSalt(allPlayerStates[0].player_address)}
                                viewOnly={getViewMode(allPlayerStates[0].player_address)}
                                playerAddress={allPlayerStates[0].player_address}
                                availableCards={getAvailableCards({
                                    playerAddress: allPlayerStates[0].player_address,
                                    playerStates: allPlayerStates
                                })}
                                winner={IsWinner({ matchState, address: allPlayerStates[0].player_address })}
                                score={getPlayerPoints({ matchState, playerAddress: allPlayerStates[0].player_address })}
                            />
                        )
                    }
                </Col>

                <Col span={9} offset={6}>
                    {allPlayerStates.length > 1
                        && (
                            <Player address={allPlayerStates[1].player_address}
                                cards={allPlayerStates[1].player_cards.map(m => m.toString())}
                                cardCount={matchState.total_rounds}
                                salt={getPlayerSalt(allPlayerStates[1].player_address)}
                                viewOnly={getViewMode(allPlayerStates[1].player_address)}
                                playerAddress={allPlayerStates[1].player_address}
                                availableCards={getAvailableCards({
                                    playerAddress: allPlayerStates[1].player_address,
                                    playerStates: allPlayerStates
                                })}
                                winner={IsWinner({ matchState, address: allPlayerStates[1].player_address })}
                                score={getPlayerPoints({ matchState, playerAddress: allPlayerStates[1].player_address })}
                            />
                        )}
                </Col>
            </Row>
            <Row className="padding-row">
                <Col span={6} offset={9}>
                    <Deck />
                </Col>

            </Row>
            <Row className="padding-row">
                <Col span={8}>
                    {allPlayerStates.length > 2
                        && (
                            <Player address={allPlayerStates[2].player_address}
                                cards={allPlayerStates[2].player_cards.map(m => m.toString())}
                                cardCount={matchState.total_rounds}
                                salt={getPlayerSalt(allPlayerStates[2].player_address)}
                                viewOnly={getViewMode(allPlayerStates[2].player_address)}
                                playerAddress={allPlayerStates[2].player_address}
                                availableCards={getAvailableCards({
                                    playerAddress: allPlayerStates[2].player_address,
                                    playerStates: allPlayerStates
                                })}
                                winner={IsWinner({ matchState, address: allPlayerStates[2].player_address })}
                                score={getPlayerPoints({ matchState, playerAddress: allPlayerStates[2].player_address })}
                            />
                        )}
                </Col>

                <Col span={8} offset={8}>
                    {allPlayerStates.length > 3
                        && (
                            <Player address={allPlayerStates[3].player_address}
                                cards={allPlayerStates[3].player_cards.map(m => m.toString())}
                                cardCount={matchState.total_rounds}
                                salt={getPlayerSalt(allPlayerStates[3].player_address)}
                                viewOnly={getViewMode(allPlayerStates[3].player_address)}
                                playerAddress={allPlayerStates[3].player_address}
                                availableCards={getAvailableCards({
                                    playerAddress: allPlayerStates[3].player_address,
                                    playerStates: allPlayerStates
                                })}
                                winner={IsWinner({ matchState, address: allPlayerStates[3].player_address })}
                                score={getPlayerPoints({ matchState, playerAddress: allPlayerStates[3].player_address })}
                            />
                        )}
                </Col>
            </Row>
        </div>)
    }

    return (
        <div style={{ width: '100%', height: '100%' }}>
            {gameJSX()}
        </div>
    )
}

export default Game;
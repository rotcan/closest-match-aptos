import { Button, Col, Input, InputNumber, Row } from "antd";
import { useState } from "react";
import { MenuOption, submitGameStartTxn } from "../aptos/data";
import useGameData from "./useGameData";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { DEFAULT_AMOUNT } from "../utils";
import useLoading from "../helper/loading/useLoading";

interface StartGameData {
    playerCount: number,
    maxTime: string,
    potSize: string,
    rounds: number,
}

const defaultGameData = () => {
    return { maxTime: "600", playerCount: 2, potSize: "" + 1,rounds:3 } as StartGameData;
}
let interval: any = undefined;
const StartGame = () => {

    const [data, setData] = useState<StartGameData>(defaultGameData());
    const { aptosClient, setTempGameState } = useGameData();
    const { account, signAndSubmitTransaction } = useWallet();
    const {setLoading}=useLoading();
    
    const submitTxn = async () => {
        if(!account){
            alert("Please connect wallet!");
        }
        if (data && aptosClient && account) {
            const response = await submitGameStartTxn({
                aptosClient: aptosClient,
                moveTime: data.maxTime,
                playerCount: "" + data.playerCount,
                potValue: (+data.potSize * DEFAULT_AMOUNT).toString(),
                rounds: ""+data.rounds,
                signAndSubmitTransaction,failureCallback: ()=>{setLoading(false)},
                initCallBack: ()=>{setLoading(true)}
            });
            // console.log("response", response);
            if (response) {
                if (interval) clearInterval(interval);

                interval = setInterval(async () => {
                    const latestMatch = await aptosClient.getLatestMatchAddressByOwner({ owner: account.address });
                    // console.log("latestMatch", latestMatch);
                    //if its the latest match clear interval
                    if (response && latestMatch) {
                        const version = response.version;
                        if (version === latestMatch.version) {
                            clearInterval(interval);
                        }
                        setTempGameState(current => ({ ...current, matchId: latestMatch.matchId, ownerAddress: account.address, menuOption: MenuOption.Game }));
                    }

                }, 5000);
            }
        }
    }

    const titleWidth=()=>{
        return 10;
    }
    return (
        <>
            <div className="game-form">
                <Row className="full-width row">
                    <Col span={titleWidth()} className="title">Player Count</Col>
                    <Col span={24-titleWidth()}  ><InputNumber max={4} min={2} defaultValue={data.playerCount} onChange={(e) => {
                        if (e)
                            setData(current => ({ ...current, playerCount: e }))
                    }} /></Col>
                </Row>
                <Row className="full-width row">
                    <Col span={titleWidth()} className="title">Max Time between Moves(sec)</Col>
                    <Col span={24-titleWidth()} ><Input defaultValue={data.maxTime} onChange={(e) => {
                        if (e)
                            setData(current => ({ ...current, maxTime: e.target.value }))
                    }} /></Col>
                </Row>
                <Row className="full-width row">
                    <Col span={titleWidth()} className="title">Rounds (3-6)</Col>
                    <Col span={24-titleWidth()} ><InputNumber  max={6} min={3}  defaultValue={data.rounds} onChange={(e) => {
                        if (e)
                            setData(current => ({ ...current, rounds: e }))
                    }} /></Col>
                </Row>
                <Row className="full-width row">
                    <Col span={titleWidth()} className="title">Pot Size</Col>
                    <Col span={24-titleWidth()} ><Input defaultValue={data.potSize} onChange={(e) => {
                        if (e)
                            setData(current => ({ ...current, potSize: e.target.value }))
                    }} /></Col>
                </Row>
                <Row className="full-width row">
                    <Col span={8} offset={16}  >
                        <Button className="menu-button full-width" onClick={() => { submitTxn() }}>Submit Txn</Button>
                    </Col>
                </Row>
            </div>
        </>
    )
}

export default StartGame;
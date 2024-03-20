import { useWallet } from "@aptos-labs/wallet-adapter-react";
import useGameData from "./useGameData";
import { StartMatchResponse } from "../aptos/sdk";
import { useEffect, useState } from "react";
import { Button, Col, Flex, Row } from "antd"; 
import { MenuOption } from "../aptos/data";
import Copy from "../helper/Copy";
import { PlayCircleOutlined } from "@ant-design/icons";
import Hash, { HashType } from "./Hash";
import { getMatchUrl } from "../utils";
import useLoading from "../helper/loading/useLoading";
import Loading from "../helper/loading/Index";

const MatchList=()=>{
    const {account}=useWallet();
    const {aptosClient,setTempGameState}=useGameData();
    const [data,setData]=useState<StartMatchResponse[]>([]);
    const {loading, setLoading}=useLoading();

    const loadData=async()=>{
        if(!account){
            alert("Please connect wallet!");
        }
        if(aptosClient && account && data.length===0){
            setLoading(true);
            const res=await aptosClient.getMatchesByOwner({owner: account.address});
            if(res){
                setData(res);
               
            }
            setLoading(false);
        }
    }

    const selectMatch=(id: string)=>{
        setLoading(true);
        setTempGameState(current=>({...current,matchId: id,menuOption: MenuOption.Game, ownerAddress: account?.address }));
    }
 

    useEffect(()=>{
        if(aptosClient && account)
            loadData();
    },[aptosClient,account])

    return (
        <Flex vertical className="game-form list-form">
            <Row  key={"header"} className="row">
                <Col span={2}  >
                    MatchId 
                </Col>
                <Col span={16}>
                    Owner 
                </Col>
                <Col span={2}>
                    Hash 
                </Col>
                <Col span={3} offset={1}>
                    Actions
                </Col>
            </Row>
            {!loading && data.length===0 && 
            <Row align={"middle"}>
                <Col span={8} offset={8}>
                    No matches found.
                </Col>
            </Row>
            }
            {/* {loading && <Row align={"middle"} style={{height: 30}}><Col span={12} offset={12}><Loading /></Col></Row>} */}
             
        {data.map(m=>{
            return (
                <Row key={m.version} className="row">
                    <Col span={2} className="title" >
                        {m.matchId}
                    </Col>
                    <Col span={16} className="title">
                    <Hash value={m.address} type={HashType.Account} title={m.address}/>
                    </Col>
                    <Col span={2} className="title">
                         <Hash value={m.version} type={HashType.Txn} title={m.version}/>
                    </Col>
                    <Col span={3} offset={1}>
                    <Button title="Goto Match" style={{width:40}} className="menu-button" onClick={()=>{selectMatch(m.matchId)}}><PlayCircleOutlined /></Button>
                    {account && <Copy title="Copy Match Url" str={getMatchUrl({matchId: m.matchId, ownerAddress: account?.address})} />}
                    </Col>
                </Row>
            )
        })}
        
        </Flex>
    )

}

export default MatchList;
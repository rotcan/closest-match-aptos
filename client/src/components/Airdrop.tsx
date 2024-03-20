import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { Button, Col, Flex, Row } from "antd";
import { useEffect, useState } from "react";
import { getCoinBalance, submitAirdropTxn } from "../aptos/data";
import useLoading from "../helper/loading/useLoading";
import { DEFAULT_AMOUNT } from "../utils";
import useGameData from "./useGameData";

export const DEFAULT_AIRDROP_AMOUNT=5;

const Airdrop = () => {
    // const [amount, setAmount] = useState<string>("" + 1)
    const { aptosClient,coinAddress,lastTxnVersion } = useGameData();
    const { account, signAndSubmitTransaction } = useWallet();
    const [balance,setBalance]=useState<number>(0);
    const {setLoading}=useLoading();
    const airdrop = async () => {
        //console.log("airdrop",aptosClient,account)
        if (aptosClient && account && coinAddress) {
            setLoading(true);
            const response = await submitAirdropTxn({
                aptosClient,
                amount: (DEFAULT_AIRDROP_AMOUNT * DEFAULT_AMOUNT).toString(), signAndSubmitTransaction, toAddress: account?.address,
                failureCallback: ()=>{setLoading(false)},
                initCallBack: ()=>{setLoading(true)},
            })
           
            //console.log(response);
            if(response){
                setLoading(false);
            }
            await updateBalance();  
        }
    }

    const updateBalance=async()=>{
        if (aptosClient && account && coinAddress) {
            const b=await getCoinBalance({address: account.address,aptosClient,coinAddress});
            setBalance(b);
        }
    }

    useEffect(()=>{
        updateBalance();
    },[aptosClient,account,coinAddress,lastTxnVersion])

    return (
        <Flex wrap="wrap" >
            <Row className="full-width row">
                {/* <Col span={6} className="full-width">
                    <Input defaultValue={amount} onChange={(e) => { if (e) setAmount(e.target.value) }} />
                </Col> */}
                <Col span={12} offset={4}>
                    <Button className="menu-button" onClick={()=>{airdrop();}}> Airdrop (5)</Button>
                </Col>
                <Col span={4} className="title">
                    <span>{(balance/+BigInt(DEFAULT_AMOUNT).toString()).toFixed(2)}</span>
                </Col>
                {/* <Col span={4} className="title">
                    <Loading/>
                </Col> */}
            </Row>
        </Flex>
    )
}

export default Airdrop;
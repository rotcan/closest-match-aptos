import { WalletSelector } from "@aptos-labs/wallet-adapter-ant-design";
import "@aptos-labs/wallet-adapter-ant-design/dist/index.css";
import { Col, Flex, Layout, Row } from "antd";
import Game from "./components/Game";
import { GameDataProvider } from "./components/useGameData";
import Screens from "./components/Screens";
import Airdrop from "./components/Airdrop";
import { getBaseUrl } from "./utils";



const Home = () => {
  //@ts-ignore
  const gameUrl = window.location.origin +window.PUBLIC_URL;
  return (
    <Layout style={{height:'100vh'}}>
      <GameDataProvider>
        <Row align="middle" className="header">
          <Col span={14} offset={2}>
            <Flex>
            <div className="logo title" ><img src={`${getBaseUrl()}/logo192.png`} /></div>
            <h1><a className="nostyle" href={gameUrl}>Closest Match</a></h1>
            </Flex>
          </Col>
          <Col span={4} >
            <Airdrop />
          </Col>
          <Col span={4} style={{ textAlign: "left" }}>
            <WalletSelector />

          </Col>
          
        </Row>

        {/* <Game  /> */}
        <Screens />
      </GameDataProvider>
    </Layout>

  );
}

export default Home;

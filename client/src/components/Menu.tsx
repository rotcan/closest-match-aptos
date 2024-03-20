import { Col, Row, Button } from "antd";
import useGameData from "./useGameData";
import { MenuOption } from "../aptos/data";

const Menu=()=>{

    const {setTempGameState}=useGameData();
    return (
        <>
        <div className="full-height full-width-m1 main-menu">
            <Row className="full-height">
                <Col span={8}  >
                    <Button className="full-height full-width shine-button" onClick={()=>{setTempGameState(current=>({...current, menuOption: MenuOption.Start}))}}>Start Game</Button>
                </Col>
                <Col span={8} >
                    <Button className="full-height full-width shine-button" onClick={()=>{setTempGameState(current=>({...current, menuOption: MenuOption.Join}))}}>Join Game</Button>
                </Col>
                <Col span={8} >
                <   Button className="full-height full-width shine-button"  onClick={()=>{setTempGameState(current=>({...current, menuOption: MenuOption.List}))}}>My Games</Button>
                </Col>
            </Row>
        </div>
        </>
    )
}

export default Menu;
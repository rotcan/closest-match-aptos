import { Col, Flex, Row } from "antd";
import HideCard from "./HideCard";
import { wrapString } from "../utils";
import Hash, { HashType } from "./Hash";
import { CrownFilled } from "@ant-design/icons";

interface Props {
    address: string,
    cards: string[],
    cardCount: number,
    salt: string,
    viewOnly: boolean,
    playerAddress: string,
    availableCards: string[],
    score: number,
    winner: boolean,
}
const Player = (props: Props) => {
    return (<>
        <Flex gap="small" wrap="wrap" vertical>
            <Row className="full-width score-title">
                <Col span={12}> 
                <div>Address: <Hash title={wrapString(props.address)} value={props.address} type={HashType.Account} />
                {props.winner && <CrownFilled className="winner-icon"/> }
                </div>
                </Col>
                <Col span={12}> <div>Score: {props.score}</div></Col>
            </Row>

            <HideCard
                cards={props.cards}
                cardCount={props.cardCount}
                salt={props.salt}
                availableCards={props.availableCards}
                viewOnly={props.viewOnly}
                playerAddress={props.playerAddress}
            />

        </Flex>
    </>)
}

export default Player;
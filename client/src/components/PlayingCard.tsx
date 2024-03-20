import { Card } from "antd";
import { Col, Row } from 'antd';
import { Image } from 'antd';
import { Dispatch, SetStateAction } from "react";
const images = require.context('../cards', true);  /* This is the key line 1 */

interface Props {
    cards: string[],
    playerAddress: string,
    availableCards: string[],
    setCardSelected: Dispatch<SetStateAction<string | undefined>>,
    selected: string | undefined,
    viewOnly: boolean, 
}
const PlayingCard = (props: Props) => {


    const isSelectable=(card: string): boolean=>{
        // console.log("card",card,props.availableCards)
        return props.availableCards.indexOf(card) > -1 ? true: false;
    }
    const selectCard=(card: string)=>{
        if(props.viewOnly)
        return;
        if(isSelectable(card)){
            if(props.selected && props.selected===card)
            {
                props.setCardSelected(undefined)
            }else{
                props.setCardSelected(card)
            }
        }
    }

    const rowArray=():number[]=>{
        return [0];
    }

    const isSelected=(card: string): boolean =>{
        return props.selected && props.selected === card ? true : false;
    }

    const colSize=()=>{
        return Math.floor(24*rowArray().length/props.cards.length)
    }
    return (
    <>
    {rowArray().map((val,index)=>{return (
        
        <Row key={props.playerAddress+"_"+val}>
            {props.cards.slice(index*props.cards.length/rowArray().length,(index+1)*props.cards.length/rowArray().length).map(m=>{return (
            <Col  span={colSize()} key={"player_"+m} >
                <Image className={isSelected(m) ? "selected playing-card " : "playing-card "} alt={m} src={images(`./${m}.png`)} 
                preview={false} 
                width={65}
                onClick={()=>{selectCard(m)}} 
                style={{opacity: isSelectable(m) ? 1 : 0.5}}/>
            </Col>)})} 
        </Row>
        
        
    )})}
    
    </>
    )
}

export default PlayingCard;
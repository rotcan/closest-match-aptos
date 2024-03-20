import { Button, Input, Select, Flex, Row, Col } from "antd";
import { useEffect, useState } from "react";
import { GetCardPoseidonHash, MakeHideCardProof, MakeRevealCardProof } from "../zk/groth";
import PlayingCard from "./PlayingCard";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { MATCH_IN_PROGRESS, MATCH_START, submitPlayCardTxn, submitRevealCardTxn } from "../aptos/data";
import useGameData from "./useGameData";
import { IsPlayCardAvailable, IsRevealCardAvailable, IsRoundFinished, getAvailableCards, getPlayedCard, storePlayedCard } from "../utils";
import useLoading from "../helper/loading/useLoading";

interface Props {
    cards: string[],
    cardCount: number,
    salt: string,
    availableCards: string[],
    viewOnly: boolean,
    playerAddress: string,
}

const HideCard = (props: Props) => {

    const [proof, setProof] = useState<string>("");
    const [salt, setSalt] = useState<string>(props.salt);
    const [cardSelected, setCardSelected] = useState<string>();
    const [cardHash, setCardHash] = useState<string>("");
    const { signAndSubmitTransaction } = useWallet();
    const { aptosClient, matchState, allPlayerStates } = useGameData();
    const {setLoading}=useLoading();

    const getProofCards = (): string[] => {
        return [...props.cards, ...Array.from(Array(10 - props.cards.length).keys()).map(_m => "0")];
    }
    const generateHideCardProof = async () => {
        if (!cardSelected) {
            alert("Please select card!");
            return;
        }
        const proof = await MakeHideCardProof({

            card_count: props.cardCount.toString(),
            cards: getProofCards(),
            current_card: cardSelected,
            salt: salt
        })
        // console.log("generateShowCardProof", cardSelected, "salt", salt, "props.salt", props.salt)
        if (aptosClient && matchState) {
            const response = await submitPlayCardTxn({
                aptosClient, matchId: matchState?.match_id, owner: matchState?.owner, secretInput: proof,
                signAndSubmitTransaction,failureCallback: ()=>{setLoading(false)},
                initCallBack: ()=>{setLoading(true)}
            });
            if (response?.success) {
                storePlayedCard({
                    address: props.playerAddress, matchState, playedCard: cardSelected,
                    round: matchState.game_state.current_round
                    //round: matchState.game_state.current_round
                });
            }
            // console.log("response", response);
        }
    }

    const generateShowCardProof = async () => {
        if (matchState) {
            const card = cardSelected ?? getPlayedCard({ address: props.playerAddress, matchState: matchState, round: matchState?.game_state.current_round })
            if (!card) {
                alert("select card to show");
                return;
            }
            // console.log("generateShowCardProof", card, "salt", salt, "props.salt", props.salt)
            const hash = await GetCardPoseidonHash({
                card_count: props.cardCount.toString(),
                cards: getProofCards(),
                current_card: card,
                salt: salt
            })
            const proof = await MakeRevealCardProof({
                card_count: props.cardCount.toString(),
                cards: getProofCards(),
                current_card: card,
                salt: salt,
                in_hash: hash
            })
            // console.log("generateShowCardProof", proof);
            if (aptosClient && matchState) {
                const response = await submitRevealCardTxn({
                    aptosClient, matchId: matchState?.match_id, owner: matchState?.owner, secretInput: proof,
                    signAndSubmitTransaction,failureCallback: ()=>{setLoading(false)},
                    initCallBack: ()=>{setLoading(true)}
                });
                // console.log("response", response);
            }
        }
    }

    const areCardsDrawn = (): boolean => {
        return matchState && matchState.match_state >= MATCH_IN_PROGRESS ? true : false;
    }

    const canPlayCards = (): boolean => {

        return matchState && matchState.match_state === MATCH_IN_PROGRESS && !IsRoundFinished({ matchState }) ? true : false;
    }


    const updateHash = async () => {
        if (cardSelected) {
            const hash = await GetCardPoseidonHash({
                card_count: props.cardCount.toString(),
                cards: getProofCards(),
                current_card: cardSelected,
                salt: salt
            })
            // console.log("hash", hash);
            setCardHash(hash);
        }
    }

    useEffect(() => {
        if (props.salt !== "") {
            setSalt(props.salt)
        }
    }, [props.salt])

    return (
        <div className="player">

            {/* <Select onChange={(e) => { setCardSelected(e) }}
                    options={props.cards.slice(0, props.cardCount).map(m => { return { value: m, label: <span>{m}</span> } })} 
                    style={{ width: 120 }} defaultValue={props.cards[0]} /> */}
            {/* <Input.Password placeholder="salt" defaultValue={salt} /> */}
            {!areCardsDrawn() && <>Waiting for draw cards txn</>}
            {areCardsDrawn() && <PlayingCard cards={props.cards.slice(0, props.cardCount)} availableCards={props.availableCards}
                setCardSelected={setCardSelected} playerAddress={props.playerAddress} selected={cardSelected} viewOnly={props.viewOnly}
            />}

            <Row style={{ paddingTop: 5, height:50 }}>
                {!props.viewOnly && canPlayCards() && <>
                    <Col span={6} offset={4}>
                        {matchState && IsPlayCardAvailable({ matchState, playerAddress: props.playerAddress })
                            &&
                            (<Button className="menu-button" onClick={() => { generateHideCardProof(); }} >Play Card</Button>)
                        }
                    </Col>
                    <Col span={6} >
                        {matchState && IsRevealCardAvailable({ matchState, playerAddress: props.playerAddress })
                            &&
                            (<Button className="menu-button" onClick={() => { generateShowCardProof(); }} >Reveal Card</Button>
                            )}                  </Col>
                </>}
            </Row>



        </div>
    )
}

export default HideCard;
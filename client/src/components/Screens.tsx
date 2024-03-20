import { useEffect } from "react";
import { MenuOption } from "../aptos/data";
import Game from "./Game";
import JoinGame from "./JoinGame";
import MatchList from "./MatchList";
import Menu from "./Menu";
import StartGame from "./StartGame";
import useGameData from "./useGameData";
import { useSearchParams } from "react-router-dom";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import Loading from "../helper/loading/Index";

const Screens=()=>{

    const {tempGameState,matchState,setTempGameState}=useGameData();
    const [queryParams,setQueryParams]=useSearchParams()
    const {account}=useWallet();

    useEffect(()=>{
        if(queryParams && queryParams.get("matchId") && queryParams.get("owner")){
          //console.log("qp", queryParams.get("gameId"));
          const owner=queryParams.get("owner")!;
          const matchId=queryParams.get("matchId")!;
          const menuOption= account && account.address === owner ? MenuOption.Game : MenuOption.Join;
          setTempGameState(current=>({...current,matchId,ownerAddress: owner, menuOption, askToJoin:true }));
        }
      },[queryParams])
      
    const jsx=()=>{
        if(tempGameState === undefined || tempGameState.menuOption===MenuOption.Home)
        return (<Menu />);

        if(tempGameState?.menuOption === MenuOption.Join ){
            return (<JoinGame />)
        }
        if(tempGameState?.menuOption === MenuOption.Game )
        return (<Game />);
        
        if(tempGameState?.menuOption === MenuOption.Start )
        return (<StartGame />);
        if(tempGameState?.menuOption === MenuOption.List )
        return (<MatchList />);
    }
    return (<div className="body">
         <Loading/>
        {jsx()}
    </div>)
}

export default Screens;
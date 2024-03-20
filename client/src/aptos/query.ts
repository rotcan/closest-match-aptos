import request, { gql } from "graphql-request"

export interface MatchStartEvent{
    data:{
        owner: string,
        match_id: string,
        match_address: string,
    },
    transaction_version: string,
}

const MatchIdQuery=gql`query MatchIdQuery {
    account_transactions(
      where: {account_address: {_eq: $match_address}}
      order_by: {transaction_version: desc}
      limit: 1
    ) {
      transaction_version
    }
  }  
`;

const MatchStartQuery=gql`query MatchStartQuery($eventName: String ) {
    events(
      limit: 10
      order_by: {transaction_version: desc}
      where: {type: {_eq: $eventName} }
    ) {
      data
      transaction_version
    }
  }
  `



export const getMatchTxnVersionsByAddress=async({address,indexerUrl}:{address: string,indexerUrl: string}):Promise<string[]>=>{
    const variables={match_address: address};
    const response: any= await request({
        url: indexerUrl,
        document: MatchIdQuery,
        variables
    })
    return response.account_transactions as string[];
}

export const getMatchStartEvents=async({indexerUrl,module,sender}:{sender: string, indexerUrl: string,module: string}):Promise<MatchStartEvent[]>=>{
    const variables={eventName: `${module}::game::MatchStartEvent` };
    const response:any= await request({
        url: indexerUrl,
        document: MatchStartQuery,
        variables
    });
    const data= response.events as MatchStartEvent[];
    return data.filter(m=>m.data.owner===sender);
}

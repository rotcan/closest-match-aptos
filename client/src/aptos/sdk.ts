//Fetch and submit txns

import { Aptos, AptosConfig, CommittedTransactionResponse, Ed25519Signature, MoveValue, Network, PendingTransactionResponse, ViewRequest } from "@aptos-labs/ts-sdk";
import { getMatchStartEvents, getMatchTxnVersionsByAddress } from "./query";
import { InputTransactionData } from "@aptos-labs/wallet-adapter-react";

export interface StartMatchResponse{
    address: string, matchId: string, version: string
}
export class AptosClient {
    private aptos: Aptos;
    private moduleAddress: string;
    private indexerUrl: string;

    constructor({ network, moduleAddress, indexerUrl }: { network: string, moduleAddress: string, indexerUrl: string, }) {
        if (!moduleAddress)
            throw Error("No module address present")
        this.indexerUrl = indexerUrl;
        this.moduleAddress = moduleAddress;
        const aptosConfig = new AptosConfig({ network: network as Network });
        this.aptos = new Aptos(aptosConfig);
    }

    private async getViewData({ funcId, args }: { funcId: string, args: any[] }): Promise<MoveValue[]> {
        const mdl = this.moduleAddress;
        const payload: ViewRequest = {
            function: mdl + "::game::" + funcId as `${string}::${string}::${string}`,
            typeArguments: [],
            functionArguments: args
        };


        const res = await this.aptos.view({ payload });
        return res;
    }

    public async getResourceData<T extends {}>({ address, resourceName }: { address: string, resourceName: string }): Promise<T | undefined> {
        const resourceType = this.moduleAddress + "::game::" + resourceName as `${string}::${string}::${string}`;
        try {
            const data = await this.aptos.getAccountResource<T>({ accountAddress: address, resourceType: resourceType })
            return data;
        } catch (e) {
        }
        return undefined;
    }

    public async getCoinAddress(): Promise<string | undefined> {
        const fnc = this.getCoinModule() + "::" + "get_coin_address";
        const payload: ViewRequest = {
            function: fnc as `${string}::${string}::${string}`,
            typeArguments: [],
            functionArguments: []
        };


        const res = await this.aptos.view({ payload });
        return res[0]?.toString();
    }

    private addressFix(val: string): string{
        if(val.startsWith("0x") && val.length!==66){
            return "0x"+val.substring(2).padStart(64,"0")
        }
        return val;
    }

    public async getCoinBalance({ coinAddress, userAddress }: { coinAddress: string, userAddress: string }): Promise<number> {
        const val = await this.aptos.getCurrentFungibleAssetBalances({
            options: {
                where: {
                    owner_address: { _eq: userAddress },
                    asset_type: { _eq: this.addressFix(coinAddress) }
                }
            }
        });
        if (val && val.length>0) {
            return val[0].amount;
        }
        return 0;
    }

    public getGameModule(): `${string}::${string}` {
        return this.moduleAddress + "::game" as `${string}::${string}`;
    }

    public getCoinModule(): `${string}::${string}` {
        return this.moduleAddress + "::mtc_coin" as `${string}::${string}`;
    }

    public async getGameAddress({ gameOwner, matchId }: { matchId: string, gameOwner: string, }): Promise<string | undefined> {
        const address = await this.getViewData({ args: [gameOwner, matchId], funcId: "get_match_state_address" });
        return address[0]?.toString();
    }

    public async getPlayerStateAddress({ playerAddress, matchId }: { matchId: string, playerAddress: string, }): Promise<string | undefined> {
        const address = await this.getViewData({ args: [playerAddress, matchId], funcId: "get_player_state_address" });
        // console.log("player state adderss",playerAddress,address);
        return address[0]?.toString();
    }


    public async getLatestMatchTxn({ matchAddress }: { matchAddress: string }): Promise<string | undefined> {
        const data = await getMatchTxnVersionsByAddress({ address: matchAddress, indexerUrl: this.indexerUrl });
        if (data.length > 0) {
            return data[0];
        }
        return undefined;
    }

    public async getLatestMatchAddressByOwner({ owner, version }: { owner: string, version?: string }): Promise<StartMatchResponse | undefined> {
        const data = await getMatchStartEvents({ indexerUrl: this.indexerUrl, module: this.moduleAddress, sender: owner });
        const ownerData = data.filter((m) => {
            if (version)
                return m.data.owner === owner && version === m.transaction_version
            return m.data.owner === owner;
        });
        if (ownerData.length > 0) {
            return {address: ownerData[0].data.match_address,version: ownerData[0].transaction_version, matchId: ownerData[0].data.match_id};
        }
        return undefined;
    }

    public async getMatchesByOwner({owner}:{owner: string}):Promise<StartMatchResponse[] | undefined>{
        const data = await getMatchStartEvents({ indexerUrl: this.indexerUrl, module: this.moduleAddress,sender: owner });
        return data.map(m=>{return {address: m.data.match_address, matchId: m.data.match_id, version: m.transaction_version}});
    }

    public async signAndSubmitTxn({ payload, signAndSubmitTransaction,initCallBack, failureCallback }:
        { signAndSubmitTransaction: (transaction: InputTransactionData) => Promise<any>, payload: InputTransactionData,
            initCallBack: ()=>void,
        failureCallback: ()=>void }): Promise<CommittedTransactionResponse | undefined> {
        try {
            if(initCallBack)
                initCallBack();
            const data = await signAndSubmitTransaction(payload) as PendingTransactionResponse;
            // console.log("data",data);
            if (data.hash) {
                const receipt = await this.aptos.waitForTransaction({ transactionHash: data.hash })
                return receipt;
            }
        } catch (e) {
            console.log("signAndSubmitTxn e",e);
            if(failureCallback)
                failureCallback();
        }
        return undefined;
    }

}
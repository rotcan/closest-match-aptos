import { bnToBytesBE, bnToBytesLE, compressPointG1Array, compressPointG2Array, toHex } from "./blsHelper";
import hideVerificationKey from "./hide_card_vk.json";
import revealVerificationKey from "./reveal_card_vk.json";
//@ts-ignore
const snarkjs = window.snarkjs;

//const baseUrl="http://localhost:3000/";
//@ts-ignore
const baseUrl=window.PUBLIC_URL ?? ".";
//const baseUrl="../../";
// const wasmFile=baseUrl+"circuits/analyze_move/analyze_move_js/analyze_move.wasm";
const hideCardWasmFile=baseUrl+"/zk/hide_card.wasm";
const hideCardzKeyFile=baseUrl+"/zk/hide_card_0001.zkey";
const revealCardWasmFile=baseUrl+"/zk/reveal_card.wasm";
const revealCardzKeyFile=baseUrl+"/zk/reveal_card_0001.zkey";

export const generateRandomKey=(length?: number):string=>{
    const crypto=window.crypto;
    const typedArray=new Uint8Array(length ?? 32);
    crypto.getRandomValues(typedArray);
    return snarkjs.utils.stringifyBigInts(typedArray);
}


// {
//     "cards": ["31","26","41","50","35","23","0","0","0","0"],
//     "card_count": "6",
//     "current_card": "41",
//     "salt": "1234"
// }

export interface HideCardInput{
    cards: string[],
    card_count: string,
    current_card: string,
    salt: string,
   
}

// {
//     "cards": ["31","26","41","50","35","23","0","0","0","0"],
//     "card_count": "6",
//     "current_card": "31",
//     "in_hash":"8562093436019683025697293716280930511899881832440662043712750561088986344710",
//     "salt": "1234"
// } 
export interface RevealCardInput{
    cards: string[],
    card_count: string,
    current_card: string,
    in_hash: string,
    salt: string,
}

interface VerificationKey{
    protocol: string,
    curve: string,
    nPublic: number,
    vk_alpha_1: string[],
    vk_beta_2: string[][],
    vk_gamma_2: string[][],
    vk_delta_2: string[][],
    vk_alphabeta_12: string[][][],
    IC: string[][],

}

 
export interface GrothProofOutput{
    proof: Uint8Array[];
    signals:Uint8Array[];
}
 

export const MakeHideCardProof=async(proofInput: HideCardInput ):Promise<GrothProofOutput>=>{
    // console.log("proofInput",proofInput)
    const {proof,publicSignals}=await hideCardGrothProof(proofInput);
    // console.log("publicSignals ",publicSignals[0]);
    return generateGrothOutput(proof,publicSignals,hideVerificationKey as VerificationKey);
}

export const GetCardPoseidonHash=async(proofInput: HideCardInput ):Promise<string>=>{
    // console.log("proofInput",proofInput)
    const { publicSignals}=await hideCardGrothProof(proofInput);
    return publicSignals[0];
}

export const MakeRevealCardProof=async(proofInput: RevealCardInput ):Promise<GrothProofOutput>=>{
    // console.log("MakeRevealCardProof proofInput",proofInput)
    const {proof,publicSignals}=await revealCardGrothProof(proofInput);
    // console.log("MakeRevealCardProof publicSignals ",publicSignals[0]);
    return generateGrothOutput(proof,publicSignals,revealVerificationKey as VerificationKey);
}
 
const generateGrothOutput=(proof: any,publicSignals: any, vk: VerificationKey): GrothProofOutput=>{
    // convertVerificationKey(vk);
    const pa=compressPointG1Array(proof.pi_a);
    const pb=compressPointG2Array(proof.pi_b);
    const pc=compressPointG1Array(proof.pi_c);

    const signals:Uint8Array[]=publicSignals.map((m:any)=>bnToBytesLE(BigInt(m),32));
     
    // console.log("pa",toHex(pa));
    // console.log("pb",toHex(pb));
    // console.log("pc",toHex(pc));
    // console.log("signals len",signals.length);
    // signals.map(m=>console.log("signals",toHex(m)));
    return {proof: [pa,pb,pc],signals};
}


 

const hideCardGrothProof = async (_proofInput: any) => {
    //await snarkjs.wtns.
    const { proof, publicSignals } = await snarkjs.groth16.fullProve( _proofInput,
     hideCardWasmFile, hideCardzKeyFile);
    return { proof, publicSignals };
};

const revealCardGrothProof = async (_proofInput: any) => {
    //await snarkjs.wtns.
    const { proof, publicSignals } = await snarkjs.groth16.fullProve( _proofInput,
        revealCardWasmFile, revealCardzKeyFile);
    return { proof, publicSignals };
};
 

const loadFromUrl=async(url: string)=>{
    const response = await fetch( url, { mode: "no-cors" });
    return response.text();
}
 

const convertVerificationKey=(key: VerificationKey)=>{
    //alpha
    const alpha=compressPointG1Array(key.vk_alpha_1);
    //beta
    const beta=compressPointG2Array(key.vk_beta_2);
    //gamma
    const gamma=compressPointG2Array(key.vk_gamma_2);
    //delta
    const delta=compressPointG2Array(key.vk_delta_2);
    //IC
    const ic=key.IC.map((m: string[])=>{return compressPointG1Array(m)});
    console.log("alpha",toHex(alpha));
    console.log("beta",toHex(beta));
    console.log("gamma",toHex(gamma));
    console.log("delta",toHex(delta));
    console.log("ic",ic.length);
    ic.map(m=>console.log("ic",toHex(m)));
}
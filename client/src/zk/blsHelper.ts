
const ffjavascript=require('ffjavascript');
const bls12=require('@noble/curves/bls12-381');

export const bnToBytesBE=(m: bigint, l : number):Uint8Array=>{
    const bytes=new Uint8Array(l);
    const bytesV=new DataView(bytes.buffer);
    let o=l;
    while (o>0){
        if( o-4>=0){
            o-=4;
            bytesV.setUint32(o,Number(m & BigInt(0xffffffff)));
            m=m >> BigInt(32);
        }else if(o-2>=0){
            o-=2;
            bytesV.setUint32(o,Number(m & BigInt(0xffff)));
            m=m >> BigInt(16);
        }else if(o-1>=0){
            o-=1;
            bytesV.setUint32(o,Number(m & BigInt(0xff)));
            m=m >> BigInt(8);
        }

    }
    return bytes;
}


export const  bnToBytesLE=(m: bigint, l : number):Uint8Array=>{
    const bytes=new Uint8Array(l);
    const bytesV=new DataView(bytes.buffer);
    let o=0;
    while (o<l){
        
        if( o + 4 <=l){
            bytesV.setUint32(o,Number(m & BigInt(0xffffffff)),true);
            o+=4;
            m=m >> BigInt(32);
        }else if(o+2<=l){
            bytesV.setUint16(o,Number(m & BigInt(0xffff)),true);
            o+=2;
            m=m >> BigInt(16);
        }else 
        if(o+1<=l){
            bytesV.setUint8(o,Number(m & BigInt(0xff)));
            o+=1;
            m=m >> BigInt(8);
        }

    }
    return bytes;
}
 

const convertBNtoBlsField=(val: string ): Uint8Array=>{
    let arr=bnToBytesBE(BigInt(val),48)
   
    return arr;
}

export const compressPointG1Array=(point: string[]): Uint8Array=>{
    return compressPointG1(point[0],point[1]);
}

export const toHex=(buffer: Uint8Array): string=> {
    return Array.prototype.map.call(buffer, x => ('00' + x.toString(16)).slice(-2)).join('');
}

export const compressPointG2Array=(point: string[][]): Uint8Array=>{
    return compressPointG2({x0: point[0][0], x1: point[0][1], y0:point[1][0], y1: point[1][1]});
}

const compressPointG1=(x: string,y: string): Uint8Array=>{
    const x_bytes=convertBNtoBlsField(x);
    const y_bytes=convertBNtoBlsField(y);
    const G1=bls12.bls12_381.G1.CURVE;
    // console.log([...x_bytes,...y_bytes].length);
    // console.log(bls12.bls12_381);
    const point=G1.fromBytes(new Uint8Array([...x_bytes,...y_bytes]));
    const P=G1.Fp.ORDER;
    const sort = Boolean((point.y * BigInt(2)) / P);
    x_bytes[0]=x_bytes[0] | 128;
    if(sort===true){
        x_bytes[0]=x_bytes[0] | 32;
    }
    return x_bytes;
}

const compressPointG2=({x0,x1,y0,y1}:{x0: string,x1: string,y0: string,y1: string}): Uint8Array=>{
    const x0_bytes=convertBNtoBlsField(x0);
    const x1_bytes=convertBNtoBlsField(x1);
    const y0_bytes=convertBNtoBlsField(y0);
    const y1_bytes=convertBNtoBlsField(y1);
    const G2=bls12.bls12_381.G2.CURVE;
    // console.log([...x_bytes,...y_bytes].length);
    // console.log(bls12.bls12_381);
    const point=G2.fromBytes(new Uint8Array([...x1_bytes,...x0_bytes,...y1_bytes,...y0_bytes,]));
    // console.log("point",point);
    // console.log(G2.toBytes(G2.Fp, point, true))
    const P= BigInt("0x1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab");
    // console.log("P",P);
    const Fp=G2.Fp;
    const Fp2=G2.Fp2;
    // const { x, y } = point.toAffine();
    const y=point.y;
    // console.log("compressPointG2",y);
    // const x = Fp2.create({ c0: Fp.create(x0_bytes), c1: Fp.create(x1_bytes) });
    const _3n=BigInt(3);
    const _2n=BigInt(2);
    const _1n=BigInt(1);
    const _0n=BigInt(0);
    // const b = bls12.bls12_381.params.G2b;
    // const right = Fp2.add(Fp2.pow(x, _3n), b); // y² = x³ + 4 * (u+1) = x³ + b
    // let y = Fp2.sqrt(right);
    // const Y_bit = y.c1 === _0n ? (y.c0 * _2n) / P : (y.c1 * _2n) / P ? _1n : _0n;
    const flag = Boolean(y.c1 === _0n ? (y.c0 * _2n) / P : (y.c1 * _2n) / P);
    // console.log(y,flag);
    const x_bytes=new Uint8Array([...x1_bytes,...x0_bytes]);
    x_bytes[0]=x_bytes[0] | 128;
    if(flag===true){
        x_bytes[0]=x_bytes[0] | 32;
    }
    return x_bytes;
}


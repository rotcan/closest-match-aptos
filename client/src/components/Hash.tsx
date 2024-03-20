export enum HashType{
    Txn,
    Account
}

const Hash=({value, type,title}:{value: string, type: HashType,title: string})=>{

    const url=(value: string): string=>{
        if(type===HashType.Txn){
            return `${process.env.REACT_APP_EXPLORER_URL}txn/${value}?network=${process.env.REACT_APP_NETWORK}`;
        }else if(type===HashType.Account){
            return `${process.env.REACT_APP_EXPLORER_URL}account/${value}?network=${process.env.REACT_APP_NETWORK}`;
        }
        return "";
    }
    return (
        <a href={url(value)} target="_blank">{title}</a>
    )
}

export default Hash;
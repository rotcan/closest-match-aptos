import { CopyOutlined } from "@ant-design/icons";
import { Button } from "antd";

 
const Copy=({str, title}:{str: string, title?: string})=>{
    
    async function copyToClip() {
        await navigator.clipboard.writeText(str);
    }

    return (
        <>
            <Button title={title} style={{width:40}} className="menu-button"  onClick={()=>{copyToClip()}}><CopyOutlined /></Button>
        </>
    )
}
export default Copy;
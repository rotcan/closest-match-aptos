import './App.css';
import './styles.scss';
import Home from './Home';
import { PetraWallet } from "petra-plugin-wallet-adapter";
import { AptosWalletAdapterProvider } from "@aptos-labs/wallet-adapter-react";
import { BrowserRouter } from 'react-router-dom';
import { LoadingProdiver } from './helper/loading/useLoading';
function App() {

  const wallets = [new PetraWallet()];
  return (
    <>
      <BrowserRouter>
        <LoadingProdiver>
          <AptosWalletAdapterProvider plugins={wallets} autoConnect={true}>
            <Home />
          </AptosWalletAdapterProvider>
        </LoadingProdiver>
      </BrowserRouter>
    </>
  );
}

export default App;

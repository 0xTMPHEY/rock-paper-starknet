import { InjectedConnector, StarknetProvider } from "@starknet-react/core";
import { Route, Routes } from "react-router-dom";
import { MainPage } from "./mainPage/MainPage";

export function App() {
    return (
        <StarknetProvider connectors={[new InjectedConnector]}>
            <Routes>
                <Route path="/" element={<MainPage />} />
            </Routes>
        </StarknetProvider>   
    )
}
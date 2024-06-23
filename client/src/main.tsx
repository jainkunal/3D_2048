import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App.tsx";
import "./index.css";
import { setup } from "./dojo/generated/setup.ts";
import { DojoProvider } from "./dojo/DojoContext.tsx";
import { dojoConfig } from "../dojoConfig.ts";
import { ApolloClient, ApolloProvider, InMemoryCache } from "@apollo/client";

async function init() {
    const rootElement = document.getElementById("root");
    if (!rootElement) throw new Error("React root not found");
    const root = ReactDOM.createRoot(rootElement as HTMLElement);

    const setupResult = await setup(dojoConfig);
    const graphQlClient = new ApolloClient({
        uri: dojoConfig.toriiUrl + "/graphql",
        cache: new InMemoryCache({ addTypename: false }),
        defaultOptions: {
            watchQuery: {
                fetchPolicy: 'no-cache',
                errorPolicy: 'ignore',
            },
            query: {
                fetchPolicy: 'no-cache',
                errorPolicy: 'all',
            },
        }
    })

    root.render(
        <React.StrictMode>
            <DojoProvider value={setupResult}>
                <ApolloProvider client={graphQlClient}>
                    <App />
                </ApolloProvider>
            </DojoProvider>
        </React.StrictMode>
    );
}

init();
